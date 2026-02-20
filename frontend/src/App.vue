<script setup>
/**
 * AURA PULSE - Orquestador Principal
 * Versión: Integración Total (Título, Filtros, Globo y Footer)
 * Optimización: shallowRef para gestión masiva de datos sísmicos + Sincronización Automática.
 */
import { onMounted, onBeforeUnmount, ref, computed, shallowRef } from 'vue';
import axios from 'axios';

// Importación de la arquitectura modular
import StarfieldBackground from './components/StarfieldBackground.vue';
import GlobeView from './components/GlobeView.vue';
import ControlPanel from './components/ControlPanel.vue';
import AuraTitle from './components/AuraTitle.vue';
import AuraFooter from './components/AuraFooter.vue';

// --- GESTIÓN DE ESTADO ---
// Usamos shallowRef para evitar que Vue analice cada propiedad interna de los sismos
const earthquakeData = shallowRef([]); 
const isLoading = ref(true);
let syncTimer = null; // Variable para almacenar nuestro reloj de sincronización

// Filtros reactivos sincronizados con el ControlPanel
const searchQuery = ref('');
const minMagnitude = ref(4.5);

/**
 * Motor de filtrado inteligente
 * Procesa la data de USGS en tiempo real según la búsqueda del usuario.
 */
const filteredEarthquakes = computed(() => {
  if (!earthquakeData.value) return [];
  
  return earthquakeData.value.filter(quake => {
    // Filtro por texto (Lugar/País)
    const matchText = quake.place.toLowerCase().includes(searchQuery.value.toLowerCase());
    // Filtro por intensidad
    const matchMag = quake.magnitude >= minMagnitude.value;
    
    return matchText && matchMag;
  });
});

/**
 * Sincronización con el Backend (Rails API)
 * @param {boolean} isBackgroundSync - Evita mostrar la pantalla de carga en actualizaciones automáticas
 */
const fetchEarthquakes = async (isBackgroundSync = false) => {
  try {
    // Solo mostramos el "Cargando..." si es la primera vez que entra el usuario
    if (!isBackgroundSync) isLoading.value = true;
    
    // Le preguntamos a NUESTRO backend (Rails), no a la USGS directo
    const response = await axios.get('http://localhost:3001/api/v1/earthquakes');
    earthquakeData.value = response.data;
    
    if (isBackgroundSync) {
      console.log(`[Aura Pulse] Auto-sincronización completada: ${earthquakeData.value.length} sismos globales.`);
    }
  } catch (error) {
    console.error('🚨 Fallo de conexión con Aura Pulse API:', error);
  } finally {
    if (!isBackgroundSync) isLoading.value = false;
  }
};

// --- CICLO DE VIDA DEL MOTOR ---
onMounted(() => {
  // 1. Ejecutar la carga inicial con interfaz de carga
  fetchEarthquakes();

  // 2. Encender el Reloj de Sincronización (cada 3 minutos = 180,000 ms)
  syncTimer = setInterval(() => {
    fetchEarthquakes(true); // true = Sincronización silenciosa en segundo plano
  }, 180000);
});

onBeforeUnmount(() => {
  // 3. Apagar el motor si el componente se destruye para liberar memoria
  if (syncTimer) clearInterval(syncTimer);
});
</script>

<template>
  <div class="app-layout">
    <StarfieldBackground />
    
    <AuraTitle />
    
    <ControlPanel 
      :earthquakes="filteredEarthquakes" 
      :loading="isLoading" 
      v-model:search="searchQuery"
      v-model:minMag="minMagnitude"
    />

    <div class="globe-layout-engine">
      <div class="globe-scaling-box">
        <GlobeView :data="filteredEarthquakes" />
      </div>
    </div>

    <AuraFooter />
  </div>
</template>

<style>
/* --- ESTILOS GLOBALES DE AURA PULSE --- */
:root {
  --tech-accent-purple: #A855F7;
  --tech-accent-pink: #EC4899;
  --tech-text-primary: #FFFFFF;
  --tech-text-secondary: #9CA3AF;
}

/* 🚀 FIX DEFINITIVO: Aniquilador de estilos por defecto de Vite */
#app {
  max-width: 100% !important; /* Rompe el límite de 1280px */
  margin: 0 !important;       /* Elimina el centrado forzado */
  padding: 0 !important;      /* Elimina los bordes grises */
  width: 100vw;
  height: 100vh;
}

/* Reset del navegador, manteniendo la transparencia para las estrellas */
html, body { 
  margin: 0; 
  padding: 0; 
  width: 100%; 
  height: 100%; 
  overflow: hidden; 
  background-color: transparent; 
}

/* Candado absoluto para que la app no se mueva de la esquina superior izquierda */
.app-layout { 
  position: absolute; 
  top: 0;
  left: 0;
  width: 100vw; 
  height: 100vh; 
  background-color: transparent; 
  overflow: hidden; 
}

/**
 * MOTOR DE POSICIONAMIENTO DEL GLOBO:
 * Centrado absoluto para que el planeta domine la escena.
 */
.globe-layout-engine { 
  position: absolute; 
  top: 0; 
  left: 0; 
  width: 100%; 
  height: 100%; 
  display: flex; 
  justify-content: center; 
  align-items: center; 
  pointer-events: none; 
  z-index: 1; 
}

.globe-scaling-box { 
  width: 100%; 
  height: 100%; 
  display: flex; 
  justify-content: center; 
  align-items: center; 
  pointer-events: auto; 
}
</style>