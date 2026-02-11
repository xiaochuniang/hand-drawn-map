# 手绘景区地图系统 - 实施指南

本文档提供从零开始实施整个手绘景区地图系统的详细步骤。

## 前置准备

### 1. 手绘地图素材准备

#### 要求
- **格式**: PNG/WebP，分辨率建议2048x2048或更高
- **分层**: 建议使用PS/AI制作，导出时保留图层信息
- **比例尺**: 确保地图按实际比例绘制
- **坐标标注**: 在地图上标记关键点的GPS坐标（至少3-4个校准点）

#### 关键点校准
在手绘地图上标记以下GPS坐标：
1. 景区入口
2. 主要景点（至少2-3个）
3. 地图四个角的坐标

### 2. 数据采集

需要采集以下数据：

#### POI数据表格

| 编号 | 名称 | 英文名 | 分类 | GPS经度 | GPS纬度 | 像素X | 像素Y | 描述 | 开放时间 | 价格 |
|------|------|--------|------|---------|---------|-------|-------|------|----------|------|
| 1 | 迎客松 | Welcoming Pine | 景点 | 118.1567 | 30.1234 | 512 | 768 | ... | 全天 | 0 |

#### 路网数据采集

绘制景区路网图，标注：
- 道路节点（交叉口、景点入口）
- 道路类型（步行道、车行道、水路）
- 道路距离和通行时间

## 实施步骤

### 第一阶段：环境搭建（1-2天）

#### 1. 服务器准备

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Docker
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker $USER

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 2. 克隆项目

```bash
git clone https://github.com/xiaochuniang/hand-drawn-map.git
cd hand-drawn-map
```

#### 3. 配置环境变量

```bash
# 复制配置文件
cp docker/.env.example docker/.env

# 编辑配置
vim docker/.env
```

配置内容：
```env
# 数据库配置
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=scenic_map
MYSQL_USER=scenic_map_user
MYSQL_PASSWORD=your_db_password

# Redis配置
REDIS_PASSWORD=your_redis_password

# PHP配置
PHP_VERSION=7.4

# Nginx配置
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443

# 应用配置
APP_ENV=production
APP_DEBUG=false
```

#### 4. 启动服务

```bash
cd docker
docker-compose up -d
```

#### 5. 初始化数据库

```bash
# 进入MySQL容器
docker-compose exec mysql bash

# 导入数据库结构
mysql -u root -p scenic_map < /docker-entrypoint-initdb.d/schema.sql
```

### 第二阶段：后端开发（5-7天）

#### 1. PHP后端框架搭建

参考 `ARCHITECTURE.md` 中的后端目录结构，创建基础框架。

#### 2. 核心API实现优先级

**第一批（核心功能）**：
1. 地图信息接口
2. POI列表接口
3. POI详情接口
4. POI搜索接口

**第二批（扩展功能）**：
1. 路线规划接口
2. 推荐路线接口
3. 用户登录接口

**第三批（管理功能）**：
1. 后台管理接口
2. 文件上传接口
3. 数据统计接口

#### 3. API测试

使用Postman或curl测试每个接口：

```bash
# 测试地图信息接口
curl http://localhost/api/map/info

# 测试POI列表接口
curl http://localhost/api/pois?map_id=1

# 测试POI搜索
curl http://localhost/api/pois/search?keyword=迎客松
```

### 第三阶段：地图瓦片处理（2-3天）

#### 1. 安装瓦片切割工具

```bash
npm install -g sharp-cli
# 或使用Python的gdal2tiles
```

#### 2. 切割地图瓦片

```bash
# 使用提供的脚本
cd scripts/tile-generator
npm install
node generate-tiles.js ../../static/maps/source.png ../../public/tiles

# 或手动切割
sharp input.png \
  --tile 256 \
  --output tiles/{z}/{x}/{y}.png
```

#### 3. 上传到CDN

```bash
# 上传到阿里云OSS（示例）
ossutil cp -r ./public/tiles oss://your-bucket/tiles/ --recursive
```

### 第四阶段：前端开发（7-10天）

#### 1. 初始化uni-app项目

```bash
# 使用HBuilderX创建uni-app项目
# 或使用命令行
vue create -p dcloudio/uni-preset-vue frontend
cd frontend
npm install
```

#### 2. 安装依赖

```bash
npm install pinia axios @types/node
```

#### 3. 开发顺序

**第一步：地图展示**
1. 创建MapView组件
2. 集成OpenLayers（通过WebView）
3. 加载手绘地图瓦片
4. 实现缩放、平移功能

**第二步：POI展示**
1. 加载POI数据
2. 在地图上渲染POI标记
3. 实现POI点击弹窗
4. 添加POI搜索功能

**第三步：路线功能**
1. 实现起点终点选择
2. 调用路线规划API
3. 在地图上绘制路线
4. 显示导航指引

**第四步：UI优化**
1. 完善交互细节
2. 添加加载动画
3. 优化性能
4. 适配不同设备

#### 4. 多端测试

```bash
# H5开发
npm run dev:h5

# 微信小程序
npm run dev:mp-weixin
# 用微信开发者工具打开 dist/dev/mp-weixin

# APP
npm run dev:app
# 用HBuilderX打开项目进行真机调试
```

### 第五阶段：后台管理系统（5-7天）

