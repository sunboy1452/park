package com.youlai.boot.system.adapter.tenant;

import com.youlai.boot.framework.tenant.TenantDomainResolver;
import com.youlai.boot.system.service.TenantService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * 域名解析租户适配器
 *
 * @author Ray.Hao
 * @since 4.8.0
 */
@Component
@RequiredArgsConstructor
public class TenantDomainResolverAdapter implements TenantDomainResolver {

    private final TenantService tenantService;

    /**
     * 按访问域名解析租户ID
     *
     * @param domain 请求域名
     * @return 租户ID，域名未绑定租户时返回 null
     */
    @Override
    public Long getTenantIdByDomain(String domain) {
        return tenantService.getTenantIdByDomain(domain);
    }
}
