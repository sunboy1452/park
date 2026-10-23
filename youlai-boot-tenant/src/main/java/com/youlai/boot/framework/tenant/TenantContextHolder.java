package com.youlai.boot.framework.tenant;

/**
 * 多租户上下文持有器。
 *
 * @author Ray.Hao
 * @since 3.0.0
 */
public class TenantContextHolder {

    private static final ThreadLocal<Long> TENANT_CONTEXT = new ThreadLocal<>();

    private static final ThreadLocal<Boolean> IGNORE_TENANT = new ThreadLocal<>();

    /**
     * 设置当前租户 ID
     *
     * @param tenantId 租户 ID
     */
    public static void setTenantId(Long tenantId) {
        TENANT_CONTEXT.set(tenantId);
    }

    /**
     * 获取当前租户 ID
     *
     * @return 租户 ID，可能为 null
     */
    public static Long getTenantId() {
        return TENANT_CONTEXT.get();
    }

    /**
     * 设置是否忽略租户过滤
     *
     * @param ignore true=忽略租户过滤
     */
    public static void setIgnoreTenant(boolean ignore) {
        IGNORE_TENANT.set(ignore);
    }

    /**
     * 当前是否忽略租户过滤
     *
     * @return true=忽略
     */
    public static boolean isIgnoreTenant() {
        return Boolean.TRUE.equals(IGNORE_TENANT.get());
    }

    /**
     * 清除当前线程的租户上下文
     */
    public static void clear() {
        TENANT_CONTEXT.remove();
        IGNORE_TENANT.remove();
    }

    /**
     * 清除当前租户 ID（保留忽略标志）
     */
    public static void remove() {
        TENANT_CONTEXT.remove();
    }

}
