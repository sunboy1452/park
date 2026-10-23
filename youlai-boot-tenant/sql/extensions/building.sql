-- Building management extension
-- Prerequisites: youlai_admin_tenant.sql and extensions/marketing.sql
-- Room inventory remains in marketing_space so existing lead.space_id links stay valid.

USE `youlai_admin_tenant`;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `asset_park` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `code` varchar(64) NOT NULL COMMENT 'Park code',
  `name` varchar(150) NOT NULL COMMENT 'Park name',
  `address` varchar(255) DEFAULT NULL COMMENT 'Address',
  `area` decimal(14,2) DEFAULT NULL COMMENT 'Land area in square meters',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1 active, 0 inactive',
  `description` varchar(1000) DEFAULT NULL COMMENT 'Description',
  `create_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `is_deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_park_code_deleted` (`tenant_id`, `code`, `is_deleted`),
  KEY `idx_tenant_park_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Park master data';

CREATE TABLE IF NOT EXISTS `asset_region` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `park_id` bigint NOT NULL COMMENT 'Park ID',
  `code` varchar(64) NOT NULL COMMENT 'Region code',
  `name` varchar(100) NOT NULL COMMENT 'Region name',
  `region_type` varchar(32) DEFAULT NULL COMMENT 'Functional type',
  `area` decimal(14,2) DEFAULT NULL COMMENT 'Land area in square meters',
  `map_x` int NOT NULL DEFAULT 40 COMMENT 'Schematic x coordinate, 0-1000',
  `map_y` int NOT NULL DEFAULT 40 COMMENT 'Schematic y coordinate, 0-1000',
  `map_width` int NOT NULL DEFAULT 280 COMMENT 'Schematic width',
  `map_height` int NOT NULL DEFAULT 230 COMMENT 'Schematic height',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1 active, 0 inactive',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Display order',
  `remark` varchar(500) DEFAULT NULL COMMENT 'Remark',
  `create_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `is_deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_park_region_code_deleted` (`tenant_id`, `park_id`, `code`, `is_deleted`),
  KEY `idx_tenant_park_region_status` (`tenant_id`, `park_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Park regions';

CREATE TABLE IF NOT EXISTS `asset_building` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `park_id` bigint NOT NULL COMMENT 'Park ID',
  `region_id` bigint NOT NULL COMMENT 'Region ID',
  `code` varchar(64) NOT NULL COMMENT 'Building code',
  `name` varchar(100) NOT NULL COMMENT 'Building name',
  `building_type` varchar(32) DEFAULT NULL COMMENT 'Building use type',
  `area` decimal(14,2) DEFAULT NULL COMMENT 'Building area in square meters',
  `map_x` int NOT NULL DEFAULT 80 COMMENT 'Schematic x coordinate, 0-1000',
  `map_y` int NOT NULL DEFAULT 80 COMMENT 'Schematic y coordinate, 0-1000',
  `map_width` int NOT NULL DEFAULT 120 COMMENT 'Schematic width',
  `map_height` int NOT NULL DEFAULT 72 COMMENT 'Schematic height',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1 active, 0 inactive',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Display order',
  `remark` varchar(500) DEFAULT NULL COMMENT 'Remark',
  `create_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `is_deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_park_building_code_deleted` (`tenant_id`, `park_id`, `code`, `is_deleted`),
  KEY `idx_tenant_region_building` (`tenant_id`, `region_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Park buildings';

