class Api::V1::EarthquakesController < ApplicationController
  # Acción original para tu panel de la App (se mantiene igual)
  def index
    earthquakes = Earthquake.order(occurred_at: :desc).limit(200)
    render json: earthquakes
  end

  # NUEVA ACCIÓN: Para que la IA busque sismos específicos
  def search
    # Extraemos parámetros de la búsqueda (ej: ?country=Chile&mag=5)
    country = params[:country]
    min_mag = params[:mag].to_f > 0 ? params[:mag].to_f : 4.5

    # Iniciamos la consulta filtrando por magnitud mínima
    @earthquakes = Earthquake.where("magnitude >= ?", min_mag)
    
    # Si el bot envía un país, filtramos por la columna 'place'
    if country.present?
      # Usamos ILIKE para que no importe si escribe "chile" o "CHILE"
      @earthquakes = @earthquakes.where("place ILIKE ?", "%#{country}%")
    end

    # Retornamos solo los 5 más recientes para que la respuesta del bot sea rápida
    render json: @earthquakes.order(occurred_at: :desc).limit(5)
  end
end