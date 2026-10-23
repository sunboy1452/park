package com.youlai.boot.framework.web.log;

import cn.hutool.core.util.StrUtil;
import cn.hutool.http.useragent.UserAgent;
import cn.hutool.http.useragent.UserAgentUtil;
import com.youlai.boot.common.annotation.Log;
import com.youlai.boot.common.enums.ActionTypeEnum;
import com.youlai.boot.common.enums.LogModuleEnum;
import com.youlai.boot.framework.security.util.SecurityUtils;
import com.youlai.boot.framework.tenant.TenantContextHolder;
import com.youlai.boot.framework.web.util.IPUtils;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.concurrent.Executor;

/**
 * 操作日志切面
 *
 * @author Ray.Hao
 * @since 4.7.0
 */
@Aspect
@Component
@Slf4j
public class OperationLogAspect {

    private static final int MAX_ERROR_MSG_LENGTH = 1000;

    private final OperationLogPort operationLogPort;
    private final Executor operationLogExecutor;

    public OperationLogAspect(
            OperationLogPort operationLogPort,
            @Qualifier("operationLogExecutor") Executor operationLogExecutor
    ) {
        this.operationLogPort = operationLogPort;
        this.operationLogExecutor = operationLogExecutor;
    }

    @Pointcut("@annotation(logAnnotation)")
    public void pointcut(Log logAnnotation) {
    }

    @Around(value = "pointcut(logAnnotation)", argNames = "jp,logAnnotation")
    public Object around(ProceedingJoinPoint jp, Log logAnnotation) throws Throwable {
        long start = System.currentTimeMillis();
        Long userId = SecurityUtils.getUserId();
        String username = SecurityUtils.getUsername();
        Throwable failure = null;

        try {
            return jp.proceed();
        } catch (Throwable e) {
            failure = e;
            throw e;
        } finally {
            long elapsed = System.currentTimeMillis() - start;
            try {
                Long operatorId = userId;
                String operatorName = username;
                // 登录接口在 proceed 前尚未认证，认证成功后补取操作人
                if (operatorId == null) {
                    operatorId = SecurityUtils.getUserId();
                    operatorName = SecurityUtils.getUsername();
                }
                OperationLog operationLog = buildOperationLog(logAnnotation, elapsed, failure, operatorId, operatorName);
                if (operationLog != null) {
                    // 落库在独立线程池执行，线程内没有租户上下文，这里把当前租户带过去
                    Long tenantId = TenantContextHolder.getTenantId();
                    operationLogExecutor.execute(() -> {
                        try {
                            if (tenantId != null) {
                                TenantContextHolder.setTenantId(tenantId);
                            }
                            operationLogPort.record(operationLog);
                        } catch (Exception e) {
                            log.error("保存操作日志失败 title={} uri={}", operationLog.title(), operationLog.requestUri(), e);
                        } finally {
                            // 线程复用，用完必须清干净
                            TenantContextHolder.clear();
                        }
                    });
                }
            } catch (Exception ex) {
                log.error("构建操作日志失败", ex);
            }
        }
    }

    private OperationLog buildOperationLog(Log ann, long elapsed, Throwable failure, Long userId, String username) {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) return null;

        HttpServletRequest req = attrs.getRequest();
        UserAgent ua = UserAgentUtil.parse(req.getHeader("User-Agent"));
        String ip = IPUtils.getIpAddr(req);

        LogModuleEnum module = ann.module();
        ActionTypeEnum action = ann.value();

        IpRegion region = parseRegion(ip);

        return new OperationLog(
                module,
                action,
                StrUtil.blankToDefault(ann.title(), module.getLabel() + "-" + action.getLabel()),
                ann.content(),
                userId,
                username,
                req.getRequestURI(),
                req.getMethod(),
                ip,
                region.province(),
                region.city(),
                getDevice(ua),
                getOs(ua),
                getBrowser(ua),
                failure == null ? 1 : 0,
                failure == null ? null : truncate(failure.getMessage(), MAX_ERROR_MSG_LENGTH),
                (int) Math.min(elapsed, Integer.MAX_VALUE),
                LocalDateTime.now()
        );
    }

    private IpRegion parseRegion(String ip) {
        String region = IPUtils.getRegion(ip);
        if (StrUtil.isBlank(region)) return IpRegion.EMPTY;
        String[] parts = region.split("\\|");
        if (parts.length < 4) return IpRegion.EMPTY;
        return new IpRegion(StrUtil.blankToDefault(parts[2], null), StrUtil.blankToDefault(parts[3], null));
    }

    private String truncate(String msg, int maxLen) {
        if (msg == null) return null;
        return msg.length() <= maxLen ? msg : msg.substring(0, maxLen);
    }

    private String getOs(UserAgent ua) {
        return Optional.ofNullable(ua).map(UserAgent::getOs).map(os -> os.getName()).orElse(null);
    }

    private String getDevice(UserAgent ua) {
        return Optional.ofNullable(ua).map(UserAgent::getPlatform).map(p -> p.getName()).orElse(null);
    }

    private String getBrowser(UserAgent ua) {
        return Optional.ofNullable(ua).map(UserAgent::getBrowser).map(b -> b.getName()).orElse(null);
    }

    private record IpRegion(String province, String city) {
        static final IpRegion EMPTY = new IpRegion(null, null);
    }
}
