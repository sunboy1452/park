package com.youlai.boot.module.asset.model.form;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class AssetForm {
    private String code;
    private String name;
    private String address;
    private BigDecimal area;
    private Integer status;
    private String description;
    private String remark;
    private Long parkId;
    private Long regionId;
    private Long buildingId;
    private String regionType;
    private String buildingType;
    private Integer mapX;
    private Integer mapY;
    private Integer mapWidth;
    private Integer mapHeight;
    private Integer sort;
    private String floorCode;
    private String floorName;
    private Integer floorNumber;
    private List<Long> buildingIds;
}
