# Hand-Drawn Map / 手绘地图

A comprehensive hand-drawn scenic map system supporting multi-platform deployment (H5, WeChat Mini Program, APP) with Vue 3 + TypeScript.

一个完整的手绘景区地图系统，支持多端部署（H5、微信小程序、APP），基于 Vue 3 + TypeScript。

## 📋 Project Overview / 项目概览

This repository contains:

### Current Implementation (v1.0)
A production-ready **Vue 3 + Vite + MapLibre GL JS** single-page application with:
- ✅ Interactive hand-drawn map display
- ✅ POI markers with bilingual popups
- ✅ Multi-modal route filtering
- ✅ Layer controls and statistics
- ✅ Responsive design

### Future Architecture (Documented)
Complete architecture documentation for **Vue 3 + uni-app + OpenLayers + PHP (Yaf)**:
- 📱 Multi-platform support (H5/WeChat/APP)
- 🔧 Backend API with PHP + Yaf
- 💾 MySQL database design
- 🎨 Admin management panel
- 🐳 Docker deployment

## 🚀 Quick Start / 快速开始

### Current Implementation

### Prerequisites / 前置要求

- Node.js (>= 18.x)
- npm or yarn

### Installation / 安装

1. Clone the repository / 克隆仓库：
```bash
git clone https://github.com/xiaochuniang/hand-drawn-map.git
cd hand-drawn-map
```

2. Install dependencies / 安装依赖：
```bash
npm install
```

3. Generate placeholder tiles (if not already generated) / 生成占位瓦片（如果尚未生成）：
```bash
npm run generate-tiles
```

4. Start the development server / 启动开发服务器：
```bash
npm run dev
```

5. Open your browser and navigate to the URL shown in the terminal (typically `http://localhost:5173`) / 打开浏览器访问终端显示的 URL（通常是 `http://localhost:5173`）

## Build for Production / 生产构建

Build the application for production / 构建生产版本：
```bash
npm run build
```

Preview the production build / 预览生产构建：
```bash
npm run preview
```

The built files will be in the `dist/` directory / 构建文件将位于 `dist/` 目录中。

## Project Structure / 项目结构

```
hand-drawn-map/
├── public/
│   └── tiles/              # Raster tiles directory / 栅格瓦片目录
│       └── {z}/{x}/{y}.svg # Tile files / 瓦片文件
├── scripts/
│   └── generate-tiles.cjs  # Tile generation script / 瓦片生成脚本
├── src/
│   ├── components/
│   │   └── MapView.vue     # Main map component / 主地图组件
│   ├── config/
│   │   └── mapConfig.ts    # Map configuration / 地图配置
│   ├── data/
│   │   ├── pois.geojson    # POI data / 兴趣点数据
│   │   ├── viewpoints.geojson # Viewpoint data / 观景点数据
│   │   └── routes.geojson  # Route data / 路线数据
│   ├── i18n/
│   │   ├── index.ts        # i18n setup / 国际化设置
│   │   └── messages.ts     # Translation messages / 翻译文本
│   ├── App.vue             # Root component / 根组件
│   ├── main.ts             # Application entry / 应用入口
│   └── style.css           # Global styles / 全局样式
├── package.json
├── vite.config.ts          # Vite configuration / Vite 配置
└── README.md
```

## Customization / 自定义

### Replacing Placeholder Tiles / 替换占位瓦片

To replace the placeholder tiles with your own hand-drawn tiles / 要替换占位瓦片为您自己的手绘瓦片：

1. Prepare your raster tiles in the format `{z}/{x}/{y}.png` or `{z}/{x}/{y}.svg` / 准备您的栅格瓦片，格式为 `{z}/{x}/{y}.png` 或 `{z}/{x}/{y}.svg`
2. Place them in the `public/tiles/` directory / 将它们放在 `public/tiles/` 目录中
3. Update the tile configuration in `src/config/mapConfig.ts` / 更新 `src/config/mapConfig.ts` 中的瓦片配置：
   - `tileUrl`: Change the file extension if needed (e.g., `.png` instead of `.svg`) / 如需要更改文件扩展名（例如 `.png` 而不是 `.svg`）
   - `tileSize`: Set to your tile size (typically 256 or 512) / 设置为您的瓦片大小（通常为 256 或 512）
   - `minZoom` and `maxZoom`: Set to your tile zoom range / 设置为您的瓦片缩放范围

