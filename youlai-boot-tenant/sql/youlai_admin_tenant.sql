
# youlai_admin_tenant 数据库(MySQL 5.7 ~ MySQL 8.x) - 多租户版本
# Copyright (c) 2021-present, youlai.tech
#
# 说明：此脚本为多租户版本的完整数据库初始化脚本
# 包含所有表结构、多租户字段、初始数据和权限配置
# 执行前请确保已备份数据库！

-- ----------------------------
-- 1. 创建数据库
-- ----------------------------
CREATE DATABASE IF NOT EXISTS youlai_admin_tenant CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci;


-- ----------------------------
-- 2. 创建表 && 数据初始化
-- ----------------------------
USE youlai_admin_tenant;

SET NAMES utf8mb4;  # 设置字符集
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';
SET FOREIGN_KEY_CHECKS = 0; # 关闭外键检查，加快导入速度

-- ----------------------------
-- 表结构：sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
                             `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
                             `tenant_id` bigint DEFAULT 0 COMMENT '租户ID',
                             `name` varchar(100) NOT NULL COMMENT '部门名称',
                             `code` varchar(100) NOT NULL COMMENT '部门编号',
                             `parent_id` bigint DEFAULT 0 COMMENT '父节点id',
                             `tree_path` varchar(255) NOT NULL COMMENT '父节点id路径',
                             `sort` smallint DEFAULT 0 COMMENT '显示顺序',
                             `status` tinyint DEFAULT 1 COMMENT '状态(1-正常 0-禁用)',
                             `create_by` bigint NULL COMMENT '创建人ID',
                             `create_time` datetime NULL COMMENT '创建时间',
                             `update_by` bigint NULL COMMENT '修改人ID',
                             `update_time` datetime NULL COMMENT '更新时间',
                             `is_deleted` tinyint DEFAULT 0 COMMENT '逻辑删除标识(1-已删除 0-未删除)',
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE INDEX `uk_tenant_code`(`tenant_id` ASC, `code` ASC, `is_deleted` ASC) USING BTREE COMMENT '租户内部门编号唯一索引',
                             KEY `idx_tenant_id` (`tenant_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '部门管理表';

-- ----------------------------
-- 表数据：sys_dept
-- ----------------------------
-- 默认租户（tenant_id=0）的部门
INSERT INTO `sys_dept` VALUES (1, 0, '有来技术', 'YOULAI', 0, '0', 1, 1, 1, NULL, 1, now(), 0);
INSERT INTO `sys_dept` VALUES (2, 0, '研发部门', 'RD001', 1, '0,1', 1, 1, 2, NULL, 2, now(), 0);
INSERT INTO `sys_dept` VALUES (3, 0, '测试部门', 'QA001', 1, '0,1', 1, 1, 2, NULL, 2, now(), 0);

-- 演示租户（tenant_id=1）的部门
INSERT INTO `sys_dept` VALUES (4, 1, '演示公司', 'DEMO_COMPANY', 0, '0', 1, 1, 4, NULL, 4, now(), 0);
INSERT INTO `sys_dept` VALUES (5, 1, '演示技术部', 'DEMO_TECH', 4, '0,4', 1, 1, 4, NULL, 5, now(), 0);
INSERT INTO `sys_dept` VALUES (6, 1, '演示运营部', 'DEMO_OPER', 4, '0,4', 1, 1, 4, NULL, 6, now(), 0);

