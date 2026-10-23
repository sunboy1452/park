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
@TableName("asset_park")
public class AssetPark extends BaseEntity {
    private String code;
    private String name;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String address;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private BigDecimal area;
    private Integer status;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String description;
    private Long createBy;
    private Long updateBy;
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;
}
