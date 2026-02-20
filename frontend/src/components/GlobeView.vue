<script setup>
/**
 * AURA PULSE - Core Visual Engine
 * Logic: Automated 3D rotation, GeoJSON Country Layers, and Seismic Mapping.
 */
import { onMounted, ref, watch, shallowRef, onBeforeUnmount } from 'vue';
import Globe from 'globe.gl';
import { fetchWorldMaps } from '../services/mapService';
import * as THREE from 'three';
THREE.ColorManagement.enabled = true;

// Props recibidos desde App.vue (Datos reactivos)
const props = defineProps({
  data: {
    type: Array,
    default: () => []
  }
});

const globeContainer = ref(null);
const globeInstance = shallowRef(null);
const countries = ref([]);

/**
 * Inicializa el globo con rotación automática y bloqueo de dragging
 */
const initGlobe = () => {
  if (!globeContainer.value) return;

  const world = Globe()(globeContainer.value)
    .backgroundColor('rgba(0,0,0,0)')
    .globeImageUrl('//unpkg.com/three-globe/example/img/earth-blue-marble.jpg')
    .bumpImageUrl('//unpkg.com/three-globe/example/img/earth-topology.png')
    .showAtmosphere(true)
    .atmosphereColor('#D8B4FE')
    .atmosphereAltitude(0.15);

  // --- CONFIGURACIÓN DE CONTROLES (Modo Monitor) ---
  const controls = world.controls();
  controls.autoRotate = true;
  controls.autoRotateSpeed = 0.7; // 360 grados / 30 segundos
  
  // Bloqueo total de interacción manual
  controls.enableRotate = false;
  controls.enableZoom = false;
  controls.enablePan = false;

  // --- CAPA DE PAÍSES (Nombres al pasar el mouse) ---
  world
    .polygonCapColor(() => 'rgba(168, 85, 247, 0.02)')
    .polygonSideColor(() => 'rgba(168, 85, 247, 0.1)')
    .polygonStrokeColor(() => 'rgba(255, 255, 255, 0.1)')
    .polygonLabel(({ properties: d }) => `
      <div class="country-tooltip">
        📍 <b>${d.NAME || d.name || 'Territorio'}</b>
      </div>
    `)
    .onPolygonHover(hoverD => world
      .polygonCapColor(d => d === hoverD ? 'rgba(168, 85, 247, 0.3)' : 'rgba(168, 85, 247, 0.02)')
    );

  globeInstance.value = world;
  
  if (props.data.length > 0) renderPoints();
};

/**
 * Mapea los sismos como puntos rojos sobre la superficie.
 * Se ejecuta automáticamente gracias al watch cuando llegan datos nuevos.
 */
const renderPoints = () => {
  if (!globeInstance.value) return;

  globeInstance.value
    .pointsData(props.data)
    .pointLat(d => d.coordinates[1])
    .pointLng(d => d.coordinates[0])
    .pointColor(() => '#FF0000') // Rojo Alarma
    .pointAltitude(0.01)       // Pegados a la corteza
    .pointRadius(0.8)
    .pointLabel(d => `
      <div class="globe-tooltip red-variant">
        <div class="mag-tag">MAGNITUD ${d.magnitude}</div>
        <div class="place-text">${d.place}</div>
        <div class="date-text">${new Date(d.occurred_at).toLocaleString()}</div>
      </div>
    `);
    
  // Un log silencioso para confirmar que la actualización automática funciona
  console.log(`[Aura Pulse Engine] Planeta sincronizado: ${props.data.length} sismos activos.`);
};

// 1. Inyectar países cuando el servicio responda
watch(countries, (newCountries) => {
  if (globeInstance.value && newCountries.length > 0) {
    globeInstance.value.polygonsData(newCountries);
  }
});

// 2. EL MOTOR DE REACTIVIDAD: Inyectar sismos cuando el Polling traiga nuevos datos de Rails
watch(() => props.data, () => {
  renderPoints();
}, { deep: true });

onMounted(async () => {
  initGlobe();
  
  // Carga asíncrona de mapas para no congelar la UI
  countries.value = await fetchWorldMaps();
  
  // Solución a la barra gris: Usar el clientWidth/Height del contenedor exacto
  window.addEventListener('resize', () => {
    if (globeInstance.value && globeContainer.value) {
      globeInstance.value.width(globeContainer.value.clientWidth);
      globeInstance.value.height(globeContainer.value.clientHeight);
    }
  });
});

onBeforeUnmount(() => {
  // Limpieza de memoria al destruir el componente
  if (globeInstance.value) globeInstance.value._destructor?.();
});
</script>

<template>
  <div class="globe-wrapper">
    <div ref="globeContainer" class="globe-viewport"></div>
  </div>
</template>

<style scoped>
/* Contenedor principal para bloquear el scrollbar */
.globe-wrapper {
  width: 100vw;
  height: 100vh;
  overflow: hidden; /* Esto mata la barra gris de forma definitiva */
  position: absolute;
  top: 0;
  left: 0;
  z-index: 1; /* Mantiene el globo al fondo */
}

.globe-viewport {
  width: 100%;
  height: 100%;
  cursor: default; /* Ya no hay mano de agarre porque está bloqueado */
}

/* Tooltip para Países (📍 Nombre) */
:deep(.country-tooltip) {
  background: rgba(10, 10, 25, 0.9);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  border: 1px solid #A855F7;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  backdrop-filter: blur(8px);
  box-shadow: 0 0 15px rgba(168, 85, 247, 0.4);
}

/* Tooltips para Sismos (Rojo) */
:deep(.globe-tooltip) {
  background: rgba(15, 10, 30, 0.95);
  border: 1px solid #FF0000;
  padding: 12px;
  border-radius: 8px;
  font-family: 'Inter', sans-serif;
  color: white;
  box-shadow: 0 0 20px rgba(255, 0, 0, 0.3);
}

:deep(.mag-tag) {
  color: #FF0000;
  font-weight: 900;
  font-size: 1.1rem;
  margin-bottom: 4px;
}

:deep(.place-text) {
  font-size: 0.9rem;
  font-weight: 500;
}

:deep(.date-text) {
  font-size: 0.75rem;
  opacity: 0.6;
}
</style>