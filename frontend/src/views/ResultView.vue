<template>
  <div class="result-page">
    <div class="result-card">
      <h2 class="result-title">🎉 游戏结束！</h2>

      <div class="score-summary">
        <div class="score-item">
          <span class="score-label">总分</span>
          <span class="score-value">{{ totalScore }} <small>/ {{ maxScore }}</small></span>
        </div>
        <div class="score-divider"></div>
        <div class="score-item">
          <span class="score-label">均分</span>
          <span class="score-value">{{ avgScore }}</span>
        </div>
        <div class="score-divider"></div>
        <div class="score-item">
          <span class="score-label">题数</span>
          <span class="score-value">{{ scoreHistory.length }}</span>
        </div>
      </div>

      <table class="result-table" v-if="scoreHistory.length">
        <thead>
          <tr>
            <th>#</th>
            <th>地点</th>
            <th>距离（米）</th>
            <th>得分</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(r, i) in scoreHistory" :key="i" :class="scoreRowClass(r.score)">
            <td>{{ i + 1 }}</td>
            <td>{{ r.locationName || '-' }}</td>
            <td>{{ r.distance }}</td>
            <td class="score-cell">{{ r.score }}</td>
          </tr>
        </tbody>
      </table>

      <p class="no-data" v-else>暂无游戏记录</p>

      <div class="result-actions">
        <router-link to="/game" class="btn-primary">再来一局</router-link>
        <router-link to="/" class="btn-secondary">返回首页</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const scoreHistory = ref([])
const totalScore = ref(0)
const avgScore = ref(0)
const totalRounds = ref(0)
const maxScore = ref(0)

onMounted(() => {
  const raw = sessionStorage.getItem('gameResult')
  if (raw) {
    try {
      const data = JSON.parse(raw)
      scoreHistory.value = data.scoreHistory || []
      totalScore.value = data.totalScore || 0
      avgScore.value = data.avgScore || 0
      totalRounds.value = data.totalRounds || 0
      maxScore.value = totalRounds.value * 100
      sessionStorage.removeItem('gameResult')
    } catch {
      router.push('/')
    }
  } else {
    router.push('/')
  }
})

function scoreRowClass(score) {
  if (score >= 80) return 'row-great'
  if (score >= 60) return 'row-good'
  if (score >= 40) return 'row-ok'
  return 'row-low'
}
</script>

<style scoped>
.result-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background: linear-gradient(135deg, #f0f2ff 0%, #e8ecf8 50%, #f5f3ff 100%);
}

.result-card {
  background: #fff;
  border-radius: 16px;
  padding: 36px 40px;
  max-width: 640px;
  width: 100%;
  box-shadow: 0 12px 48px rgba(26, 26, 92, 0.12);
  text-align: center;
}

.result-title {
  margin: 0 0 24px;
  font-size: 28px;
  color: #1A1A5C;
}

/* 分数概览 */
.score-summary {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 24px;
  margin-bottom: 28px;
  padding: 20px 16px;
  background: #f6f7ff;
  border-radius: 12px;
}

.score-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.score-label {
  font-size: 14px;
  color: #888;
}

.score-value {
  font-size: 28px;
  font-weight: 700;
  color: #1A56DB;
}

.score-value small {
  font-size: 16px;
  font-weight: 400;
  color: #999;
}

.score-divider {
  width: 1px;
  height: 48px;
  background: #ddd;
}

/* 表格 */
.result-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 28px;
}

.result-table th,
.result-table td {
  padding: 10px 14px;
  border-bottom: 1px solid #eee;
  text-align: center;
}

.result-table th {
  background: #f8f8f8;
  font-weight: 600;
  font-size: 14px;
  color: #555;
}

.result-table tbody tr:hover {
  background: #f5f7ff;
}

.score-cell {
  font-weight: 600;
}

.row-great .score-cell { color: #16a34a; }
.row-good .score-cell { color: #1A56DB; }
.row-ok .score-cell { color: #d97706; }
.row-low .score-cell { color: #dc2626; }

.no-data {
  color: #999;
  font-size: 16px;
  margin-bottom: 28px;
}

/* 按钮 */
.result-actions {
  display: flex;
  justify-content: center;
  gap: 16px;
}

.btn-primary {
  display: inline-block;
  padding: 12px 40px;
  font-size: 18px;
  font-weight: 600;
  color: #fff;
  background: linear-gradient(135deg, #1A56DB 0%, #3B82F6 100%);
  border-radius: 30px;
  text-decoration: none;
  transition: all 0.2s ease;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(26, 86, 219, 0.35);
}

.btn-secondary {
  display: inline-block;
  padding: 12px 32px;
  font-size: 16px;
  color: #555;
  background: #f0f0f0;
  border-radius: 30px;
  text-decoration: none;
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: #e4e4e4;
}

@media (max-width: 768px) {
  .result-card {
    padding: 24px 20px;
  }

  .result-title {
    font-size: 22px;
    margin-bottom: 16px;
  }

  .score-summary {
    gap: 12px;
    padding: 14px 10px;
  }

  .score-value {
    font-size: 22px;
  }

  .score-value small {
    font-size: 14px;
  }

  .result-actions {
    flex-direction: column;
    align-items: center;
  }

  .btn-primary,
  .btn-secondary {
    width: 100%;
    text-align: center;
  }
}
</style>
