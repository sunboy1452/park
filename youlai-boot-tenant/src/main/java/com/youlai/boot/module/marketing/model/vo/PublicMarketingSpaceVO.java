package com.youlai.boot.module.marketing.model.vo;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class PublicMarketingSpaceVO {

    private Long id;
    private String projectName;
    private Long parkId;
    private Long regionId;
    private Long buildingId;
    private Long floorId;
    private String parkName;
    private String regionName;
    private String buildingName;
    private String floorName;
    private String roomNo;
    private BigDecimal area;
    private BigDecimal rentUnitPrice;
    private String availability;
    private String displayTitle;
    private String description;
    private String coverUrl;
    private String vrUrl;
}
