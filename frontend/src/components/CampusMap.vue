<template>
  <div ref="mapWrapper" class="map-wrapper" :style="wrapperStyle">
    <img
        ref="mapImg"
        :src="mapImage"
        class="map-image"
        :style="imageStyle"
        @click="handleClick"
        draggable="false"
    />
    <svg
        class="marker-layer"
        :style="svgStyle"
        :viewBox="'0 0 ' + mapWidth + ' ' + mapHeight"
        preserveAspectRatio="none"
    >
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
import { ref, reactive, computed, onMounted, onBeforeUnmount, watch, nextTick } from 'vue'

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
const mapImg = ref(null)

// 图片实际渲染区域的尺寸和位置（由 JS 统一计算，图片和 SVG 共用）
const fit = reactive({
  renderedWidth: props.width,
  renderedHeight: props.height,
  offsetX: 0,
  offsetY: 0
})

const wrapperStyle = computed(() => ({
  width: props.width + 'px',
  height: props.height + 'px'
}))

// 图片和 SVG 使用完全相同的尺寸和位置，避免各自信箱机制产生差异
const imageStyle = computed(() => ({
  width: fit.renderedWidth + 'px',
  height: fit.renderedHeight + 'px',
  position: 'absolute',
  left: fit.offsetX + 'px',
  top: fit.offsetY + 'px'
}))

const svgStyle = computed(() => ({
  position: 'absolute',
  left: fit.offsetX + 'px',
  top: fit.offsetY + 'px',
  width: fit.renderedWidth + 'px',
  height: fit.renderedHeight + 'px',
  pointerEvents: 'none'
}))

function recalcFit() {
  const img = mapImg.value
  if (!img || !img.naturalWidth || !img.naturalHeight) return

  const containerW = props.width
  const containerH = props.height
  const imageAspect = img.naturalWidth / img.naturalHeight
  const containerAspect = containerW / containerH

  let rw, rh, ox, oy

  if (imageAspect > containerAspect) {
    rw = containerW
    rh = containerW / imageAspect
    ox = 0
    oy = (containerH - rh) / 2
  } else {
    rh = containerH
    rw = containerH * imageAspect
    ox = (containerW - rw) / 2
    oy = 0
  }

  fit.renderedWidth = rw
  fit.renderedHeight = rh
  fit.offsetX = ox
  fit.offsetY = oy
}

function handleClick(e) {
  if (!props.clickable) return

  // 点击位置相对于图片渲染区域的坐标
  const imgEl = mapImg.value
  if (!imgEl) return
  const imgRect = imgEl.getBoundingClientRect()

  const clickX = e.clientX - imgRect.left
  const clickY = e.clientY - imgRect.top

  // 缩放到地图坐标（无需信箱偏移，因为图片和 SVG 已精确对齐）
  const x = Math.round(clickX * (props.mapWidth / fit.renderedWidth))
  const y = Math.round(clickY * (props.mapHeight / fit.renderedHeight))

  const clampedX = Math.max(0, Math.min(props.mapWidth, x))
  const clampedY = Math.max(0, Math.min(props.mapHeight, y))

  emit('mapClick', { x: clampedX, y: clampedY })
}

function onImageLoad() {
  recalcFit()
}

let resizeObserver = null

onMounted(() => {
  const img = mapImg.value
  if (img) {
    if (img.complete) {
      recalcFit()
    }
    img.addEventListener('load', onImageLoad)
  }

  // 监听容器尺寸变化
  if (mapWrapper.value) {
    resizeObserver = new ResizeObserver(() => {
      recalcFit()
    })
    resizeObserver.observe(mapWrapper.value)
  }
})

onBeforeUnmount(() => {
  const img = mapImg.value
  if (img) {
    img.removeEventListener('load', onImageLoad)
  }
  if (resizeObserver) {
    resizeObserver.disconnect()
  }
})

// 当 width/height props 变化时重新计算
watch([() => props.width, () => props.height], () => {
  nextTick(() => recalcFit())
})
</script>

<style scoped>
.map-wrapper {
  position: relative;
  overflow: hidden;
  border-radius: 12px;
  cursor: crosshair;
  background: #e8e8e8;
}
.map-image {
  display: block;
  /* object-fit 不再需要，由 JS 手动控制尺寸 */
  user-select: none;
  -webkit-user-drag: none;
}
.marker-layer {
  z-index: 2;
}
</style>
