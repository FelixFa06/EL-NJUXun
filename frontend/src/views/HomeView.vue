<template>
  <div class="home-wrapper">
    <!-- 玩家须知弹窗 -->
    <div class="notice-overlay" v-if="showNotice" @click.self="closeNotice">
      <div class="notice-card">
        <div class="notice-header">
          <h2>📋 玩家须知</h2>
        </div>
        <div class="notice-body">
          <div class="notice-section">
            <h3>🎮 游戏玩法</h3>
            <p>游戏会展示一张南京大学鼓楼校区的<strong>实景照片</strong>，你需要根据照片内容，在校园地图上<strong>点击猜测</strong>这张照片的拍摄位置。</p>
            <p>系统会根据你的猜测位置与真实位置之间的距离计算<strong>得分</strong>——猜得越近，分数越高！</p>
          </div>
          <div class="notice-section">
            <h3>📏 计分规则</h3>
            <ul>
              <li>距离 ≤ 10 米 → <strong>100 分</strong></li>
              <li>距离 ≤ 50 米 → <strong>80~99 分</strong></li>
              <li>距离 ≤ 100 米 → <strong>60~79 分</strong></li>
              <li>距离 ≤ 200 米 → <strong>40~59 分</strong></li>
              <li>距离 ≤ 500 米 → <strong>20~39 分</strong></li>
              <li>距离 &gt; 1000 米 → <strong>0 分</strong></li>
            </ul>
          </div>
          <div class="notice-section">
            <h3>💡 小贴士</h3>
            <p>每局游戏共 <strong>10 道题</strong>，仔细观察照片中的建筑、道路和植被特征，结合地图进行判断。祝你取得好成绩！</p>
          </div>
          <div class="notice-section">
            <h3>📦 开源地址</h3>
            <p>本项目代码已开源至 GitHub，地址为 <a href="https://github.com/FelixFa06/EL-NJUXun" target="_blank">https://github.com/FelixFa06/EL-NJUXun</a></p>
          </div>
          <div class="notice-footer-info">
            <p>© 2026 南京大学 EL 大赛交互组</p>
          </div>
        </div>
        <div class="notice-actions">
          <button class="btn-close-notice" @click="closeNotice">关 闭</button>
        </div>
      </div>
    </div>

    <!-- 主页面内容 -->
    <div
      class="home-content"
      :class="{ 'blur-bg': showNotice }"
      :style="{ backgroundImage: `url(${bgImage})` }"
    >
      <div class="home-overlay"></div>
      <div class="home-center">
        <div class="title-group">
          <h1 class="main-title">南大图寻</h1>
          <p class="sub-title">NJUXun — 探索南大，在指尖丈量校园</p>
        </div>
        <router-link to="/game" class="start-link">
          <button class="btn-start">开始探索</button>
        </router-link>
      </div>
      <div class="home-attribution">
        <span>南京大学鼓楼校区</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import bgImage from '../assets/nju_bg_1.jpg'

const showNotice = ref(true)

function closeNotice() {
  showNotice.value = false
}
</script>

<style scoped>
/* ========== 整体布局 ========== */
.home-wrapper {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  position: relative;
}

/* ========== 玩家须知弹窗 ========== */
.notice-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.65);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.notice-card {
  background: #fff;
  border-radius: 16px;
  max-width: 560px;
  width: 90%;
  max-height: 85vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.35s ease;
}

@keyframes slideUp {
  from { transform: translateY(40px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.notice-header {
  background: linear-gradient(135deg, #1A1A5C 0%, #3B2D7A 50%, #5B3D9E 100%);
  color: #fff;
  text-align: center;
  padding: 24px 20px 20px;
  border-radius: 16px 16px 0 0;
}

.notice-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  letter-spacing: 2px;
}

.notice-body {
  padding: 20px 28px 8px;
}

.notice-section {
  margin-bottom: 18px;
}

.notice-section h3 {
  margin: 0 0 8px;
  font-size: 17px;
  color: #1A1A5C;
  font-weight: 600;
}

.notice-section p {
  margin: 4px 0;
  font-size: 15px;
  line-height: 1.7;
  color: #333;
}

.notice-section ul {
  margin: 6px 0;
  padding-left: 20px;
  list-style: none;
}

.notice-section ul li {
  font-size: 15px;
  line-height: 1.8;
  color: #444;
  position: relative;
}

.notice-section ul li::before {
  content: '▸';
  position: absolute;
  left: -18px;
  color: #5B3D9E;
  font-size: 12px;
  top: 2px;
}

.notice-footer-info {
  text-align: center;
  margin-top: 8px;
  padding-top: 12px;
  border-top: 1px solid #eee;
}

.notice-footer-info p {
  margin: 0;
  font-size: 13px;
  color: #888;
  letter-spacing: 1px;
}

.notice-actions {
  text-align: center;
  padding: 12px 28px 28px;
}

.btn-close-notice {
  padding: 12px 60px;
  font-size: 17px;
  font-weight: 600;
  color: #fff;
  background: linear-gradient(135deg, #1A1A5C 0%, #5B3D9E 100%);
  border: none;
  border-radius: 30px;
  cursor: pointer;
  letter-spacing: 6px;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(26, 26, 92, 0.3);
}

.btn-close-notice:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(26, 26, 92, 0.45);
}

.btn-close-notice:active {
  transform: translateY(0);
}

/* ========== 主页面 ========== */
.home-content {
  width: 100%;
  height: 100%;
  background: center center / cover no-repeat;
  background-color: #1A1A5C; /* 图片加载前的后备色 */
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: filter 0.3s ease;
}

.home-content.blur-bg {
  filter: blur(2px);
}

.home-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    135deg,
    rgba(26, 26, 92, 0.35) 0%,
    rgba(59, 45, 122, 0.2) 50%,
    rgba(26, 26, 92, 0.35) 100%
  );
}

.home-center {
  position: relative;
  z-index: 1;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 40px;
}

.title-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.main-title {
  margin: 0;
  font-size: 72px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 16px;
  text-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}

.sub-title {
  margin: 0;
  font-size: 18px;
  color: rgba(255, 255, 255, 0.85);
  letter-spacing: 4px;
  font-weight: 300;
}

.start-link {
  text-decoration: none;
}

.btn-start {
  padding: 16px 72px;
  font-size: 24px;
  font-weight: 600;
  color: #1A1A5C;
  background: #fff;
  border: none;
  border-radius: 40px;
  cursor: pointer;
  letter-spacing: 8px;
  transition: all 0.35s ease;
  box-shadow: 0 6px 30px rgba(0, 0, 0, 0.25);
}

.btn-start:hover {
  transform: translateY(-3px) scale(1.03);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.35);
  background: #f0eeff;
}

.btn-start:active {
  transform: translateY(-1px) scale(1.01);
}

.home-attribution {
  position: absolute;
  bottom: 24px;
  right: 32px;
  z-index: 1;
}

.home-attribution span {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.5);
  letter-spacing: 2px;
}

/* ========== 响应式 ========== */
@media (max-width: 768px) {
  .main-title {
    font-size: 42px;
    letter-spacing: 10px;
  }

  .sub-title {
    font-size: 14px;
    letter-spacing: 2px;
  }

  .btn-start {
    padding: 14px 48px;
    font-size: 18px;
    letter-spacing: 4px;
  }

  .notice-card {
    max-width: 95%;
    max-height: 80vh;
  }

  .notice-header h2 {
    font-size: 20px;
  }

  .btn-close-notice {
    padding: 10px 40px;
    font-size: 15px;
    letter-spacing: 4px;
  }
}
</style>
