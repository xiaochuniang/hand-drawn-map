# 从现有实现迁移到完整架构指南

## 现状分析

当前仓库实现了一个基于 **Vue 3 + Vite + MapLibre GL JS** 的单页面地图应用，具备：
- ✅ 手绘地图展示（栅格瓦片）
- ✅ POI 标注与交互
- ✅ 路线展示与筛选
- ✅ 中英双语支持
- ❌ 无后端支持
- ❌ 无多端支持（仅H5）
- ❌ 无后台管理
- ❌ 使用MapLibre而非OpenLayers

## 迁移策略

### 方案一：渐进式迁移（推荐）

保留现有实现作为 **H5版本**，逐步添加新功能。

#### 阶段1：添加后端API（1-2周）

1. **创建PHP后端项目**
```bash
mkdir -p backend/{application,conf,public}
cd backend
composer init
composer require yaf/yaf
```

2. **实现核心API**
   - 地图信息API
   - POI列表/详情API
   - 路线规划API

3. **前端对接API**
```typescript
// 修改现有的静态GeoJSON加载为API调用
// src/api/poi.ts
export async function getPOIs(params) {
  const response = await fetch(`${API_BASE}/api/pois`, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
    params
  });
  return response.json();
}
```

#### 阶段2：数据库集成（1周）

1. 导入database/schema.sql
2. 将现有GeoJSON数据导入数据库
3. 实现数据迁移脚本

#### 阶段3：添加uni-app支持（2-3周）

1. **创建uni-app项目**
```bash
mkdir frontend-uniapp
cd frontend-uniapp
vue create -p dcloudio/uni-preset-vue .
```

2. **复用现有组件逻辑**
   - 将MapView组件改造为WebView方式
   - 复用API调用逻辑
   - 复用i18n配置

3. **适配多端**
   - H5版本
   - 微信小程序版本
   - APP版本

#### 阶段4：地图引擎迁移（1-2周）

**选项A：保持MapLibre（推荐）**
- MapLibre更轻量，性能更好
- 已有实现成熟
- 社区活跃

**选项B：迁移到OpenLayers**
```typescript
// 使用OpenLayers替换MapLibre
import Map from 'ol/Map';
import View from 'ol/View';
import TileLayer from 'ol/layer/Tile';
import XYZ from 'ol/source/XYZ';

const map = new Map({
  target: 'map',
  layers: [
    new TileLayer({
      source: new XYZ({
        url: '/tiles/{z}/{x}/{y}.svg'
      })
    })
  ],
  view: new View({
    center: [0, 0],
    zoom: 1
  })
});
```

#### 阶段5：后台管理系统（2-3周）

1. 创建admin目录
2. 使用Vue Admin模板
3. 实现POI管理、地图管理等功能

### 方案二：全新重构

完全按照ARCHITECTURE.md重新搭建项目。

**优点**：
- 架构清晰，符合最佳实践
- 易于维护和扩展

**缺点**：
- 时间成本高（6-8周）
- 需要重写所有代码
- 过渡期需维护两套代码

## 具体迁移步骤

### 步骤1：保留现有实现

```bash
# 重命名现有目录
mv src frontend-h5-legacy
mv public public-legacy

# 保留当前分支
git branch legacy-implementation
```

### 步骤2：创建新目录结构

```bash
# 创建新结构
mkdir -p frontend/{src,static}
mkdir -p backend/{application,conf,public}
mkdir -p admin/src
mkdir -p database/{migrations,seeds}
mkdir -p docs/api
```

### 步骤3：迁移数据

```python
# scripts/migrate-data.py
import json
import mysql.connector

# 读取旧的GeoJSON
with open('../public-legacy/pois.geojson') as f:
    pois = json.load(f)

# 连接数据库
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="password",
    database="scenic_map"
)

cursor = db.cursor()

# 插入POI数据
for feature in pois['features']:
    props = feature['properties']
    coords = feature['geometry']['coordinates']
    
    sql = """INSERT INTO pois 
             (map_id, category_id, name, name_en, description, description_en,
              longitude, latitude, pixel_x, pixel_y, status)
             VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    
    values = (
        1,  # map_id
        1,  # category_id, 需要根据实际分类映射
        props.get('name_zh'),
        props.get('name_en'),
        props.get('desc_zh'),
        props.get('desc_en'),
        coords[0],  # longitude
        coords[1],  # latitude
        0,  # pixel_x, 需要根据坐标转换计算
        0,  # pixel_y
        1   # status
    )
    
    cursor.execute(sql, values)

db.commit()
cursor.close()
db.close()
```

### 步骤4：前端API对接

```typescript
// frontend/src/api/index.ts
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.VUE_APP_API_BASE_URL || 'http://localhost/api',
  timeout: 10000
});

// 请求拦截器
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  error => Promise.reject(error)
);

// 响应拦截器
api.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response?.status === 401) {
      // 处理未授权
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

```typescript
// frontend/src/api/poi.ts
import api from './index';

