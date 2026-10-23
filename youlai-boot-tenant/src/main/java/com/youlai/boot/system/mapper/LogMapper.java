package com.youlai.boot.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youlai.boot.system.model.dto.VisitCountDTO;
import com.youlai.boot.system.model.vo.VisitOverviewVO;
import com.youlai.boot.system.model.entity.SysLog;
import com.youlai.boot.system.model.query.LogQuery;
import com.youlai.boot.system.model.vo.LogPageVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;


/**
 * 系统日志数据访问层
 *
 * @author Ray
 * @since 2.10.0
 */
@Mapper
public interface LogMapper extends BaseMapper<SysLog> {

    /**
     * 获取日志分页列表
     *
     * @param page        分页参数
     * @param queryParams 查询参数
     * @param tenantId    租户ID，为空查全部租户
     * @return 日志分页列表
     */
    Page<LogPageVO> getLogPage(@Param("page") Page<LogPageVO> page,
                               @Param("queryParams") LogQuery queryParams,
                               @Param("tenantId") Long tenantId);

    /**
     * 统计浏览数(PV)
     *
     * @param startDate 开始日期 yyyy-MM-dd
     * @param endDate   结束日期 yyyy-MM-dd
     * @param tenantId  租户ID，为空查全部租户
     * @return 按日期分组的浏览量
     */
    List<VisitCountDTO> getPvCounts(@Param("startDate") String startDate,
                                    @Param("endDate") String endDate,
                                    @Param("tenantId") Long tenantId);

    /**
     * 统计IP数
     *
     * @param startDate 开始日期 yyyy-MM-dd
     * @param endDate   结束日期 yyyy-MM-dd
     * @param tenantId  租户ID，为空查全部租户
     * @return 按日期分组的访问IP数
     */
    List<VisitCountDTO> getIpCounts(@Param("startDate") String startDate,
                                    @Param("endDate") String endDate,
                                    @Param("tenantId") Long tenantId);

    /**
     * 获取浏览量(PV)统计
     *
     * @param tenantId 租户ID，为空查全部租户
     * @return 浏览量统计
     */
    VisitOverviewVO getPvStats(@Param("tenantId") Long tenantId);

    /**
     * 获取访问IP统计
     *
     * @param tenantId 租户ID，为空查全部租户
     * @return 访问IP统计
     */
    VisitOverviewVO getUvStats(@Param("tenantId") Long tenantId);
}