CREATE TABLE IF NOT EXISTS `asset_floor` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `building_id` bigint NOT NULL COMMENT 'Building ID',
  `floor_code` varchar(64) NOT NULL COMMENT 'Floor code',
  `floor_name` varchar(100) NOT NULL COMMENT 'Floor name',
  `floor_number` int NOT NULL COMMENT 'Floor number; below ground is negative',
  `area` decimal(14,2) DEFAULT NULL COMMENT 'Floor area in square meters',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1 active, 0 inactive',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Display order',
  `remark` varchar(500) DEFAULT NULL COMMENT 'Remark',
  `create_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `is_deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_building_floor_code_deleted` (`tenant_id`, `building_id`, `floor_code`, `is_deleted`),
  KEY `idx_tenant_building_floor_number` (`tenant_id`, `building_id`, `floor_number`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Building floors';

CREATE TABLE IF NOT EXISTS `asset_project` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `code` varchar(64) NOT NULL COMMENT 'Project code',
  `name` varchar(150) NOT NULL COMMENT 'Project name',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1 active, 0 inactive',
  `remark` varchar(500) DEFAULT NULL COMMENT 'Remark',
  `create_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `is_deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_asset_project_code_deleted` (`tenant_id`, `code`, `is_deleted`),
  KEY `idx_tenant_asset_project_status` (`tenant_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Building access projects';

CREATE TABLE IF NOT EXISTS `asset_project_building` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `project_id` bigint NOT NULL COMMENT 'Project ID',
  `building_id` bigint NOT NULL COMMENT 'Building ID; projects can span parks',
  `create_time` datetime NOT NULL,
  `create_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_project_building` (`tenant_id`, `project_id`, `building_id`),
  KEY `idx_tenant_building_project` (`tenant_id`, `building_id`, `project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Project building membership';

SET @building_sql = IF(
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'marketing_space' AND column_name = 'park_id') = 0,
  'ALTER TABLE `marketing_space` ADD COLUMN `park_id` bigint DEFAULT NULL COMMENT ''Park ID'', ADD COLUMN `region_id` bigint DEFAULT NULL COMMENT ''Region ID'', ADD COLUMN `building_id` bigint DEFAULT NULL COMMENT ''Building ID'', ADD COLUMN `floor_id` bigint DEFAULT NULL COMMENT ''Floor ID'', ADD KEY `idx_tenant_park_space` (`tenant_id`, `park_id`, `is_deleted`), ADD KEY `idx_tenant_building_space` (`tenant_id`, `building_id`, `is_deleted`), ADD KEY `idx_tenant_floor_space` (`tenant_id`, `floor_id`, `is_deleted`)',
  'SELECT 1'
);
PREPARE building_stmt FROM @building_sql;
EXECUTE building_stmt;
DEALLOCATE PREPARE building_stmt;

INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES
(11, 0, '0', '建筑管理', 'C', '', '/building', 'Layout', NULL, NULL, 1, 11, 'el-icon-OfficeBuilding', '/building/overview', now(), now(), NULL),
(1101, 11, '0,11', '园区概览', 'M', 'AssetOverview', 'overview', 'asset/overview/index', NULL, 1, 1, 1, 'el-icon-DataAnalysis', NULL, now(), now(), NULL),
(110101, 1101, '0,11,1101', '概览查询', 'B', NULL, '', NULL, 'asset:overview:list', NULL, 1, 1, '', NULL, now(), now(), NULL),
(1102, 11, '0,11', '园区管理', 'M', 'AssetParks', 'parks', 'asset/parks/index', NULL, 1, 1, 2, 'el-icon-MapLocation', NULL, now(), now(), NULL),
(110201, 1102, '0,11,1102', '园区查询', 'B', NULL, '', NULL, 'asset:park:list', NULL, 1, 1, '', NULL, now(), now(), NULL),
(110202, 1102, '0,11,1102', '园区新增', 'B', NULL, '', NULL, 'asset:park:create', NULL, 1, 2, '', NULL, now(), now(), NULL),
(110203, 1102, '0,11,1102', '园区修改', 'B', NULL, '', NULL, 'asset:park:update', NULL, 1, 3, '', NULL, now(), now(), NULL),
(110204, 1102, '0,11,1102', '园区删除', 'B', NULL, '', NULL, 'asset:park:delete', NULL, 1, 4, '', NULL, now(), now(), NULL),
(1103, 11, '0,11', '楼栋管理', 'M', 'AssetBuildings', 'buildings', 'asset/buildings/index', NULL, 1, 1, 4, 'el-icon-OfficeBuilding', NULL, now(), now(), NULL),
(110301, 1103, '0,11,1103', '楼栋查询', 'B', NULL, '', NULL, 'asset:building:list', NULL, 1, 1, '', NULL, now(), now(), NULL),
(110302, 1103, '0,11,1103', '楼栋新增', 'B', NULL, '', NULL, 'asset:building:create', NULL, 1, 2, '', NULL, now(), now(), NULL),
(110303, 1103, '0,11,1103', '楼栋修改', 'B', NULL, '', NULL, 'asset:building:update', NULL, 1, 3, '', NULL, now(), now(), NULL),
(110304, 1103, '0,11,1103', '楼栋删除', 'B', NULL, '', NULL, 'asset:building:delete', NULL, 1, 4, '', NULL, now(), now(), NULL),
(1104, 11, '0,11', '区域管理', 'M', 'AssetRegions', 'regions', 'asset/regions/index', NULL, 1, 1, 3, 'el-icon-MapLocation', NULL, now(), now(), NULL),
(110401, 1104, '0,11,1104', '区域查询', 'B', NULL, '', NULL, 'asset:region:list', NULL, 1, 1, '', NULL, now(), now(), NULL),
(110402, 1104, '0,11,1104', '区域新增', 'B', NULL, '', NULL, 'asset:region:create', NULL, 1, 2, '', NULL, now(), now(), NULL),
(110403, 1104, '0,11,1104', '区域修改', 'B', NULL, '', NULL, 'asset:region:update', NULL, 1, 3, '', NULL, now(), now(), NULL),
(110404, 1104, '0,11,1104', '区域删除', 'B', NULL, '', NULL, 'asset:region:delete', NULL, 1, 4, '', NULL, now(), now(), NULL),
(1105, 11, '0,11', '项目管理', 'M', 'AssetProjects', 'projects', 'asset/projects/index', NULL, 1, 1, 6, 'el-icon-Collection', NULL, now(), now(), NULL),
(110501, 1105, '0,11,1105', '项目查询', 'B', NULL, '', NULL, 'asset:project:list', NULL, 1, 1, '', NULL, now(), now(), NULL),
(110502, 1105, '0,11,1105', '项目新增', 'B', NULL, '', NULL, 'asset:project:create', NULL, 1, 2, '', NULL, now(), now(), NULL),
(110503, 1105, '0,11,1105', '项目修改', 'B', NULL, '', NULL, 'asset:project:update', NULL, 1, 3, '', NULL, now(), now(), NULL),
(110504, 1105, '0,11,1105', '项目删除', 'B', NULL, '', NULL, 'asset:project:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);

UPDATE `sys_menu` SET `parent_id` = 11, `tree_path` = '0,11', `name` = '房源管理', `route_name` = 'AssetSpaces', `route_path` = 'spaces', `component` = 'marketing/spaces/index', `sort` = 5 WHERE `id` = 1003;
UPDATE `sys_menu` SET `tree_path` = '0,11,1003' WHERE `parent_id` = 1003 AND `id` BETWEEN 100301 AND 100399;

INSERT IGNORE INTO `sys_tenant_menu` (`tenant_id`, `menu_id`)
SELECT 0, `id` FROM `sys_menu` WHERE `id` = 11 OR `tree_path` LIKE '0,11%';
INSERT IGNORE INTO `sys_tenant_menu` (`tenant_id`, `menu_id`)
SELECT 1, `id` FROM `sys_menu` WHERE (`id` = 11 OR `tree_path` LIKE '0,11%') AND `scope` = 2;
INSERT IGNORE INTO `sys_tenant_plan_menu` (`plan_id`, `menu_id`)
SELECT 2, `id` FROM `sys_menu` WHERE (`id` = 11 OR `tree_path` LIKE '0,11%') AND `scope` = 2;

INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`, `tenant_id`) VALUES
(2, 11, 0), (2, 1101, 0), (2, 110101, 0), (2, 1102, 0), (2, 110201, 0), (2, 110202, 0), (2, 110203, 0), (2, 110204, 0),
(2, 1103, 0), (2, 110301, 0), (2, 110302, 0), (2, 110303, 0), (2, 110304, 0), (2, 1104, 0), (2, 110401, 0), (2, 110402, 0), (2, 110403, 0), (2, 110404, 0),
(2, 1105, 0), (2, 110501, 0), (2, 110502, 0), (2, 110503, 0), (2, 110504, 0),
(13, 11, 1), (13, 1101, 1), (13, 110101, 1), (13, 1102, 1), (13, 110201, 1), (13, 110202, 1), (13, 110203, 1), (13, 110204, 1),
(13, 1103, 1), (13, 110301, 1), (13, 110302, 1), (13, 110303, 1), (13, 110304, 1), (13, 1104, 1), (13, 110401, 1), (13, 110402, 1), (13, 110403, 1), (13, 110404, 1),
(13, 1105, 1), (13, 110501, 1), (13, 110502, 1), (13, 110503, 1), (13, 110504, 1);

INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`, `tenant_id`)
SELECT 15, `menu_id`, `tenant_id` FROM `sys_role_menu` WHERE `role_id` = 13 AND `tenant_id` = 1 AND `menu_id` IN (11, 1101, 110101, 1102, 110201, 110202, 110203, 110204, 1103, 110301, 110302, 110303, 110304, 1104, 110401, 110402, 110403, 110404, 1105, 110501, 110502, 110503, 110504);

UPDATE `sys_menu`
SET `sort` = CASE `id` WHEN 1103 THEN 4 WHEN 1104 THEN 3 END
WHERE `parent_id` = 11
  AND ((`id` = 1103 AND `name` = '楼栋管理') OR (`id` = 1104 AND `name` = '区域管理'));
