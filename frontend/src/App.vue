<template>
  <router-view />
  <footer class="icp-footer">
    <div class="footer-content">
      <span class="copyright">&copy; {{ currentYear }} 南大图寻</span>
      <a href="https://beian.miit.gov.cn/" target="_blank" rel="noopener">鄂ICP备2026031078号</a>
      <a href="https://beian.mps.gov.cn/#/query/webSearch?code=42130202448238" rel="noreferrer" target="_blank" class="police-beian">
        <img src="/images/police-badge.png" width="16" height="16" alt="公安备案标识">
        鄂公网安备42130202448238号
      </a>
    </div>
  </footer>
</template>

<script setup>
import { computed } from 'vue'

const currentYear = computed(() => new Date().getFullYear())
</script>

<style>
body {
  margin: 0;
  font-family: '微软雅黑', sans-serif;
}

.icp-footer {
  text-align: center;
  padding: 12px 16px;
  background: #f5f5f5;
  border-top: 1px solid #e0e0e0;
}

.footer-content {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  gap: 8px 16px;
}

.footer-content .copyright {
  font-size: 13px;
  color: #888;
}

.icp-footer a {
  font-size: 13px;
  color: #888;
  text-decoration: none;
  letter-spacing: 1px;
}

.icp-footer a.police-beian {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  letter-spacing: 0;
}

.icp-footer a.police-beian img {
  flex-shrink: 0;
}

.icp-footer a:hover {
  color: #555;
}
</style>
