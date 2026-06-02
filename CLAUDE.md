# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

南大图寻（NJUXun）— 2026 南京大学 EL 大赛交互组项目。一个基于校园地图照片的定位猜测游戏：玩家看到一张校园实景照片，在地图上点击猜测拍摄位置，系统根据实际坐标与猜测坐标的距离计算得分。

## 技术栈

- **前端**: Vue 3 (Composition API) + Vite 5 + Vue Router 4 + Pinia 3 + Element Plus 2 + Axios
- **后端**: Node.js + Express 4 + MySQL (mysql2) + JWT 认证
- **无 TypeScript**，全部使用纯 JavaScript

### 依赖注册状态

`frontend/src/main.js` 当前只注册了 `router`。以下依赖的实际状态：

- **Vue Router** ✅ 已注册（`app.use(router)`）
- **Pinia** ❌ 仅安装，未 `createPinia()` / `app.use(pinia)`，stores 目录为空
- **Element Plus** ❌ 仅安装，未 `import` 样式 / `app.use(ElementPlus)`

在组件中使用 `<el-button>` 等 Element Plus 组件或 `useStore()` 之前，需先在 `main.js` 中完成对应注册。

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

# 数据库初始化（首次使用）
mysql -u root -p < backend/scripts/init_db.sql
```

> **注意**：`.env` 被 `.gitignore` 忽略，首次使用需 `cp .env.example .env` 并填写实际数据库密码和 JWT 密钥。后端启动依赖 `.env` 中的数据库连接信息。

## 项目架构

### 路由与页面流

```
/ (HomeView)  →  /game (GameView)  →  /result (ResultView)
   首页           游戏主页面           结果页面
```

所有路由通过 `vue-router` 懒加载（`() => import(...)`），定义在 `frontend/src/router/index.js`。

### 各页面当前状态

| 页面 | 状态 | 说明 |
|------|------|------|
| HomeView | 骨架 | 标题 + "开始探索"按钮（`<router-link>` 到 `/game`） |
| GameView | 基础可用 | 地图点击 → 坐标捕获 → 蓝色标记显示 → `submitGuess()` 弹出 alert；照片区域为占位文字 |
| ResultView | 占位 | 仅标题和一句描述文字 |

GameView 的核心交互流程已通：`CampusMap` 的 `@mapClick` → `onMapClick(pos)` 存储坐标 → computed `markers` 生成蓝色猜测标记 → 点击"提交答案"调用 `submitGuess()`（当前仅 `alert`，待接入后端 API）。

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

使用 MySQL，数据库名 `njuxun`。初始化脚本：`backend/scripts/init_db.sql`。通过 `.env` 配置连接信息，参考 `.env.example` 创建 `.env`。

三张核心表结构：

**users** — 用户表
`id`(PK, AUTO_INCREMENT), `username`(VARCHAR(100), UNIQUE, NOT NULL), `email`(VARCHAR(255), UNIQUE, NOT NULL), `password`(VARCHAR(255), NOT NULL), `total_score`(INT, DEFAULT 0), `games_played`(INT, DEFAULT 0), `created_at`(DATETIME, DEFAULT CURRENT_TIMESTAMP)

**locations** — 地点/题目表
`id`(PK, AUTO_INCREMENT), `name`(VARCHAR(100), NOT NULL), `description`(TEXT), `px_x`(INT, NOT NULL), `px_y`(INT, NOT NULL), `image_url`(VARCHAR(255), NOT NULL), `difficulty`(TINYINT, DEFAULT 3), `area`(VARCHAR(50)), `created_at`(DATETIME, DEFAULT CURRENT_TIMESTAMP)

**game_records** — 游戏记录表
`id`(PK, AUTO_INCREMENT), `user_id`(INT, NOT NULL, FK→users.id ON DELETE CASCADE), `location_id`(INT, NOT NULL, FK→locations.id ON DELETE RESTRICT), `guess_px_x`(INT, NOT NULL), `guess_px_y`(INT, NOT NULL), `distance_meters`(DECIMAL(10,2), NOT NULL), `score`(INT, NOT NULL), `created_at`(DATETIME, DEFAULT CURRENT_TIMESTAMP)

> 坐标字段（`px_x`, `px_y`, `guess_px_x`, `guess_px_y`）均为原始图片像素坐标，基准尺寸 7087×10630。非经纬度。

### 状态管理

项目引入了 Pinia，但目前尚未创建 store 文件。Store 文件应放在 `frontend/src/stores/` 目录下。

### 静态资源

- 前端地图图片: `frontend/src/assets/gulou_map.png`（鼓楼校区地图）
- 后端校园照片: `backend/public/images/`（待添加）
- 数据文件: `data/` 目录（待添加）
