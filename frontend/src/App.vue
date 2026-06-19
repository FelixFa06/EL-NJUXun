<template>
  <router-view />
  <footer class="icp-footer">
    <a href="https://beian.miit.gov.cn/" target="_blank" rel="noopener">鄂ICP备2026031078号</a>
  </footer>
</template>

<script setup>
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

.icp-footer a {
  font-size: 13px;
  color: #888;
  text-decoration: none;
  letter-spacing: 1px;
}

.icp-footer a:hover {
  color: #555;
}
</style>
