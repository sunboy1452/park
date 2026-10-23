package com.youlai.boot.module.marketing.model.query;

import com.youlai.boot.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Schema(description = "渠道分页查询")
public class MarketingChannelPageQuery extends BaseQuery {

    private String keyword;
    private String channelType;
    private Integer status;
}
