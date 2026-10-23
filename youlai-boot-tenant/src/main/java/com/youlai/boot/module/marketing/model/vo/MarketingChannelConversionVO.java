package com.youlai.boot.module.marketing.model.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MarketingChannelConversionVO {

    private Long channelId;
    private String channelName;
    private Integer leadCount;
    private Integer convertedCount;
}
