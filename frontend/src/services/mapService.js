// frontend/src/services/mapService.js
export const fetchWorldMaps = async () => {
  try {
    // Usamos un CDN confiable para el GeoJSON de países
    const response = await fetch('https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_admin_0_countries.geojson');
    const data = await response.json();
    return data.features;
  } catch (error) {
    console.error("🚨 Error cargando el mapa mundial:", error);
    return [];
  }
};