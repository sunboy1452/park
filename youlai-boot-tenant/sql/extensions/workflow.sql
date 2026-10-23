# 工作流模块（可选扩展）
# Copyright (c) 2026-present, youlai.tech

-- ----------------------------------------------------------------------------
-- 工作流模块扩展脚本（全量执行，可重复运行）
-- 前置：先执行 ../youlai_admin_tenant.sql 与 dynamic-form.sql
--
-- 引擎表（ACT_* / FLW_*）由 Flowable 按 flowable.database-schema-update 策略自动创建，
-- 本脚本不含建表；且其租户隔离走引擎原生 TENANT_ID_ 列，
-- 已在 TenantAccessHandler 按前缀排除（不经过 MyBatis-Plus 租户拦截器）。
--
-- 菜单段不写 always_show，并登记 sys_tenant_menu / sys_tenant_plan_menu；
-- 授权写 3 列（role_id, menu_id, tenant_id）；
-- 演示角色/用户归属演示租户(tenant_id=1)：角色 8-10、用户 10-12；
-- 发起表单按租户各一套：平台租户 1004-1007、演示租户 1014-1017
-- ----------------------------------------------------------------------------

USE `youlai_admin_tenant`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 菜单（顶级 ID=9，顺延动态表单 ID=8）
-- scope 走默认值 2（业务菜单）；不写 always_show 列
-- ----------------------------
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (9, 0, '0', '工作流', 'C', '', '/workflow', 'Layout', NULL, NULL, 1, 9, 'el-icon-Connection', '/workflow/launch', now(), now(), '{"badge":"NEW"}');
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (901, 9, '0,9', '流程设计', 'M', 'WorkflowModel', 'model', 'workflow/model', NULL, NULL, 1, 1, 'el-icon-Coin', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (90101, 901, '0,9,901', '流程查询', 'B', NULL, '', NULL, 'workflow:model:list', NULL, 1, 1, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (90102, 901, '0,9,901', '流程新增', 'B', NULL, '', NULL, 'workflow:model:create', NULL, 1, 2, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (90103, 901, '0,9,901', '流程修改', 'B', NULL, '', NULL, 'workflow:model:update', NULL, 1, 3, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (90104, 901, '0,9,901', '流程删除', 'B', NULL, '', NULL, 'workflow:model:delete', NULL, 1, 4, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (90105, 901, '0,9,901', '流程发布', 'B', NULL, '', NULL, 'workflow:model:deploy', NULL, 1, 5, '', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (90106, 901, '0,9,901', '流程重置', 'B', NULL, '', NULL, 'workflow:model:reset', NULL, 1, 6, '', NULL, now(), now(), NULL);
-- 流程启停：启用开关走 definition:update，删除复用 model:delete
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (90107, 901, '0,9,901', '流程启停', 'B', NULL, '', NULL, 'workflow:definition:update', NULL, 1, 7, '', NULL, now(), now(), NULL);
-- 流程设计器（隐藏菜单，列表"设计"按钮跳转）
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (902, 9, '0,9', '流程设计器', 'M', 'WorkflowDesigner', 'designer', 'workflow/designer', NULL, 1, 0, 2, '', NULL, now(), now(), NULL);

-- 发起/审批中心仅登录校验，不设按钮权限
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (904, 9, '0,9', '发起流程', 'M', 'WorkflowLaunch', 'launch', 'workflow/launch', NULL, NULL, 1, 4, 'el-icon-Promotion', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (905, 9, '0,9', '审批中心', 'M', 'WorkflowTask', 'task', 'workflow/task/index', NULL, NULL, 1, 5, 'el-icon-Stamp', NULL, now(), now(), NULL);
INSERT IGNORE INTO `sys_menu` (`id`, `parent_id`, `tree_path`, `name`, `type`, `route_name`, `route_path`, `component`, `perm`, `keep_alive`, `visible`, `sort`, `icon`, `redirect`, `create_time`, `update_time`, `params`) VALUES (90501, 905, '0,9,905', '终止流程', 'B', NULL, '', NULL, 'workflow:instance:terminate', NULL, 1, 1, '', NULL, now(), now(), NULL);

-- ----------------------------
-- 菜单的租户 / 套餐登记（主脚本中这两张表是 INSERT...SELECT 派生的，
-- 执行时 ID=9 段尚不存在，故此处补登记）
-- ----------------------------
INSERT IGNORE INTO `sys_tenant_menu` (tenant_id, menu_id)
SELECT 0, id FROM `sys_menu` WHERE id = 9 OR tree_path LIKE '0,9%';

INSERT IGNORE INTO `sys_tenant_menu` (tenant_id, menu_id)
SELECT 1, id FROM `sys_menu` WHERE (id = 9 OR tree_path LIKE '0,9%') AND scope = 2;

INSERT IGNORE INTO `sys_tenant_plan_menu` (plan_id, menu_id)
SELECT 2, id FROM `sys_menu` WHERE (id = 9 OR tree_path LIKE '0,9%') AND scope = 2;

-- ----------------------------
-- 菜单授权（sys_role_menu 为 3 列：role_id, menu_id, tenant_id）
--   平台租户(0)：role 2 = 系统管理员 ADMIN —— 含流程设计等管理菜单
--   演示租户(1)：role 13 = DEMO_ADMIN、role 15 = ADMIN —— 含管理菜单
--   演示租户(1)：role 8/9/10 = 总经理/财务/行政 —— 仅发起与审批中心
-- ----------------------------
INSERT IGNORE INTO `sys_role_menu` VALUES
(2, 9, 0), (2, 901, 0), (2, 90101, 0), (2, 90102, 0), (2, 90103, 0), (2, 90104, 0),
(2, 90105, 0), (2, 90106, 0), (2, 90107, 0), (2, 902, 0), (2, 904, 0), (2, 905, 0), (2, 90501, 0);

INSERT IGNORE INTO `sys_role_menu` VALUES
(13, 9, 1), (13, 901, 1), (13, 90101, 1), (13, 90102, 1), (13, 90103, 1), (13, 90104, 1),
(13, 90105, 1), (13, 90106, 1), (13, 90107, 1), (13, 902, 1), (13, 904, 1), (13, 905, 1), (13, 90501, 1);

INSERT IGNORE INTO `sys_role_menu` VALUES
(15, 9, 1), (15, 901, 1), (15, 90101, 1), (15, 90102, 1), (15, 90103, 1), (15, 90104, 1),
(15, 90105, 1), (15, 90106, 1), (15, 90107, 1), (15, 902, 1), (15, 904, 1), (15, 905, 1), (15, 90501, 1);

INSERT IGNORE INTO `sys_role_menu` VALUES (8, 9, 1), (8, 904, 1), (8, 905, 1);
INSERT IGNORE INTO `sys_role_menu` VALUES (9, 9, 1), (9, 904, 1), (9, 905, 1);
INSERT IGNORE INTO `sys_role_menu` VALUES (10, 9, 1), (10, 904, 1), (10, 905, 1);

-- ----------------------------
-- 演示角色与用户（归属演示租户 tenant_id=1，密码 123456）
-- 审批环节按 BPMN candidateGroups 绑定专用角色
-- ----------------------------
INSERT IGNORE INTO `sys_role` (`id`, `tenant_id`, `name`, `code`, `sort`, `status`, `data_scope`, `create_time`, `update_time`, `is_deleted`) VALUES
(8, 1, '总经理', 'GENERAL_MANAGER', 8, 1, 4, now(), now(), 0),
(9, 1, '财务', 'FINANCE', 9, 1, 4, now(), now(), 0),
(10, 1, '行政', 'ADMINISTRATION', 10, 1, 4, now(), now(), 0);

INSERT IGNORE INTO `sys_user` (`id`, `tenant_id`, `username`, `nickname`, `gender`, `password`, `dept_id`, `avatar`, `mobile`, `status`, `email`, `create_time`, `update_time`, `is_deleted`) VALUES
(10, 1, 'manager', '总经理', 1, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', NULL, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345684', 1, 'manager@youlaitech.com', now(), now(), 0),
(11, 1, 'finance', '财务专员', 2, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', NULL, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345685', 1, 'finance@youlaitech.com', now(), now(), 0),
(12, 1, 'clerk', '行政专员', 2, '$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq', NULL, 'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif', '18812345686', 1, 'clerk@youlaitech.com', now(), now(), 0);

-- sys_user_role 为 (user_id, role_id, tenant_id)，tenant_id 必须显式给，
-- 否则取默认值 0 会把演示租户的用户角色挂到平台租户
INSERT IGNORE INTO `sys_user_role` (user_id, role_id, tenant_id) VALUES (10, 8, 1), (11, 9, 1), (12, 10, 1);

-- ----------------------------
-- 演示流程的发起表单（依赖动态表单扩展，form_* 表带 tenant_id）
-- form_key 与 BPMN 开始节点 flowable:formKey 一一对应
-- 平台租户(0) ID 段 1004-1007；演示租户(1) ID 段 1014-1017
-- ----------------------------
INSERT IGNORE INTO `form_definition` (`id`, `tenant_id`, `form_key`, `form_name`, `description`, `form_json`, `options_json`, `status`, `is_public`, `category`, `menu_id`, `version`, `create_time`, `update_time`, `create_by`, `update_by`, `is_deleted`) VALUES
(1004, 0, 'leave_apply', '请假申请', '演示流程"请假审批"的发起表单，天数超过 3 天自动流转总经理审批', '[{"type":"select","field":"leave_type","title":"请假类型","info":"","props":{},"options":[{"label":"事假","value":"personal"},{"label":"病假","value":"sick"},{"label":"年假","value":"annual"},{"label":"调休","value":"compensatory"}],"validate":[{"required":true,"message":"请选择请假类型"}]},{"type":"inputNumber","field":"days","title":"请假天数","info":"","props":{"min":0.5,"max":30,"precision":1},"validate":[{"required":true,"message":"请输入请假天数"}]},{"type":"datePicker","field":"start_date","title":"开始日期","info":"","props":{"valueFormat":"YYYY-MM-DD"},"validate":[{"required":true,"message":"请选择开始日期"}]},{"type":"datePicker","field":"end_date","title":"结束日期","info":"","props":{"valueFormat":"YYYY-MM-DD"},"validate":[{"required":true,"message":"请选择结束日期"}]},{"type":"textarea","field":"reason","title":"请假事由","info":"","props":{"placeholder":"请简要说明请假事由"},"validate":[{"required":true,"message":"请填写请假事由"}]}]', '{"labelPosition":"right","size":"default"}', 1, 0, 'workflow', NULL, 1, now(), now(), NULL, NULL, 0),
(1005, 0, 'expense_apply', '报销申请', '演示流程"报销审批"的发起表单，金额超过 5000 元自动流转总经理审批', '[{"type":"select","field":"expense_type","title":"报销类型","info":"","props":{},"options":[{"label":"差旅费","value":"travel"},{"label":"办公费","value":"office"},{"label":"招待费","value":"hospitality"},{"label":"培训费","value":"training"}],"validate":[{"required":true,"message":"请选择报销类型"}]},{"type":"inputNumber","field":"amount","title":"报销金额（元）","info":"","props":{"min":0,"max":1000000,"precision":2},"validate":[{"required":true,"message":"请输入报销金额"}]},{"type":"datePicker","field":"expense_date","title":"费用发生日期","info":"","props":{"valueFormat":"YYYY-MM-DD"},"validate":[{"required":true,"message":"请选择费用发生日期"}]},{"type":"textarea","field":"reason","title":"报销说明","info":"","props":{"placeholder":"请简要说明费用用途"},"validate":[{"required":true,"message":"请填写报销说明"}]}]', '{"labelPosition":"right","size":"default"}', 1, 0, 'workflow', NULL, 1, now(), now(), NULL, NULL, 0),
(1006, 0, 'purchase_apply', '采购申请', '演示流程"采购申请"的发起表单，金额超过 1 万元流转总经理审批，通过后回退发起人执行采购', '[{"type":"input","field":"item_name","title":"采购物品","info":"","props":{"placeholder":"请输入采购物品名称"},"validate":[{"required":true,"message":"请填写采购物品"}]},{"type":"inputNumber","field":"quantity","title":"采购数量","info":"","props":{"min":1,"precision":0},"validate":[{"required":true,"message":"请输入采购数量"}]},{"type":"inputNumber","field":"amount","title":"预估金额（元）","info":"","props":{"min":0,"precision":2},"validate":[{"required":true,"message":"请输入预估金额"}]},{"type":"textarea","field":"reason","title":"采购事由","info":"","props":{"placeholder":"请简要说明采购背景与用途"},"validate":[{"required":true,"message":"请填写采购事由"}]}]', '{"labelPosition":"right","size":"default"}', 1, 0, 'workflow', NULL, 1, now(), now(), NULL, NULL, 0),
(1007, 0, 'seal_apply', '用章申请', '演示流程"用章申请"的发起表单，部门领导与行政两级审批', '[{"type":"select","field":"seal_type","title":"印章类型","info":"","props":{},"options":[{"label":"公章","value":"official"},{"label":"合同章","value":"contract"},{"label":"财务章","value":"finance"},{"label":"法人章","value":"legal"}],"validate":[{"required":true,"message":"请选择印章类型"}]},{"type":"datePicker","field":"usage_date","title":"用章日期","info":"","props":{"valueFormat":"YYYY-MM-DD"},"validate":[{"required":true,"message":"请选择用章日期"}]},{"type":"textarea","field":"usage","title":"用章事由","info":"","props":{"placeholder":"请说明用章文件及事由"},"validate":[{"required":true,"message":"请填写用章事由"}]}]', '{"labelPosition":"right","size":"default"}', 1, 0, 'workflow', NULL, 1, now(), now(), NULL, NULL, 0),
(1014, 1, 'leave_apply', '请假申请', '演示流程"请假审批"的发起表单，天数超过 3 天自动流转总经理审批', '[{"type":"select","field":"leave_type","title":"请假类型","info":"","props":{},"options":[{"label":"事假","value":"personal"},{"label":"病假","value":"sick"},{"label":"年假","value":"annual"},{"label":"调休","value":"compensatory"}],"validate":[{"required":true,"message":"请选择请假类型"}]},{"type":"inputNumber","field":"days","title":"请假天数","info":"","props":{"min":0.5,"max":30,"precision":1},"validate":[{"required":true,"message":"请输入请假天数"}]},{"type":"datePicker","field":"start_date","title":"开始日期","info":"","props":{"valueFormat":"YYYY-MM-DD"},"validate":[{"required":true,"message":"请选择开始日期"}]},{"type":"datePicker","field":"end_date","title":"结束日期","info":"","props":{"valueFormat":"YYYY-MM-DD"},"validate":[{"required":true,"message":"请选择结束日期"}]},{"type":"textarea","field":"reason","title":"请假事由","info":"","props":{"placeholder":"请简要说明请假事由"},"validate":[{"required":true,"message":"请填写请假事由"}]}]', '{"labelPosition":"right","size":"default"}', 1, 0, 'workflow', NULL, 1, now(), now(), NULL, NULL, 0),
(1015, 1, 'expense_apply', '报销申请', '演示流程"报销审批"的发起表单，金额超过 5000 元自动流转总经理审批', '[{"type":"select","field":"expense_type","title":"报销类型","info":"","props":{},"options":[{"label":"差旅费","value":"travel"},{"label":"办公费","value":"office"},{"label":"招待费","value":"hospitality"},{"label":"培训费","value":"training"}],"validate":[{"required":true,"message":"请选择报销类型"}]},{"type":"inputNumber","field":"amount","title":"报销金额（元）","info":"","props":{"min":0,"max":1000000,"precision":2},"validate":[{"required":true,"message":"请输入报销金额"}]},{"type":"datePicker","field":"expense_date","title":"费用发生日期","info":"","props":{"valueFormat":"YYYY-MM-DD"},"validate":[{"required":true,"message":"请选择费用发生日期"}]},{"type":"textarea","field":"reason","title":"报销说明","info":"","props":{"placeholder":"请简要说明费用用途"},"validate":[{"required":true,"message":"请填写报销说明"}]}]', '{"labelPosition":"right","size":"default"}', 1, 0, 'workflow', NULL, 1, now(), now(), NULL, NULL, 0),
(1016, 1, 'purchase_apply', '采购申请', '演示流程"采购申请"的发起表单，金额超过 1 万元流转总经理审批，通过后回退发起人执行采购', '[{"type":"input","field":"item_name","title":"采购物品","info":"","props":{"placeholder":"请输入采购物品名称"},"validate":[{"required":true,"message":"请填写采购物品"}]},{"type":"inputNumber","field":"quantity","title":"采购数量","info":"","props":{"min":1,"precision":0},"validate":[{"required":true,"message":"请输入采购数量"}]},{"type":"inputNumber","field":"amount","title":"预估金额（元）","info":"","props":{"min":0,"precision":2},"validate":[{"required":true,"message":"请输入预估金额"}]},{"type":"textarea","field":"reason","title":"采购事由","info":"","props":{"placeholder":"请简要说明采购背景与用途"},"validate":[{"required":true,"message":"请填写采购事由"}]}]', '{"labelPosition":"right","size":"default"}', 1, 0, 'workflow', NULL, 1, now(), now(), NULL, NULL, 0),
(1017, 1, 'seal_apply', '用章申请', '演示流程"用章申请"的发起表单，部门领导与行政两级审批', '[{"type":"select","field":"seal_type","title":"印章类型","info":"","props":{},"options":[{"label":"公章","value":"official"},{"label":"合同章","value":"contract"},{"label":"财务章","value":"finance"},{"label":"法人章","value":"legal"}],"validate":[{"required":true,"message":"请选择印章类型"}]},{"type":"datePicker","field":"usage_date","title":"用章日期","info":"","props":{"valueFormat":"YYYY-MM-DD"},"validate":[{"required":true,"message":"请选择用章日期"}]},{"type":"textarea","field":"usage","title":"用章事由","info":"","props":{"placeholder":"请说明用章文件及事由"},"validate":[{"required":true,"message":"请填写用章事由"}]}]', '{"labelPosition":"right","size":"default"}', 1, 0, 'workflow', NULL, 1, now(), now(), NULL, NULL, 0);

-- 预置表单版本快照（固化 v1 规则，防止编辑定义后历史数据回显漂移）
INSERT IGNORE INTO `form_snapshot` (`id`, `tenant_id`, `form_id`, `version`, `form_json`, `options_json`, `create_time`, `update_time`, `is_deleted`) VALUES
(1004, 0, 1004, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1004), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1004), now(), now(), 0),
(1005, 0, 1005, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1005), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1005), now(), now(), 0),
(1006, 0, 1006, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1006), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1006), now(), now(), 0),
(1007, 0, 1007, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1007), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1007), now(), now(), 0),
(1014, 1, 1014, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1014), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1014), now(), now(), 0),
(1015, 1, 1015, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1015), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1015), now(), now(), 0),
(1016, 1, 1016, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1016), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1016), now(), now(), 0),
(1017, 1, 1017, 1, (SELECT `form_json` FROM `form_definition` WHERE `id` = 1017), (SELECT `options_json` FROM `form_definition` WHERE `id` = 1017), now(), now(), 0);
