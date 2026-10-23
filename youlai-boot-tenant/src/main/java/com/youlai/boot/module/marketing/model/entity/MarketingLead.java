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
@TableName("marketing_lead")
public class MarketingLead extends BaseEntity {

    private String customerName;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String companyName;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String contactName;
    private String phone;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String email;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private Long channelId;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String projectName;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private Long spaceId;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private BigDecimal intendedArea;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private BigDecimal budget;
    private String stage;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private Long assigneeId;
    @TableField(updateStrategy = FieldStrategy.ALWAYS)
    private String remark;
    private Long createBy;
    private Long updateBy;
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;

    @TableField(exist = false)
    private String channelName;
    @TableField(exist = false)
    private String assigneeName;
}
