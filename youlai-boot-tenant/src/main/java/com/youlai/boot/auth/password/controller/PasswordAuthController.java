package com.youlai.boot.auth.password.controller;

import com.youlai.boot.auth.password.model.form.LoginForm;
import com.youlai.boot.auth.password.model.vo.CaptchaVO;
import com.youlai.boot.auth.password.service.PasswordAuthService;
import com.youlai.boot.common.annotation.Log;
import com.youlai.boot.common.enums.ActionTypeEnum;
import com.youlai.boot.common.enums.LogModuleEnum;
import com.youlai.boot.common.enums.StatusEnum;
import com.youlai.boot.common.result.Result;
import com.youlai.boot.common.result.ResultCode;
import com.youlai.boot.framework.security.model.AuthenticationToken;
import com.youlai.boot.framework.security.model.SecurityUser;
import com.youlai.boot.framework.tenant.TenantContextHolder;
import com.youlai.boot.framework.web.ratelimit.RateLimit;
import com.youlai.boot.system.model.entity.User;
import com.youlai.boot.system.service.TenantService;
import com.youlai.boot.system.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Objects;

/**
 * 账号密码认证接口
 *
 * @author Ray.Hao
 * @since 4.8.0
 */
@Tag(name = "01.认证中心")
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class PasswordAuthController {

    private final PasswordAuthService passwordAuthService;
    private final UserService userService;
    private final TenantService tenantService;
    private final PasswordEncoder passwordEncoder;

    @Operation(summary = "获取验证码")
    @GetMapping("/captcha")
    public Result<CaptchaVO> getCaptcha() {
        CaptchaVO captcha = passwordAuthService.getCaptcha();
        return Result.success(captcha);
    }

    @Operation(summary = "账号密码登录")
    @PostMapping("/login")
    @Log(module = LogModuleEnum.LOGIN, value = ActionTypeEnum.LOGIN)
    @RateLimit
    public Result<AuthenticationToken> login(HttpServletRequest request, @RequestBody @Valid LoginForm loginForm) {
        String username = loginForm.getUsername();
        String password = loginForm.getPassword();
        Long tenantId = loginForm.getTenantId();

        // 1. 指定了租户ID，直接登录
        if (tenantId != null) {
            AuthenticationToken authenticationToken = passwordAuthService.login(username, password, tenantId);
            return Result.success(authenticationToken);
        }

        // 2. 未指定租户ID，优先从域名解析租户
        String domain = request.getServerName();
        if (domain != null) {
            Long tenantIdFromDomain = tenantService.getTenantIdByDomain(domain);
            if (tenantIdFromDomain != null) {
                AuthenticationToken authenticationToken = passwordAuthService.login(username, password, tenantIdFromDomain);
                return Result.success(authenticationToken);
            }
        }

        // 3. 域名也解析不到，跨所有租户查询该用户名
        TenantContextHolder.setIgnoreTenant(true);
        List<User> users;
        try {
            users = userService.listUsersByUsernameAcrossAllTenants(username);
        } finally {
            TenantContextHolder.clear();
        }

        if (users.isEmpty()) {
            return Result.failed(ResultCode.USER_PASSWORD_ERROR);
        }

        // 过滤启用状态的用户
        List<User> activeUsers = users.stream()
                .filter(user -> user.getStatus() != null && StatusEnum.ENABLE.getValue().equals(user.getStatus()))
                .toList();

        if (activeUsers.isEmpty()) {
            return Result.failed(ResultCode.USER_PASSWORD_ERROR);
        }

        // 密码校验通过后，才允许进入"选择租户"分支
        List<User> passwordMatchedUsers = activeUsers.stream()
                .filter(user -> Objects.nonNull(user.getPassword()) && passwordEncoder.matches(password, user.getPassword()))
                .toList();

        if (passwordMatchedUsers.isEmpty()) {
            return Result.failed(ResultCode.USER_PASSWORD_ERROR);
        }

        // 有租户切换权限的账号，登录后可切换租户
        for (User candidate : passwordMatchedUsers) {
            TenantContextHolder.setTenantId(candidate.getTenantId());
            SecurityUser authInfo;
            try {
                authInfo = userService.getAuthInfoByUsernameInTenant(username, candidate.getTenantId());
            } finally {
                TenantContextHolder.clear();
            }
            if (authInfo != null && Boolean.TRUE.equals(authInfo.getCanSwitchTenant())) {
                AuthenticationToken authenticationToken = passwordAuthService.login(username, password, candidate.getTenantId());
                return Result.success(authenticationToken);
            }
        }

        // 无租户切换权限：仅允许单一租户账号登录
        if (passwordMatchedUsers.size() == 1) {
            User user = passwordMatchedUsers.get(0);
            AuthenticationToken authenticationToken = passwordAuthService.login(username, password, user.getTenantId());
            return Result.success(authenticationToken);
        }

        return Result.failed("该账号存在于多个租户下，请使用租户域名或指定租户登录");
    }

}
