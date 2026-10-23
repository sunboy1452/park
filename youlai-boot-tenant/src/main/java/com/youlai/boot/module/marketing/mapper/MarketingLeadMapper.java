package com.youlai.boot.module.marketing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.youlai.boot.module.marketing.model.entity.MarketingLead;
import com.youlai.boot.module.marketing.model.vo.MarketingChannelConversionVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface MarketingLeadMapper extends BaseMapper<MarketingLead> {

    @Select("SELECT channel_id AS channelId, COUNT(*) AS leadCount, " +
            "SUM(CASE WHEN stage = 'CONVERTED' THEN 1 ELSE 0 END) AS convertedCount " +
            "FROM marketing_lead WHERE is_deleted = 0 AND channel_id IS NOT NULL GROUP BY channel_id")
    List<MarketingChannelConversionVO> getChannelConversions();
}
