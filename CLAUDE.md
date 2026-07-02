# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

南大图寻（NJUXun）— 2026 南京大学 EL 大赛交互组项目。玩家看到校园实景照片，在地图上点击猜测拍摄位置，系统根据实际坐标与猜测坐标的距离计算得分。每局 10 题，满分 1000 分。

## 技术栈

- **前端**: Vue 3 (Composition API) + Vite 5 + Vue Router 4 + Pinia 3 + Element Plus 2 + Axios
- **后端**: Node.js + Express 4 + MySQL (mysql2) + JWT 认证（jsonwebtoken + bcryptjs）
- **无 TypeScript**，全部使用纯 JavaScript

### 依赖注册状态

`frontend/src/main.js` 当前只注册了 `router`：

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

# 数据库初始化（建库 + 建表）
mysql -u root -p < backend/scripts/init_db.sql

# 导入种子数据（24 个校园地点）
mysql -u root -p njuxun < backend/scripts/seed_locations.sql
```

> **注意**：`.env` 被 `.gitignore` 忽略，首次使用需 `cp .env.example .env` 并填写实际 MySQL 密码和 JWT 密钥。后端启动依赖 `.env` 中的数据库连接信息。

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
| HomeView | 完整 | 首次进入弹出"玩家须知"（玩法+计分规则+开源地址），背景为南大校园照片，点击"开始探索"进入游戏 |
| GameView | 完整 | 10 轮游戏：左侧地图点击猜测 → 右侧展示实景照片 → 提交答案 → 显示得分+红蓝标记+亮紫色连线 → 下一题/查看结果 |
| ResultView | 完整 | 从 `sessionStorage` 读取结果，展示总分/均分/题数 + 每轮详情表格，支持再来一局/返回首页 |

### GameView 核心交互流程

1. `onMounted` → `restartGame()` 重置状态 → `fetchRandomLocation()` 获取题目
2. 用户点击地图 → `onMapClick(pos)` 存储坐标 → 蓝色猜测标记 + "提交答案"按钮
3. 点击"提交答案" → `submitGuess()` 计算像素距离 × 比例尺 → 分段计分 → 显示红色真实标记 + 亮紫色虚线连线
4. 点击"下一题" → `nextRound()` 递增轮次 → 重新获取题目
5. 第 10 题提交后 → `finishGame()` 将结果写入 `sessionStorage` → `router.push('/result')`

**计分公式**（距离 d 单位为米）：
- d≤10: 100 分；d≤50: 80~99；d≤100: 60~79；d≤200: 40~59；d≤500: 20~39；d≤1000: 1~19；d>1000: 0

**数据获取策略**：优先从后端 `GET /api/locations/random?exclude=id1,id2` 获取，3 秒超时或失败后降级到 `frontend/public/locations.json`（24 条本地数据）。使用 `image_url` 作为去重键。

### 地图组件坐标系统

`CampusMap.vue` 是全项目最核心的组件：

- **当前地图尺寸**: 2546×3914 像素（`frontend/src/assets/gulou_map.png`）
- **原始高清版**: `gulou_map_original_7087x10630.png` 也存在于 assets 中，但代码未使用
- **坐标转换**: 屏幕点击 → `getBoundingClientRect()` 获取图片显示尺寸 → `/scale` 消除缩放 → `×(mapWidth/renderedWidth)` 映射到原始像素坐标
- **比例尺**: 0.34608 米/像素（硬编码在 GameView 的 `submitGuess` 中）
- **标记层**: SVG `<circle>` 叠加在地图上，`viewBox` 匹配原始尺寸实现坐标对齐
- **连线**: SVG `<line>` — 带 `stroke-dasharray` 的亮紫色虚线

**缩放与平移功能**（2026-06 新增）：
- 鼠标滚轮缩放 / 双指捏合缩放（1×~5×）
- 鼠标拖拽平移 / 单指拖拽平移
- 缩放按钮（+/−/↺）位于地图右下角
- `DRAG_THRESHOLD = 5px` 区分拖动和点击
- `ResizeObserver` 监听容器尺寸变化自动重算布局

CampusMap props/events 接口：
- Props: `mapImage`, `mapWidth`(默认2546), `mapHeight`(默认3914), `width`, `height`, `markers`(Array of `{x,y,type}`), `polyline`(Array of `{x,y}` × 2), `clickable`
- Events: `@mapClick` → `{ x, y }`（原始图片像素坐标，已 clamp 到有效范围）

## 后端结构

### 实际状态（非骨架）

`backend/app.js` 注册了 `cors`、`express.json()`、静态文件服务、路由模块和 SPA fallback：

- `routes/locations.js` — `GET /api/locations/random?exclude=id1,id2`（随机取题，支持排除已选）
- `GET /api/health` — 健康检查（含 `SELECT 1` 数据库连通性验证）
- 生产环境托管 `frontend/dist/` 静态文件
- `GET *` SPA fallback — 非 `/api` 路由全部返回 `index.html`
- 监听 `0.0.0.0:PORT`（支持外部访问，默认 3000）

### 目录

```
backend/
├── routes/        — 路由模块（locations.js 已实现）
├── models/        — 数据模型（预留，当前为空）
├── middleware/     — 中间件（预留，当前为空，JWT 验证待实现）
├── config/        — database.js（mysql2 连接池，connectionLimit:10）
├── scripts/       — init_db.sql + seed_locations.sql（24 条种子数据）
└── public/images/ — 校园实景照片
```

### 数据库

MySQL 数据库名 `njuxun`，三张表（详见 `backend/scripts/init_db.sql`）：

- **users** — `id`, `username`(UNIQUE), `email`(UNIQUE), `password`, `total_score`, `games_played`, `created_at`
- **locations** — `id`, `name`, `description`, `px_x`, `px_y`, `image_url`, `difficulty`(TINYINT, 1~5), `area`, `created_at`
- **game_records** — `id`, `user_id`(FK→users CASCADE), `location_id`(FK→locations RESTRICT), `guess_px_x`, `guess_px_y`, `distance_meters`(DECIMAL(10,2)), `score`, `created_at`

> **坐标基准**: 所有 `px_x`/`px_y` 字段基于 2546×3914 像素地图。种子数据 24 条，坐标范围 x: 891~1980, y: 819~2332。

## 位置数据

两份数据文件，内容一致，修改时需保持同步：

1. `frontend/public/locations.json` — 前端 fallback，GameView 在后端不可用时直接 fetch 此文件
2. `backend/scripts/seed_locations.sql` — 数据库种子，导入 MySQL

## Vite 开发配置

`frontend/vite.config.js`：
- `/api` 请求代理到 `http://localhost:3000`（开发环境跨域方案）
- `allowedHosts` 含 ngrok 域名（内网穿透测试用）

## Nginx 生产部署

`nginx.conf` 位于项目根目录，将 80 端口反向代理到 `127.0.0.1:3000`。部署路径：`/etc/nginx/conf.d/njuxun.conf`。

## 当前待完成事项

- Pinia store 注册与创建（`main.js` 中 `createPinia()` + `app.use(pinia)`）
- Element Plus 注册（如需使用其组件）
- 用户认证（JWT middleware 尚未实现）
- 后端其他 API 端点（用户注册/登录、游戏记录保存/查询）
