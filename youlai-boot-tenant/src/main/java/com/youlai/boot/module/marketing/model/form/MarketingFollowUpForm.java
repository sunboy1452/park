package com.youlai.boot.module.marketing.model.form;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Schema(description = "线索跟进记录表单")
public class MarketingFollowUpForm {

    @NotBlank
    @Size(max = 32)
    private String followType;
    @NotBlank
    @Size(max = 2000)
    private String content;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime nextFollowAt;
}