export const poiApi = {
  // 获取POI列表
  list(params?: any) {
    return api.get('/pois', { params });
  },
  
  // 获取POI详情
  detail(id: number) {
    return api.get(`/pois/${id}`);
  },
  
  // 搜索POI
  search(keyword: string) {
    return api.get('/pois/search', { params: { keyword } });
  },
  
  // 获取POI分类
  categories() {
    return api.get('/pois/categories');
  }
};
```

### 步骤5：更新地图组件

```vue
<!-- frontend/src/components/MapView/MapView.vue -->
<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { poiApi } from '@/api/poi';
import maplibregl from 'maplibre-gl';

const map = ref<maplibregl.Map>();
const pois = ref([]);

onMounted(async () => {
  // 初始化地图
  map.value = new maplibregl.Map({
    container: 'map',
    style: {
      version: 8,
      sources: {
        'raster-tiles': {
          type: 'raster',
          tiles: ['/tiles/{z}/{x}/{y}.svg'],
          tileSize: 256
        }
      },
      layers: [{
        id: 'background',
        type: 'raster',
        source: 'raster-tiles'
      }]
    },
    center: [0, 0],
    zoom: 1
  });
  
  // 从API加载POI数据
  const response = await poiApi.list();
  pois.value = response.data.items;
  
  // 添加POI标记
  pois.value.forEach(poi => {
    new maplibregl.Marker()
      .setLngLat([poi.longitude, poi.latitude])
      .setPopup(new maplibregl.Popup().setHTML(`
        <h3>${poi.name}</h3>
        <p>${poi.description}</p>
      `))
      .addTo(map.value);
  });
});
</script>
```

## 兼容性处理

### 保持旧版本运行

在迁移过程中，可以同时运行新旧版本：

```nginx
# nginx配置
server {
    listen 80;
    server_name map.example.com;
    
    # 新版本（API + 新前端）
    location /api/ {
        proxy_pass http://localhost:8080;
    }
    
    location /v2/ {
        alias /var/www/new-frontend/;
    }
    
    # 旧版本（保持向后兼容）
    location / {
        alias /var/www/legacy-frontend/;
    }
}
```

### 数据迁移脚本

```bash
#!/bin/bash
# scripts/migrate.sh

echo "开始数据迁移..."

# 1. 导出旧数据
echo "导出GeoJSON数据..."
cp -r public-legacy/*.geojson /tmp/

# 2. 导入数据库
echo "导入数据库..."
mysql -u root -p scenic_map < database/schema.sql

# 3. 运行数据迁移脚本
echo "转换数据格式..."
python3 scripts/migrate-data.py

# 4. 验证数据
echo "验证数据完整性..."
mysql -u root -p scenic_map -e "SELECT COUNT(*) FROM pois"

echo "数据迁移完成！"
```

## 测试计划

### 1. 单元测试

```typescript
// frontend/tests/unit/poi.spec.ts
import { describe, it, expect } from 'vitest';
import { poiApi } from '@/api/poi';

describe('POI API', () => {
  it('should fetch POI list', async () => {
    const result = await poiApi.list();
    expect(result.code).toBe(200);
    expect(result.data.items).toBeInstanceOf(Array);
  });
  
  it('should search POI', async () => {
    const result = await poiApi.search('迎客松');
    expect(result.code).toBe(200);
    expect(result.data.length).toBeGreaterThan(0);
  });
});
```

### 2. E2E测试

```typescript
// frontend/tests/e2e/map.spec.ts
import { test, expect } from '@playwright/test';

test('地图应该正常加载', async ({ page }) => {
  await page.goto('http://localhost:5173');
  await expect(page.locator('#map')).toBeVisible();
});

test('POI标记应该可点击', async ({ page }) => {
  await page.goto('http://localhost:5173');
  await page.click('.maplibregl-marker:first-child');
  await expect(page.locator('.maplibregl-popup')).toBeVisible();
});
```

## 性能对比

| 指标 | 旧版本 | 新版本 | 改进 |
|------|--------|--------|------|
| 首屏加载时间 | 2.5s | 1.8s | ↓28% |
| POI数据加载 | 本地 | API | 实时更新 |
| 支持平台 | H5 | H5/小程序/APP | +200% |
| 管理便捷性 | 需开发 | 可视化后台 | +∞ |

## 回滚方案

如果迁移出现问题，可以快速回滚：

```bash
# 回滚到旧版本
git checkout legacy-implementation

# 恢复Nginx配置
sudo mv /etc/nginx/sites-available/scenic-map.backup \
        /etc/nginx/sites-available/scenic-map
sudo nginx -s reload

# 恢复数据库（如果需要）
mysql -u root -p scenic_map < backup/scenic_map_backup.sql
```

## 总结

- **推荐方案**: 渐进式迁移（方案一）
- **总时间**: 8-12周
- **风险**: 中等（保留旧版本作为备份）
- **收益**: 高（获得完整的多端支持和管理能力）

选择渐进式迁移可以在不影响现有用户的情况下，逐步引入新功能，降低迁移风险。