#### 1. 使用Vue Admin模板

推荐使用：
- Vue Element Admin
- Ant Design Pro Vue
- Naive UI Admin

#### 2. 核心功能实现

1. 地图管理
   - 上传手绘地图
   - 设置地图边界
   - 配置初始视图

2. POI管理
   - POI CRUD
   - 可视化标注（拖拽调整位置）
   - 批量导入/导出

3. 路线管理
   - 路网编辑器
   - 路线规划测试
   - 推荐路线管理

4. 数据统计
   - 访问量统计
   - 热门POI排行
   - 用户行为分析

### 第六阶段：测试与优化（3-5天）

#### 1. 功能测试

测试清单：
- [ ] 地图加载速度
- [ ] POI标记准确性
- [ ] 路线规划正确性
- [ ] 搜索功能
- [ ] 多设备兼容性
- [ ] 弱网环境表现

#### 2. 性能优化

```bash
# 前端构建优化
npm run build
# 检查打包大小
du -sh dist/*

# 图片压缩
find ./static -name "*.png" -exec pngquant --quality=70-85 {} \;

# 启用Gzip
# 在nginx.conf中配置
gzip on;
gzip_types text/plain application/json image/svg+xml;
```

#### 3. 安全加固

```bash
# 更新依赖
npm audit fix
composer update

# 配置HTTPS
certbot --nginx -d yourdomain.com

# 配置防火墙
sudo ufw enable
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
```

### 第七阶段：部署上线（1-2天）

#### 1. 构建生产版本

```bash
# 前端构建
cd frontend
npm run build:h5
npm run build:mp-weixin

# 后端优化
cd backend
composer install --no-dev --optimize-autoloader
```

#### 2. 配置域名和SSL

```nginx
# /etc/nginx/sites-available/scenic-map
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    root /var/www/scenic-map/public;
    index index.php index.html;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
```

#### 3. 配置CDN

将静态资源上传到CDN：
- 地图瓦片
- POI图片
- 音频文件

#### 4. 配置监控

```bash
# 安装监控工具
apt install prometheus node-exporter
# 或使用云服务监控（阿里云云监控、腾讯云监控）
```

### 第八阶段：运营维护

#### 1. 数据更新流程

1. 景区管理员登录后台
2. 更新POI信息
3. 系统自动缓存清理
4. 前端自动获取最新数据

#### 2. 定期备份

```bash
# 创建备份脚本
cat > /root/backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d)
mysqldump -u root -p scenic_map > /backup/scenic_map_$DATE.sql
tar -czf /backup/files_$DATE.tar.gz /var/www/scenic-map
find /backup -mtime +30 -delete
EOF

chmod +x /root/backup.sh

# 添加到crontab
crontab -e
# 每天凌晨3点备份
0 3 * * * /root/backup.sh
```

#### 3. 监控告警

配置告警规则：
- 服务器CPU/内存使用率 > 80%
- API响应时间 > 1秒
- 错误率 > 1%
- 磁盘使用率 > 90%

## 常见问题

### 1. 地图加载慢
**解决方案**：
- 使用CDN加速
- 启用浏览器缓存
- 压缩图片
- 使用WebP格式

### 2. 坐标偏移
**解决方案**：
- 增加校准点数量
- 使用多点校准算法
- 手动微调偏移参数

### 3. 小程序包大小超限
**解决方案**：
- 使用分包加载
- 图片存CDN，不打包
- 压缩代码
- 移除未使用的依赖

### 4. 路径规划不准确
**解决方案**：
- 完善路网数据
- 调整权重参数
- 增加路径约束条件

## 成本估算

### 开发成本

| 项目 | 工作量 | 人天 | 费用（估算） |
|------|--------|------|--------------|
| 需求分析 | 1人 | 3天 | 3000元 |
| 手绘地图制作 | 1人 | 5天 | 5000-20000元 |
| 后端开发 | 1人 | 15天 | 15000元 |
| 前端开发 | 1人 | 20天 | 20000元 |
| 后台管理 | 1人 | 10天 | 10000元 |
| 测试与优化 | 1人 | 5天 | 5000元 |
| **总计** | - | **58天** | **58000-73000元** |

### 运营成本（年）

| 项目 | 费用 |
|------|------|
| 服务器（4核8G） | 3000-6000元 |
| CDN流量（1TB） | 2000-4000元 |
| 域名+SSL证书 | 300元 |
| 存储（100GB） | 500元 |
| **总计** | **5800-10800元/年** |

## 里程碑

- **Week 1**: 环境搭建完成，数据库设计完成
- **Week 2**: 后端核心API完成50%
- **Week 3**: 后端核心API完成100%，前端地图展示完成
- **Week 4**: 前端POI展示完成，路线功能开发50%
- **Week 5**: 前端所有功能完成，后台管理开发50%
- **Week 6**: 后台管理完成，进入测试阶段
- **Week 7**: 测试与优化
- **Week 8**: 部署上线

## 总结

本实施指南提供了一个完整的开发路线图。根据实际情况，可以调整开发顺序和重点。建议采用敏捷开发方式，先完成MVP（最小可行产品），然后逐步迭代优化。

关键成功因素：
1. 高质量的手绘地图素材
2. 准确的POI和路网数据
3. 良好的用户体验设计
4. 稳定的技术架构
5. 持续的运营维护