Example / 示例:
```typescript
export const mapConfig: MapConfig = {
  tileUrl: '/tiles/{z}/{x}/{y}.png', // Changed to .png / 改为 .png
  tileSize: 256,
  minZoom: 0,
  maxZoom: 18, // Extended zoom range / 扩展缩放范围
  // ... other settings
};
```

### Updating Map Bounds / 更新地图边界

Update the bbox in `src/config/mapConfig.ts` to match your map area / 更新 `src/config/mapConfig.ts` 中的 bbox 以匹配您的地图区域：

```typescript
bbox: {
  west: -180,   // Western longitude / 西经
  south: -85,   // Southern latitude / 南纬
  east: 180,    // Eastern longitude / 东经
  north: 85     // Northern latitude / 北纬
},
initialCenter: [0, 0],  // [longitude, latitude] / [经度, 纬度]
initialZoom: 1,         // Initial zoom level / 初始缩放级别
```

### Updating Data / 更新数据

Edit the GeoJSON files in `public/` to add or modify features / 编辑 `public/` 中的 GeoJSON 文件以添加或修改要素：

- **POIs** (`pois.geojson`): Points of Interest / 兴趣点
- **Viewpoints** (`viewpoints.geojson`): Scenic viewpoints / 观景点
- **Routes** (`routes.geojson`): Walking, biking, and boat routes / 步行、骑行和船只路线

Each feature should include bilingual properties / 每个要素应包含双语属性：
- `name_zh` / `name_en`: Name in Chinese/English / 中英文名称
- `desc_zh` / `desc_en`: Description in Chinese/English / 中英文描述
- For routes / 对于路线：
  - `mode`: `walk`, `bike`, or `boat` / 交通方式：步行、骑行或船只
  - `duration_min`: Duration in minutes / 持续时间（分钟）
  - `distance_km`: Distance in kilometers / 距离（公里）
  - `highlight_ids`: Array of POI/viewpoint IDs along the route / 路线沿途的兴趣点/观景点 ID 数组

## 📚 Full-Stack Architecture / 完整架构

For implementing a complete production system with backend, multi-platform support, and admin panel, see:

完整生产系统的实现（包含后端、多端支持、后台管理），请参阅：

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Complete system architecture / 完整系统架构
  - Frontend: Vue 3 + uni-app (H5/WeChat/APP)
  - Backend: PHP + Yaf framework
  - Database: MySQL + Redis
  - Admin panel: Vue 3
  - Docker deployment

- **[docs/IMPLEMENTATION.md](./docs/IMPLEMENTATION.md)** - Step-by-step implementation guide / 分步实施指南
  - 8-phase implementation plan
  - Cost estimation
  - Development roadmap

- **[docs/MIGRATION_GUIDE.md](./docs/MIGRATION_GUIDE.md)** - Migration from current to full architecture / 从当前实现迁移到完整架构
  - Gradual migration strategy
  - Data migration scripts
  - API integration

- **[database/schema.sql](./database/schema.sql)** - Complete database schema / 完整数据库结构

## Technologies Used / 使用的技术

### Current Implementation
- **Vue 3** - Progressive JavaScript framework / 渐进式 JavaScript 框架
- **Vite** - Next generation frontend tooling / 下一代前端构建工具
- **TypeScript** - Typed superset of JavaScript / JavaScript 的类型化超集
- **MapLibre GL JS** - Open-source mapping library / 开源地图库
- **vue-i18n** - Internationalization plugin for Vue.js / Vue.js 国际化插件

### Full Architecture (Documented)
- **uni-app** - Multi-platform development framework / 多端开发框架
- **OpenLayers** - Map rendering engine (alternative) / 地图渲染引擎（可选）
- **PHP + Yaf** - Backend framework / 后端框架
- **MySQL + Redis** - Database and cache / 数据库与缓存
- **Docker** - Containerization / 容器化部署

## License / 许可证

This project is open source and available under the MIT License.

本项目是开源的，采用 MIT 许可证。

## Contributing / 贡献

Contributions are welcome! Please feel free to submit a Pull Request.

欢迎贡献！请随时提交 Pull Request。

