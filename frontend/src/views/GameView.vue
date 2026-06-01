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
        <p>照片区域（待接入）</p>
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
import { ref, computed } from 'vue'
import CampusMap from '../components/CampusMap.vue'

const clickPos = ref({ x: 0, y: 0 })
const hasClicked = ref(false)

const markers = computed(() => {
  if (!hasClicked.value) return []
  return [{ x: clickPos.value.x, y: clickPos.value.y, type: 'guess' }]
})

function onMapClick(pos) {
  console.log('点击坐标：', pos)
  clickPos.value = { x: pos.x, y: pos.y }
  hasClicked.value = true
}

function submitGuess() {
  alert('提交坐标：' + clickPos.value.x + ', ' + clickPos.value.y)
}
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
}
.map-area {
  width: 400px;
  height: 600px;
}
.photo-area {
  width: 400px;
  height: 450px;
  background: #f0f0f0;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
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
</style>
