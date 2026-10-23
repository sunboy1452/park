package com.youlai.boot.module.marketing.model.form;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@Schema(description = "招商线索表单")
public class MarketingLeadForm {

    @NotBlank
    @Size(max = 100)
    private String customerName;
    @Size(max = 150)
    private String companyName;
    @Size(max = 100)
    private String contactName;
    @NotBlank
    @Size(max = 32)
    private String phone;
    @Email
    @Size(max = 128)
    private String email;
    private Long channelId;
    @Size(max = 150)
    private String projectName;
    private Long spaceId;
    private BigDecimal intendedArea;
    private BigDecimal budget;
    @NotBlank
    @Pattern(regexp = "NEW|CONTACTED|VISITED|INTENTION|CONVERTED|LOST")
    private String stage;
    private Long assigneeId;
    @Size(max = 1000)
    private String remark;
}
