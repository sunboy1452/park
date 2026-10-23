package com.youlai.boot.system.adapter.log;

import com.youlai.boot.framework.tenant.TenantContextHolder;
import com.youlai.boot.framework.web.log.OperationLog;
import com.youlai.boot.framework.web.log.OperationLogPort;
import com.youlai.boot.system.converter.LogConverter;
import com.youlai.boot.system.model.entity.SysLog;
import com.youlai.boot.system.service.LogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * 操作日志适配器
 *
 * @author Ray.Hao
 * @since 4.7.0
 */
@Component
@RequiredArgsConstructor
public class OperationLogAdapter implements OperationLogPort {

    private final LogService logService;
    private final LogConverter logConverter;

    /**
     * 记录操作日志
     */
    @Override
    public void record(OperationLog operationLog) {
        Long tenantId = TenantContextHolder.getTenantId();
        boolean ignoreTenantBefore = TenantContextHolder.isIgnoreTenant();
        try {
            if (tenantId == null) {
                TenantContextHolder.setIgnoreTenant(true);
            }
            SysLog entity = logConverter.toEntity(operationLog);
            // sys_log 不参与自动填充，租户需要手动写入
            entity.setTenantId(tenantId);
            logService.save(entity);
        } finally {
            TenantContextHolder.setIgnoreTenant(ignoreTenantBefore);
        }
    }
}
