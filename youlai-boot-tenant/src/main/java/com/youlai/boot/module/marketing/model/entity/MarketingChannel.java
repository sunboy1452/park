package com.youlai.boot.module.marketing.model.entity;

import com.baomidou.mybatisplus.annotation.FieldStrategy;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.youlai.boot.common.base.BaseEntity;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@EqualsAndHashCode(callSuper = true)
@TableName("marketing_channel")
public class MarketingChannel extends BaseEntity {

    private String code;
    private String name;
    private String channelType;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String contactName;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String contactPhone;
    private Integer status;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String remark;
    private Long createBy;
    private Long updateBy;
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;
}
