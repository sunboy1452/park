package com.youlai.boot.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.core.config.GlobalConfig;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.DataPermissionInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.TenantLineInnerInterceptor;
import com.youlai.boot.framework.mybatis.MetaFieldFillHandler;
import com.youlai.boot.framework.mybatis.RoleDataPermissionHandler;
import com.youlai.boot.framework.tenant.TenantAccessHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * MyBatis-Plus 配置
 *
 * @author Ray.Hao
 * @since 2022/7/2
 */
@Configuration
@EnableTransactionManagement
@RequiredArgsConstructor
public class MybatisConfig {

    private final TenantAccessHandler tenantAccessHandler;

    /**
     * 分页插件、数据权限插件、多租户插件
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();

        // 多租户
        interceptor.addInnerInterceptor(new TenantLineInnerInterceptor(tenantAccessHandler));

        // 数据权限
        interceptor.addInnerInterceptor(new DataPermissionInterceptor(new RoleDataPermissionHandler()));

        // 分页
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));

        return interceptor;
    }

    /**
     * 字段自动填充（createTime、updateTime、tenantId）
     */
    @Bean
    public GlobalConfig globalConfig() {
        GlobalConfig globalConfig = new GlobalConfig();
        globalConfig.setMetaObjectHandler(new MetaFieldFillHandler());
        return globalConfig;
    }

}