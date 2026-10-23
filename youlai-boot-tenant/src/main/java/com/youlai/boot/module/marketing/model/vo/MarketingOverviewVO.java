package com.youlai.boot.module.marketing.model.vo;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class MarketingOverviewVO {

    private Integer leadTotal;
    private Integer newLeadCount;
    private Integer pendingFollowUpCount;
    private Integer visitCount;
    private Integer intentionCount;
    private Integer convertedCount;
    private List<MarketingChannelConversionVO> channelConversion;
}
