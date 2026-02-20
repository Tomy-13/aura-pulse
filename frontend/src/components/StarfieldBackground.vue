<script setup>
/**
 * AURA PULSE - Starfield HD Engine
 * Optimización: Soporte para pantallas Retina/High-DPI y auto-resize.
 */
import { onMounted, onBeforeUnmount, ref } from 'vue';

const canvasRef = ref(null);
let ctx = null;
let stars = [];
let animationId = null;

const createStars = (w, h) => {
  // Ajustamos a 3000 estrellas. Al verse ultra nítidas, no necesitas 6000.
  // Esto libera un 50% de carga de CPU para que el globo 3D gire aún mejor.
  stars = Array.from({ length: 3000 }, () => ({
    x: Math.random() * w,
    y: Math.random() * h,
    size: Math.random() * 1.5,
    opacity: Math.random(),
    speed: Math.random() * 0.02 + 0.005,
    growing: Math.random() > 0.5
  }));
};

const draw = () => {
  if (!ctx || !canvasRef.value) return;
  
  // Limpiamos usando el tamaño lógico de la ventana
  ctx.clearRect(0, 0, window.innerWidth, window.innerHeight);
  
  stars.forEach(s => {
    ctx.beginPath();
    ctx.arc(s.x, s.y, s.size, 0, Math.PI * 2);
    ctx.fillStyle = `rgba(216, 180, 254, ${s.opacity})`; // Violeta claro
    ctx.fill();

    // Lógica de parpadeo (Blink)
    if (s.growing) {
      s.opacity += s.speed;
      if (s.opacity >= 1) {
        s.growing = false;
        s.opacity = 1;
      }
    } else {
      s.opacity -= s.speed;
      if (s.opacity <= 0.1) {
        s.growing = true;
        s.opacity = 0.1;
      }
    }
  });
  
  animationId = requestAnimationFrame(draw);
};

// 🚀 EL FIX HD: Escalador de resolución nativa
const resizeCanvas = () => {
  if (!canvasRef.value) return;
  
  const canvas = canvasRef.value;
  const dpr = window.devicePixelRatio || 1; // Detecta si es pantalla normal o Retina/4K
  
  const logicalWidth = window.innerWidth;
  const logicalHeight = window.innerHeight;
  
  // Multiplicamos los píxeles internos por el DPR del monitor
  canvas.width = logicalWidth * dpr;
  canvas.height = logicalHeight * dpr;
  
  // Reseteamos el contexto y aplicamos la escala para que las coordenadas coincidan
  ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);
  
  createStars(logicalWidth, logicalHeight);
};

onMounted(() => {
  resizeCanvas(); // Inicializamos con la resolución correcta
  window.addEventListener('resize', resizeCanvas); // Escuchamos cambios de pantalla
  draw();
});

onBeforeUnmount(() => {
  cancelAnimationFrame(animationId);
  window.removeEventListener('resize', resizeCanvas);
});
</script>

<template>
  <canvas ref="canvasRef" class="stars-canvas"></canvas>
</template>

<style scoped>
.stars-canvas {
  position: absolute;
  top: 0; 
  left: 0;
  width: 100%; 
  height: 100%;
  z-index: -1;
  background: radial-gradient(circle at center, #1a0f30 0%, #090514 100%);
  /* Aseguramos que el canvas no bloquee los clics en el resto de la app */
  pointer-events: none; 
}
</style>