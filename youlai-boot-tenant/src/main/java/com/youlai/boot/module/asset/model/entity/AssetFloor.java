package com.youlai.boot.module.asset.model.entity;

import com.baomidou.mybatisplus.annotation.FieldStrategy;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.youlai.boot.common.base.BaseEntity;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@EqualsAndHashCode(callSuper = true)
@TableName("asset_floor")
public class AssetFloor extends BaseEntity {
    private Long buildingId;
    private String floorCode;
    private String floorName;
    private Integer floorNumber;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private BigDecimal area;
    private Integer status;
    private Integer sort;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String remark;
    private Long createBy;
    private Long updateBy;
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;
}