-- ----------------------------
-- 表结构：sys_dict
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict`;
CREATE TABLE `sys_dict` (
                            `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键 ',
                            `dict_code` varchar(50) COMMENT '类型编码',
                            `name` varchar(50) COMMENT '类型名称',
                            `status` tinyint(1) DEFAULT '1' COMMENT '状态(1-正常 0-禁用)',
                            `remark` varchar(255) COMMENT '备注',
                            `create_time` datetime COMMENT '创建时间',
                            `create_by` bigint COMMENT '创建人ID',
                            `update_time` datetime COMMENT '更新时间',
                            `update_by` bigint COMMENT '修改人ID',
                            `is_deleted` tinyint DEFAULT '0' COMMENT '是否删除(1-删除，0-未删除)',
                            PRIMARY KEY (`id`) USING BTREE,
                            KEY `idx_dict_code` (`dict_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据字典类型表';
-- ----------------------------
-- 表数据：sys_dict
-- ----------------------------
INSERT INTO `sys_dict` VALUES (1, 'gender', '性别', 1, NULL, now() , 1,now(), 1,0);
INSERT INTO `sys_dict` VALUES (2, 'notice_type', '通知类型', 1, NULL, now(), 1,now(), 1,0);
INSERT INTO `sys_dict` VALUES (3, 'notice_level', '通知级别', 1, NULL, now(), 1,now(), 1,0);


-- ----------------------------
-- 表结构：sys_dict_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_item`;
CREATE TABLE `sys_dict_item` (
                                 `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
                                 `dict_code` varchar(50) COMMENT '关联字典编码，与sys_dict表中的dict_code对应',
                                 `value` varchar(50) COMMENT '字典项值',
                                 `label` varchar(100) COMMENT '字典项标签',
                                 `tag_type` varchar(50) COMMENT '标签样式(primary-主要 success-成功 warning-警告 danger-危险 info-信息，空为无样式)',
                                 `status` tinyint DEFAULT '0' COMMENT '状态(1-启用 0-停用)',
                                 `sort` int DEFAULT '0' COMMENT '排序',
                                 `remark` varchar(255) COMMENT '备注',
                                 `create_time` datetime COMMENT '创建时间',
                                 `create_by` bigint COMMENT '创建人ID',
                                 `update_time` datetime COMMENT '更新时间',
                                 `update_by` bigint COMMENT '修改人ID',
                                 `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除(1-已删除 0-未删除)',
                                 PRIMARY KEY (`id`) USING BTREE,
                                 KEY `idx_dict_code` (`dict_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据字典项表';

-- ----------------------------
-- 表数据：sys_dict_item
-- ----------------------------
INSERT INTO `sys_dict_item` VALUES (1, 'gender', '1', '男', 'primary', 1, 1, NULL, now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (2, 'gender', '2', '女', 'danger', 1, 2, NULL, now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (3, 'gender', '0', '保密', 'info', 1, 3, NULL, now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (4, 'notice_type', '1', '系统升级', 'success', 1, 1, '', now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (5, 'notice_type', '2', '系统维护', 'primary', 1, 2, '', now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (6, 'notice_type', '3', '安全警告', 'danger', 1, 3, '', now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (7, 'notice_type', '4', '假期通知', 'success', 1, 4, '', now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (8, 'notice_type', '5', '公司新闻', 'primary', 1, 5, '', now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (9, 'notice_type', '99', '其他', 'info', 1, 99, '', now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (10, 'notice_level', 'L', '低', 'info', 1, 1, '', now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (11, 'notice_level', 'M', '中', 'warning', 1, 2, '', now(), 1,now(),1, 0);
INSERT INTO `sys_dict_item` VALUES (12, 'notice_level', 'H', '高', 'danger', 1, 3, '', now(), 1,now(),1, 0);

-- ----------------------------
-- 表结构：sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
                             `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
                             `parent_id` bigint NOT NULL COMMENT '父菜单ID',
                             `tree_path` varchar(255) COMMENT '父节点ID路径',
                             `name` varchar(64) NOT NULL COMMENT '菜单名称',
                             `type` char(1) NOT NULL COMMENT '菜单类型（C-目录 M-菜单 E-外链 B-按钮）',
                             `route_name` varchar(255) COMMENT '路由名称（Vue Router 中用于命名路由）',
                             `route_path` varchar(128) COMMENT '路由路径（Vue Router 中定义的 URL 路径）',
                             `component` varchar(128) COMMENT '组件路径（组件页面完整路径，相对于 src/views/，缺省后缀 .vue）',
                             `external_url` varchar(512) COMMENT '外链地址',
                             `perm` varchar(128) COMMENT '【按钮】权限标识',
                             `keep_alive` tinyint DEFAULT 0 COMMENT '【菜单】是否开启页面缓存（1-是 0-否）',
                             `visible` tinyint(1) DEFAULT 1 COMMENT '显示状态（1-显示 0-隐藏）',
                             `sort` int DEFAULT 0 COMMENT '排序',
                             `icon` varchar(64) COMMENT '菜单图标',
                             `redirect` varchar(128) COMMENT '跳转路径',
                             `create_time` datetime NULL COMMENT '创建时间',
                             `update_time` datetime NULL COMMENT '更新时间',
                             `params` json NULL COMMENT '路由参数',
                             `scope` tinyint(1) NOT NULL DEFAULT 2 COMMENT '菜单范围(1=平台菜单 2=业务菜单)',
                             PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '系统菜单表';

-- ----------------------------
-- 表数据：sys_menu
-- ----------------------------
-- ID 规则：子 ID = 父 ID × 100 + 两位序号（如 10101 即租户管理 101 的第 1 个按钮），tree_path 与 ID 同构可机器校验
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (1, 0, '0', '平台管理', 'C', '', '/platform', 'Layout', NULL, NULL, 1, 1, 'el-icon-Platform', '/platform/tenant', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (2, 0, '0', '系统管理', 'C', '', '/system', 'Layout', NULL, NULL, 1, 2, 'system', '/system/user', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (3, 0, '0', '代码生成', 'C', '', '/codegen', 'Layout', NULL, NULL, 1, 3, 'code', '/codegen/index', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (4, 0, '0', '通用组件', 'C', '', '/component', 'Layout', NULL, NULL, 1, 4, 'el-icon-SetUp', '/component/basic/icon-demo', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (5, 0, '0', '多级菜单', 'C', '', '/multi-level', 'Layout', NULL, NULL, 1, 5, 'el-icon-Guide', '/multi-level/level-one/level-two/level-three-a', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (6, 0, '0', '路由示例', 'C', '', '/route-example', 'Layout', NULL, NULL, 1, 6, 'el-icon-Share', '/route-example/route-param', now(), now(), NULL);
-- 平台管理
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (101, 1, '0,1', '租户管理', 'M', 'Tenant', 'tenant', 'system/tenant/index', NULL, 1, 1, 1, 'el-icon-OfficeBuilding', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10101, 101, '0,1,101', '租户查询', 'B', NULL, '', NULL, 'sys:tenant:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10102, 101, '0,1,101', '租户新增', 'B', NULL, '', NULL, 'sys:tenant:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10103, 101, '0,1,101', '租户编辑', 'B', NULL, '', NULL, 'sys:tenant:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10104, 101, '0,1,101', '租户删除', 'B', NULL, '', NULL, 'sys:tenant:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10105, 101, '0,1,101', '租户启用/禁用', 'B', NULL, '', NULL, 'sys:tenant:change-status', NULL, 1, 5, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10106, 101, '0,1,101', '租户切换', 'B', NULL, '', NULL, 'sys:tenant:switch', NULL, 1, 6, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10107, 101, '0,1,101', '设置套餐', 'B', NULL, '', NULL, 'sys:tenant:plan-assign', NULL, 1, 7, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (102, 1, '0,1', '租户套餐', 'M', 'TenantPlan', 'tenant-plan', 'system/tenant/plan', NULL, 1, 1, 2, 'el-icon-CollectionTag', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10201, 102, '0,1,102', '套餐查询', 'B', NULL, '', NULL, 'sys:tenant-plan:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10202, 102, '0,1,102', '套餐新增', 'B', NULL, '', NULL, 'sys:tenant-plan:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10203, 102, '0,1,102', '套餐编辑', 'B', NULL, '', NULL, 'sys:tenant-plan:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10204, 102, '0,1,102', '套餐删除', 'B', NULL, '', NULL, 'sys:tenant-plan:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10205, 102, '0,1,102', '套餐菜单配置', 'B', NULL, '', NULL, 'sys:tenant-plan:assign', NULL, 1, 5, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (103, 1, '0,1', '应用管理', 'M', 'App', 'app', 'system/app/index', NULL, 1, 1, 3, 'el-icon-Mobile', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10301, 103, '0,1,103', '应用查询', 'B', NULL, '', NULL, 'sys:app:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10302, 103, '0,1,103', '应用新增', 'B', NULL, '', NULL, 'sys:app:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10303, 103, '0,1,103', '应用编辑', 'B', NULL, '', NULL, 'sys:app:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10304, 103, '0,1,103', '应用删除', 'B', NULL, '', NULL, 'sys:app:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (10305, 103, '0,1,103', '应用启用/禁用', 'B', NULL, '', NULL, 'sys:app:change-status', NULL, 1, 5, '', NULL, now(), now(), NULL);
-- 系统管理
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (201, 2, '0,2', '用户管理', 'M', 'User', 'user', 'system/user/index', NULL, 1, 1, 1, 'el-icon-User', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20101, 201, '0,2,201', '用户查询', 'B', NULL, '', NULL, 'sys:user:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20102, 201, '0,2,201', '用户新增', 'B', NULL, '', NULL, 'sys:user:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20103, 201, '0,2,201', '用户编辑', 'B', NULL, '', NULL, 'sys:user:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20104, 201, '0,2,201', '用户删除', 'B', NULL, '', NULL, 'sys:user:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20105, 201, '0,2,201', '重置密码', 'B', NULL, '', NULL, 'sys:user:reset-password', NULL, 1, 5, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20106, 201, '0,2,201', '用户导入', 'B', NULL, '', NULL, 'sys:user:import', NULL, 1, 6, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20107, 201, '0,2,201', '用户导出', 'B', NULL, '', NULL, 'sys:user:export', NULL, 1, 7, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (202, 2, '0,2', '角色管理', 'M', 'Role', 'role', 'system/role/index', NULL, 1, 1, 2, 'role', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20201, 202, '0,2,202', '角色查询', 'B', NULL, '', NULL, 'sys:role:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20202, 202, '0,2,202', '角色新增', 'B', NULL, '', NULL, 'sys:role:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20203, 202, '0,2,202', '角色编辑', 'B', NULL, '', NULL, 'sys:role:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20204, 202, '0,2,202', '角色删除', 'B', NULL, '', NULL, 'sys:role:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20205, 202, '0,2,202', '角色分配权限', 'B', NULL, '', NULL, 'sys:role:assign', NULL, 1, 5, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (203, 2, '0,2', '菜单管理', 'M', 'SysMenu', 'menu', 'system/menu/index', NULL, 1, 1, 3, 'menu', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20301, 203, '0,2,203', '菜单查询', 'B', NULL, '', NULL, 'sys:menu:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20302, 203, '0,2,203', '菜单新增', 'B', NULL, '', NULL, 'sys:menu:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20303, 203, '0,2,203', '菜单编辑', 'B', NULL, '', NULL, 'sys:menu:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20304, 203, '0,2,203', '菜单删除', 'B', NULL, '', NULL, 'sys:menu:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (204, 2, '0,2', '部门管理', 'M', 'Dept', 'dept', 'system/dept/index', NULL, 1, 1, 4, 'tree', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20401, 204, '0,2,204', '部门查询', 'B', NULL, '', NULL, 'sys:dept:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20402, 204, '0,2,204', '部门新增', 'B', NULL, '', NULL, 'sys:dept:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20403, 204, '0,2,204', '部门编辑', 'B', NULL, '', NULL, 'sys:dept:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20404, 204, '0,2,204', '部门删除', 'B', NULL, '', NULL, 'sys:dept:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (205, 2, '0,2', '字典管理', 'M', 'Dict', 'dict', 'system/dict/index', NULL, 1, 1, 5, 'dict', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20501, 205, '0,2,205', '字典查询', 'B', NULL, '', NULL, 'sys:dict:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20502, 205, '0,2,205', '字典新增', 'B', NULL, '', NULL, 'sys:dict:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20503, 205, '0,2,205', '字典编辑', 'B', NULL, '', NULL, 'sys:dict:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20504, 205, '0,2,205', '字典删除', 'B', NULL, '', NULL, 'sys:dict:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (206, 2, '0,2', '字典项', 'M', 'DictItem', 'dict-item', 'system/dict/dict-item', NULL, 1, 0, 6, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20601, 206, '0,2,206', '字典项查询', 'B', NULL, '', NULL, 'sys:dict-item:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20602, 206, '0,2,206', '字典项新增', 'B', NULL, '', NULL, 'sys:dict-item:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20603, 206, '0,2,206', '字典项编辑', 'B', NULL, '', NULL, 'sys:dict-item:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20604, 206, '0,2,206', '字典项删除', 'B', NULL, '', NULL, 'sys:dict-item:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (207, 2, '0,2', '系统日志', 'M', 'Log', 'log', 'system/log/index', NULL, 1, 1, 7, 'document', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20701, 207, '0,2,207', '日志查询', 'B', NULL, '', NULL, 'sys:log:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (208, 2, '0,2', '系统配置', 'M', 'Config', 'config', 'system/config/index', NULL, 1, 1, 8, 'setting', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20801, 208, '0,2,208', '系统配置查询', 'B', NULL, '', NULL, 'sys:config:list', 1, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20802, 208, '0,2,208', '系统配置新增', 'B', NULL, '', NULL, 'sys:config:create', 1, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20803, 208, '0,2,208', '系统配置修改', 'B', NULL, '', NULL, 'sys:config:update', 1, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20804, 208, '0,2,208', '系统配置删除', 'B', NULL, '', NULL, 'sys:config:delete', 1, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20805, 208, '0,2,208', '系统配置刷新', 'B', NULL, '', NULL, 'sys:config:refresh', 1, 1, 5, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (209, 2, '0,2', '通知公告', 'M', 'Notice', 'notice', 'system/notice/index', NULL, NULL, 1, 9, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20901, 209, '0,2,209', '通知查询', 'B', NULL, '', NULL, 'sys:notice:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20902, 209, '0,2,209', '通知新增', 'B', NULL, '', NULL, 'sys:notice:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20903, 209, '0,2,209', '通知编辑', 'B', NULL, '', NULL, 'sys:notice:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20904, 209, '0,2,209', '通知删除', 'B', NULL, '', NULL, 'sys:notice:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20905, 209, '0,2,209', '通知发布', 'B', NULL, '', NULL, 'sys:notice:publish', 1, 1, 5, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (20906, 209, '0,2,209', '通知撤回', 'B', NULL, '', NULL, 'sys:notice:revoke', 1, 1, 6, '', NULL, now(), now(), NULL);
-- 代码生成
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (301, 3, '0,3', '代码生成', 'M', 'Codegen', 'index', 'codegen/index', NULL, 1, 1, 1, 'code', NULL, now(), now(), NULL);
-- 通用组件（401 基础 / 402 表单 / 403 表格）
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (401, 4, '0,4', '基础组件', 'C', '', 'basic', 'Layout', NULL, NULL, 1, 1, 'el-icon-Brush', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40101, 401, '0,4,401', 'Icons', 'M', 'IconDemo', 'icon-demo', 'demo/component/icons', NULL, 1, 1, 1, 'el-icon-Notification', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40102, 401, '0,4,401', '拖拽组件', 'M', 'Drag', 'drag', 'demo/component/drag', NULL, NULL, 1, 2, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40103, 401, '0,4,401', '滚动文本', 'M', 'TextScroll', 'text-scroll', 'demo/component/text-scroll', NULL, NULL, 1, 3, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40104, 401, '0,4,401', '字典实时同步', 'M', 'DictSync', 'dict-sync', 'demo/component/dict-sync', NULL, NULL, 1, 4, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (402, 4, '0,4', '表单组件', 'C', '', 'form', 'Layout', NULL, NULL, 1, 2, 'el-icon-EditPen', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40201, 402, '0,4,402', '富文本编辑器', 'M', 'WangEditor', 'wang-editor', 'demo/component/wang-editor', NULL, 1, 1, 1, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40202, 402, '0,4,402', '图片上传', 'M', 'Upload', 'upload', 'demo/component/upload', NULL, 1, 1, 2, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40203, 402, '0,4,402', '图标选择器', 'M', 'DemoIconSelect', 'icon-select', 'demo/component/icon-select', NULL, 1, 1, 3, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40204, 402, '0,4,402', '字典组件', 'M', 'DictDemo', 'dict-demo', 'demo/component/dictionary', NULL, 1, 1, 4, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40205, 402, '0,4,402', '列表选择器', 'M', 'TableSelect', 'table-select', 'demo/component/table-select/index', NULL, 1, 1, 5, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (403, 4, '0,4', '表格组件', 'C', '', 'table', 'Layout', NULL, NULL, 1, 3, 'el-icon-Grid', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40301, 403, '0,4,403', '增删改查', 'M', 'Crud', 'crud', 'demo/table/crud/index', NULL, 1, 1, 1, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40302, 403, '0,4,403', 'CRUD单文件', 'M', 'CrudSingle', 'crud-single', 'demo/table/crud-single', NULL, 1, 1, 2, 'el-icon-Reading', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40303, 403, '0,4,403', 'VxeTable', 'M', 'VxeTable', 'vxe-table', 'demo/table/vxe-table/index', NULL, 1, 1, 3, 'el-icon-MagicStick', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (40304, 403, '0,4,403', '自适应表格操作列', 'M', 'AutoOperationColumn', 'operation-column', 'demo/table/auto-operation-column', NULL, 1, 1, 4, '', '', now(), now(), NULL);
-- 多级菜单
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (501, 5, '0,5', '一级菜单', 'C', '', 'level-one', 'Layout', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (50101, 501, '0,5,501', '二级菜单', 'C', '', 'level-two', 'Layout', NULL, NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (5010101, 50101, '0,5,501,50101', '三级菜单 A', 'M', 'MultiLevelLevelThreeA', 'level-three-a', 'demo/route/multi-level/level-one/level-two/level-three-a/index', NULL, 1, 1, 1, '', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (5010102, 50101, '0,5,501,50101', '三级菜单 B', 'M', 'MultiLevelLevelThreeB', 'level-three-b', 'demo/route/multi-level/level-one/level-two/level-three-b/index', NULL, 1, 1, 2, '', '', now(), now(), NULL);
-- 路由示例
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (601, 6, '0,6', '路由参数', 'M', 'RouteParam', 'route-param', 'demo/route/route-param', NULL, 1, 1, 1, 'el-icon-Star', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (602, 6, '0,6', '页面缓存', 'M', 'RouteCache', 'cache', 'demo/route/cache/index', NULL, 1, 1, 2, 'el-icon-Stopwatch', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (603, 6, '0,6', '页面跳转', 'M', 'RouteNavigate', 'navigate', 'demo/route/navigate/index', NULL, 1, 1, 3, 'el-icon-Position', NULL, now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `external_url`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (604, 6, '0,6', '内嵌页面', 'E', 'PracticeDoc', 'iframe', 'iframe', 'https://www.apifox.cn/apidoc/shared-195e783f-4d85-4235-a038-eec696de4ea5', NULL, 1, 1, 4, 'el-icon-Document', '', now(), now(), NULL);
INSERT INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `external_url`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (605, 6, '0,6', '外部链接', 'E', NULL, NULL, NULL, 'https://juejin.cn/post/7228990409909108793', NULL, NULL, 1, 5, 'el-icon-Link', '', now(), now(), NULL);

-- ----------------------------
-- 菜单 scope 初始化
-- ----------------------------
UPDATE `sys_menu`
SET `scope` = 1
WHERE `id` = 1 OR `tree_path` LIKE '0,1%';

-- ----------------------------
-- 表结构：sys_tenant_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_tenant_menu`;
CREATE TABLE `sys_tenant_menu`  (
                                    `tenant_id` bigint NOT NULL COMMENT '租户ID',
                                    `menu_id` bigint NOT NULL COMMENT '菜单ID',
                                    PRIMARY KEY (`tenant_id`, `menu_id`) USING BTREE,
                                    KEY `idx_tenant_menu_menu_id` (`menu_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '租户菜单关联表';

-- ----------------------------
-- 表数据：sys_tenant_menu
-- ----------------------------
-- 平台租户（tenant_id=0）可用菜单：全量菜单
INSERT INTO `sys_tenant_menu` (tenant_id, menu_id)
SELECT 0, id FROM `sys_menu`;

-- 演示租户（tenant_id=1）可用菜单：仅租户菜单（不含平台管理）
INSERT INTO `sys_tenant_menu` (tenant_id, menu_id)
SELECT 1, id FROM `sys_menu`
WHERE scope = 2;

-- ----------------------------
-- 表结构：sys_tenant_plan
-- ----------------------------
DROP TABLE IF EXISTS `sys_tenant_plan`;
CREATE TABLE `sys_tenant_plan`  (
                                  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '套餐ID',
                                  `name` varchar(100) NOT NULL COMMENT '套餐名称',
                                  `code` varchar(50) NOT NULL COMMENT '套餐编码',
                                  `status` tinyint DEFAULT '1' COMMENT '状态(1-启用 0-停用)',
                                  `sort` int DEFAULT 0 COMMENT '排序',
                                  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
                                  `create_time` datetime NULL COMMENT '创建时间',
                                  `update_time` datetime NULL COMMENT '更新时间',
                                  PRIMARY KEY (`id`) USING BTREE,
                                  UNIQUE KEY `uk_code` (`code`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '租户套餐表';

-- ----------------------------
-- 表结构：sys_tenant_plan_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_tenant_plan_menu`;
CREATE TABLE `sys_tenant_plan_menu`  (
                                       `plan_id` bigint NOT NULL COMMENT '套餐ID',
                                       `menu_id` bigint NOT NULL COMMENT '菜单ID',
                                       PRIMARY KEY (`plan_id`, `menu_id`) USING BTREE,
                                       KEY `idx_plan_menu_menu_id` (`menu_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '租户套餐菜单关联表';

-- ----------------------------
-- 表数据：sys_tenant_plan
-- ----------------------------
INSERT INTO `sys_tenant_plan` VALUES (1, '基础套餐', 'BASIC', 1, 1, '仅系统管理菜单', now(), now());
INSERT INTO `sys_tenant_plan` VALUES (2, '高级套餐', 'PRO', 1, 2, '全部租户菜单', now(), now());

-- ----------------------------
-- 表数据：sys_tenant_plan_menu
-- ----------------------------
-- 基础套餐：系统管理菜单
INSERT INTO `sys_tenant_plan_menu` (plan_id, menu_id)
SELECT 1, id FROM `sys_menu`
WHERE id = 2 OR tree_path LIKE '0,2%';

-- 高级套餐：全部租户菜单
INSERT INTO `sys_tenant_plan_menu` (plan_id, menu_id)
SELECT 2, id FROM `sys_menu`
WHERE scope = 2;

-- ----------------------------
-- 表结构：sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `tenant_id` bigint DEFAULT 0 COMMENT '租户ID',
                             `name` varchar(64) NOT NULL COMMENT '角色名称',
                             `code` varchar(32) NOT NULL COMMENT '角色编码',
                             `sort` int NULL COMMENT '显示顺序',
                             `status` tinyint(1) DEFAULT 1 COMMENT '角色状态(1-正常 0-停用)',
                             `data_scope` tinyint NULL COMMENT '数据权限(1-所有数据 2-部门及子部门数据 3-本部门数据 4-本人数据 5-自定义部门数据)',
                             `create_by` bigint NULL COMMENT '创建人 ID',
                             `create_time` datetime NULL COMMENT '创建时间',
                             `update_by` bigint NULL COMMENT '更新人ID',
                             `update_time` datetime NULL COMMENT '更新时间',
                             `is_deleted` tinyint(1) DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE INDEX `uk_tenant_name`(`tenant_id` ASC, `name` ASC, `is_deleted` ASC) USING BTREE COMMENT '租户内角色名称唯一索引',
                             UNIQUE INDEX `uk_tenant_code`(`tenant_id` ASC, `code` ASC, `is_deleted` ASC) USING BTREE COMMENT '租户内角色编码唯一索引',
                             KEY `idx_tenant_id` (`tenant_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '系统角色表';

-- ----------------------------
-- 表数据：sys_role
-- ----------------------------
-- 默认租户（tenant_id=0）的角色
INSERT INTO `sys_role` VALUES (1, 0, '超级管理员', 'ROOT', 1, 1, 1, NULL, now(), NULL, now(), 0);
INSERT INTO `sys_role` VALUES (2, 0, '系统管理员', 'ADMIN', 2, 1, 1, NULL, now(), NULL, NULL, 0);
INSERT INTO `sys_role` VALUES (3, 0, '访问游客', 'GUEST', 3, 1, 3, NULL, now(), NULL, now(), 0);

-- 用于验证数据权限的角色（tenant_id=0）
INSERT INTO `sys_role` VALUES (4, 0, '部门主管', 'DEPT_MANAGER', 4, 1, 2, NULL, now(), NULL, now(), 0);
INSERT INTO `sys_role` VALUES (5, 0, '部门成员', 'DEPT_MEMBER', 5, 1, 3, NULL, now(), NULL, now(), 0);
INSERT INTO `sys_role` VALUES (6, 0, '普通员工', 'EMPLOYEE', 6, 1, 4, NULL, now(), NULL, now(), 0);
INSERT INTO `sys_role` VALUES (7, 0, '自定义权限用户', 'CUSTOM_USER', 7, 1, 5, NULL, now(), NULL, now(), 0);

-- 演示租户（tenant_id=1）的角色
INSERT INTO `sys_role` VALUES (13, 1, '演示租户管理员', 'DEMO_ADMIN', 1, 1, 1, NULL, now(), NULL, now(), 0);
INSERT INTO `sys_role` VALUES (14, 1, '演示普通用户', 'DEMO_USER', 2, 1, 3, NULL, now(), NULL, now(), 0);
INSERT INTO `sys_role` VALUES (15, 1, '演示租户系统管理员', 'ADMIN', 3, 1, 1, NULL, now(), NULL, now(), 0);

-- ----------------------------
-- 表结构：sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
                                  `role_id` bigint NOT NULL COMMENT '角色ID',
                                  `menu_id` bigint NOT NULL COMMENT '菜单ID',
                                  `tenant_id` bigint DEFAULT 0 COMMENT '租户ID',
                                  PRIMARY KEY (`tenant_id`, `role_id`, `menu_id`) USING BTREE,
                                  KEY `idx_role_menu_tenant_id` (`tenant_id`),
                                  KEY `idx_tenant_role` (`tenant_id`, `role_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '角色菜单关联表';

-- ----------------------------
-- 表结构：sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
                                  `tenant_id` bigint DEFAULT 0 COMMENT '租户ID',
                                  `role_id` bigint NOT NULL COMMENT '角色ID',
                                  `dept_id` bigint NOT NULL COMMENT '部门ID',
                                  PRIMARY KEY (`tenant_id`, `role_id`, `dept_id`) USING BTREE,
                                  KEY `idx_role_dept_tenant_id` (`tenant_id`),
                                  KEY `idx_tenant_role_dept` (`tenant_id`, `role_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '角色部门关联表(用于自定义数据权限)';

-- ----------------------------
-- 表数据：sys_role_dept
-- ----------------------------
INSERT IGNORE INTO `sys_role_dept` VALUES (0, 7, 1);
INSERT IGNORE INTO `sys_role_dept` VALUES (0, 7, 2);

-- ----------------------------
-- 表数据：sys_role_menu
-- ----------------------------
-- ============================================
-- ROOT 角色菜单权限（role_id=1）- 拥有所有权限
-- 顶级目录
INSERT INTO `sys_role_menu` VALUES (1, 1, 0), (1, 2, 0), (1, 3, 0), (1, 4, 0), (1, 5, 0), (1, 6, 0);
-- 平台管理
INSERT INTO `sys_role_menu` VALUES (1, 101, 0), (1, 10101, 0), (1, 10102, 0), (1, 10103, 0), (1, 10104, 0), (1, 10105, 0), (1, 10106, 0), (1, 10107, 0);
INSERT INTO `sys_role_menu` VALUES (1, 102, 0), (1, 10201, 0), (1, 10202, 0), (1, 10203, 0), (1, 10204, 0), (1, 10205, 0);
INSERT INTO `sys_role_menu` VALUES (1, 203, 0), (1, 20301, 0), (1, 20302, 0), (1, 20303, 0), (1, 20304, 0);
INSERT INTO `sys_role_menu` VALUES (1, 208, 0), (1, 20801, 0), (1, 20802, 0), (1, 20803, 0), (1, 20804, 0), (1, 20805, 0);
-- 系统管理
INSERT INTO `sys_role_menu` VALUES (1, 201, 0), (1, 20101, 0), (1, 20102, 0), (1, 20103, 0), (1, 20104, 0), (1, 20105, 0), (1, 20106, 0), (1, 20107, 0);
INSERT INTO `sys_role_menu` VALUES (1, 202, 0), (1, 20201, 0), (1, 20202, 0), (1, 20203, 0), (1, 20204, 0), (1, 20205, 0);
INSERT INTO `sys_role_menu` VALUES (1, 204, 0), (1, 20401, 0), (1, 20402, 0), (1, 20403, 0), (1, 20404, 0);
INSERT INTO `sys_role_menu` VALUES (1, 205, 0), (1, 20501, 0), (1, 20502, 0), (1, 20503, 0), (1, 20504, 0);
INSERT INTO `sys_role_menu` VALUES (1, 206, 0), (1, 20601, 0), (1, 20602, 0), (1, 20603, 0), (1, 20604, 0);
INSERT INTO `sys_role_menu` VALUES (1, 207, 0);
INSERT INTO `sys_role_menu` VALUES (1, 209, 0), (1, 20901, 0), (1, 20902, 0), (1, 20903, 0), (1, 20904, 0), (1, 20905, 0), (1, 20906, 0);
-- 代码生成
INSERT INTO `sys_role_menu` VALUES (1, 301, 0);
-- 组件封装
INSERT INTO `sys_role_menu` VALUES (1, 40201, 0), (1, 40202, 0), (1, 40203, 0), (1, 40204, 0), (1, 40301, 0), (1, 40205, 0), (1, 40102, 0), (1, 40103, 0), (1, 40304, 0);
-- 功能演示 / 多级菜单
INSERT INTO `sys_role_menu` VALUES (1, 40101, 0), (1, 40104, 0), (1, 40303, 0), (1, 40302, 0), (1, 501, 0), (1, 50101, 0), (1, 5010101, 0), (1, 5010102, 0);
-- 路由示例
INSERT INTO `sys_role_menu` VALUES (1, 601, 0), (1, 602, 0), (1, 603, 0), (1, 604, 0), (1, 605, 0);
-- 应用管理（平台级）
INSERT INTO `sys_role_menu` VALUES (1, 103, 0), (1, 10301, 0), (1, 10302, 0), (1, 10303, 0), (1, 10304, 0), (1, 10305, 0);

-- ============================================
-- 系统管理员角色菜单权限（role_id=2）
-- 顶级目录
INSERT INTO `sys_role_menu` VALUES (2, 1, 0), (2, 2, 0), (2, 3, 0), (2, 4, 0), (2, 5, 0), (2, 6, 0);
 -- 平台管理
 INSERT INTO `sys_role_menu` VALUES (2, 101, 0), (2, 10101, 0), (2, 10102, 0), (2, 10103, 0), (2, 10104, 0), (2, 10105, 0), (2, 10106, 0), (2, 10107, 0);
 INSERT INTO `sys_role_menu` VALUES (2, 102, 0), (2, 10201, 0), (2, 10202, 0), (2, 10203, 0), (2, 10204, 0), (2, 10205, 0);
 -- 系统管理
 INSERT INTO `sys_role_menu` VALUES (2, 201, 0), (2, 20101, 0), (2, 20102, 0), (2, 20103, 0), (2, 20104, 0), (2, 20105, 0), (2, 20106, 0), (2, 20107, 0);
 INSERT INTO `sys_role_menu` VALUES (2, 202, 0), (2, 20201, 0), (2, 20202, 0), (2, 20203, 0), (2, 20204, 0), (2, 20205, 0);
 INSERT INTO `sys_role_menu` VALUES (2, 203, 0), (2, 20301, 0), (2, 20302, 0), (2, 20303, 0), (2, 20304, 0);
 INSERT INTO `sys_role_menu` VALUES (2, 204, 0), (2, 20401, 0), (2, 20402, 0), (2, 20403, 0), (2, 20404, 0);
 INSERT INTO `sys_role_menu` VALUES (2, 205, 0), (2, 20501, 0), (2, 20502, 0), (2, 20503, 0), (2, 20504, 0);
INSERT INTO `sys_role_menu` VALUES (2, 206, 0), (2, 20601, 0), (2, 20602, 0), (2, 20603, 0), (2, 20604, 0);
INSERT INTO `sys_role_menu` VALUES (2, 207, 0);
INSERT INTO `sys_role_menu` VALUES (2, 208, 0), (2, 20801, 0), (2, 20802, 0), (2, 20803, 0), (2, 20804, 0), (2, 20805, 0);
INSERT INTO `sys_role_menu` VALUES (2, 209, 0), (2, 20901, 0), (2, 20902, 0), (2, 20903, 0), (2, 20904, 0), (2, 20905, 0), (2, 20906, 0);
-- 代码生成
INSERT INTO `sys_role_menu` VALUES (2, 301, 0);
-- 组件封装
INSERT INTO `sys_role_menu` VALUES (2, 40201, 0), (2, 40202, 0), (2, 40203, 0), (2, 40204, 0), (2, 40301, 0), (2, 40205, 0), (2, 40102, 0), (2, 40103, 0), (2, 40304, 0);
-- 功能演示 / 多级菜单
INSERT INTO `sys_role_menu` VALUES (2, 40101, 0), (2, 40104, 0), (2, 40303, 0), (2, 40302, 0), (2, 501, 0), (2, 50101, 0), (2, 5010101, 0), (2, 5010102, 0);
-- 路由示例
INSERT INTO `sys_role_menu` VALUES (2, 601, 0), (2, 602, 0), (2, 603, 0), (2, 604, 0), (2, 605, 0);
-- 应用管理（平台级）
INSERT INTO `sys_role_menu` VALUES (2, 103, 0), (2, 10301, 0), (2, 10302, 0), (2, 10303, 0), (2, 10304, 0), (2, 10305, 0);

-- ============================================
-- 数据权限测试角色（tenant_id=0）- 最小可用菜单
-- ============================================
INSERT INTO `sys_role_menu` VALUES (4, 2, 0), (4, 201, 0), (4, 20101, 0), (4, 202, 0), (4, 20201, 0), (4, 204, 0), (4, 20401, 0), (4, 205, 0), (4, 20501, 0), (4, 207, 0), (4, 209, 0), (4, 20901, 0);
INSERT INTO `sys_role_menu` VALUES (5, 2, 0), (5, 201, 0), (5, 20101, 0), (5, 202, 0), (5, 20201, 0), (5, 204, 0), (5, 20401, 0), (5, 205, 0), (5, 20501, 0), (5, 207, 0), (5, 209, 0), (5, 20901, 0);
INSERT INTO `sys_role_menu` VALUES (6, 2, 0), (6, 201, 0), (6, 20101, 0), (6, 202, 0), (6, 20201, 0), (6, 204, 0), (6, 20401, 0), (6, 205, 0), (6, 20501, 0), (6, 207, 0), (6, 209, 0), (6, 20901, 0);
INSERT INTO `sys_role_menu` VALUES (7, 2, 0), (7, 201, 0), (7, 20101, 0), (7, 202, 0), (7, 20201, 0), (7, 204, 0), (7, 20401, 0), (7, 205, 0), (7, 20501, 0), (7, 207, 0), (7, 209, 0), (7, 20901, 0);

-- ============================================
-- 演示租户角色菜单权限（tenant_id=1）
-- ============================================
-- 演示租户管理员（role_id=13）- 拥有系统管理权限（不包含平台管理）
-- 顶级目录（仅系统管理相关）
INSERT INTO `sys_role_menu` VALUES (13, 2, 1), (13, 3, 1), (13, 4, 1), (13, 5, 1), (13, 6, 1);
-- 系统管理（租户侧）
INSERT INTO `sys_role_menu` VALUES (13, 201, 1), (13, 20101, 1), (13, 20102, 1), (13, 20103, 1), (13, 20104, 1), (13, 20105, 1), (13, 20106, 1), (13, 20107, 1);
INSERT INTO `sys_role_menu` VALUES (13, 202, 1), (13, 20201, 1), (13, 20202, 1), (13, 20203, 1), (13, 20204, 1), (13, 20205, 1);
INSERT INTO `sys_role_menu` VALUES (13, 204, 1), (13, 20401, 1), (13, 20402, 1), (13, 20403, 1), (13, 20404, 1);
INSERT INTO `sys_role_menu` VALUES (13, 205, 1), (13, 20501, 1), (13, 20502, 1), (13, 20503, 1), (13, 20504, 1);
INSERT INTO `sys_role_menu` VALUES (13, 206, 1), (13, 20601, 1), (13, 20602, 1), (13, 20603, 1), (13, 20604, 1);
INSERT INTO `sys_role_menu` VALUES (13, 207, 1);
INSERT INTO `sys_role_menu` VALUES (13, 209, 1), (13, 20901, 1), (13, 20902, 1), (13, 20903, 1), (13, 20904, 1), (13, 20905, 1), (13, 20906, 1);
-- 代码生成
INSERT INTO `sys_role_menu` VALUES (13, 301, 1);
-- 组件封装
INSERT INTO `sys_role_menu` VALUES (13, 40201, 1), (13, 40202, 1), (13, 40203, 1), (13, 40204, 1), (13, 40301, 1), (13, 40205, 1), (13, 40102, 1), (13, 40103, 1), (13, 40304, 1);
-- 功能演示 / 多级菜单
INSERT INTO `sys_role_menu` VALUES (13, 40101, 1), (13, 40104, 1), (13, 40303, 1), (13, 40302, 1), (13, 501, 1), (13, 50101, 1), (13, 5010101, 1), (13, 5010102, 1);
-- 路由示例
INSERT INTO `sys_role_menu` VALUES (13, 601, 1), (13, 602, 1), (13, 603, 1), (13, 604, 1), (13, 605, 1);

-- 演示租户系统管理员（role_id=15）- 复用演示租户管理员菜单权限
INSERT INTO `sys_role_menu` (role_id, menu_id, tenant_id)
 SELECT 15, menu_id, 1 FROM `sys_role_menu` WHERE role_id = 13 AND tenant_id = 1;

-- 演示普通用户（role_id=14）- 仅查看权限
INSERT INTO `sys_role_menu` VALUES (14, 2, 1), (14, 201, 1), (14, 20101, 1), (14, 202, 1), (14, 20201, 1), (14, 204, 1), (14, 20401, 1), (14, 205, 1), (14, 20501, 1), (14, 207, 1), (14, 209, 1), (14, 20901, 1);
INSERT INTO `sys_role_menu` VALUES (1, 20701, 0), (1, 401, 0), (1, 402, 0), (1, 403, 0);
INSERT INTO `sys_role_menu` VALUES (2, 20701, 0), (2, 401, 0), (2, 402, 0), (2, 403, 0);
-- ----------------------------
-- 表结构：sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `tenant_id` bigint DEFAULT 0 COMMENT '租户ID',
                              `username` varchar(64) COMMENT '用户名',
                             `nickname` varchar(64) COMMENT '昵称',
                             `gender` tinyint(1) DEFAULT 1 COMMENT '性别((1-男 2-女 0-保密)',
                             `password` varchar(100) COMMENT '密码',
                             `dept_id` bigint COMMENT '部门ID',
                             `avatar` varchar(255) COMMENT '用户头像',
                             `mobile` varchar(20) COMMENT '联系方式',
                             `status` tinyint(1) DEFAULT 1 COMMENT '状态(1-正常 0-禁用)',
                             `email` varchar(128) COMMENT '用户邮箱',
                             `create_time` datetime COMMENT '创建时间',
                             `create_by` bigint COMMENT '创建人ID',
                             `update_time` datetime COMMENT '更新时间',
                             `update_by` bigint COMMENT '修改人ID',
                             `is_deleted` tinyint(1) DEFAULT 0 COMMENT '逻辑删除标识(0-未删除 1-已删除)',
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE KEY `uk_username_tenant` (`username`, `tenant_id`, `is_deleted`),
                             KEY `idx_tenant_id` (`tenant_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '系统用户表';

-- ----------------------------
-- 表数据：sys_user
-- ----------------------------
-- 默认租户（tenant_id=0）的用户
INSERT INTO `sys_user` VALUES (1, 0, 'root', '平台租户超级管理员', 0, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', NULL, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345677', 1, 'youlaitech@163.com', now(), NULL, now(), NULL, 0);
INSERT INTO `sys_user` VALUES (2, 0, 'admin', '平台租户系统管理员', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 1, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18888888888', 1, 'youlaitech@163.com', now(), NULL, now(), NULL, 0);
INSERT INTO `sys_user` VALUES (3, 0, 'test', '平台租户测试天命人', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 3, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345679', 1, 'youlaitech@163.com', now(), NULL, now(), NULL, 0);
INSERT INTO `sys_user` VALUES (6, 0, 'dept_manager', '部门主管', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 1, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345680', 1, 'manager@youlaitech.com', now(), NULL, now(), NULL, 0);
INSERT INTO `sys_user` VALUES (7, 0, 'dept_member', '部门成员', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 1, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345681', 1, 'member@youlaitech.com', now(), NULL, now(), NULL, 0);
INSERT INTO `sys_user` VALUES (8, 0, 'employee', '普通员工', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 2, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345682', 1, 'employee@youlaitech.com', now(), NULL, now(), NULL, 0);
INSERT INTO `sys_user` VALUES (9, 0, 'custom_user', '自定义权限用户', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 3, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345683', 1, 'custom@youlaitech.com', now(), NULL, now(), NULL, 0);

-- 演示租户（tenant_id=1）的用户
INSERT INTO `sys_user` VALUES (4, 1, 'admin', '演示租户管理员', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 4, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345680', 1, 'demo@youlai.tech', now(), NULL, now(), NULL, 0);
INSERT INTO `sys_user` VALUES (5, 1, 'test', '演示测试人员', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', 6, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345681', 1, 'test@youlai.tech', now(), NULL, now(), NULL, 0);

-- ----------------------------
-- 表结构：sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
                                  `user_id` bigint NOT NULL COMMENT '用户ID',
                                  `role_id` bigint NOT NULL COMMENT '角色ID',
                                  `tenant_id` bigint DEFAULT 0 COMMENT '租户ID',
                                  PRIMARY KEY (`tenant_id`, `user_id`, `role_id`) USING BTREE,
                                  KEY `idx_user_role_tenant_id` (`tenant_id`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '用户角色关联表';

-- ----------------------------
-- 表数据：sys_user_role
-- ----------------------------
-- 默认租户（tenant_id=0）的用户角色关联
INSERT INTO `sys_user_role` VALUES (1, 1, 0);
INSERT INTO `sys_user_role` VALUES (2, 2, 0);
INSERT INTO `sys_user_role` VALUES (3, 3, 0);

INSERT INTO `sys_user_role` VALUES (6, 4, 0);
INSERT INTO `sys_user_role` VALUES (7, 5, 0);
INSERT INTO `sys_user_role` VALUES (8, 6, 0);
INSERT INTO `sys_user_role` VALUES (9, 7, 0);

-- 演示租户（tenant_id=1）的用户角色关联
INSERT INTO `sys_user_role` VALUES (4, 13, 1);
INSERT INTO `sys_user_role` VALUES (4, 15, 1);
INSERT INTO `sys_user_role` VALUES (5, 14, 1);


-- ----------------------------
-- 表结构：sys_user_social
-- ----------------------------
-- 用户第三方账号绑定表（扫码登录、微信小程序登录）
-- 唯一键含 tenant_id：openid 只在单个微信应用内唯一
DROP TABLE IF EXISTS `sys_user_social`;
CREATE TABLE `sys_user_social`  (
                                    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
                                    `tenant_id` bigint DEFAULT 0 COMMENT '租户ID',
                                    `user_id` bigint NOT NULL COMMENT '用户ID',
                                    `platform` varchar(20) NOT NULL COMMENT '平台类型(WECHAT_MINI/WECHAT_MP/ALIPAY/QQ/APPLE)',
                                    `openid` varchar(64) NOT NULL COMMENT '平台openid',
                                    `unionid` varchar(64) DEFAULT NULL COMMENT '微信unionid',
                                    `nickname` varchar(64) DEFAULT NULL COMMENT '第三方昵称',
                                    `avatar` varchar(255) DEFAULT NULL COMMENT '第三方头像URL',
                                    `session_key` varchar(128) DEFAULT NULL COMMENT '微信session_key',
                                    `verified` tinyint(1) DEFAULT 1 COMMENT '是否已验证(1-已验证 0-未验证)',
                                    `create_time` datetime DEFAULT NULL COMMENT '绑定时间',
                                    `update_time` datetime DEFAULT NULL COMMENT '更新时间',
                                    PRIMARY KEY (`id`) USING BTREE,
                                    UNIQUE KEY `uk_tenant_platform_openid` (`tenant_id`, `platform`, `openid`),
                                    KEY `idx_user_id` (`user_id`),
                                    KEY `idx_unionid` (`unionid`)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COMMENT = '用户第三方账号绑定表';


-- ----------------------------
-- 表结构：sys_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_log`;
CREATE TABLE `sys_log` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    `tenant_id` BIGINT DEFAULT 0 COMMENT '租户ID',
    `module` TINYINT NOT NULL COMMENT '模块，数字枚举，参考 LogModule 枚举',
    `action_type` TINYINT NOT NULL COMMENT '操作类型，数字枚举，参考 ActionType 枚举',
    `title` VARCHAR(100) NOT NULL COMMENT '前端显示标题',
    `content` VARCHAR(500) COMMENT '自定义日志内容',
    `operator_id` BIGINT COMMENT '操作人ID',
    `operator_name` VARCHAR(50) COMMENT '操作人名称',
    `request_uri` VARCHAR(255) COMMENT '请求路径',
    `request_method` VARCHAR(10) COMMENT '请求方法',
    `ip` VARCHAR(45) COMMENT 'IP地址',
    `province` VARCHAR(100) COMMENT '省份',
    `city` VARCHAR(100) COMMENT '城市',
    `device` VARCHAR(100) COMMENT '设备',
    `os` VARCHAR(100) COMMENT '操作系统',
    `browser` VARCHAR(100) COMMENT '浏览器',
    `status` TINYINT DEFAULT 1 COMMENT '0失败 1成功',
    `error_msg` VARCHAR(1000) COMMENT '错误信息',
    `execution_time` INT COMMENT '执行时间(ms)',
    `create_time` DATETIME COMMENT '操作时间',
    PRIMARY KEY (`id`) USING BTREE,
    KEY `idx_tenant_module_action` (`tenant_id`, `module`, `action_type`, `create_time`),
    KEY `idx_tenant_operator` (`tenant_id`, `operator_id`, `create_time`),
    KEY `idx_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统操作日志表';

-- ----------------------------
-- 表结构：gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table` (
                              `id` bigint NOT NULL AUTO_INCREMENT,
                              `table_name` varchar(100) NOT NULL COMMENT '表名',
                              `module_name` varchar(100) COMMENT '模块名',
                              `package_name` varchar(255) NOT NULL COMMENT '包名',
                              `business_name` varchar(100) NOT NULL COMMENT '业务名',
                              `entity_name` varchar(100) NOT NULL COMMENT '实体类名',
                              `author` varchar(50) NOT NULL COMMENT '作者',
                              `parent_menu_id` bigint COMMENT '上级菜单ID，对应sys_menu的id ',
                              `remove_table_prefix` varchar(20) COMMENT '要移除的表前缀，如: sys_',
                              `page_type` varchar(20) COMMENT '页面类型(classic|crud)',
                              `create_time` datetime COMMENT '创建时间',
                              `update_time` datetime COMMENT '更新时间',
                              `is_deleted` tinyint(4) DEFAULT 0 COMMENT '是否删除',
                              PRIMARY KEY (`id`),
                              UNIQUE KEY `uk_tablename` (`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代码生成配置表';

-- ----------------------------
-- 表结构：gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column` (
                                    `id` bigint NOT NULL AUTO_INCREMENT,
                                    `table_id` bigint NOT NULL COMMENT '关联的表配置ID',
                                    `column_name` varchar(100)  ,
                                    `column_type` varchar(50)  ,
                                    `column_length` int ,
                                    `field_name` varchar(100) NOT NULL COMMENT '字段名称',
                                    `field_type` varchar(100) COMMENT '字段类型',
                                    `field_sort` int COMMENT '字段排序',
                                    `field_comment` varchar(255) COMMENT '字段描述',
                                    `max_length` int ,
                                    `is_required` tinyint(1) COMMENT '是否必填',
                                    `is_show_in_list` tinyint(1) DEFAULT '0' COMMENT '是否在列表显示',
                                    `is_show_in_form` tinyint(1) DEFAULT '0' COMMENT '是否在表单显示',
                                    `is_show_in_query` tinyint(1) DEFAULT '0' COMMENT '是否在查询条件显示',
                                    `query_type` tinyint COMMENT '查询方式',
                                    `form_type` tinyint COMMENT '表单类型',
                                    `dict_type` varchar(50) COMMENT '字典类型',
                                    `create_time` datetime COMMENT '创建时间',
                                    `update_time` datetime COMMENT '更新时间',
                                    PRIMARY KEY (`id`),
                                    KEY `idx_table_id` (`table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代码生成字段配置表';

-- ----------------------------
-- 系统配置表
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
                              `id` bigint NOT NULL AUTO_INCREMENT,
                              `config_name` varchar(50) NOT NULL COMMENT '配置名称',
                              `config_key` varchar(50) NOT NULL COMMENT '配置key',
                              `config_value` varchar(100) NOT NULL COMMENT '配置值',
                              `remark` varchar(255) COMMENT '备注',
                              `create_time` datetime COMMENT '创建时间',
                              `create_by` bigint COMMENT '创建人ID',
                              `update_time` datetime COMMENT '更新时间',
                              `update_by` bigint COMMENT '更新人ID',
                              `is_deleted` tinyint(4) DEFAULT '0' NOT NULL COMMENT '逻辑删除标识(0-未删除 1-已删除)',
                              PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

INSERT INTO `sys_config` VALUES (1, '系统限流QPS', 'IP_QPS_THRESHOLD_LIMIT', '10', '单个IP请求的最大每秒查询数（QPS）阈值Key', now(), 1, NULL, NULL, 0);

-- ----------------------------
-- 通知公告表
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice` (
                              `id` bigint NOT NULL AUTO_INCREMENT,
                              `tenant_id` bigint DEFAULT 0 COMMENT '租户ID',
                              `title` varchar(50) COMMENT '通知标题',
                              `content` text COMMENT '通知内容',
                              `type` tinyint NOT NULL COMMENT '通知类型（关联字典编码：notice_type）',
                              `level` varchar(5) NOT NULL COMMENT '通知等级（字典code：notice_level）',
                              `target_type` tinyint NOT NULL COMMENT '目标类型（1: 全体, 2: 指定）',
                              `target_user_ids` varchar(255) COMMENT '目标人ID集合（多个使用英文逗号,分割）',
                              `publisher_id` bigint COMMENT '发布人ID',
                              `publish_status` tinyint DEFAULT '0' COMMENT '发布状态（0: 未发布, 1: 已发布, -1: 已撤回）',
                              `publish_time` datetime COMMENT '发布时间',
                              `revoke_time` datetime COMMENT '撤回时间',
                              `create_by` bigint NOT NULL COMMENT '创建人ID',
                              `create_time` datetime NOT NULL COMMENT '创建时间',
                              `update_by` bigint COMMENT '更新人ID',
                              `update_time` datetime COMMENT '更新时间',
                              `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除（0: 未删除, 1: 已删除）',
                              PRIMARY KEY (`id`) USING BTREE,
                              KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统通知公告表';

INSERT INTO `sys_notice` VALUES (1, 0, 'v3.0.0 版本发布 - 多租户功能上线', '<p>🎉 新版本发布，主要更新内容：</p><p>1. 新增多租户功能，支持租户隔离和数据管理</p><p>2. 优化系统性能，提升响应速度</p><p>3. 完善权限管理，增强安全性</p><p>4. 修复已知问题，提升系统稳定性</p>', 1, 'H', 1, NULL, 1, 1, '2024-12-15 10:00:00', NULL, 1, '2024-12-15 10:00:00', 1, '2024-12-15 10:00:00', 0);
INSERT INTO `sys_notice` VALUES (2, 0, '系统维护通知 - 2024年12月20日', '<p>⏰ 系统维护通知</p><p>系统将于 <strong>2024年12月20日（本周五）凌晨 2:00-4:00</strong> 进行例行维护升级。</p><p>维护期间系统将暂停服务，请提前做好数据备份工作。</p><p>给您带来的不便，敬请谅解！</p>', 2, 'H', 1, NULL, 1, 1, '2024-12-18 14:30:00', NULL, 1, '2024-12-18 14:30:00', 1, '2024-12-18 14:30:00', 0);
INSERT INTO `sys_notice` VALUES (3, 0, '安全提醒 - 防范钓鱼邮件', '<p>⚠️ 安全提醒</p><p>近期发现有不法分子通过钓鱼邮件进行网络攻击，请大家提高警惕：</p><p>1. 不要点击来源不明的邮件链接</p><p>2. 不要下载可疑附件</p><p>3. 遇到可疑邮件请及时联系IT部门</p><p>4. 定期修改密码，使用强密码策略</p>', 3, 'H', 1, NULL, 1, 1, '2024-12-10 09:00:00', NULL, 1, '2024-12-10 09:00:00', 1, '2024-12-10 09:00:00', 0);
INSERT INTO `sys_notice` VALUES (4, 0, '元旦假期安排通知', '<p>📅 元旦假期安排</p><p>根据国家法定节假日安排，公司元旦假期时间为：</p><p><strong>2024年12月30日（周一）至 2025年1月1日（周三）</strong>，共3天。</p><p>2024年12月29日（周日）正常上班。</p><p>祝大家元旦快乐，假期愉快！</p>', 4, 'M', 1, NULL, 1, 1, '2024-12-25 16:00:00', NULL, 1, '2024-12-25 16:00:00', 1, '2024-12-25 16:00:00', 0);
INSERT INTO `sys_notice` VALUES (5, 0, '新产品发布会邀请', '<p>🎊 新产品发布会邀请</p><p>公司将于 <strong>2025年1月15日下午14:00</strong> 在总部会议室举办新产品发布会。</p><p>届时将展示最新研发的产品和技术成果，欢迎全体员工参加。</p><p>请各部门提前安排好工作，准时参加。</p>', 5, 'M', 1, NULL, 1, 1, '2024-12-28 11:00:00', NULL, 1, '2024-12-28 11:00:00', 1, '2024-12-28 11:00:00', 0);
INSERT INTO `sys_notice` VALUES (6, 0, 'v2.16.1 版本更新', '<p>✨ 版本更新</p><p>v2.16.1 版本已发布，主要修复内容：</p><p>1. 修复 WebSocket 重复连接导致的后台线程阻塞问题</p><p>2. 优化通知公告功能，提升用户体验</p><p>3. 修复部分已知bug</p><p>建议尽快更新到最新版本。</p>', 1, 'M', 1, NULL, 1, 1, '2024-12-05 15:30:00', NULL, 1, '2024-12-05 15:30:00', 1, '2024-12-05 15:30:00', 0);
INSERT INTO `sys_notice` VALUES (7, 0, '年终总结会议通知', '<p>📋 年终总结会议通知</p><p>各部门年终总结会议将于 <strong>2024年12月30日上午9:00</strong> 召开。</p><p>请各部门负责人提前准备好年度工作总结和下年度工作计划。</p><p>会议地点：总部大会议室</p>', 5, 'M', 2, '1,2', 1, 1, '2024-12-22 10:00:00', NULL, 1, '2024-12-22 10:00:00', 1, '2024-12-22 10:00:00', 0);
INSERT INTO `sys_notice` VALUES (8, 0, '系统功能优化完成', '<p>✅ 系统功能优化</p><p>已完成以下功能优化：</p><p>1. 优化用户管理界面，提升操作体验</p><p>2. 增强数据导出功能，支持更多格式</p><p>3. 优化搜索功能，提升查询效率</p><p>4. 修复部分界面显示问题</p>', 1, 'L', 1, NULL, 1, 1, '2024-12-12 14:20:00', NULL, 1, '2024-12-12 14:20:00', 1, '2024-12-12 14:20:00', 0);
INSERT INTO `sys_notice` VALUES (9, 0, '员工培训计划', '<p>📚 员工培训计划</p><p>为提升员工专业技能，公司将于 <strong>2025年1月8日-10日</strong> 组织技术培训。</p><p>培训内容：</p><p>1. 新技术框架应用</p><p>2. 代码规范与最佳实践</p><p>3. 系统架构设计</p><p>请各部门合理安排工作，确保培训顺利进行。</p>', 5, 'M', 1, NULL, 1, 1, '2024-12-20 09:30:00', NULL, 1, '2024-12-20 09:30:00', 1, '2024-12-20 09:30:00', 0);
INSERT INTO `sys_notice` VALUES (10, 0, '数据备份提醒', '<p>💾 数据备份提醒</p><p>请各部门注意定期备份重要数据，建议每周至少备份一次。</p><p>备份方式：</p><p>1. 使用系统自带备份功能</p><p>2. 手动导出重要数据</p><p>3. 联系IT部门协助备份</p><p>数据安全，人人有责！</p>', 3, 'L', 1, NULL, 1, 1, '2024-12-08 08:00:00', NULL, 1, '2024-12-08 08:00:00', 1, '2024-12-08 08:00:00', 0);

-- ----------------------------
-- 用户通知公告表
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_notice`;
CREATE TABLE `sys_user_notice` (
                                   `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
                                   `notice_id` bigint NOT NULL COMMENT '公共通知id',
                                   `user_id` bigint NOT NULL COMMENT '用户id',
                                   `tenant_id` bigint DEFAULT 0 COMMENT '租户ID',
                                   `is_read` tinyint DEFAULT '0' COMMENT '读取状态（0: 未读, 1: 已读）',
                                   `read_time` datetime COMMENT '阅读时间',
                                   `create_time` datetime NOT NULL COMMENT '创建时间',
                                   `update_time` datetime COMMENT '更新时间',
                                   `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除(0: 未删除, 1: 已删除)',
                                   PRIMARY KEY (`id`) USING BTREE,
                                   KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户通知公告关联表';

INSERT INTO `sys_user_notice` VALUES (1, 1, 2, 0, 1, NULL, now(), now(), 0);
INSERT INTO `sys_user_notice` VALUES (2, 2, 2, 0, 1, NULL, now(), now(), 0);
INSERT INTO `sys_user_notice` VALUES (3, 3, 2, 0, 1, NULL, now(), now(), 0);
INSERT INTO `sys_user_notice` VALUES (4, 4, 2, 0, 1, NULL, now(), now(), 0);
INSERT INTO `sys_user_notice` VALUES (5, 5, 2, 0, 1, NULL, now(), now(), 0);
INSERT INTO `sys_user_notice` VALUES (6, 6, 2, 0, 1, NULL, now(), now(), 0);
INSERT INTO `sys_user_notice` VALUES (7, 7, 2, 0, 1, NULL, now(), now(), 0);
INSERT INTO `sys_user_notice` VALUES (8, 8, 2, 0, 1, NULL, now(), now(), 0);
INSERT INTO `sys_user_notice` VALUES (9, 9, 2, 0, 1, NULL, now(), now(), 0);
INSERT INTO `sys_user_notice` VALUES (10, 10, 2, 0, 1, NULL, now(), now(), 0);

-- ----------------------------
-- 租户表（多租户模式）
-- ----------------------------
DROP TABLE IF EXISTS `sys_tenant`;
CREATE TABLE `sys_tenant` (
                              `id` bigint NOT NULL AUTO_INCREMENT COMMENT '租户ID',
                              `name` varchar(100) NOT NULL COMMENT '租户名称',
                              `code` varchar(50) NOT NULL COMMENT '租户编码（唯一）',
                              `contact_name` varchar(50) DEFAULT NULL COMMENT '联系人姓名',
                              `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系人电话',
                              `contact_email` varchar(100) DEFAULT NULL COMMENT '联系人邮箱',
                              `domain` varchar(100) DEFAULT NULL COMMENT '租户域名（用于域名识别）',
                              `logo` varchar(255) DEFAULT NULL COMMENT '租户Logo',
                              `plan_id` bigint DEFAULT NULL COMMENT '套餐ID',
                              `status` tinyint DEFAULT '1' COMMENT '状态(1-正常 0-禁用)',
                              `remark` varchar(500) DEFAULT NULL COMMENT '备注',
                              `expire_time` datetime DEFAULT NULL COMMENT '过期时间（NULL表示永不过期）',
                              `create_time` datetime COMMENT '创建时间',
                              `update_time` datetime COMMENT '更新时间',
                              PRIMARY KEY (`id`),
                              UNIQUE KEY `uk_code` (`code`),
                              UNIQUE KEY `uk_domain` (`domain`),
                              KEY `idx_status` (`status`),
                              KEY `idx_plan_id` (`plan_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='系统租户表';

-- ----------------------------
-- 表数据：sys_tenant
-- ----------------------------
INSERT INTO `sys_tenant` (
  `id`,
  `name`,
  `code`,
  `contact_name`,
  `contact_phone`,
  `contact_email`,
  `domain`,
  `logo`,
  `plan_id`,
  `status`,
  `remark`,
  `expire_time`,
  `create_time`,
  `update_time`
) VALUES
  (0, '平台租户', 'PLATFORM', '系统管理员', '18888888888', 'admin@youlai.tech', 'vue.youlai.tech', NULL, NULL, 1, '平台租户', NULL, now(), now()),
  (1, '演示租户', 'DEMO', '演示用户', '18812345679', 'demo@youlai.tech', 'demo.youlai.tech', NULL, 2, 1, '演示租户', NULL, now(), now());

-- ----------------------------
-- 应用管理表（平台级，记录各渠道小程序的 AppId/密钥与归属租户）
-- ----------------------------
DROP TABLE IF EXISTS `sys_app`;
CREATE TABLE `sys_app`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app_name` varchar(100) NOT NULL COMMENT '应用名称',
  `app_code` varchar(100) NOT NULL COMMENT '应用编码',
  `platform` varchar(20) NOT NULL COMMENT '平台(wechat-mp/wechat-oa/alipay-mp)',
  `app_id` varchar(64) NOT NULL COMMENT '微信/支付宝分配的 AppId',
  `app_secret` varchar(256) DEFAULT NULL COMMENT '应用密钥',
  `merchant_id` varchar(64) DEFAULT NULL COMMENT '商户号',
  `merchant_key` varchar(512) DEFAULT NULL COMMENT '商户密钥',
  `status` tinyint DEFAULT 1 COMMENT '状态(1-启用 0-停用)',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `tenant_id` bigint DEFAULT 0 COMMENT '归属租户ID(0 表示平台级)',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT 0 COMMENT '逻辑删除(0-否 1-是)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_app_code` (`app_code`),
  UNIQUE KEY `uk_app_id` (`app_id`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='应用管理表';

SET FOREIGN_KEY_CHECKS = 1;


