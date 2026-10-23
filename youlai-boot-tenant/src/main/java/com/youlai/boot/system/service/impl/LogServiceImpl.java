package com.youlai.boot.system.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youlai.boot.common.constant.SystemConstants;
import com.youlai.boot.framework.security.util.SecurityUtils;
import com.youlai.boot.framework.tenant.TenantContextHolder;
import com.youlai.boot.system.mapper.LogMapper;
import com.youlai.boot.system.model.dto.VisitCountDTO;
import com.youlai.boot.system.model.vo.VisitOverviewVO;
import com.youlai.boot.system.model.entity.SysLog;
import com.youlai.boot.system.model.query.LogQuery;
import com.youlai.boot.system.model.vo.LogPageVO;
import com.youlai.boot.system.model.vo.VisitTrendVO;
import com.youlai.boot.system.service.LogService;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 系统日志 服务实现类
 *
 * @author Ray.Hao
 * @since 2.10.0
 */
@Service
public class LogServiceImpl extends ServiceImpl<LogMapper, SysLog>
        implements LogService {

    /**
     * 获取日志分页列表
     *
     * @param queryParams 查询参数
     * @return 日志分页列表
     */
    @Override
    public Page<LogPageVO> getLogPage(LogQuery queryParams) {
        return this.baseMapper.getLogPage(new Page<>(queryParams.getPageNum(), queryParams.getPageSize()),
                queryParams, resolveTenantFilter());
    }

    /**
     * 获取访问趋势
     *
     * @param startDate 开始时间
     * @param endDate   结束时间
     * @return
     */
    @Override
    public VisitTrendVO getVisitTrend(LocalDate startDate, LocalDate endDate) {
        VisitTrendVO visitTrend = new VisitTrendVO();
        List<String> dates = new ArrayList<>();

        // 获取日期范围内的日期
        while (!startDate.isAfter(endDate)) {
            dates.add(startDate.toString());
            startDate = startDate.plusDays(1);
        }
        visitTrend.setDates(dates);

        // 获取访问量和访问 IP 数的统计数据
        String startTime = dates.get(0) + " 00:00:00";
        String endTime = dates.get(dates.size() - 1) + " 23:59:59";
        Long tenantId = resolveTenantFilter();
        List<VisitCountDTO> pvCounts = this.baseMapper.getPvCounts(startTime, endTime, tenantId);
        List<VisitCountDTO> ipCounts = this.baseMapper.getIpCounts(startTime, endTime, tenantId);

        // 将统计数据转换为 Map
        Map<String, Integer> pvMap = pvCounts.stream().collect(Collectors.toMap(VisitCountDTO::getDate, VisitCountDTO::getCount));
        Map<String, Integer> uvMap = ipCounts.stream().collect(Collectors.toMap(VisitCountDTO::getDate, VisitCountDTO::getCount));

        // 匹配日期和访问量/访客数
        List<Integer> pvList = new ArrayList<>();
        List<Integer> uvList = new ArrayList<>();

        for (String date : dates) {
            pvList.add(pvMap.getOrDefault(date, 0));
            uvList.add(uvMap.getOrDefault(date, 0));
        }

        visitTrend.setPvList(pvList);
        visitTrend.setUvList(uvList);

        return visitTrend;
    }

    /**
     * 访问量统计
     */
    @Override
    public VisitOverviewVO getVisitStats() {
        VisitOverviewVO result = new VisitOverviewVO();
        Long tenantId = resolveTenantFilter();

        // 访客数统计(UV)
        VisitOverviewVO uvStats = this.baseMapper.getUvStats(tenantId);
        if(uvStats!=null){
            result.setTodayUvCount(uvStats.getTodayUvCount());
            result.setTotalUvCount(uvStats.getTotalUvCount());
            result.setUvGrowthRate(uvStats.getUvGrowthRate());
        }

        // 浏览量统计(PV)
        VisitOverviewVO pvStats = this.baseMapper.getPvStats(tenantId);
        if(pvStats!=null){
            result.setTodayPvCount(pvStats.getTodayPvCount());
            result.setTotalPvCount(pvStats.getTotalPvCount());
            result.setPvGrowthRate(pvStats.getPvGrowthRate());
        }

        return result;
    }

    /**
     * 日志查询的租户范围：平台租户与超级管理员看全部，其余只统计本租户
     *
     * @return 需要过滤的租户ID，null 表示不过滤
     */
    private Long resolveTenantFilter() {
        Long tenantId = TenantContextHolder.getTenantId();
        if (tenantId == null || SystemConstants.PLATFORM_TENANT_ID.equals(tenantId) || SecurityUtils.isRoot()) {
            return null;
        }
        return tenantId;
    }

}
