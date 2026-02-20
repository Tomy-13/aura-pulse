<template>
  <footer class="tech-footer">
    <div class="footer-backdrop"></div>
    <div class="footer-content">
      
      <div class="brand-section">
        <div class="status-indicator"></div>
        <span class="brand-name">AURA PULSE</span>
        <span class="version-tag"></span>
      </div>

      <div class="copyright-section">
        <span class="copyright-symbol">©</span>
        <span class="copyright-year">2026</span>
        <span class="copyright-brand">AURA PULSE INTERSTELLAR</span>
        <span class="divider">•</span>
        <span class="rights-text">TODOS LOS DERECHOS RESERVADOS</span>
      </div>

      <div class="tech-meta">
        <div class="stack-info">
          VUE 3 <span class="sub-sep">+</span> RAILS <span class="sub-sep">+</span> THREE.JS
        </div>
        <div class="vertical-divider"></div>
        <div class="data-feed">
          <span class="feed-label">FEED:</span>
          <span class="feed-value">USGS.GOV</span>
        </div>
      </div>
      
    </div>
  </footer>
</template>

<style scoped>
.tech-footer {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 40px;
  z-index: 1000;
  pointer-events: none;
}

/* Efecto Glassmorphism Avanzado */
.footer-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(to top, rgba(15, 10, 25, 0.95), rgba(15, 10, 25, 0.4));
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-top: 1px solid rgba(168, 85, 247, 0.25);
  box-shadow: 0 -5px 20px rgba(0, 0, 0, 0.5);
}

.footer-content {
  position: relative;
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  padding: 0 40px;
  font-family: 'Inter', sans-serif;
  font-size: 0.62rem;
  color: #9CA3AF;
  letter-spacing: 1.2px;
}

/* --- IZQUIERDA: BRANDING --- */
.brand-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.status-indicator {
  width: 6px;
  height: 6px;
  background-color: #EC4899;
  border-radius: 50%;
  box-shadow: 0 0 12px #EC4899;
  animation: pulse-glow 2s infinite ease-in-out;
}

.brand-name {
  color: #FFFFFF;
  font-weight: 800;
  text-shadow: 0 0 8px rgba(255, 255, 255, 0.3);
}

.version-tag {
  font-family: monospace;
  color: #A855F7;
  opacity: 0.8;
}

/* --- CENTRO: COPYRIGHT --- */
.copyright-section {
  display: flex;
  align-items: center;
  gap: 6px;
  text-transform: uppercase;
  font-weight: 500;
}

.copyright-symbol {
  color: #A855F7;
  font-size: 0.8rem;
  font-weight: bold;
}

.copyright-brand {
  color: #E5E7EB;
  font-weight: 600;
}

.divider {
  color: #EC4899;
  margin: 0 4px;
}

.rights-text {
  font-size: 0.58rem;
  opacity: 0.6;
}

/* --- DERECHA: TECH META --- */
.tech-meta {
  display: flex;
  align-items: center;
  gap: 15px;
}

.stack-info {
  font-family: monospace;
  color: #D8B4FE;
}

.sub-sep {
  color: #6B7280;
  font-weight: normal;
}

.vertical-divider {
  width: 1px;
  height: 12px;
  background: rgba(168, 85, 247, 0.3);
}

.data-feed {
  display: flex;
  gap: 6px;
}

.feed-label {
  opacity: 0.5;
}

.feed-value {
  color: #EC4899;
  font-weight: 800;
}

/* Animación de pulso */
@keyframes pulse-glow {
  0%, 100% { transform: scale(1); opacity: 1; box-shadow: 0 0 12px #EC4899; }
  50% { transform: scale(1.4); opacity: 0.5; box-shadow: 0 0 20px #EC4899; }
}
</style>