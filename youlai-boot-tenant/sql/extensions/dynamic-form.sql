# 动态表单模块（可选扩展）
# Copyright (c) 2026-present, youlai.tech

-- ----------------------------------------------------------------------------
-- 动态表单模块扩展脚本（全量执行，可重复运行）
-- 前置：请先执行 ../youlai_admin_tenant.sql
--
-- 三张业务表均带 tenant_id，由 MyBatis-Plus 租户拦截器自动隔离（不入 ignore-tables）
-- 菜单段不写 always_show，scope 走默认值 2（业务菜单）
-- 菜单需额外登记 sys_tenant_menu / sys_tenant_plan_menu，授权写 3 列（含 tenant_id）
--
-- 示例表单 ID 段：平台租户(0) = 1001-1003，演示租户(1) = 1011-1013。
-- 后续工作流扩展使用 1004-1007(租户0) / 1014-1017(租户1)。
-- ----------------------------------------------------------------------------

USE `youlai_admin_tenant`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 表结构：form_definition
-- ----------------------------
DROP TABLE IF EXISTS `form_definition`;
CREATE TABLE `form_definition` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `form_key` varchar(64) NOT NULL COMMENT '表单唯一标识（业务编码，如 employee_onboarding）',
  `form_name` varchar(100) NOT NULL COMMENT '表单名称',
  `description` varchar(255) DEFAULT NULL COMMENT '表单描述',
  `form_json` json NOT NULL COMMENT '表单规则（form-create rule 数组）',
  `options_json` json DEFAULT NULL COMMENT '表单全局配置（labelPosition/size/submitBtn 等）',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态(0草稿 1已发布 -1已停用)',
  `is_public` tinyint NOT NULL DEFAULT 0 COMMENT '是否允许匿名公开访问(0否 1是)',
  `category` varchar(16) NOT NULL DEFAULT 'normal' COMMENT '表单类型(normal通用表单 workflow审批表单)',
  `menu_id` bigint DEFAULT NULL COMMENT '生成的访问菜单ID（NULL未生成，幂等防重复）',
  `version` int NOT NULL DEFAULT 1 COMMENT '版本号，每次发布+1',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除(0未删 1已删)',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_form_key` (`tenant_id`, `form_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='表单定义表';

