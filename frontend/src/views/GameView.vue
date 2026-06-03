<template>
  <div class="game-container">
    <h2>游戏页面</h2>
    <div class="game-layout">
      <div class="map-area">
        <CampusMap
            @mapClick="onMapClick"
            :markers="markers"
            :width="400"
            :height="600"
        />
      </div>
      <div class="photo-area">
        <img :src="currentPhoto" alt="校园照片" v-if="currentPhoto" />
        <p v-else>加载中...</p>
      </div>
    </div>
    <div class="info-panel" v-if="hasClicked">
      <p>你点击的位置：x={{ clickPos.x }}, y={{ clickPos.y }}</p>
      <button @click="submitGuess">提交答案</button>
    </div>
    <div class="info-panel" v-else>
      <p>请在地图上点击选择位置</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import CampusMap from '../components/CampusMap.vue'

// ------------------- 假数据（等后端好了就删掉这部分）--------------------
const mockLocations = [
  {
    id: 1,
    name: "北大楼",
    image_url: "/e6.jpg",
    difficulty: 2,
    area: "北园",
    px_x: 1200,
    px_y: 800
  },
  {
    id: 2,
    name: "图书馆",
    image_url: "/e6.jpg",
    difficulty: 3,
    area: "北园",
    px_x: 1400,
    px_y: 900
  },
  {
    id: 3,
    name: "大礼堂",
    image_url: "/e6.jpg",
    difficulty: 3,
    area: "北园",
    px_x: 1100,
    px_y: 750
  }
]
// ------------------- 假数据结束 --------------------

const clickPos = ref({ x: 0, y: 0 })
const hasClicked = ref(false)
const currentLocation = ref(null)
const currentPhoto = ref('')

// 从后端获取随机地点
async function fetchRandomLocation() {
  try {
    const res = await fetch('http://localhost:3000/api/locations/random')
    const data = await res.json()
    currentLocation.value = data
    currentPhoto.value = 'http://localhost:3000' + data.image_url
    console.log('当前地点ID：', data.id)
  } catch (err) {
    console.error('获取地点失败：', err)
  }
}

const markers = computed(() => {
  if (!hasClicked.value) return []
  return [{ x: clickPos.value.x, y: clickPos.value.y, type: 'guess' }]
})

function onMapClick(pos) {
  clickPos.value = { x: pos.x, y: pos.y }
  hasClicked.value = true
}

function submitGuess() {
  alert('提交坐标：(' + clickPos.value.x + ', ' + clickPos.value.y + ')' +
      '\n真实坐标：(' + currentLocation.value.px_x + ', ' + currentLocation.value.px_y + ')')
}

// 页面加载时自动获取一个地点
onMounted(() => {
  fetchRandomLocation()
})
</script>

<style scoped>
.game-container {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
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
}
.photo-area img {
  width: 100%;
  height: 100%;
  object-fit: contain;    /* 改为 contain，保持照片完整显示 */
  background: #e0e0e0;    /* 留白区域的背景色 */
}
.map-area {
  flex: 2;
  height: 600px;
}
.info-panel {
  padding: 12px 20px;
  background: #f5f5f5;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 16px;
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
  .game-layout {
    flex-direction: column;
    height: auto;
  }
  .map-area {
    width: 100%;
    height: 400px;
  }
  .photo-area {
    width: 100%;
    height: 250px;
  }
}

</style>
