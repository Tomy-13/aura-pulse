require 'net/http'
require 'json'

class UsgsSyncService
  # Usamos freeze para evitar que la constante se modifique accidentalmente en memoria
  API_URL = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_month.geojson'.freeze

  # Patrón de diseño estándar: El método de clase instancia la clase y ejecuta el proceso
  def self.call
    new.call
  end

  def call
    Rails.logger.info("📡 [UsgsSyncService] Iniciando conexión con el satélite de la USGS...")

    response = fetch_data
    return unless response # Si la red falla, abortamos con gracia sin crashear el sistema

    data = parse_json(response)
    return unless data && data['features'].present? # Si el JSON viene vacío o roto, abortamos

    process_earthquakes(data['features'])
  rescue StandardError => e
    # Capturador global de errores inesperados (Evita que el servidor muera)
    Rails.logger.error("🚨 [UsgsSyncService] Error crítico del sistema: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
  end

  private

  def fetch_data
    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    # ⏱️ TIMEOUTS: Vital para que tu servidor no se quede congelado si la USGS no responde
    http.open_timeout = 10 # Segundos máximos para conectar
    http.read_timeout = 10 # Segundos máximos para recibir los datos

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("🔴 [UsgsSyncService] USGS API respondió con error HTTP: #{response.code}")
      return nil
    end

    response.body
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error("⏳ [UsgsSyncService] Tiempo de espera agotado (Timeout): #{e.message}")
    nil
  rescue SocketError => e
    Rails.logger.error("🔌 [UsgsSyncService] Problema de red o DNS (SocketError): #{e.message}")
    nil
  end

  def parse_json(body)
    JSON.parse(body)
  rescue JSON::ParserError => e
    Rails.logger.error("🧩 [UsgsSyncService] El archivo de la USGS no es un JSON válido: #{e.message}")
    nil
  end

  def process_earthquakes(features)
    nuevos = 0
    actualizados = 0

    # 🗄️ TRANSACTION: Abre la base de datos una sola vez para procesar todos los sismos. 
    # Si algo falla a la mitad, no guarda datos corruptos. Aumenta la velocidad x10.
    ActiveRecord::Base.transaction do
      features.each do |feature|
        props = feature['properties']
        geom = feature['geometry']

        # Validación de seguridad defensiva por si un sismo viene sin coordenadas
        next unless props.present? && geom.present? && geom['coordinates'].is_a?(Array)

        earthquake = Earthquake.find_or_initialize_by(external_id: feature['id'])
        es_nuevo = earthquake.new_record?
        
        earthquake.assign_attributes(
          magnitude: props['mag'],
          place: props['place'],
          occurred_at: Time.at(props['time'] / 1000.0),
          coordinates: geom['coordinates'],
          continent: 'Global' # TODO: Filtrado geográfico
        )

        if earthquake.save
          es_nuevo ? nuevos += 1 : actualizados += 1
        else
          # Si un sismo no se puede guardar, logueamos el error exacto pero no detenemos el bucle
          Rails.logger.warn("⚠️ [UsgsSyncService] Sismo omitido (#{feature['id']}): #{earthquake.errors.full_messages.to_sentence}")
        end
      end
    end

    Rails.logger.info("✅ [UsgsSyncService] Sincronización completa: #{nuevos} nuevos, #{actualizados} actualizados.")
  end
end