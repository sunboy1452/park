package com.youlai.boot.framework.tenant;

/**
 * 域名解析租户端口
 *
 * @author Ray.Hao
 * @since 4.8.0
 */
public interface TenantDomainResolver {

    /**
     * 按访问域名解析租户ID
     *
     * @param domain 请求域名
     * @return 租户ID，域名未绑定租户时返回 null
     */
    Long getTenantIdByDomain(String domain);
}
