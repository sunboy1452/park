package com.youlai.boot.module.asset.model.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AssetBuildingOptionVO {
    private Long id;
    private String code;
    private String name;
    private Long parkId;
    private String parkName;
    private Long regionId;
    private String regionName;
}
