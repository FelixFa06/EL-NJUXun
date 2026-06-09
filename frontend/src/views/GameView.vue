<template>
  <div class="game-container">
    <h2>游戏页面</h2>
    <div class="progress-bar">
      <span>第 {{ currentRound }} / {{ totalRounds }} 题</span>
      <span class="total-score">累计得分：{{ totalScore }} 分</span>
    </div>
    <div class="game-layout">
      <div class="map-area" ref="mapContainer">
        <CampusMap
            @mapClick="onMapClick"
            :markers="markers"
            :width="mapDisplayWidth"
            :height="mapDisplayHeight"
        />
      </div>
      <div class="photo-area">
        <div class="photo-loading" v-if="photoLoading">
          <span>📷 照片加载中...</span>
        </div>
        <img
          v-show="currentPhoto"
          :key="currentPhoto"
          :src="currentPhoto"
          alt="校园照片"
          @load="onPhotoLoaded"
          @error="onPhotoError"
        />
        <p v-if="!currentPhoto && !photoLoading">暂无照片</p>
      </div>
    </div>

    <!-- 游戏中的信息面板 -->
    <div class="info-panel" v-if="showResult && result">
      <div class="result-detail">
        <span>📍 真实位置：（{{ result.realLocation.px_x }}, {{ result.realLocation.px_y }}）</span>
        <span>🎯 你猜的位置：（{{ clickPos.x }}, {{ clickPos.y }}）</span>
        <span>📏 距离：<strong>{{ result.distance }} 米</strong></span>
        <span>⭐ 得分：<strong>{{ result.score }} 分</strong></span>
      </div>
      <button v-if="currentRound < totalRounds" @click="nextRound">下一题</button>
      <button v-else @click="finishGame">查看结果</button>
    </div>
    <div class="info-panel" v-else-if="hasClicked">
      <p>你点击的位置：x={{ clickPos.x }}, y={{ clickPos.y }}</p>
      <button @click="submitGuess">提交答案</button>
    </div>
    <div class="info-panel" v-else>
      <p>请在地图上点击选择位置</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import CampusMap from '../components/CampusMap.vue'

const router = useRouter()

const TOTAL_ROUNDS = 10
const mapContainer = ref(null)
const mapDisplayWidth = ref(400)
const mapDisplayHeight = ref(600)

function updateMapSize() {
  if (mapContainer.value) {
    mapDisplayWidth.value = mapContainer.value.clientWidth
    // 使用容器实际高度，避免地图 wrapper 溢出覆盖下方信息面板
    // 移动端 height:auto 时 clientHeight 由内容撑开，fallback 到宽度比例
    const h = mapContainer.value.clientHeight
    mapDisplayHeight.value = h > 0 ? h : Math.round(mapContainer.value.clientWidth * 1.5)
  }
}

const clickPos = ref({ x: 0, y: 0 })
const hasClicked = ref(false)
const showResult = ref(false)
const currentLocation = ref(null)
const currentPhoto = ref('')
const photoLoading = ref(false)
const result = ref(null)
const currentRound = ref(1)
const totalRounds = ref(TOTAL_ROUNDS)
const scoreHistory = ref([])
const usedLocationIds = ref(new Set())

const totalScore = computed(() => {
  return scoreHistory.value.reduce((sum, r) => sum + r.score, 0)
})

const avgScore = computed(() => {
  if (scoreHistory.value.length === 0) return 0
  return Math.round(totalScore.value / scoreHistory.value.length)
})

