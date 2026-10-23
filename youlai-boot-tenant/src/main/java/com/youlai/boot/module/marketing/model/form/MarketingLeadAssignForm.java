package com.youlai.boot.module.marketing.model.form;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Schema(description = "线索分配表单，assigneeId 为空时解除分配")
public class MarketingLeadAssignForm {

    private Long assigneeId;
}
