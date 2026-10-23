package com.youlai.boot.auth.session.service;

import cn.hutool.core.util.StrUtil;
import com.youlai.boot.common.exception.BusinessException;
import com.youlai.boot.common.result.ResultCode;
import com.youlai.boot.framework.security.model.AuthenticationToken;
import com.youlai.boot.framework.security.model.SecurityUserDetails;
import com.youlai.boot.framework.security.token.TokenManager;
import com.youlai.boot.framework.security.util.SecurityUtils;
import com.youlai.boot.system.service.TenantService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

/**
 * 登录态服务
 *
 * @author Ray.Hao
 * @since 4.8.0
 */
@Service
@RequiredArgsConstructor
public class AuthSessionService {

    private final TokenManager tokenManager;
    private final TenantService tenantService;

    /**
     * 注销登录
     */
    public void logout() {
        String token = SecurityUtils.getAccessToken();
        if (StrUtil.isNotBlank(token)) {
            tokenManager.invalidateToken(token);
            // 清除Security上下文
            SecurityContextHolder.clearContext();
        }
    }

    /**
     * 刷新令牌
     *
     * @param refreshToken 刷新令牌
     * @return 新的访问令牌
     */
    public AuthenticationToken refreshToken(String refreshToken) {
        return tokenManager.refreshToken(refreshToken);
    }

    /**
     * 切换租户
     *
     * @param tenantId 目标租户ID
     * @return 目标租户下的访问令牌
     */
    public AuthenticationToken switchTenant(Long tenantId) {
        if (!tenantService.hasTenantSwitchPermission()) {
            throw new BusinessException("无权限");
        }

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof SecurityUserDetails details)) {
            throw new BusinessException(ResultCode.ACCESS_TOKEN_INVALID);
        }

        if (!tenantService.canAccessTenant(details.getUserId(), tenantId)) {
            throw new BusinessException("无权限");
        }

        SecurityUserDetails newDetails = new SecurityUserDetails();
        newDetails.setUserId(details.getUserId());
        newDetails.setUsername(details.getUsername());
        newDetails.setDeptId(details.getDeptId());
        newDetails.setDataScopes(details.getDataScopes());
        newDetails.setTenantId(tenantId);
        newDetails.setCanSwitchTenant(details.getCanSwitchTenant());

        Authentication newAuth = new UsernamePasswordAuthenticationToken(
                newDetails, authentication.getCredentials(), authentication.getAuthorities());
        return tokenManager.generateToken(newAuth);
    }

}
