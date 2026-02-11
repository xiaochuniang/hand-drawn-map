-- 手绘景区地图系统数据库结构
-- Database: scenic_map

CREATE DATABASE IF NOT EXISTS `scenic_map` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `scenic_map`;

-- --------------------------------------------------------
-- 表的结构：地图表
-- --------------------------------------------------------

CREATE TABLE `maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '地图ID',
  `name` varchar(100) NOT NULL COMMENT '地图名称',
  `name_en` varchar(100) DEFAULT NULL COMMENT '地图名称（英文）',
  `description` text COMMENT '地图描述',
  `bounds` json NOT NULL COMMENT '地图边界 {"minLng":..., "maxLng":..., "minLat":..., "maxLat":...}',
  `center` json NOT NULL COMMENT '地图中心点 {"lng":..., "lat":...}',
  `initial_zoom` int(11) DEFAULT 1 COMMENT '初始缩放级别',
  `min_zoom` int(11) DEFAULT 0 COMMENT '最小缩放级别',
  `max_zoom` int(11) DEFAULT 5 COMMENT '最大缩放级别',
  `tile_url` varchar(255) DEFAULT NULL COMMENT '瓦片URL模板',
  `image_url` varchar(255) DEFAULT NULL COMMENT '完整地图图片URL',
  `image_width` int(11) DEFAULT NULL COMMENT '地图图片宽度（像素）',
  `image_height` int(11) DEFAULT NULL COMMENT '地图图片高度（像素）',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='地图表';

-- --------------------------------------------------------
-- 表的结构：POI分类表
-- --------------------------------------------------------

CREATE TABLE `poi_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `name_en` varchar(50) DEFAULT NULL COMMENT '分类名称（英文）',
  `icon` varchar(100) DEFAULT NULL COMMENT '分类图标URL',
  `color` varchar(20) DEFAULT '#FF0000' COMMENT '标记颜色',
  `sort` int(11) DEFAULT 0 COMMENT '排序',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status_sort` (`status`, `sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='POI分类表';

-- --------------------------------------------------------
-- 表的结构：POI表
-- --------------------------------------------------------

CREATE TABLE `pois` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'POI ID',
  `map_id` int(11) NOT NULL COMMENT '地图ID',
  `category_id` int(11) NOT NULL COMMENT '分类ID',
  `name` varchar(100) NOT NULL COMMENT 'POI名称',
  `name_en` varchar(100) DEFAULT NULL COMMENT 'POI名称（英文）',
  `description` text COMMENT 'POI描述',
  `description_en` text COMMENT 'POI描述（英文）',
  `longitude` decimal(10, 7) NOT NULL COMMENT '经度（GPS）',
  `latitude` decimal(10, 7) NOT NULL COMMENT '纬度（GPS）',
  `pixel_x` int(11) NOT NULL COMMENT '像素坐标X',
  `pixel_y` int(11) NOT NULL COMMENT '像素坐标Y',
  `images` json DEFAULT NULL COMMENT '图片列表 ["url1", "url2", ...]',
  `open_time` varchar(100) DEFAULT NULL COMMENT '开放时间',
  `price` decimal(10, 2) DEFAULT NULL COMMENT '价格',
  `audio_url` varchar(255) DEFAULT NULL COMMENT '语音讲解URL',
  `phone` varchar(50) DEFAULT NULL COMMENT '联系电话',
  `tags` json DEFAULT NULL COMMENT '标签 ["tag1", "tag2", ...]',
  `sort` int(11) DEFAULT 0 COMMENT '排序',
  `view_count` int(11) DEFAULT 0 COMMENT '查看次数',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_map_id` (`map_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status_sort` (`status`, `sort`),
  KEY `idx_location` (`longitude`, `latitude`),
  CONSTRAINT `fk_poi_map` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_poi_category` FOREIGN KEY (`category_id`) REFERENCES `poi_categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='POI表';

-- --------------------------------------------------------
-- 表的结构：路网节点表
-- --------------------------------------------------------

CREATE TABLE `road_nodes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '节点ID',
  `map_id` int(11) NOT NULL COMMENT '地图ID',
  `node_name` varchar(50) DEFAULT NULL COMMENT '节点名称',
  `node_type` varchar(20) DEFAULT 'normal' COMMENT '节点类型：normal-普通节点，entrance-入口，exit-出口',
  `longitude` decimal(10, 7) NOT NULL COMMENT '经度（GPS）',
  `latitude` decimal(10, 7) NOT NULL COMMENT '纬度（GPS）',
  `pixel_x` int(11) NOT NULL COMMENT '像素坐标X',
  `pixel_y` int(11) NOT NULL COMMENT '像素坐标Y',
  `poi_id` int(11) DEFAULT NULL COMMENT '关联的POI ID（如果有）',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_map_id` (`map_id`),
  KEY `idx_poi_id` (`poi_id`),
  CONSTRAINT `fk_node_map` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_node_poi` FOREIGN KEY (`poi_id`) REFERENCES `pois` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='路网节点表';

-- --------------------------------------------------------
-- 表的结构：路网边表
-- --------------------------------------------------------

