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
            stroke="#D946EF" stroke-width="4" stroke-dasharray="10,6"
            stroke-linecap="round"
        />
        <circle
            v-for="(m, i) in markers" :key="i"
            :cx="m.x" :cy="m.y" r="12"
            :fill="m.type === 'real' ? '#FF4444' : '#4488FF'"
            stroke="white" stroke-width="3"
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
const justTapped = ref(false) // 防止 touch 和 click 重复触发

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
  // 手机端已通过 touch 事件处理，避免重复触发
  if (justTapped.value) {
    justTapped.value = false
    return
  }

  const imgEl = mapImg.value
  if (!imgEl) return
  const imgRect = imgEl.getBoundingClientRect()

  const clickX = e.clientX - imgRect.left
  const clickY = e.clientY - imgRect.top

  const s = scale.value
  // getBoundingClientRect() 已包含 CSS transform 的平移效果，
  // clickX/s 已正确映射到未缩放图层坐标，无需再加 panX
  const origX = clickX / s
  const origY = clickY / s

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
const DRAG_THRESHOLD = 5  // 移动超过 5px 才算拖动

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
    // 双指：记录初始状态用于缩放 + 平移
    const mid = getTouchMidpoint(e.touches)
    touchCache.value = {
      mode: 'pinch',
      initialDist: getTouchDist(e.touches),
      initialMidX: mid.x,
      initialMidY: mid.y,
      initialScale: scale.value,
      initialPanX: panX.value,
      initialPanY: panY.value,
    }
  } else if (e.touches.length === 1) {
    // 单指：可能是点击或拖动
    touchCache.value = {
      mode: 'single',
      startX: e.touches[0].clientX,
      startY: e.touches[0].clientY,
      startPanX: panX.value,
      startPanY: panY.value,
      moved: false,
    }
  }
}

function onTouchMove(e) {
  const tc = touchCache.value
  if (!tc) return

  if (tc.mode === 'pinch' && e.touches.length === 2) {
    e.preventDefault()
    const newDist = getTouchDist(e.touches)
    const mid = getTouchMidpoint(e.touches)

    // 缩放：基于初始距离的比例（不更新缓存，始终用 touchstart 基准）
    let newScale = tc.initialScale * (newDist / tc.initialDist)
    newScale = Math.max(MIN_SCALE, Math.min(MAX_SCALE, newScale))

    // 平移：中点位移（屏幕像素）→ 转换为渲染像素
    const dMidX = mid.x - tc.initialMidX
    const dMidY = mid.y - tc.initialMidY
    const newPanX = tc.initialPanX - dMidX
    const newPanY = tc.initialPanY - dMidY

    scale.value = newScale
    panX.value = newPanX
    panY.value = newPanY
    clampPan()
  } else if (tc.mode === 'single' && e.touches.length === 1) {
    const dx = e.touches[0].clientX - tc.startX
    const dy = e.touches[0].clientY - tc.startY
    const dist = Math.sqrt(dx * dx + dy * dy)

    if (dist > DRAG_THRESHOLD) {
      tc.moved = true
      // 拖动平移：反向移动地图
      panX.value = tc.startPanX - dx
      panY.value = tc.startPanY - dy
      clampPan()
    }
  }
}

function onTouchEnd(e) {
  if (touchCache.value?.mode === 'single' && !touchCache.value.moved && e.touches.length === 0) {
    // 单指没拖动 = 点击，手动触发地图坐标计算
    const tc = touchCache.value
    touchCache.value = null
    handleClickFromTouch(tc.startX, tc.startY)
    return
  }
  if (e.touches.length < 2) {
    touchCache.value = null
  }
}

// 从触摸坐标模拟点击
function handleClickFromTouch(clientX, clientY) {
  if (!props.clickable) return
  const imgEl = mapImg.value
  if (!imgEl) return
  const imgRect = imgEl.getBoundingClientRect()

  const clickX = clientX - imgRect.left
  const clickY = clientY - imgRect.top

  const s = scale.value
  // getBoundingClientRect() 已包含 CSS transform 的平移效果，
  // clickX/s 已正确映射到未缩放图层坐标，无需再加 panX
  const origX = clickX / s
  const origY = clickY / s

  const x = Math.round(origX * (props.mapWidth / fit.renderedWidth))
  const y = Math.round(origY * (props.mapHeight / fit.renderedHeight))

  const clampedX = Math.max(0, Math.min(props.mapWidth, x))
  const clampedY = Math.max(0, Math.min(props.mapHeight, y))

  // 标记刚刚由 touch 触发了点击，阻止后续 click 事件重复触发
  justTapped.value = true
  emit('mapClick', { x: clampedX, y: clampedY })
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
