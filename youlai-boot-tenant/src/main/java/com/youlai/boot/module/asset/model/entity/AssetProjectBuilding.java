package com.youlai.boot.module.asset.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@TableName("asset_project_building")
public class AssetProjectBuilding {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long projectId;
    private Long buildingId;
    private LocalDateTime createTime;
    private Long createBy;
    @TableField(exist = false)
    private Long tenantId;
}
