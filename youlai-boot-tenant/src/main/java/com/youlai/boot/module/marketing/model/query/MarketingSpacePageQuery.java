package com.youlai.boot.module.marketing.model.query;

import com.youlai.boot.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Schema(description = "房源分页查询")
public class MarketingSpacePageQuery extends BaseQuery {

    private String keyword;
    private String projectName;
    private Long parkId;
    private Long buildingId;
    private String availability;
    private Integer publishStatus;
}
