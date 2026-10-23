package com.youlai.boot.module.asset.model.vo;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class AssetProjectVO {
    private Long id;
    private String code;
    private String name;
    private Integer status;
    private String remark;
    private LocalDateTime updateTime;
    private List<Long> buildingIds;
    private List<String> buildingLabels;
}
