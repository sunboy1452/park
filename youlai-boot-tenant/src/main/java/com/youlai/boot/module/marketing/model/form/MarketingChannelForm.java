package com.youlai.boot.module.marketing.model.form;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.Range;

@Getter
@Setter
@Schema(description = "招商渠道表单")
public class MarketingChannelForm {

    @NotBlank
    @Size(max = 64)
    private String code;
    @NotBlank
    @Size(max = 100)
    private String name;
    @NotBlank
    @Pattern(regexp = "ONLINE|OFFLINE|BROKER|PARTNER|OTHER")
    private String channelType;
    @Size(max = 100)
    private String contactName;
    @Size(max = 32)
    private String contactPhone;
    @NotNull
    @Range(min = 0, max = 1)
    private Integer status;
    @Size(max = 500)
    private String remark;
}
