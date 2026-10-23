package com.youlai.boot.module.workflow.util;

import com.youlai.boot.framework.tenant.TenantContextHolder;

/**
 * 工作流租户上下文工具
 *
 * @author Ray.Hao
 * @since 4.6.0
 */
public final class WorkflowTenantHelper {

    private WorkflowTenantHelper() {
    }

    /**
     * 获取当前租户在 Flowable 中的租户标识
     *
     * @return 当前租户标识，无租户上下文时返回 null
     */
    public static String currentTenantId() {
        Long tenantId = TenantContextHolder.getTenantId();
        return tenantId == null ? null : String.valueOf(tenantId);
    }
}
