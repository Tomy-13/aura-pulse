<script setup>
/**
 * AURA PULSE - Interactive Control Panel
 */
import { computed } from 'vue';

const props = defineProps({
  earthquakes: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false }
});

// Usamos defineModel (Vue 3.4+) para sincronizar los filtros con App.vue
const search = defineModel('search', { type: String, default: '' });
const minMag = defineModel('minMag', { type: Number, default: 4.5 });

const recentEarthquakes = computed(() => {
  if (!props.earthquakes || props.earthquakes.length === 0) return [];
  return [...props.earthquakes]
    .sort((a, b) => new Date(b.occurred_at) - new Date(a.occurred_at))
    .slice(0, 8); 
});

const formatTime = (dateString) => {
  return new Date(dateString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
};
</script>

<template>
  <div class="ui-wrapper">
    <section class="panel-card">
      <header class="panel-header">
        <div class="status-group">
          <div class="status-dot" :class="{ 'is-syncing': loading }"></div>
          <h2 class="panel-title">Radar de Sismos</h2>
        </div>
        <div class="count-badge" v-if="!loading">
          {{ earthquakes.length }} Resultados
        </div>
      </header>

      <div class="filters-section">
        <input 
          type="text" 
          v-model="search" 
          placeholder="Buscar país o región..." 
          class="tech-input"
        />
        
        <div class="mag-selector">
          <label>Magnitud Min:</label>
          <select v-model="minMag" class="tech-select">
            <option :value="4.5">M 4.5+</option>
            <option :value="5.0">M 5.0+</option>
            <option :value="6.0">M 6.0+</option>
            <option :value="7.0">M 7.0+ (Peligro)</option>
          </select>
        </div>
      </div>

      <div class="divider"></div>

      <div v-if="loading" class="sync-message">
        Sincronizando satélites...
      </div>
      
      <div class="earthquake-list" v-else-if="recentEarthquakes.length > 0">
        <div v-for="quake in recentEarthquakes" :key="quake.id" class="earthquake-item">
          <div class="quake-mag">M {{ quake.magnitude }}</div>
          <div class="quake-details">
            <div class="quake-place">{{ quake.place }}</div>
            <div class="quake-time">{{ formatTime(quake.occurred_at) }}</div>
          </div>
        </div>
      </div>
      
      <div v-else class="empty-state">
        No se encontraron sismos con esos filtros.
      </div>
    </section>
  </div>
</template>

<style scoped>
.ui-wrapper {
  position: absolute;

  /* Bajamos el panel a 180px para dar espacio al título */
  top: 200px; 
  left: 40px;
  z-index: 100;
  pointer-events: none; 
}

.panel-card {
  background: rgba(15, 10, 25, 0.75);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(168, 85, 247, 0.2);
  border-radius: 12px;
  width: 340px; 
  padding: 20px;
  pointer-events: auto;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
}

.panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;}
.status-group { display: flex; align-items: center; gap: 10px; }
.panel-title { font-size: 0.9rem; font-weight: 600; color: white; margin: 0; text-transform: uppercase; letter-spacing: 1px; }
.status-dot { width: 8px; height: 8px; background-color: #EC4899; border-radius: 50%; box-shadow: 0 0 10px #EC4899; }
.status-dot.is-syncing { background-color: #f59e0b; box-shadow: 0 0 10px #f59e0b; animation: blink 1s infinite alternate; }
.count-badge { font-size: 0.7rem; background: rgba(168, 85, 247, 0.2); color: #D8B4FE; padding: 4px 8px; border-radius: 12px; border: 1px solid rgba(168, 85, 247, 0.4); }

/* ESTILOS DE LOS FILTROS */
.filters-section { display: flex; flex-direction: column; gap: 10px; }
.tech-input, .tech-select {
  background: rgba(0, 0, 0, 0.4);
  border: 1px solid rgba(168, 85, 247, 0.4);
  color: white;
  padding: 10px 12px;
  border-radius: 6px;
  font-family: 'Inter', sans-serif;
  font-size: 0.85rem;
  outline: none;
  transition: border-color 0.3s;
  width: 100%;
  box-sizing: border-box;
}
.tech-input:focus, .tech-select:focus { border-color: #EC4899; box-shadow: 0 0 8px rgba(236, 72, 153, 0.3); }
.tech-input::placeholder { color: #6B7280; }

.mag-selector {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.8rem;
  color: #9CA3AF;
}
.mag-selector select { width: 60%; }

.divider { height: 1px; background: linear-gradient(to right, rgba(174, 101, 243, 0.5), transparent); margin: 15px 0; }

.earthquake-list { display: flex; flex-direction: column; gap: 12px; max-height: 350px; overflow-y: auto; padding-right: 5px; }
.earthquake-list::-webkit-scrollbar { width: 4px; }
.earthquake-list::-webkit-scrollbar-track { background: rgba(255, 255, 255, 0.05); }
.earthquake-list::-webkit-scrollbar-thumb { background: var(--tech-accent-purple); border-radius: 4px; }

.earthquake-item { display: flex; align-items: flex-start; gap: 12px; padding: 10px; border-radius: 8px; background: rgba(255, 255, 255, 0.02); transition: all 0.2s ease; cursor: pointer; }
.earthquake-item:hover { background: rgba(168, 85, 247, 0.1); transform: translateX(4px); border-left: 2px solid var(--tech-accent-pink); }

.quake-mag { color: hwb(17 0% 0%); font-weight: 900; font-size: 1.1rem; min-width: 45px; text-shadow: 0 0 10px rgba(255, 0, 0, 0.4); }
.quake-details { display: flex; flex-direction: column; gap: 4px; }
.quake-place { font-size: 0.8rem; color: #E5E7EB; line-height: 1.2; }
.quake-time { font-size: 0.7rem; color: #9CA3AF; }

.sync-message, .empty-state { font-size: 0.8rem; color: hsl(271, 100%, 64%); font-style: italic; text-align: center; margin-top: 10px; }
@keyframes blink { from { opacity: 1; } to { opacity: 0.3; } }
</style>