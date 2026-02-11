# 手绘景区地图系统 - 完整项目架构

## 项目概述

基于 Vue3 + uni-app + OpenLayers + PHP(Yaf) 的手绘景区地图系统，支持多端部署（H5、微信小程序、APP），提供景区地图展示、POI管理、路线规划、后台管理等功能。

## 技术栈

### 前端
- **框架**: Vue 3 + TypeScript
- **多端方案**: uni-app (支持 H5/微信小程序/APP)
- **构建工具**: Vite
- **地图引擎**: OpenLayers 7.x
- **状态管理**: Pinia
- **UI 框架**: uni-ui / uView UI
- **网络请求**: uni.request (封装 axios 风格)

### 后端
- **语言**: PHP 7.4+
- **框架**: Yaf 3.x
- **数据库**: MySQL 5.7+
- **缓存**: Redis 5.x
- **文件存储**: 阿里云 OSS / 七牛云
- **API 文档**: Swagger/OpenAPI

### 部署
- **Web 服务器**: Nginx
- **PHP**: PHP-FPM
- **CDN**: 阿里云/腾讯云 CDN
- **容器化**: Docker + Docker Compose

## 项目目录结构

```
hand-drawn-map/
├── frontend/                           # 前端项目（uni-app）
│   ├── src/
│   │   ├── pages/                     # 页面
│   │   │   ├── index/                 # 首页（地图展示）
│   │   │   │   ├── index.vue
│   │   │   │   └── index.scss
│   │   │   ├── poi/                   # POI详情页
│   │   │   ├── route/                 # 路线规划页
│   │   │   └── search/                # 搜索页
│   │   ├── components/                # 组件
│   │   │   ├── MapView/              # 地图组件（核心）
│   │   │   │   ├── MapView.vue
│   │   │   │   ├── MapControls.vue   # 地图控制器
│   │   │   │   ├── POIMarker.vue     # POI标记
│   │   │   │   └── RouteLayer.vue    # 路线图层
│   │   │   ├── POICard/              # POI卡片
│   │   │   └── SearchBar/            # 搜索栏
│   │   ├── store/                     # 状态管理
│   │   │   ├── index.ts
│   │   │   ├── modules/
│   │   │   │   ├── map.ts            # 地图状态
│   │   │   │   ├── poi.ts            # POI数据
│   │   │   │   └── route.ts          # 路线数据
│   │   ├── api/                       # API接口
│   │   │   ├── index.ts
│   │   │   ├── map.ts
│   │   │   ├── poi.ts
│   │   │   └── route.ts
│   │   ├── utils/                     # 工具函数
│   │   │   ├── request.ts            # 网络请求封装
│   │   │   ├── coordinate.ts         # 坐标转换
│   │   │   ├── map-utils.ts          # 地图工具
│   │   │   └── storage.ts            # 本地存储
│   │   ├── types/                     # TypeScript类型定义
│   │   │   ├── map.d.ts
│   │   │   ├── poi.d.ts
│   │   │   └── api.d.ts
│   │   ├── config/                    # 配置文件
│   │   │   ├── map.config.ts         # 地图配置
│   │   │   └── api.config.ts         # API配置
│   │   ├── static/                    # 静态资源
│   │   │   ├── tiles/                # 地图瓦片
│   │   │   ├── icons/                # 图标
│   │   │   └── images/               # 图片
│   │   ├── App.vue
│   │   ├── main.ts
│   │   ├── pages.json                # uni-app页面配置
│   │   ├── manifest.json             # uni-app应用配置
│   │   └── uni.scss                  # 全局样式
│   ├── vite.config.ts
│   ├── tsconfig.json
│   └── package.json
│
├── backend/                           # 后端项目（PHP + Yaf）
│   ├── application/
│   │   ├── Bootstrap.php             # 引导类
│   │   ├── controllers/              # 控制器
│   │   │   ├── Api/                  # API控制器
│   │   │   │   ├── MapController.php
│   │   │   │   ├── PoiController.php
│   │   │   │   ├── RouteController.php
│   │   │   │   └── UserController.php
│   │   │   └── Admin/                # 后台管理控制器
│   │   │       ├── MapController.php
│   │   │       ├── PoiController.php
│   │   │       └── SystemController.php
│   │   ├── models/                   # 模型
│   │   │   ├── Map.php
│   │   │   ├── Poi.php
│   │   │   ├── Route.php
│   │   │   ├── Category.php
│   │   │   └── User.php
│   │   ├── services/                 # 服务层
│   │   │   ├── MapService.php
│   │   │   ├── PoiService.php
│   │   │   ├── RouteService.php
│   │   │   ├── CoordinateService.php # 坐标转换服务
│   │   │   └── UploadService.php     # 文件上传服务
│   │   ├── library/                  # 类库
│   │   │   ├── Database/             # 数据库封装
│   │   │   ├── Cache/                # 缓存封装
│   │   │   ├── Response/             # 响应处理
│   │   │   └── Validator/            # 验证器
│   │   ├── plugins/                  # 插件
│   │   │   ├── AuthPlugin.php        # 认证插件
│   │   │   └── LogPlugin.php         # 日志插件
│   │   └── views/                    # 视图（如需要）
│   ├── conf/
│   │   ├── application.ini           # 应用配置
│   │   ├── routes.php                # 路由配置
│   │   └── database.php              # 数据库配置
│   ├── public/
│   │   ├── index.php                 # 入口文件
│   │   └── .htaccess
│   ├── tests/                        # 测试
│   └── composer.json
│
├── admin/                             # 后台管理前端（Vue3）
│   ├── src/
│   │   ├── views/                    # 视图
│   │   │   ├── map/                  # 地图管理
│   │   │   ├── poi/                  # POI管理
│   │   │   ├── route/                # 路线管理
│   │   │   └── system/               # 系统设置
│   │   ├── components/               # 组件
│   │   ├── api/                      # API
│   │   ├── router/                   # 路由
│   │   ├── store/                    # 状态管理
│   │   └── main.ts
│   ├── vite.config.ts
│   └── package.json
│
├── database/                          # 数据库
│   ├── migrations/                   # 迁移文件
│   ├── seeds/                        # 种子数据
│   └── schema.sql                    # 数据库结构
│
├── docs/                              # 文档
│   ├── api/                          # API文档
│   │   ├── map.md
│   │   ├── poi.md
│   │   └── route.md
│   ├── deployment.md                 # 部署文档
│   └── development.md                # 开发文档
│
├── scripts/                           # 脚本
│   ├── tile-generator/               # 瓦片生成脚本
│   ├── deploy.sh                     # 部署脚本
│   └── backup.sh                     # 备份脚本
│
├── docker/                            # Docker配置
│   ├── nginx/
│   │   └── nginx.conf
│   ├── php/
│   │   └── Dockerfile
│   ├── mysql/
│   │   └── init.sql
│   └── docker-compose.yml
│
└── README.md
```

