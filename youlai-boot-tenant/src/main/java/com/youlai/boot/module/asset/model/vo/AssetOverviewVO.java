package com.youlai.boot.module.asset.model.vo;

import com.youlai.boot.module.asset.model.entity.AssetBuilding;
import com.youlai.boot.module.asset.model.entity.AssetRegion;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class AssetOverviewVO {
    private Long parkId;
    private Integer parkCount;
    private Integer regionCount;
    private Integer buildingCount;
    private Integer floorCount;
    private Integer spaceCount;
    private Integer availableSpaceCount;
    private Integer leasedSpaceCount;
    private List<AssetRegion> regions;
    private List<AssetBuilding> buildings;
}
