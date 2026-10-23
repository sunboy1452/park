# 营销招商模块（可选扩展）
# Copyright (c) 2026-present, youlai.tech

-- ----------------------------------------------------------------------------
-- 营销招商扩展脚本（幂等，可重复执行）
-- 前置：请先执行 ../youlai_admin_tenant.sql
-- 业务表均含 tenant_id，由 MyBatis-Plus 租户拦截器自动隔离。
-- 房源只维护在 marketing_space 中，后续资产模块应在此基础上扩展，勿复制房源记录。
-- ----------------------------------------------------------------------------

USE `youlai_admin_tenant`;

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `marketing_channel` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `code` varchar(64) NOT NULL COMMENT '渠道编码',
  `name` varchar(100) NOT NULL COMMENT '渠道名称',
  `channel_type` varchar(20) NOT NULL COMMENT '渠道类型(ONLINE/OFFLINE/BROKER/PARTNER/OTHER)',
  `contact_name` varchar(100) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(32) DEFAULT NULL COMMENT '联系电话',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态(1启用 0停用)',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除(0未删 1已删)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_channel_code_deleted` (`tenant_id`, `code`, `is_deleted`),
  KEY `idx_tenant_channel_type_status` (`tenant_id`, `channel_type`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='招商渠道表';

CREATE TABLE IF NOT EXISTS `marketing_lead` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `customer_name` varchar(100) NOT NULL COMMENT '客户名称',
  `company_name` varchar(150) DEFAULT NULL COMMENT '公司名称',
  `contact_name` varchar(100) DEFAULT NULL COMMENT '联系人',
  `phone` varchar(32) NOT NULL COMMENT '联系电话',
  `email` varchar(128) DEFAULT NULL COMMENT '邮箱',
  `channel_id` bigint DEFAULT NULL COMMENT '来源渠道ID',
  `project_name` varchar(150) DEFAULT NULL COMMENT '意向项目名称',
  `space_id` bigint DEFAULT NULL COMMENT '意向房源ID',
  `intended_area` decimal(12,2) DEFAULT NULL COMMENT '意向面积',
  `budget` decimal(14,2) DEFAULT NULL COMMENT '预算',
  `stage` varchar(20) NOT NULL DEFAULT 'NEW' COMMENT '阶段(NEW/CONTACTED/VISITED/INTENTION/CONVERTED/LOST)',
  `assignee_id` bigint DEFAULT NULL COMMENT '负责人用户ID',
  `remark` varchar(1000) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除(0未删 1已删)',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_lead_stage` (`tenant_id`, `stage`),
  KEY `idx_tenant_lead_channel` (`tenant_id`, `channel_id`),
  KEY `idx_tenant_lead_assignee` (`tenant_id`, `assignee_id`),
  KEY `idx_tenant_lead_space` (`tenant_id`, `space_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='招商线索表';

CREATE TABLE IF NOT EXISTS `marketing_lead_follow_up` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `lead_id` bigint NOT NULL COMMENT '线索ID',
  `follow_type` varchar(32) NOT NULL COMMENT '跟进方式',
  `content` varchar(2000) NOT NULL COMMENT '跟进内容',
  `next_follow_at` datetime DEFAULT NULL COMMENT '下次跟进时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除(0未删 1已删)',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_followup_lead` (`tenant_id`, `lead_id`, `create_time`),
  KEY `idx_tenant_followup_next_at` (`tenant_id`, `next_follow_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='线索跟进记录表';

CREATE TABLE IF NOT EXISTS `marketing_space` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `space_code` varchar(64) NOT NULL COMMENT '房源编号',
  `project_name` varchar(150) NOT NULL COMMENT '项目名称',
  `building_name` varchar(100) DEFAULT NULL COMMENT '楼栋名称',
  `floor_name` varchar(100) DEFAULT NULL COMMENT '楼层名称',
  `room_no` varchar(64) DEFAULT NULL COMMENT '房间号',
  `area` decimal(12,2) NOT NULL COMMENT '面积',
  `rent_unit_price` decimal(12,2) DEFAULT NULL COMMENT '租金单价',
  `availability` varchar(20) NOT NULL COMMENT '可租状态(AVAILABLE/RESERVED/LEASED/MAINTENANCE)',
  `display_title` varchar(150) NOT NULL COMMENT '展示标题',
  `description` varchar(2000) DEFAULT NULL COMMENT '展示描述',
  `cover_url` varchar(500) DEFAULT NULL COMMENT '封面图片地址',
  `vr_url` varchar(500) DEFAULT NULL COMMENT 'VR地址',
  `publish_status` tinyint NOT NULL DEFAULT 0 COMMENT '发布状态(0草稿 1已发布 2已下线)',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除(0未删 1已删)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_space_code_deleted` (`tenant_id`, `space_code`, `is_deleted`),
  KEY `idx_tenant_space_public` (`tenant_id`, `publish_status`, `availability`),
  KEY `idx_tenant_space_project` (`tenant_id`, `project_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='招商房源表';

-- 菜单（顶级 ID=10，顺延动态表单 ID=8、工作流 ID=9）
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES
(10, 0, '0', '营销招商', 'C', '', '/marketing', 'Layout', NULL, NULL, 1, 10, 'el-icon-DataAnalysis', '/marketing/overview', now(), now(), NULL),
(1001, 10, '0,10', '渠道管理', 'M', 'MarketingChannels', 'channels', 'marketing/channels/index', NULL, 1, 1, 1, 'el-icon-Connection', NULL, now(), now(), NULL),
(100101, 1001, '0,10,1001', '渠道查询', 'B', NULL, '', NULL, 'marketing:channel:list', NULL, 1, 1, '', NULL, now(), now(), NULL),
(100102, 1001, '0,10,1001', '渠道新增', 'B', NULL, '', NULL, 'marketing:channel:create', NULL, 1, 2, '', NULL, now(), now(), NULL),
(100103, 1001, '0,10,1001', '渠道修改', 'B', NULL, '', NULL, 'marketing:channel:update', NULL, 1, 3, '', NULL, now(), now(), NULL),
(100104, 1001, '0,10,1001', '渠道删除', 'B', NULL, '', NULL, 'marketing:channel:delete', NULL, 1, 4, '', NULL, now(), now(), NULL),
(1002, 10, '0,10', '线索管理', 'M', 'MarketingLeads', 'leads', 'marketing/leads/index', NULL, 1, 1, 2, 'el-icon-User', NULL, now(), now(), NULL),
(100201, 1002, '0,10,1002', '线索查询', 'B', NULL, '', NULL, 'marketing:lead:list', NULL, 1, 1, '', NULL, now(), now(), NULL),
(100202, 1002, '0,10,1002', '线索新增', 'B', NULL, '', NULL, 'marketing:lead:create', NULL, 1, 2, '', NULL, now(), now(), NULL),
(100203, 1002, '0,10,1002', '线索修改', 'B', NULL, '', NULL, 'marketing:lead:update', NULL, 1, 3, '', NULL, now(), now(), NULL),
(100204, 1002, '0,10,1002', '线索删除', 'B', NULL, '', NULL, 'marketing:lead:delete', NULL, 1, 4, '', NULL, now(), now(), NULL),
(100205, 1002, '0,10,1002', '线索分配', 'B', NULL, '', NULL, 'marketing:lead:assign', NULL, 1, 5, '', NULL, now(), now(), NULL),
(100206, 1002, '0,10,1002', '跟进查询', 'B', NULL, '', NULL, 'marketing:follow-up:list', NULL, 1, 6, '', NULL, now(), now(), NULL),
(100207, 1002, '0,10,1002', '跟进新增', 'B', NULL, '', NULL, 'marketing:follow-up:create', NULL, 1, 7, '', NULL, now(), now(), NULL),
(100208, 1002, '0,10,1002', '跟进修改', 'B', NULL, '', NULL, 'marketing:follow-up:update', NULL, 1, 8, '', NULL, now(), now(), NULL),
(100209, 1002, '0,10,1002', '跟进删除', 'B', NULL, '', NULL, 'marketing:follow-up:delete', NULL, 1, 9, '', NULL, now(), now(), NULL),
(1003, 10, '0,10', '房源管理', 'M', 'MarketingSpaces', 'spaces', 'marketing/spaces/index', NULL, 1, 1, 3, 'el-icon-OfficeBuilding', NULL, now(), now(), NULL),
(100301, 1003, '0,10,1003', '房源查询', 'B', NULL, '', NULL, 'marketing:space:list', NULL, 1, 1, '', NULL, now(), now(), NULL),
(100302, 1003, '0,10,1003', '房源新增', 'B', NULL, '', NULL, 'marketing:space:create', NULL, 1, 2, '', NULL, now(), now(), NULL),
(100303, 1003, '0,10,1003', '房源修改', 'B', NULL, '', NULL, 'marketing:space:update', NULL, 1, 3, '', NULL, now(), now(), NULL),
(100304, 1003, '0,10,1003', '房源删除', 'B', NULL, '', NULL, 'marketing:space:delete', NULL, 1, 4, '', NULL, now(), now(), NULL),
(1004, 10, '0,10', '营销概览', 'M', 'MarketingOverview', 'overview', 'marketing/overview/index', NULL, 1, 1, 4, 'el-icon-DataLine', NULL, now(), now(), NULL),
(100401, 1004, '0,10,1004', '概览查询', 'B', NULL, '', NULL, 'marketing:overview:list', NULL, 1, 1, '', NULL, now(), now(), NULL);

INSERT IGNORE INTO `sys_tenant_menu` (tenant_id, menu_id)
SELECT 0, id FROM `sys_menu` WHERE id = 10 OR tree_path LIKE '0,10%';

INSERT IGNORE INTO `sys_tenant_menu` (tenant_id, menu_id)
SELECT 1, id FROM `sys_menu` WHERE (id = 10 OR tree_path LIKE '0,10%') AND scope = 2;

INSERT IGNORE INTO `sys_tenant_plan_menu` (plan_id, menu_id)
SELECT 2, id FROM `sys_menu` WHERE (id = 10 OR tree_path LIKE '0,10%') AND scope = 2;

-- 授权给平台租户系统管理员及演示租户管理员，sys_role_menu 列顺序为 role_id, menu_id, tenant_id。
INSERT IGNORE INTO `sys_role_menu` (`role_id`, `menu_id`, `tenant_id`) VALUES
(2, 10, 0), (2, 1001, 0), (2, 100101, 0), (2, 100102, 0), (2, 100103, 0), (2, 100104, 0),
(2, 1002, 0), (2, 100201, 0), (2, 100202, 0), (2, 100203, 0), (2, 100204, 0), (2, 100205, 0),
(2, 100206, 0), (2, 100207, 0), (2, 100208, 0), (2, 100209, 0),
(2, 1003, 0), (2, 100301, 0), (2, 100302, 0), (2, 100303, 0), (2, 100304, 0),
(2, 1004, 0), (2, 100401, 0),
(13, 10, 1), (13, 1001, 1), (13, 100101, 1), (13, 100102, 1), (13, 100103, 1), (13, 100104, 1),
(13, 1002, 1), (13, 100201, 1), (13, 100202, 1), (13, 100203, 1), (13, 100204, 1), (13, 100205, 1),
(13, 100206, 1), (13, 100207, 1), (13, 100208, 1), (13, 100209, 1),
(13, 1003, 1), (13, 100301, 1), (13, 100302, 1), (13, 100303, 1), (13, 100304, 1),
(13, 1004, 1), (13, 100401, 1),
(15, 10, 1), (15, 1001, 1), (15, 100101, 1), (15, 100102, 1), (15, 100103, 1), (15, 100104, 1),
(15, 1002, 1), (15, 100201, 1), (15, 100202, 1), (15, 100203, 1), (15, 100204, 1), (15, 100205, 1),
(15, 100206, 1), (15, 100207, 1), (15, 100208, 1), (15, 100209, 1),
(15, 1003, 1), (15, 100301, 1), (15, 100302, 1), (15, 100303, 1), (15, 100304, 1),
(15, 1004, 1), (15, 100401, 1);