## 核心功能模块

### 1. 地图展示模块
- **手绘地图加载**: 支持瓦片地图和单张大图两种模式
- **缩放与平移**: 流畅的地图交互体验
- **图层管理**: 底图层、POI层、路线层、设施层
- **坐标映射**: 像素坐标与真实GPS坐标的转换

### 2. POI管理模块
- **POI标注**: 景点、设施（厕所、餐厅、停车场）
- **分类管理**: 按类型分类显示POI
- **详情展示**: 名称、描述、图片、开放时间、价格
- **搜索功能**: 按名称、类型搜索POI
- **语音讲解**: 景点语音介绍（可选）

### 3. 路线规划模块
- **起点终点选择**: 用户选择起点和目的地
- **路径算法**: Dijkstra算法计算最短路径
- **路线展示**: 在地图上绘制路线
- **导航指引**: 文字+箭头指引
- **多种交通方式**: 步行、观光车、自驾

### 4. 后台管理模块
- **地图管理**: 上传/更新手绘地图，设置地图边界
- **POI管理**: CRUD操作，拖拽调整位置
- **路线管理**: 编辑路线节点，设置权重
- **用户管理**: 用户权限控制
- **数据统计**: 访问量、热门景点统计

## 数据库设计

详见 `database/schema.sql`

### 核心表结构

```sql
-- 地图表
maps (id, name, bounds, tile_url, created_at, updated_at)

-- POI表
pois (id, map_id, category_id, name, name_en, description, description_en, 
      latitude, longitude, pixel_x, pixel_y, images, open_time, price, 
      audio_url, status, created_at, updated_at)

-- POI分类表
poi_categories (id, name, name_en, icon, sort, status)

-- 路线表
routes (id, map_id, name, description, mode, distance, duration, 
        path_nodes, created_at, updated_at)

-- 路网节点表
road_nodes (id, map_id, node_name, latitude, longitude, pixel_x, pixel_y)

-- 路网边表
road_edges (id, from_node_id, to_node_id, distance, weight, road_type)

-- 用户表
users (id, username, password, role, created_at, updated_at)
```

## API接口设计

### 基础接口规范
- **Base URL**: `https://api.example.com/v1`
- **认证方式**: JWT Token
- **响应格式**: JSON
- **状态码**: 遵循HTTP标准

### 主要接口

#### 地图相关
```
GET  /api/map/info           # 获取地图基本信息
GET  /api/map/tiles/{z}/{x}/{y}  # 获取地图瓦片
GET  /api/map/bounds         # 获取地图边界
```

