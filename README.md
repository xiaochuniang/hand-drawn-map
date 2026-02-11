# Hand-Drawn Map / 手绘地图

A Vue 3 + Vite + TypeScript single-page interactive map application using MapLibre GL JS, featuring hand-drawn watercolor-style basemap with bilingual support (Chinese/English).

一个基于 Vue 3 + Vite + TypeScript 的单页面交互地图应用，使用 MapLibre GL JS，支持手绘水彩风格底图和中英双语切换。

## Features / 特性

- 🗺️ **Hand-Drawn Basemap** - Raster tile-based map with watercolor-style placeholder tiles / 基于栅格瓦片的手绘水彩风格底图
- 🌍 **Bilingual Support** - Chinese and English UI with vue-i18n / 使用 vue-i18n 实现中英文双语界面
- 📍 **POI Markers** - Points of Interest with interactive popups / 兴趣点标记，支持交互式弹窗
- 🏔️ **Viewpoints** - Scenic viewpoint markers / 观景点标记
- 🚶 **Multi-Modal Routes** - Walking, biking, and boat routes with filtering / 支持步行、骑行、船只等多种交通方式路线及筛选
- 📊 **Route Statistics** - Display total duration and distance for selected routes / 显示选中路线的总时长和总距离
- 🎛️ **Layer Controls** - Toggle visibility of different map layers / 图层开关控制
- 🔄 **Configurable Bounds** - Centralized bbox configuration for map bounds / 集中配置地图边界

## Getting Started / 快速开始

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

Edit the GeoJSON files in `src/data/` to add or modify features / 编辑 `src/data/` 中的 GeoJSON 文件以添加或修改要素：

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

## Technologies Used / 使用的技术

- **Vue 3** - Progressive JavaScript framework / 渐进式 JavaScript 框架
- **Vite** - Next generation frontend tooling / 下一代前端构建工具
- **TypeScript** - Typed superset of JavaScript / JavaScript 的类型化超集
- **MapLibre GL JS** - Open-source mapping library / 开源地图库
- **vue-i18n** - Internationalization plugin for Vue.js / Vue.js 国际化插件

## License / 许可证

This project is open source and available under the MIT License.

本项目是开源的，采用 MIT 许可证。

## Contributing / 贡献

Contributions are welcome! Please feel free to submit a Pull Request.

欢迎贡献！请随时提交 Pull Request。

