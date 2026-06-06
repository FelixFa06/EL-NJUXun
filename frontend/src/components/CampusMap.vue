<template>
  <div
    ref="mapWrapper"
    class="map-wrapper"
    :style="wrapperStyle"
    @touchstart="onTouchStart"
    @touchmove.prevent="onTouchMove"
    @touchend="onTouchEnd"
    @dblclick="zoomIn"
  >
    <div class="map-transform-layer" :style="transformLayerStyle">
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

    <!-- 缩放按钮 -->
    <div class="zoom-controls" v-if="clickable">
      <button class="zoom-btn" @click.stop="zoomIn" title="放大">+</button>
      <button class="zoom-btn" @click.stop="zoomOut" title="缩小">−</button>
      <button class="zoom-btn zoom-reset" v-if="isZoomed" @click.stop="resetZoom" title="重置">↺</button>
    </div>
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

// ===== 缩放/平移状态 =====
const scale = ref(1)
const panX = ref(0)  // 平移偏移（渲染像素）
const panY = ref(0)
const touchCache = ref(null)  // 多点触控缓存

const MIN_SCALE = 1
const MAX_SCALE = 5
const ZOOM_STEP = 0.5

const isZoomed = computed(() => scale.value > 1)

// 变化层样式：应用 scale + translate
const transformLayerStyle = computed(() => {
  if (scale.value === 1 && panX.value === 0 && panY.value === 0) return {}
  return {
    transform: `scale(${scale.value}) translate(${-panX.value}px, ${-panY.value}px)`,
    transformOrigin: '0 0',
  }
})

// ===== 缩放控制函数 =====
function zoomIn() {
  const newScale = Math.min(MAX_SCALE, scale.value + ZOOM_STEP)
  // 以中心点为缩放原点
  const ratio = newScale / scale.value
  const cx = props.width / 2
  const cy = props.height / 2
  panX.value = cx - ratio * (cx - panX.value)
  panY.value = cy - ratio * (cy - panY.value)
  scale.value = newScale
  clampPan()
}

function zoomOut() {
  const newScale = Math.max(MIN_SCALE, scale.value - ZOOM_STEP)
  if (newScale <= MIN_SCALE) {
    scale.value = MIN_SCALE
    panX.value = 0
    panY.value = 0
    return
  }
  const ratio = newScale / scale.value
  panX.value *= ratio
  panY.value *= ratio
  scale.value = newScale
  clampPan()
}

function resetZoom() {
  scale.value = 1
  panX.value = 0
  panY.value = 0
}

function clampPan() {
  // 限制平移范围：不让内容完全移出可视区
  const s = scale.value
  const maxPanX = Math.max(0, fit.renderedWidth * s - props.width)
  const maxPanY = Math.max(0, fit.renderedHeight * s - props.height)
  panX.value = Math.max(0, Math.min(maxPanX, panX.value))
  panY.value = Math.max(0, Math.min(maxPanY, panY.value))
}

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

  const imgEl = mapImg.value
  if (!imgEl) return
  const imgRect = imgEl.getBoundingClientRect()

  // 点击在屏幕上的位置相对于图片元素
  const clickX = e.clientX - imgRect.left
  const clickY = e.clientY - imgRect.top

  // 修正缩放和平移：反向变换得到原始图片坐标
  const s = scale.value
  const origX = clickX / s + panX.value
  const origY = clickY / s + panY.value

  // 缩放到地图坐标
  const x = Math.round(origX * (props.mapWidth / fit.renderedWidth))
  const y = Math.round(origY * (props.mapHeight / fit.renderedHeight))

  const clampedX = Math.max(0, Math.min(props.mapWidth, x))
  const clampedY = Math.max(0, Math.min(props.mapHeight, y))

  emit('mapClick', { x: clampedX, y: clampedY })
}

function onImageLoad() {
  recalcFit()
}

// ===== 触摸手势处理 =====
function getTouchDist(touches) {
  const dx = touches[0].clientX - touches[1].clientX
  const dy = touches[0].clientY - touches[1].clientY
  return Math.sqrt(dx * dx + dy * dy)
}

function getTouchMidpoint(touches) {
  return {
    x: (touches[0].clientX + touches[1].clientX) / 2,
    y: (touches[0].clientY + touches[1].clientY) / 2,
  }
}

function onTouchStart(e) {
  if (!props.clickable) return
  if (e.touches.length === 2) {
    // 双指开始：记录初始状态
    touchCache.value = {
      dist: getTouchDist(e.touches),
      midX: getTouchMidpoint(e.touches).x,
      midY: getTouchMidpoint(e.touches).y,
      startScale: scale.value,
      startPanX: panX.value,
      startPanY: panY.value,
    }
  }
}

function onTouchMove(e) {
  if (!touchCache.value || e.touches.length !== 2) return
  e.preventDefault()

  const tc = touchCache.value
  const newDist = getTouchDist(e.touches)
  const mid = getTouchMidpoint(e.touches)

  // 缩放：基于初始双指距离的比例变化
  let newScale = tc.startScale * (newDist / tc.dist)
  newScale = Math.max(MIN_SCALE, Math.min(MAX_SCALE, newScale))

  // 平移：中点位移除以 scale（补偿缩放导致的位移量变化）
  const wrapperRect = mapWrapper.value.getBoundingClientRect()
  const dMidX = mid.x - tc.midX
  const dMidY = mid.y - tc.midY

  let newPanX = tc.startPanX - dMidX / tc.startScale
  let newPanY = tc.startPanY - dMidY / tc.startScale

  scale.value = newScale
  panX.value = newPanX
  panY.value = newPanY
  clampPan()

  // 更新缓存为当前值，便于下一帧增量计算
  touchCache.value = {
    dist: newDist,
    midX: mid.x,
    midY: mid.y,
    startScale: newScale,
    startPanX: newPanX,
    startPanY: newPanY,
  }
}

function onTouchEnd(e) {
  if (e.touches.length < 2) {
    touchCache.value = null
  }
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
  touch-action: none;  /* 阻止浏览器默认手势，由 JS 接管 */
}
.map-transform-layer {
  position: relative;
  width: 100%;
  height: 100%;
  will-change: transform;
}
.map-image {
  display: block;
  user-select: none;
  -webkit-user-drag: none;
}
.marker-layer {
  z-index: 2;
}

/* 缩放按钮 */
.zoom-controls {
  position: absolute;
  right: 8px;
  bottom: 8px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  z-index: 10;
}
.zoom-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: 1px solid #ccc;
  background: rgba(255, 255, 255, 0.9);
  font-size: 20px;
  font-weight: bold;
  color: #333;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  line-height: 1;
  -webkit-tap-highlight-color: transparent;
  touch-action: manipulation;
}
.zoom-btn:hover {
  background: #f0f0f0;
}
.zoom-btn:active {
  background: #e0e0e0;
  transform: scale(0.95);
}
.zoom-reset {
  font-size: 16px;
}
</style>