#### POI相关
```
GET    /api/pois             # 获取POI列表
GET    /api/pois/{id}        # 获取POI详情
GET    /api/pois/search      # 搜索POI
GET    /api/pois/categories  # 获取POI分类
```

#### 路线相关
```
POST   /api/routes/plan      # 路线规划
GET    /api/routes/{id}      # 获取路线详情
GET    /api/routes/recommend # 获取推荐路线
```

#### 后台管理接口
```
POST   /admin/login          # 管理员登录
POST   /admin/pois           # 创建POI
PUT    /admin/pois/{id}      # 更新POI
DELETE /admin/pois/{id}      # 删除POI
POST   /admin/upload         # 上传文件
```

详细接口文档见 `docs/api/`

## 开发流程

### 环境准备

1. **安装依赖**
```bash
# 前端
cd frontend
npm install

# 后端
cd backend
composer install

# 后台管理
cd admin
npm install
```

2. **配置数据库**
```bash
# 创建数据库
mysql -u root -p < database/schema.sql

# 导入测试数据
mysql -u root -p < database/seeds/test_data.sql
```

3. **配置环境变量**
```bash
# 复制配置文件
cp backend/conf/application.ini.example backend/conf/application.ini

# 修改数据库配置
vim backend/conf/application.ini
```

### 本地开发

```bash
# 启动前端开发服务器（uni-app H5模式）
cd frontend
npm run dev:h5

# 启动PHP开发服务器
cd backend
php -S localhost:8080 -t public

# 启动后台管理开发服务器
cd admin
npm run dev
```

### 小程序开发

```bash
# 微信小程序
cd frontend
npm run dev:mp-weixin

# 然后用微信开发者工具打开 frontend/dist/dev/mp-weixin
```

## 部署指南

### Docker部署（推荐）

```bash
# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 手动部署

详见 `docs/deployment.md`

## 核心技术实现

### 1. OpenLayers集成（uni-app）

由于uni-app不直接支持OpenLayers，需要使用H5模式或者使用Web-View组件：

```typescript
// frontend/src/components/MapView/MapView.vue
<template>
  <view class="map-container">
    <!-- #ifdef H5 -->
    <web-view :src="mapUrl" @message="handleMapMessage"></web-view>
    <!-- #endif -->
    
    <!-- #ifdef MP-WEIXIN -->
    <web-view :src="mapUrl" @message="handleMapMessage"></web-view>
    <!-- #endif -->
    
    <!-- #ifdef APP-PLUS -->
    <web-view :src="mapUrl" @message="handleMapMessage"></web-view>
    <!-- #endif -->
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const mapUrl = ref('/static/map/index.html') // OpenLayers地图页面

const handleMapMessage = (e: any) => {
  // 处理地图事件
  const { type, data } = e.detail.data[0]
  
  switch (type) {
    case 'poiClick':
      // 处理POI点击
      break
    case 'mapMove':
      // 处理地图移动
      break
  }
}
</script>
```

### 2. 坐标转换实现

```typescript
// frontend/src/utils/coordinate.ts
export interface PixelCoordinate {
  x: number
  y: number
}

export interface GeoCoordinate {
  longitude: number
  latitude: number
}

export class CoordinateConverter {
  private bounds: {
    minLng: number
    maxLng: number
    minLat: number
    maxLat: number
  }
  
  private imageSize: {
    width: number
    height: number
  }
  
  constructor(bounds: any, imageSize: any) {
    this.bounds = bounds
    this.imageSize = imageSize
  }
  
  // 像素坐标转GPS坐标
  pixelToGeo(pixel: PixelCoordinate): GeoCoordinate {
    const { x, y } = pixel
    const { minLng, maxLng, minLat, maxLat } = this.bounds
    const { width, height } = this.imageSize
    
    const longitude = minLng + (x / width) * (maxLng - minLng)
    const latitude = maxLat - (y / height) * (maxLat - minLat)
    
    return { longitude, latitude }
  }
  
  // GPS坐标转像素坐标
  geoToPixel(geo: GeoCoordinate): PixelCoordinate {
    const { longitude, latitude } = geo
    const { minLng, maxLng, minLat, maxLat } = this.bounds
    const { width, height } = this.imageSize
    
    const x = ((longitude - minLng) / (maxLng - minLng)) * width
    const y = ((maxLat - latitude) / (maxLat - minLat)) * height
    
    return { x, y }
  }
}
```

### 3. 路径规划算法（PHP）

```php
// backend/application/services/RouteService.php
class RouteService {
    