// 从后端获取随机地点（后端不可用时 fallback 到本地 JSON）
async function fetchRandomLocation() {
  // 把所有题目都做完了（极端情况：总题数 ≤ 10）
  if (usedLocationIds.value.size >= TOTAL_ROUNDS) {
    console.warn('可用地点不足，重置已用列表')
    usedLocationIds.value.clear()
  }

  photoLoading.value = true
  currentPhoto.value = ''

  try {
    const exclude = [...usedLocationIds.value].join(',')
    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), 3000)
    const url = exclude
      ? `/api/locations/random?exclude=${exclude}`
      : '/api/locations/random'
    const res = await fetch(url, { signal: controller.signal })
    clearTimeout(timeout)

    // 检查 HTTP 状态码，非 2xx 或响应数据无效时抛出错误走 fallback
    if (!res.ok) {
      throw new Error(`后端返回 ${res.status}`)
    }
    const data = await res.json()
    if (!data || !data.image_url) {
      throw new Error('响应数据缺少 image_url')
    }

    currentLocation.value = data
    // 添加缓存破坏参数，确保浏览器重新加载
    currentPhoto.value = addCacheBuster(data.image_url)
    // 统一使用 image_url 追踪已用地点
    usedLocationIds.value.add(data.image_url)
    console.log('当前地点：', data.name)
    return
  } catch (err) {
    console.warn('后端不可用，使用本地数据:', err.message)
  }
  // fallback：从本地 JSON 随机选一个未用过的
  await loadLocalLocation()
}

async function loadLocalLocation() {
  try {
    const res = await fetch('/locations.json')
    const allLocations = await res.json()

    // 过滤掉已用地点（用 image_url 作为唯一标识）
    const available = allLocations.filter(
      loc => !usedLocationIds.value.has(loc.image_url)
    )

    if (available.length === 0) {
      console.warn('所有地点已用过，重置已用列表')
      usedLocationIds.value.clear()
      const randomIndex = Math.floor(Math.random() * allLocations.length)
      currentLocation.value = allLocations[randomIndex]
      currentPhoto.value = addCacheBuster(allLocations[randomIndex].image_url)
      usedLocationIds.value.add(allLocations[randomIndex].image_url)
    } else {
      const randomIndex = Math.floor(Math.random() * available.length)
      currentLocation.value = available[randomIndex]
      currentPhoto.value = addCacheBuster(available[randomIndex].image_url)
      usedLocationIds.value.add(available[randomIndex].image_url)
    }
    console.log('当前地点：', currentLocation.value.name)
  } catch (err) {
    console.error('加载本地数据失败：', err)
  }
}

const markers = computed(() => {
  const list = []
  if (hasClicked.value) {
    list.push({ x: clickPos.value.x, y: clickPos.value.y, type: 'guess' })
  }
  if (showResult.value && result.value) {
    list.push({ x: result.value.realLocation.px_x, y: result.value.realLocation.px_y, type: 'real' })
  }
  return list
})

function onMapClick(pos) {
  clickPos.value = { x: pos.x, y: pos.y }
  hasClicked.value = true
}

// 为图片 URL 添加缓存破坏参数，防止浏览器使用缓存
function addCacheBuster(url) {
  if (!url) return ''
  const separator = url.includes('?') ? '&' : '?'
  return `${url}${separator}_t=${Date.now()}`
}

function onPhotoLoaded() {
  photoLoading.value = false
}

function onPhotoError() {
  photoLoading.value = false
  console.error('照片加载失败：', currentPhoto.value)
}

function submitGuess() {
  if (!currentLocation.value || !hasClicked.value) return

  // 计算像素距离
  const dx = clickPos.value.x - currentLocation.value.px_x
  const dy = clickPos.value.y - currentLocation.value.px_y
  const pixelDist = Math.sqrt(dx * dx + dy * dy)

  // 比例尺 0.34608 米/像素
  const scale = 0.34608
  const distanceMeters = Math.round(pixelDist * scale * 100) / 100

  // 算分
  let score = 0
  if (distanceMeters <= 10) score = 100
  else if (distanceMeters <= 50) score = Math.round(80 + 20 * (50 - distanceMeters) / 40)
  else if (distanceMeters <= 100) score = Math.round(60 + 20 * (100 - distanceMeters) / 50)
  else if (distanceMeters <= 200) score = Math.round(40 + 20 * (200 - distanceMeters) / 100)
  else if (distanceMeters <= 500) score = Math.round(20 + 20 * (500 - distanceMeters) / 300)
  else if (distanceMeters <= 1000) score = Math.round(1 + 19 * (1000 - distanceMeters) / 500)
  else score = 0

  const roundResult = {
    distance: distanceMeters,
    score: score,
    realLocation: {
      px_x: currentLocation.value.px_x,
      px_y: currentLocation.value.px_y
    },
    locationName: currentLocation.value.name
  }
  result.value = roundResult
  scoreHistory.value.push(roundResult)
  showResult.value = true
}

