/** 权限相关常量 */

/** 超级管理员角色标识 */
export const ROLE_ROOT = "ROOT";

/** 全部权限标识 */
export const PERM_ALL = "*:*:*";

/** 按钮权限码，取值来自后端菜单表的 perm 字段 */
export const PERM = {
  user: {
    list: "sys:user:list",
    create: "sys:user:create",
    update: "sys:user:update",
    delete: "sys:user:delete",
    resetPassword: "sys:user:reset-password",
  },
  role: {
    list: "sys:role:list",
    create: "sys:role:create",
    update: "sys:role:update",
    delete: "sys:role:delete",
    assign: "sys:role:assign",
  },
  dept: {
    list: "sys:dept:list",
    create: "sys:dept:create",
    update: "sys:dept:update",
    delete: "sys:dept:delete",
  },
  menu: {
    list: "sys:menu:list",
    create: "sys:menu:create",
    update: "sys:menu:update",
    delete: "sys:menu:delete",
  },
  dict: {
    list: "sys:dict:list",
    create: "sys:dict:create",
    update: "sys:dict:update",
    delete: "sys:dict:delete",
  },
  dictItem: {
    list: "sys:dict-item:list",
    create: "sys:dict-item:create",
    update: "sys:dict-item:update",
    delete: "sys:dict-item:delete",
  },
  config: {
    list: "sys:config:list",
    create: "sys:config:create",
    update: "sys:config:update",
    delete: "sys:config:delete",
  },
  notice: {
    list: "sys:notice:list",
    create: "sys:notice:create",
    update: "sys:notice:update",
    delete: "sys:notice:delete",
    publish: "sys:notice:publish",
    revoke: "sys:notice:revoke",
  },
  log: {
    list: "sys:log:list",
  },
} as const;
