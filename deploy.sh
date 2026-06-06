#!/bin/bash
# ============================================
#  NJUXun 一键部署脚本
#  用法: bash deploy.sh
#  放在服务器上项目根目录执行
# ============================================

set -e

# 自动切换到脚本所在目录（项目根目录）
cd "$(dirname "$0")"

echo "📦 拉取最新代码..."
git pull

echo ""
echo "📦 安装后端依赖..."
cd backend && npm install --production && cd ..

echo ""
echo "📦 安装前端依赖 + 构建..."
cd frontend && npm install && npm run build && cd ..

echo ""
echo "🚀 重启服务..."
pm2 restart ecosystem.config.js --cwd backend || pm2 start backend/ecosystem.config.js

echo ""
echo "✅ 部署完成！"
pm2 status
