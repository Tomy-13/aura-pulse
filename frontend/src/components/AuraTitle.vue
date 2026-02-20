<template>
  <div class="brand-wrapper">
    <h1 class="main-logo">
      AURA<span class="accent-text">PULSE</span>
    </h1>
    <div class="decorator-box">
      <span class="tech-id">V 2.0.48</span>
      <p class="tagline">SISTEMA DE INTELIGENCIA SÍSMICA GLOBAL</p>
    </div>
  </div>
</template>

<style scoped>
/* Importamos la nueva fuente directamente desde Google Fonts */
@import url('https://fonts.googleapis.com/css2?family=Audiowide&display=swap');

.brand-wrapper {
  position: absolute;
  top: 40px;
  left: 40px;
  z-index: 110;
  pointer-events: none;
}

.main-logo {
  /* Aplicamos la nueva fuente y ajustamos su espaciado */
  font-family: 'Audiowide', sans-serif;
  font-size: 3.2rem;
  letter-spacing: 2px; 
  margin: 0;
  background: linear-gradient(to bottom, #ffffff 30%, #a855f7 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  filter: drop-shadow(0 0 10px rgba(168, 85, 247, 0.5));
}

.accent-text {
  color: #ec4899;
  -webkit-text-fill-color: #ec4899;
  text-shadow: 0 0 15px rgba(236, 72, 153, 0.8);
  /* Eliminamos la animación de latido para un look estático e innovador */
}

.decorator-box {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-top: -2px;
}

.tech-id {
  font-size: 0.6rem;
  background: rgba(168, 85, 247, 0.2);
  color: #a855f7;
  padding: 2px 6px;
  border: 1px solid rgba(168, 85, 247, 0.4);
  font-family: monospace;
}

.tagline {
  font-size: 0.7rem;
  letter-spacing: 4px;
  color: #9ca3af;
  margin: 0;
  text-transform: uppercase;
  font-weight: 300;
}
</style>