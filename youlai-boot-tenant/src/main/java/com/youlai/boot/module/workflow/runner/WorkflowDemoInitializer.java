package com.youlai.boot.module.workflow.runner;

import com.youlai.boot.framework.tenant.TenantContextHolder;
import com.youlai.boot.module.workflow.config.ConditionalOnWorkflowEnabled;
import com.youlai.boot.module.workflow.service.WorkflowDemoService;
import com.youlai.boot.system.model.entity.Tenant;
import com.youlai.boot.system.service.TenantService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * 演示流程启动初始化器
 *
 * @author Ray.Hao
 * @since 4.9.0
 */
@ConditionalOnWorkflowEnabled
@Component
@ConditionalOnProperty(name = "workflow.demo.enabled", havingValue = "true")
@RequiredArgsConstructor
@Slf4j
public class WorkflowDemoInitializer implements ApplicationRunner {

    private final WorkflowDemoService workflowDemoService;
    private final TenantService tenantService;

    /**
     * 按租户逐个初始化演示流程
     */
    @Override
    public void run(ApplicationArguments args) {
        for (Tenant tenant : tenantService.list()) {
            try {
                TenantContextHolder.setTenantId(tenant.getId());
                workflowDemoService.initIfAbsent();
            } catch (Exception e) {
                log.error("租户[{}]演示流程初始化失败，已跳过", tenant.getId(), e);
            } finally {
                TenantContextHolder.clear();
            }
        }
    }

}
