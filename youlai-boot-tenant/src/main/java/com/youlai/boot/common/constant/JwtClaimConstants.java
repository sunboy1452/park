package com.youlai.boot.common.constant;

/**
 * JWT Claims声明常量
 *
 * @author haoxr
 * @since 2023/11/24
 */
public interface JwtClaimConstants {

    // 令牌类型
    String TOKEN_TYPE = "tokenType";

    // 用户ID
    String USER_ID = "userId";

    // 部门ID
    String DEPT_ID = "deptId";

    // 数据权限
    String DATA_SCOPE = "dataScope";

    // 数据权限列表（多角色）
    String DATA_SCOPES = "dataScopes";

    // 权限(角色Code)集合
    String AUTHORITIES = "authorities";

    // 租户ID
    String TENANT_ID = "tenantId";

    // 租户切换权限（true 可切换租户）
    String CAN_SWITCH_TENANT = "canSwitchTenant";

    // Token 版本号
    String TOKEN_VERSION = "tokenVersion";

}