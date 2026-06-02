# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

南大图寻（NJUXun）— 2026 南京大学 EL 大赛交互组项目。一个基于校园地图照片的定位猜测游戏：玩家看到一张校园实景照片，在地图上点击猜测拍摄位置，系统根据实际坐标与猜测坐标的距离计算得分。

## 技术栈

- **前端**: Vue 3 (Composition API) + Vite 5 + Vue Router 4 + Pinia 3 + Element Plus 2 + Axios
- **后端**: Node.js + Express 4 + MySQL (mysql2) + JWT 认证
- **无 TypeScript**，全部使用纯 JavaScript

## 常用命令

```bash
# 前端开发（Vite dev server，默认端口 5173）
cd frontend && npm run dev

# 前端构建
cd frontend && npm run build

# 后端开发（nodemon 热重载，默认端口 3000）
cd backend && npm run dev

# 后端生产启动
cd backend && npm start
```

## 项目架构

### 路由与页面流

```
/ (HomeView)  →  /game (GameView)  →  /result (ResultView)
   首页           游戏主页面           结果页面
```

所有路由通过 `vue-router` 懒加载（`() => import(...)`），定义在 `frontend/src/router/index.js`。

### 地图组件坐标系统

`CampusMap.vue` 是全项目最核心的组件，其坐标系统设计如下：

- **原始图片尺寸**: 7087×10630 像素（鼓楼校区地图，`frontend/src/assets/gulou_map.png`）
- **坐标转换**: 用户在屏幕上点击 → 通过 `getBoundingClientRect()` 获取显示尺寸 → 用 `原始尺寸/显示尺寸` 计算缩放比 → 得到原始图片坐标
- **标记层**: 使用 SVG `<circle>` 覆盖在地图上，通过 `viewBox` 匹配原始图片尺寸实现坐标对齐
- **连线**: 使用 SVG `<line>` 绘制猜测点与实际位置之间的虚线

`CampusMap.vue` 的 props/events 接口：
- Props: `mapImage`, `mapWidth`(默认7087), `mapHeight`(默认10630), `width`, `height`, `markers`(Array), `polyline`(Array), `clickable`
- Events: `@mapClick` → `{ x, y }`（原始图片坐标）

### 后端结构

后端目前是骨架阶段，`app.js` 只注册了 `cors`、`express.json()`、静态文件服务和一个 `/api/health` 健康检查端点。

规划的目录结构：
- `routes/` — 路由模块（当前为空）
- `models/` — 数据模型（当前为空）
- `middleware/` — 中间件，如 JWT 验证（当前为空）
- `scripts/` — 数据导入脚本
- `public/images/` — 校园实景照片

### 数据库

使用 MySQL，通过 `.env` 配置连接信息。数据库名为 `el_njuxun`。参考 `.env.example` 创建 `.env` 文件。

### 状态管理

项目引入了 Pinia，但目前尚未创建 store 文件。Store 文件应放在 `frontend/src/stores/` 目录下。

### 静态资源

- 前端地图图片: `frontend/src/assets/gulou_map.png`（鼓楼校区地图）
- 后端校园照片: `backend/public/images/`（待添加）
- 数据文件: `data/` 目录（待添加）