CREATE TABLE `road_edges` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '边ID',
  `map_id` int(11) NOT NULL COMMENT '地图ID',
  `from_node_id` int(11) NOT NULL COMMENT '起始节点ID',
  `to_node_id` int(11) NOT NULL COMMENT '结束节点ID',
  `distance` decimal(10, 2) NOT NULL COMMENT '距离（米）',
  `weight` decimal(10, 2) NOT NULL COMMENT '权重（用于路径计算）',
  `road_type` varchar(20) DEFAULT 'walk' COMMENT '道路类型：walk-步行道，vehicle-车行道，boat-水路',
  `is_bidirectional` tinyint(1) DEFAULT 1 COMMENT '是否双向：0-单向，1-双向',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_map_id` (`map_id`),
  KEY `idx_from_node` (`from_node_id`),
  KEY `idx_to_node` (`to_node_id`),
  KEY `idx_road_type` (`road_type`),
  CONSTRAINT `fk_edge_map` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_edge_from_node` FOREIGN KEY (`from_node_id`) REFERENCES `road_nodes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_edge_to_node` FOREIGN KEY (`to_node_id`) REFERENCES `road_nodes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='路网边表';

-- --------------------------------------------------------
-- 表的结构：推荐路线表
-- --------------------------------------------------------

CREATE TABLE `routes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '路线ID',
  `map_id` int(11) NOT NULL COMMENT '地图ID',
  `name` varchar(100) NOT NULL COMMENT '路线名称',
  `name_en` varchar(100) DEFAULT NULL COMMENT '路线名称（英文）',
  `description` text COMMENT '路线描述',
  `description_en` text COMMENT '路线描述（英文）',
  `mode` varchar(20) DEFAULT 'walk' COMMENT '交通方式：walk-步行，bike-自行车，boat-船',
  `distance` decimal(10, 2) NOT NULL COMMENT '总距离（公里）',
  `duration` int(11) NOT NULL COMMENT '预计时长（分钟）',
  `path_nodes` json NOT NULL COMMENT '路径节点列表 [node_id1, node_id2, ...]',
  `path_coords` json NOT NULL COMMENT '路径坐标列表 [[lng, lat], [lng, lat], ...]',
  `highlight_pois` json DEFAULT NULL COMMENT '沿途推荐POI [poi_id1, poi_id2, ...]',
  `difficulty` varchar(20) DEFAULT 'easy' COMMENT '难度：easy-简单，medium-中等，hard-困难',
  `tags` json DEFAULT NULL COMMENT '标签 ["亲子游", "摄影路线", ...]',
  `sort` int(11) DEFAULT 0 COMMENT '排序',
  `view_count` int(11) DEFAULT 0 COMMENT '查看次数',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_map_id` (`map_id`),
  KEY `idx_mode` (`mode`),
  KEY `idx_status_sort` (`status`, `sort`),
  CONSTRAINT `fk_route_map` FOREIGN KEY (`map_id`) REFERENCES `maps` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='推荐路线表';

-- --------------------------------------------------------
-- 表的结构：用户表
-- --------------------------------------------------------

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码（加密）',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `role` varchar(20) DEFAULT 'user' COMMENT '角色：admin-管理员，editor-编辑，user-普通用户',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `last_login_at` timestamp NULL DEFAULT NULL COMMENT '最后登录时间',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- --------------------------------------------------------
-- 表的结构：访问日志表（可选，用于数据统计）
-- --------------------------------------------------------

CREATE TABLE `access_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` int(11) DEFAULT NULL COMMENT '用户ID',
  `resource_type` varchar(20) NOT NULL COMMENT '资源类型：poi, route, map',
  `resource_id` int(11) NOT NULL COMMENT '资源ID',
  `action` varchar(20) NOT NULL COMMENT '操作：view, search, navigate',
  `ip` varchar(50) DEFAULT NULL COMMENT 'IP地址',
  `user_agent` varchar(255) DEFAULT NULL COMMENT 'User Agent',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_resource` (`resource_type`, `resource_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='访问日志表';

-- --------------------------------------------------------
-- 初始化数据：创建默认管理员
-- --------------------------------------------------------

INSERT INTO `users` (`username`, `password`, `nickname`, `role`, `status`) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '管理员', 'admin', 1);
-- 默认密码: password (请在生产环境中修改)

-- --------------------------------------------------------
-- 初始化数据：POI分类
-- --------------------------------------------------------

INSERT INTO `poi_categories` (`name`, `name_en`, `icon`, `color`, `sort`) VALUES
('景点', 'Scenic Spot', '/icons/scenic.png', '#FF6B6B', 1),
('餐厅', 'Restaurant', '/icons/restaurant.png', '#4ECDC4', 2),
('厕所', 'Toilet', '/icons/toilet.png', '#95E1D3', 3),
('停车场', 'Parking', '/icons/parking.png', '#FFE66D', 4),
('商店', 'Shop', '/icons/shop.png', '#FF8B94', 5),
('服务中心', 'Service Center', '/icons/service.png', '#A8D8EA', 6);
