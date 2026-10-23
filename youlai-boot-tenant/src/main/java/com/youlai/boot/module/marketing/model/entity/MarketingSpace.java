package com.youlai.boot.module.marketing.model.entity;

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
@TableName("marketing_space")
public class MarketingSpace extends BaseEntity {

    private String spaceCode;
    private String projectName;
    private Long parkId;
    private Long regionId;
    private Long buildingId;
    private Long floorId;
    @TableField(exist = false)
    private String parkName;
    @TableField(exist = false)
    private String regionName;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String buildingName;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String floorName;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String roomNo;
    private BigDecimal area;
    private BigDecimal rentUnitPrice;
    private String availability;
    private String displayTitle;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String description;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String coverUrl;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String vrUrl;
    private Integer publishStatus;
    private Long createBy;
    private Long updateBy;
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;
}