-- ----------------------------
-- 表结构：form_data
-- ----------------------------
DROP TABLE IF EXISTS `form_data`;
CREATE TABLE `form_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `form_id` bigint NOT NULL COMMENT '表单定义ID',
  `form_version` int NOT NULL COMMENT '表单版本（提交时快照）',
  `data_json` json NOT NULL COMMENT '表单数据（field -> value 映射）',
  `create_by` bigint DEFAULT NULL COMMENT '提交人ID（匿名提交为空）',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID（数据修正时记录）',
  `create_time` datetime NOT NULL COMMENT '提交时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除(0未删 1已删)',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_form_id` (`tenant_id`, `form_id`),
  KEY `idx_tenant_create_by` (`tenant_id`, `create_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='表单数据表';

-- ----------------------------
-- 表结构：form_snapshot
-- ----------------------------
-- 版本快照表：发布时固化规则，数据回显按提交时版本加载，
-- 防止表单定义变更（字段删除/改名）导致历史数据回显漂移；
-- 快照只增不改，update_time 仅因实体继承 BaseEntity 保留列，无业务语义
DROP TABLE IF EXISTS `form_snapshot`;
CREATE TABLE `form_snapshot` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `form_id` bigint NOT NULL COMMENT '表单定义ID',
  `version` int NOT NULL COMMENT '版本号（发布时递增后的值）',
  `form_json` json NOT NULL COMMENT '表单规则快照（form-create rule 数组）',
  `options_json` json DEFAULT NULL COMMENT '表单全局配置快照',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除(0未删 1已删)',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_form_version` (`tenant_id`, `form_id`, `version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='表单版本快照表';

-- ----------------------------
-- 菜单（扩展段顶级 ID=8，基础段 1-7 见 youlai_admin_tenant.sql）
-- scope 走默认值 2（业务菜单）：由 youlai_admin_tenant.sql 的 scope init 语句
-- 把「平台管理」(id=1 及其子树) 标为 1，其余一律为业务菜单。
-- ----------------------------
-- params 携 {"badge":"NEW"}：挂顶级"动态表单"一级可见（二级折叠态角标不可见），宣传期过后清空 params 即消失
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (8, 0, '0', '动态表单', 'C', '', '/dynamic-form', 'Layout', NULL, NULL, 1, 8, 'el-icon-Document', '/dynamic-form/definition', now(), now(), '{"badge":"NEW"}');
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (801, 8, '0,8', '表单列表', 'M', 'FormDefinition', 'definition', 'dynamic-form/index', NULL, 1, 1, 1, 'el-icon-List', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (80101, 801, '0,8,801', '表单查询', 'B', NULL, '', NULL, 'form:definition:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (80102, 801, '0,8,801', '表单新增', 'B', NULL, '', NULL, 'form:definition:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (80103, 801, '0,8,801', '表单修改', 'B', NULL, '', NULL, 'form:definition:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (80104, 801, '0,8,801', '表单删除', 'B', NULL, '', NULL, 'form:definition:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
-- 表单设计器（隐藏菜单，visible=0，列表"设计"按钮携 id 跳转）
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (803, 8, '0,8', '表单设计器', 'M', 'FormDesigner', 'designer', 'dynamic-form/designer', NULL, 1, 0, 3, '', NULL, now(), now(), NULL);
-- 表单预览（隐藏菜单，visible=0，设计器"预览"按钮携 id 跳转，运行态真预览）
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (804, 8, '0,8', '表单预览', 'M', 'FormPreview', 'preview', 'dynamic-form/preview', NULL, 1, 0, 4, '', NULL, now(), now(), NULL);
-- 表单数据（隐藏菜单，visible=0，列表"数据"按钮携 formKey 跳转）
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (802, 8, '0,8', '表单数据', 'M', 'FormData', 'data', 'dynamic-form/data', NULL, 1, 0, 2, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (80201, 802, '0,8,802', '数据查询', 'B', NULL, '', NULL, 'form:data:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (80202, 802, '0,8,802', '数据删除', 'B', NULL, '', NULL, 'form:data:delete', NULL, 1, 2, '', NULL, now(), now(), NULL);

-- ----------------------------
-- 示例表单入口（预置双入口：内嵌菜单 + 公开外链；与 saveFormMenu 生成的结构完全一致——
--   type=M、component=dynamic-form/render、route_path=formKey、params 携 formKey、
--   route_name 遵循 FormRender+驼峰(formKey) 全局唯一约束，防发布向导重复生成）
-- ----------------------------
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (805, 8, '0,8', '表单示例', 'C', '', 'sample', 'Layout', NULL, NULL, 1, 5, 'el-icon-Files', '/dynamic-form/sample/open_source_survey', now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (80501, 805, '0,8,805', '开源项目问卷收集', 'M', 'FormRenderOpenSourceSurvey', 'open_source_survey', 'dynamic-form/render', NULL, NULL, 1, 1, 'el-icon-Tickets', NULL, now(), now(), '{"formKey":"open_source_survey"}');
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (80502, 805, '0,8,805', '活动报名表', 'M', 'FormRenderActivityRegistration', 'activity_registration', 'dynamic-form/render', NULL, NULL, 1, 2, 'el-icon-Calendar', NULL, now(), now(), '{"formKey":"activity_registration"}');
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (80503, 805, '0,8,805', '意见反馈', 'M', 'FormRenderFeedback', 'feedback', 'dynamic-form/render', NULL, NULL, 1, 3, 'el-icon-ChatLineRound', NULL, now(), now(), '{"formKey":"feedback"}');

-- ----------------------------
-- 菜单的租户 / 套餐登记
-- 主脚本里的 sys_tenant_menu、sys_tenant_plan_menu 是 INSERT...SELECT 派生的，
-- 执行时新菜单尚不存在，故此处为 ID=8 段补登记（与主脚本同一口径：租户0 全量、租户1 与套餐2 取 scope=2）
-- ----------------------------
INSERT IGNORE INTO `sys_tenant_menu` (tenant_id, menu_id)
SELECT 0, id FROM `sys_menu` WHERE id = 8 OR tree_path LIKE '0,8%';

INSERT IGNORE INTO `sys_tenant_menu` (tenant_id, menu_id)
SELECT 1, id FROM `sys_menu` WHERE (id = 8 OR tree_path LIKE '0,8%') AND scope = 2;

INSERT IGNORE INTO `sys_tenant_plan_menu` (plan_id, menu_id)
SELECT 2, id FROM `sys_menu` WHERE (id = 8 OR tree_path LIKE '0,8%') AND scope = 2;

-- ----------------------------
-- 角色菜单授权（sys_role_menu 为 3 列：role_id, menu_id, tenant_id）
--   平台租户(0)：role 2 = 系统管理员 ADMIN
--   演示租户(1)：role 13 = DEMO_ADMIN、role 15 = ADMIN
-- ----------------------------
INSERT IGNORE INTO `sys_role_menu` VALUES
(2, 8, 0), (2, 801, 0), (2, 80101, 0), (2, 80102, 0), (2, 80103, 0), (2, 80104, 0),
(2, 802, 0), (2, 80201, 0), (2, 80202, 0), (2, 803, 0), (2, 804, 0), (2, 805, 0),
(2, 80501, 0), (2, 80502, 0), (2, 80503, 0);

INSERT IGNORE INTO `sys_role_menu` VALUES
(13, 8, 1), (13, 801, 1), (13, 80101, 1), (13, 80102, 1), (13, 80103, 1), (13, 80104, 1),
(13, 802, 1), (13, 80201, 1), (13, 80202, 1), (13, 803, 1), (13, 804, 1), (13, 805, 1),
(13, 80501, 1), (13, 80502, 1), (13, 80503, 1);

INSERT IGNORE INTO `sys_role_menu` VALUES
(15, 8, 1), (15, 801, 1), (15, 80101, 1), (15, 80102, 1), (15, 80103, 1), (15, 80104, 1),
(15, 802, 1), (15, 80201, 1), (15, 80202, 1), (15, 803, 1), (15, 804, 1), (15, 805, 1),
(15, 80501, 1), (15, 80502, 1), (15, 80503, 1);

-- ----------------------------
-- 预置示例表单（开箱即用，覆盖常用组件类型）
-- 平台租户(0) ID 段 1001-1003；演示租户(1) ID 段 1011-1013
-- 已发布（status=1）+ 双入口预置：
--   内嵌：菜单 80501/80502/80503（动态表单 > 表单示例），menu_id 已回填，发布向导"入口管理"可直接改挂载/角色
--   外链：is_public=1，匿名访问 /f/{form_key}（问卷/报名/反馈天然适合对外收集）
-- ----------------------------
INSERT IGNORE INTO `form_definition` (`id`, `tenant_id`, `form_key`, `form_name`, `description`, `form_json`, `options_json`, `status`, `is_public`, `menu_id`, `version`, `create_time`, `update_time`, `create_by`, `update_by`, `is_deleted`) VALUES
(1001, 0, 'open_source_survey', '开源项目问卷收集', '面向社区的开源项目推荐与信息收集问卷', '[{"type":"input","field":"project_name","title":"项目名称","info":"","props":{"placeholder":"如 vue3-element-admin"},"validate":[{"required":true,"message":"请输入项目名称"}]},{"type":"input","field":"repo_url","title":"项目地址","info":"","props":{"placeholder":"https://github.com/xxx/xxx"},"validate":[{"required":true,"message":"请输入项目地址"}]},{"type":"select","field":"category","title":"项目领域","info":"","props":{},"options":[{"label":"前端","value":"frontend"},{"label":"后端","value":"backend"},{"label":"移动端","value":"mobile"},{"label":"AI 与大模型","value":"ai"},{"label":"开发工具","value":"tools"},{"label":"其他","value":"other"}],"validate":[{"required":true,"message":"请选择项目领域"}]},{"type":"radio","field":"license","title":"开源协议","info":"","options":[{"label":"MIT","value":"MIT"},{"label":"Apache-2.0","value":"Apache-2.0"},{"label":"GPLv3","value":"GPLv3"},{"label":"其他","value":"other"}]},{"type":"select","field":"stars","title":"Star 数量级","info":"","props":{},"options":[{"label":"100 以内","value":"lt100"},{"label":"100 ~ 1k","value":"100to1k"},{"label":"1k ~ 10k","value":"1kto10k"},{"label":"10k 以上","value":"gt10k"}]},{"type":"textarea","field":"recommend","title":"推荐理由","info":"","props":{"placeholder":"一句话说说它解决了什么问题"},"validate":[{"required":true,"message":"请填写推荐理由"}]},{"type":"input","field":"contact","title":"联系邮箱","info":"","props":{"placeholder":"选填，便于回访"}}]', '{"labelPosition":"right","size":"default"}', 1, 1, 80501, 1, now(), now(), NULL, NULL, 0),
(1002, 0, 'activity_registration', '活动报名表', '线下活动/聚会报名登记，含场次选择与用餐需求', '[{"type":"input","field":"name","title":"姓名","info":"","props":{},"validate":[{"required":true,"message":"请输入姓名"}]},{"type":"input","field":"phone","title":"手机号码","info":"","props":{"placeholder":"用于接收活动通知"},"validate":[{"required":true,"message":"请输入手机号码"}]},{"type":"radio","field":"gender","title":"性别","info":"","options":[{"label":"男","value":"male"},{"label":"女","value":"female"}]},{"type":"checkbox","field":"sessions","title":"参加场次","info":"","options":[{"label":"主论坛","value":"main"},{"label":"工作坊 A","value":"workshop_a"},{"label":"工作坊 B","value":"workshop_b"},{"label":"晚间交流","value":"evening"}]},{"type":"inputNumber","field":"attendees","title":"同行人数","info":"","props":{"min":0,"max":10}},{"type":"radio","field":"dinner","title":"用餐需求","info":"","options":[{"label":"正常","value":"normal"},{"label":"素食","value":"vegetarian"},{"label":"无需用餐","value":"none"}]},{"type":"textarea","field":"remark","title":"备注","info":"","props":{"placeholder":"选填"}}]', '{"labelPosition":"right","size":"default"}', 1, 1, 80502, 1, now(), now(), NULL, NULL, 0),
(1003, 0, 'feedback', '意见反馈', '产品/系统通用意见反馈表，含满意度评分', '[{"type":"select","field":"type","title":"反馈类型","info":"","props":{},"options":[{"label":"功能建议","value":"feature"},{"label":"问题报告","value":"bug"},{"label":"体验吐槽","value":"ux"},{"label":"其他","value":"other"}],"validate":[{"required":true,"message":"请选择反馈类型"}]},{"type":"rate","field":"rating","title":"整体满意度","info":"","props":{}},{"type":"textarea","field":"content","title":"反馈内容","info":"","props":{"placeholder":"请具体描述你的建议或遇到的问题"},"validate":[{"required":true,"message":"请填写反馈内容"}]},{"type":"input","field":"contact","title":"联系方式","info":"","props":{"placeholder":"选填，便于跟进回复"}}]', '{"labelPosition":"right","size":"default"}', 1, 1, 80503, 1, now(), now(), NULL, NULL, 0),
(1011, 1, 'open_source_survey', '开源项目问卷收集', '面向社区的开源项目推荐与信息收集问卷', '[{"type":"input","field":"project_name","title":"项目名称","info":"","props":{"placeholder":"如 vue3-element-admin"},"validate":[{"required":true,"message":"请输入项目名称"}]},{"type":"input","field":"repo_url","title":"项目地址","info":"","props":{"placeholder":"https://github.com/xxx/xxx"},"validate":[{"required":true,"message":"请输入项目地址"}]},{"type":"select","field":"category","title":"项目领域","info":"","props":{},"options":[{"label":"前端","value":"frontend"},{"label":"后端","value":"backend"},{"label":"移动端","value":"mobile"},{"label":"AI 与大模型","value":"ai"},{"label":"开发工具","value":"tools"},{"label":"其他","value":"other"}],"validate":[{"required":true,"message":"请选择项目领域"}]},{"type":"radio","field":"license","title":"开源协议","info":"","options":[{"label":"MIT","value":"MIT"},{"label":"Apache-2.0","value":"Apache-2.0"},{"label":"GPLv3","value":"GPLv3"},{"label":"其他","value":"other"}]},{"type":"select","field":"stars","title":"Star 数量级","info":"","props":{},"options":[{"label":"100 以内","value":"lt100"},{"label":"100 ~ 1k","value":"100to1k"},{"label":"1k ~ 10k","value":"1kto10k"},{"label":"10k 以上","value":"gt10k"}]},{"type":"textarea","field":"recommend","title":"推荐理由","info":"","props":{"placeholder":"一句话说说它解决了什么问题"},"validate":[{"required":true,"message":"请填写推荐理由"}]},{"type":"input","field":"contact","title":"联系邮箱","info":"","props":{"placeholder":"选填，便于回访"}}]', '{"labelPosition":"right","size":"default"}', 1, 1, 80501, 1, now(), now(), NULL, NULL, 0),
(1012, 1, 'activity_registration', '活动报名表', '线下活动/聚会报名登记，含场次选择与用餐需求', '[{"type":"input","field":"name","title":"姓名","info":"","props":{},"validate":[{"required":true,"message":"请输入姓名"}]},{"type":"input","field":"phone","title":"手机号码","info":"","props":{"placeholder":"用于接收活动通知"},"validate":[{"required":true,"message":"请输入手机号码"}]},{"type":"radio","field":"gender","title":"性别","info":"","options":[{"label":"男","value":"male"},{"label":"女","value":"female"}]},{"type":"checkbox","field":"sessions","title":"参加场次","info":"","options":[{"label":"主论坛","value":"main"},{"label":"工作坊 A","value":"workshop_a"},{"label":"工作坊 B","value":"workshop_b"},{"label":"晚间交流","value":"evening"}]},{"type":"inputNumber","field":"attendees","title":"同行人数","info":"","props":{"min":0,"max":10}},{"type":"radio","field":"dinner","title":"用餐需求","info":"","options":[{"label":"正常","value":"normal"},{"label":"素食","value":"vegetarian"},{"label":"无需用餐","value":"none"}]},{"type":"textarea","field":"remark","title":"备注","info":"","props":{"placeholder":"选填"}}]', '{"labelPosition":"right","size":"default"}', 1, 1, 80502, 1, now(), now(), NULL, NULL, 0),
(1013, 1, 'feedback', '意见反馈', '产品/系统通用意见反馈表，含满意度评分', '[{"type":"select","field":"type","title":"反馈类型","info":"","props":{},"options":[{"label":"功能建议","value":"feature"},{"label":"问题报告","value":"bug"},{"label":"体验吐槽","value":"ux"},{"label":"其他","value":"other"}],"validate":[{"required":true,"message":"请选择反馈类型"}]},{"type":"rate","field":"rating","title":"整体满意度","info":"","props":{}},{"type":"textarea","field":"content","title":"反馈内容","info":"","props":{"placeholder":"请具体描述你的建议或遇到的问题"},"validate":[{"required":true,"message":"请填写反馈内容"}]},{"type":"input","field":"contact","title":"联系方式","info":"","props":{"placeholder":"选填，便于跟进回复"}}]', '{"labelPosition":"right","size":"default"}', 1, 1, 80503, 1, now(), now(), NULL, NULL, 0);

-- 预置表单版本快照（已发布语义 = 固化 v1 规则，防止后续编辑定义导致历史数据回显漂移）
INSERT IGNORE INTO `form_snapshot` (`id`, `tenant_id`, `form_id`, `version`, `form_json`, `options_json`, `create_time`, `update_time`, `is_deleted`) VALUES
(1001, 0, 1001, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1001), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1001), now(), now(), 0),
(1002, 0, 1002, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1002), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1002), now(), now(), 0),
(1003, 0, 1003, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1003), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1003), now(), now(), 0),
(1011, 1, 1011, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1011), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1011), now(), now(), 0),
(1012, 1, 1012, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1012), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1012), now(), now(), 0),
(1013, 1, 1013, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1013), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1013), now(), now(), 0);
