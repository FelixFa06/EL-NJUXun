<template>
  <div ref="mapWrapper" class="map-wrapper" :style="{ width: width + 'px', height: height + 'px' }">
    <div class="image-container" ref="imageContainer">
      <img
          :src="mapImage"
          class="map-image"
          @click="handleClick"
          draggable="false"
      />
    </div>
    <svg class="marker-layer" :viewBox="'0 0 ' + mapWidth + ' ' + mapHeight">
      <line
          v-if="polyline.length === 2"
          :x1="polyline[0].x" :y1="polyline[0].y"
          :x2="polyline[1].x" :y2="polyline[1].y"
          stroke="#FF33FF" stroke-width="3" stroke-dasharray="8,4"
      />
      <circle
          v-for="(m, i) in markers" :key="i"
          :cx="m.x" :cy="m.y" r="8"
          :fill="m.type === 'real' ? '#FF4444' : '#4488FF'"
          stroke="white" stroke-width="2"
      />
    </svg>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
  mapImage: { type: String, default: '/gulou_map.png' },
  mapWidth: { type: Number, default: 2546 },
  mapHeight: { type: Number, default: 3914 },
  width: { type: Number, default: 600 },
  height: { type: Number, default: 450 },
  markers: { type: Array, default: () => [] },
  polyline: { type: Array, default: () => [] },
  clickable: { type: Boolean, default: true }
})

const emit = defineEmits(['mapClick'])
const mapWrapper = ref(null)
const imageContainer = ref(null)

function handleClick(e) {
  if (!props.clickable) return
  const rect = imageContainer.value.getBoundingClientRect()
  const scaleX = props.mapWidth / rect.width
  const scaleY = props.mapHeight / rect.height
  const x = Math.round((e.clientX - rect.left) * scaleX)
  const y = Math.round((e.clientY - rect.top) * scaleY)
  emit('mapClick', { x, y })
}
</script>

<style scoped>
.map-wrapper {
  position: relative;
  overflow: hidden;
  border-radius: 12px;
  cursor: crosshair;
  background: #e8e8e8;
  width: 100%;
  height: 100%;
}
.image-container {
  position: relative;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}
.map-image {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: fill;
}
.marker-layer {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}
</style>

