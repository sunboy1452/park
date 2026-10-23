package com.youlai.boot.framework.tenant;

import com.baomidou.mybatisplus.extension.plugins.handler.TenantLineHandler;
import com.youlai.boot.framework.tenant.TenantProperties;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.LongValue;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * MyBatis-Plus 多租户处理器
 *
 * @author Ray.Hao
 * @since 3.0.0
 */
@Component
@RequiredArgsConstructor
public class TenantAccessHandler implements TenantLineHandler {

    private final TenantProperties tenantProperties;

    private Set<String> ignoreTableSet;

    private static final Set<String> SYSTEM_TABLES = Set.of(
            "tables",
            "columns"
    );

    // 不参与 MyBatis-Plus 租户隔离的表前缀
    private static final List<String> IGNORE_TABLE_PREFIXES = List.of("act_", "flw_");

    @PostConstruct
    void init() {
        List<String> ignoreTables = tenantProperties.getIgnoreTables();
        ignoreTableSet = ignoreTables != null
                ? ignoreTables.stream().map(String::toLowerCase).collect(Collectors.toSet())
                : Set.of();
    }

    @Override
    public Expression getTenantId() {
        Long tenantId = TenantContextHolder.getTenantId();
        if (tenantId == null) {
            throw new IllegalStateException("租户ID为空，访问数据库前需设置租户上下文");
        }
        return new LongValue(tenantId);
    }

    @Override
    public String getTenantIdColumn() {
        return tenantProperties.getColumn();
    }

    @Override
    public boolean ignoreTable(String tableName) {
        if (tableName == null) {
            return false;
        }

        String lowerTableName = tableName.toLowerCase();

        if (SYSTEM_TABLES.contains(lowerTableName)
                || IGNORE_TABLE_PREFIXES.stream().anyMatch(lowerTableName::startsWith)) {
            return true;
        }

        if (TenantContextHolder.isIgnoreTenant()) {
            return true;
        }

        // 租户上下文未设置（如登录前），跳过租户过滤
        if (TenantContextHolder.getTenantId() == null) {
            return true;
        }

        return ignoreTableSet.contains(lowerTableName);
    }
}
