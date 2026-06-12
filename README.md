# NJUXun — 南大图寻

2026 南京大学 EL 大赛交互组参赛作品。

**官方网址：** http://njuxun.top

## 项目简介

**南大图寻** 是一个基于校园地图照片的定位猜测游戏。玩家在游戏中看到一张校园实景照片，需要在地图上点击猜测拍摄位置——猜得越准、得分越高。系统根据实际坐标与猜测坐标的直线距离计算得分。

核心玩法：

1. 系统展示一张南京大学鼓楼校区的实景照片
2. 玩家在校园地图上点击猜测这张照片是在哪里拍的
3. 系统在地图上同时显示**真实位置**（红点）和**猜测位置**（蓝点），并用虚线连接
4. 根据两点之间的实际距离计算本次得分
5. 累计总分，支持多轮游戏

## 技术栈

| 类型 | 技术 |
|------|------|
| 前端框架 | Vue 3 (Composition API) |
| 构建工具 | Vite 5 |
| 路由 | Vue Router 4 |
| 状态管理 | Pinia 3 |
| UI 组件库 | Element Plus 2 |
| HTTP 客户端 | Axios |
| 后端框架 | Node.js + Express 4 |
| 数据库 | MySQL |
| 数据库驱动 | mysql2 |
| 认证 | JWT（jsonwebtoken） |
| 开发热重载 | nodemon（后端） |

> 项目全部使用纯 JavaScript，无 TypeScript。

## 项目结构

```
njuxun/
├── frontend/                 # Vue 3 前端
│   ├── src/
│   │   ├── components/       # 公共组件（核心：CampusMap 地图组件）
│   │   ├── views/            # 页面组件（HomeView / GameView / ResultView）
│   │   ├── router/           # 路由配置（Vue Router，懒加载）
│   │   ├── stores/           # Pinia 状态管理
│   │   ├── utils/            # 工具函数
│   │   └── assets/           # 静态资源（含鼓楼校区地图 gulou_map.png）
│   ├── public/               # 公共资源
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
├── backend/                  # Node.js 后端
│   ├── routes/               # 路由模块（API 端点）
│   ├── models/               # 数据模型（与数据库表对应）
│   ├── middleware/            # 中间件（JWT 验证等）
│   ├── scripts/              # 脚本（含数据库初始化脚本）
│   │   └── init_db.sql       # 建库建表 SQL
│   ├── public/images/        # 校园实景照片
│   ├── app.js                # Express 入口
│   └── package.json
├── data/                     # 数据文件
├── docs/                     # 文档
├── .env.example              # 环境变量模板
└── README.md
```

页面路由

```
/ (HomeView)  →  /game (GameView)  →  /result (ResultView)
   首页            游戏主页面             结果页面
```

| 路由 | 页面 | 功能 |
|------|------|------|
| `/` | HomeView | 首页，展示游戏简介和开始入口 |
| `/game` | GameView | 游戏主页面，展示照片 + 地图交互 |
| `/result` | ResultView | 结果页面，展示猜测结果与得分 |

所有路由通过 `vue-router` 懒加载（`() => import(...)`），定义在 `frontend/src/router/index.js`。

## 地图坐标系统

`CampusMap` 组件是项目最核心的组件，其坐标系统设计如下：

- **原始图片尺寸**：2546×3914 像素（鼓楼校区地图）
- **坐标单位**：以原始图片像素为坐标单位（非经纬度）
- **坐标转换流程**：屏幕点击 → `getBoundingClientRect()` 获取显示尺寸 → `原始尺寸 / 显示尺寸` 计算缩放比 → 得到原始图片坐标
- **标记渲染**：使用 SVG `<circle>` 叠加在地图上，通过 `viewBox="0 0 7087 10630"` 匹配原始图片尺寸实现坐标对齐
- **连线绘制**：使用 SVG `<line>` 在猜测点和真实位置之间绘制虚线

> 所有涉及地图坐标的计算都应以原始图片像素（2546×3914）为基准。

## 快速开始

### 环境配置

```bash
# 1. 创建环境变量文件
cp .env.example .env

# 2. 编辑 .env，填入你的 MySQL 密码和 JWT 密钥
# DB_PASSWORD=你的MySQL密码
# JWT_SECRET=一个随机字符串
```

### 安装依赖

```bash
# 前端
cd frontend && npm install

# 后端
cd backend && npm install
```

### 启动开发服务器

```bash
# 前端（Vite dev server，默认 http://localhost:5173）
cd frontend && npm run dev

# 后端（nodemon 热重载，默认 http://localhost:3000）
cd backend && npm run dev
```

### 验证

浏览器打开 `http://localhost:5173` 查看前端页面；访问 `http://localhost:3000/api/health` 检查后端健康状态。

## 当前待办（2026/6/10 upd）

- Pinia store 注册与创建（`main.js` 中 `createPinia()` + `app.use(pinia)`）
- Element Plus 注册（如需使用其组件）
- 用户认证（JWT middleware 尚未实现）
- 后端其他 API 端点（用户注册/登录、游戏记录保存/查询）

## 部署指南

基于 **Ubuntu 20.04/22.04**，需预装 Node.js ≥18、MySQL ≥8.0、PM2、Nginx、Git。

### 首次部署

```bash
# 1. 克隆项目并配置环境变量
git clone <your-repo-url> /opt/njuxun && cd /opt/njuxun
cp .env.example .env            # 编辑填入 MySQL 密码和 JWT 密钥

# 2. 修改 nginx.conf 中的 server_name 为你的域名或 IP

# 3. 一键部署（建库 → 种子数据 → Nginx → 依赖 → 构建 → 启动）
bash deploy.sh --setup

# 4. 设置开机自启（按提示执行输出的命令）
pm2 startup

# 5. 验证
curl http://localhost:3000/api/health
```

浏览器访问 `http://<你的IP或域名>` 即可。

### 后续更新

```bash
cd /opt/njuxun && bash deploy.sh    # git pull → 安装依赖 → 构建 → 重启
```

---

## 许可证

本项目基于 [MIT License](LICENSE) 开源。