// 进入下一题
function nextRound() {
  currentRound.value++
  clickPos.value = { x: 0, y: 0 }
  hasClicked.value = false
  showResult.value = false
  result.value = null
  currentPhoto.value = ''
  photoLoading.value = true
  fetchRandomLocation()
}

// 最后一题提交后，保存结果并跳转结果页
function finishGame() {
  sessionStorage.setItem('gameResult', JSON.stringify({
    scoreHistory: scoreHistory.value,
    totalScore: totalScore.value,
    avgScore: avgScore.value,
    totalRounds: totalRounds.value
  }))
  router.push('/result')
}

// 重新开始（每次进入 /game 都会重置状态）
function restartGame() {
  currentRound.value = 1
  scoreHistory.value = []
  usedLocationIds.value.clear()
  clickPos.value = { x: 0, y: 0 }
  hasClicked.value = false
  showResult.value = false
  result.value = null
  currentPhoto.value = ''
  photoLoading.value = true
  fetchRandomLocation()
}

// 每次进入页面自动重置状态并开始新游戏
onMounted(() => {
  updateMapSize()
  window.addEventListener('resize', updateMapSize)
  restartGame()
})

onUnmounted(() => {
  window.removeEventListener('resize', updateMapSize)
})
</script>

<style scoped>
.game-container {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  touch-action: manipulation;
}
.progress-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
  background: #eef2ff;
  border-radius: 8px;
  font-weight: 500;
  font-size: 15px;
}
.total-score {
  color: #1A56DB;
}
.game-layout {
  display: flex;
  gap: 16px;
  height: 600px;
}
.photo-area {
  flex: 6;
  background: #f0f0f0;
  border-radius: 12px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}
.photo-area img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  background: #e0e0e0;
}
.photo-loading {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #888;
  font-size: 18px;
  background: #f5f5f5;
  z-index: 1;
}
.map-area {
  flex: 2;
  height: 600px;
  overflow: hidden;
}
.info-panel {
  padding: 12px 20px;
  background: #f5f5f5;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 16px;
}
.result-detail {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 20px;
  flex: 1;
}
.result-detail span {
  white-space: nowrap;
}
/* 游戏结束面板 */
.game-over-panel {
  padding: 24px;
  background: #fff;
  border-radius: 12px;
  border: 1px solid #e0e0e0;
  text-align: center;
}
.game-over-panel h3 {
  margin: 0 0 12px;
  font-size: 22px;
}
.final-score {
  font-size: 18px;
  margin-bottom: 16px;
  display: flex;
  justify-content: center;
  gap: 16px;
}
.final-score strong {
  color: #1A56DB;
  font-size: 24px;
}
.score-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 16px;
}
.score-table th,
.score-table td {
  padding: 8px 12px;
  border-bottom: 1px solid #eee;
}
.score-table th {
  background: #f8f8f8;
  font-weight: 600;
}
.score-table tbody tr:hover {
  background: #f5f7ff;
}
button {
  padding: 8px 24px;
  font-size: 16px;
  cursor: pointer;
  background: #1A56DB;
  color: white;
  border: none;
  border-radius: 6px;
}
button:hover {
  background: #1547b8;
}
@media (max-width: 768px) {
  .game-container {
    padding: 10px;
    gap: 10px;
  }
  .game-layout {
    flex-direction: column;
    height: auto;
  }
  .map-area {
    width: 100%;
    height: auto;
    max-height: 55vh;
    overflow: hidden;
  }
  .photo-area {
    width: 100%;
    height: 220px;
  }
  .result-detail {
    flex-direction: column;
    gap: 4px;
  }
  .info-panel {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
  .progress-bar {
    font-size: 13px;
  }
  h2 {
    font-size: 16px;
  }
}

</style>