    /**
     * Dijkstra算法计算最短路径
     */
    public function calculateShortestPath($fromNodeId, $toNodeId) {
        $graph = $this->buildGraph();
        $distances = [];
        $previous = [];
        $queue = new PriorityQueue();
        
        // 初始化
        foreach ($graph as $nodeId => $edges) {
            $distances[$nodeId] = PHP_INT_MAX;
            $previous[$nodeId] = null;
        }
        
        $distances[$fromNodeId] = 0;
        $queue->insert($fromNodeId, 0);
        
        // Dijkstra主循环
        while (!$queue->isEmpty()) {
            $currentNode = $queue->extract();
            
            if ($currentNode === $toNodeId) {
                break;
            }
            
            foreach ($graph[$currentNode] as $neighbor => $weight) {
                $alt = $distances[$currentNode] + $weight;
                
                if ($alt < $distances[$neighbor]) {
                    $distances[$neighbor] = $alt;
                    $previous[$neighbor] = $currentNode;
                    $queue->insert($neighbor, $alt);
                }
            }
        }
        
        // 构建路径
        $path = [];
        $current = $toNodeId;
        while ($current !== null) {
            array_unshift($path, $current);
            $current = $previous[$current];
        }
        
        return [
            'path' => $path,
            'distance' => $distances[$toNodeId],
            'nodes' => $this->getPathNodes($path)
        ];
    }
    
    /**
     * 构建路网图
     */
    private function buildGraph() {
        $edges = RoadEdges::findAll();
        $graph = [];
        
        foreach ($edges as $edge) {
            if (!isset($graph[$edge->from_node_id])) {
                $graph[$edge->from_node_id] = [];
            }
            $graph[$edge->from_node_id][$edge->to_node_id] = $edge->weight;
        }
        
        return $graph;
    }
}
```

### 4. 地图瓦片切片脚本

```javascript
// scripts/tile-generator/generate-tiles.js
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const TILE_SIZE = 256;
const ZOOM_LEVELS = [0, 1, 2, 3, 4];

async function generateTiles(inputImage, outputDir) {
  const image = sharp(inputImage);
  const metadata = await image.metadata();
  
  for (const zoom of ZOOM_LEVELS) {
    const scale = Math.pow(2, zoom);
    const scaledWidth = TILE_SIZE * scale;
    const scaledHeight = TILE_SIZE * scale;
    
    // 缩放图片
    const resized = await image
      .resize(scaledWidth, scaledHeight, { fit: 'fill' })
      .toBuffer();
    
    // 切割成瓦片
    for (let x = 0; x < scale; x++) {
      for (let y = 0; y < scale; y++) {
        const left = x * TILE_SIZE;
        const top = y * TILE_SIZE;
        
        const tileDir = path.join(outputDir, String(zoom), String(x));
        fs.mkdirSync(tileDir, { recursive: true });
        
        await sharp(resized)
          .extract({
            left,
            top,
            width: TILE_SIZE,
            height: TILE_SIZE
          })
          .toFile(path.join(tileDir, `${y}.png`));
        
        console.log(`Generated tile: ${zoom}/${x}/${y}`);
      }
    }
  }
}

// 使用方法
generateTiles('./input/scenic-map.png', './output/tiles');
```

## 性能优化

### 前端优化
1. **图片懒加载**: 非视野内的POI图标延迟加载
2. **瓦片缓存**: 使用uni.setStorage缓存已加载的瓦片
3. **防抖节流**: 地图移动事件使用节流
4. **虚拟列表**: POI列表使用虚拟滚动

### 后端优化
1. **Redis缓存**: 缓存POI数据、地图配置
2. **数据库索引**: 为经纬度字段建立空间索引
3. **CDN加速**: 静态资源使用CDN分发
4. **API限流**: 防止接口被恶意调用

## 测试

### 前端测试
```bash
cd frontend
npm run test:unit  # 单元测试
npm run test:e2e   # E2E测试
```

### 后端测试
```bash
cd backend
composer test      # PHPUnit测试
```

## 常见问题

### 1. uni-app如何使用OpenLayers？
使用Web-View组件加载独立的OpenLayers页面，通过postMessage通信。

### 2. 如何处理坐标偏差？
使用CoordinateConverter进行坐标转换，配合多点校准提高精度。

### 3. 小程序如何实现离线地图？
使用小程序的本地存储API缓存瓦片，但受存储限制（小程序最大10MB）。

### 4. 如何优化大图加载？
使用瓦片切片方案，按需加载可视区域的瓦片。

## 参考资料

- [OpenLayers官方文档](https://openlayers.org/)
- [uni-app官方文档](https://uniapp.dcloud.net.cn/)
- [Yaf框架文档](https://www.php.net/manual/zh/book.yaf.php)
- [瓦片地图规范](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames)

## 许可证

MIT License

## 联系方式

- 项目维护者: [Your Name]
- Email: [your.email@example.com]
- Issues: [GitHub Issues](https://github.com/xiaochuniang/hand-drawn-map/issues)
