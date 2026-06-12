#!/bin/bash
# ============================================
#  NJUXun 一键部署脚本
#  用法: bash deploy.sh              # 更新部署（默认）
#        bash deploy.sh --setup      # 首次部署（含数据库初始化）
#  放在服务器上项目根目录执行
# ============================================

set -e

# 自动切换到脚本所在目录（项目根目录）
cd "$(dirname "$0")"

MODE="${1:-update}"

# ==================== 前置检查 ====================

echo "🔍 检查运行环境..."

# Node.js
if ! command -v node &> /dev/null; then
  echo "❌ 未安装 Node.js，请先安装 Node.js ≥ 18"
  exit 1
fi

# PM2
if ! command -v pm2 &> /dev/null; then
  echo "❌ 未安装 PM2，请先执行: npm install -g pm2"
  exit 1
fi

# .env
if [ ! -f ".env" ]; then
  echo "❌ 缺少 .env 文件，请先执行: cp .env.example .env 并填入实际配置"
  exit 1
fi

echo "✅ 环境检查通过"

# ==================== 首次部署 ====================

if [ "$MODE" == "--setup" ]; then
  echo ""
  echo "📦 首次部署模式：初始化数据库..."

  if [ -f "backend/scripts/init_db.sql" ]; then
    mysql -u root -p < backend/scripts/init_db.sql
  else
    echo "⚠️  未找到 init_db.sql，跳过建库建表"
  fi

  if [ -f "backend/scripts/seed_locations.sql" ]; then
    mysql -u root -p njuxun < backend/scripts/seed_locations.sql
  else
    echo "⚠️  未找到 seed_locations.sql，跳过种子数据导入"
  fi

  echo ""
  echo "📦 配置 Nginx（如果未配置）..."
  if [ -f "nginx.conf" ] && [ ! -f "/etc/nginx/conf.d/njuxun.conf" ]; then
    sudo cp nginx.conf /etc/nginx/conf.d/njuxun.conf
    sudo nginx -t && sudo systemctl reload nginx
    echo "✅ Nginx 配置完成"
  else
    echo "⏭️  Nginx 已配置或 nginx.conf 不存在，跳过"
  fi
fi

# ==================== 拉取代码 ====================

echo ""
echo "📦 拉取最新代码..."
git pull

# ==================== 安装依赖 & 构建 ====================

echo ""
echo "📦 安装后端依赖..."
cd backend && npm install --production && cd ..

echo ""
echo "📦 安装前端依赖 + 构建..."
cd frontend && npm install && npm run build && cd ..

# ==================== 重启服务 ====================

echo ""
echo "🚀 重启服务..."

# 用进程名重启（更可靠）；若不存在则用配置文件启动
if pm2 show njuxun &> /dev/null; then
  pm2 restart njuxun
else
  pm2 start backend/ecosystem.config.js
  pm2 save
fi

# ==================== 健康检查 ====================

echo ""
echo "🩺 等待服务启动..."
sleep 2

HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health 2>/dev/null || echo "000")

if [ "$HEALTH" == "200" ]; then
  echo "✅ 健康检查通过"
else
  echo "⚠️  健康检查返回 HTTP $HEALTH，请检查 pm2 logs njuxun"
fi

echo ""
echo "✅ 部署完成！"
pm2 status
