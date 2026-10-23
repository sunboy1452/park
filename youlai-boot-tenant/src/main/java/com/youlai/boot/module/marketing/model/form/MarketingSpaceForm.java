package com.youlai.boot.module.marketing.model.form;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@Schema(description = "招商房源表单")
public class MarketingSpaceForm {

    @NotBlank
    @Size(max = 64)
    private String spaceCode;
    @NotBlank
    @Size(max = 150)
    private String projectName;
    private Long parkId;
    private Long regionId;
    private Long buildingId;
    private Long floorId;
    @Size(max = 100)
    private String buildingName;
    @Size(max = 100)
    private String floorName;
    @Size(max = 64)
    private String roomNo;
    @NotNull
    private BigDecimal area;
    private BigDecimal rentUnitPrice;
    @NotBlank
    @Pattern(regexp = "AVAILABLE|RESERVED|LEASED|MAINTENANCE")
    private String availability;
    @NotBlank
    @Size(max = 150)
    private String displayTitle;
    @Size(max = 2000)
    private String description;
    @Size(max = 500)
    private String coverUrl;
    @Size(max = 500)
    private String vrUrl;
    @NotNull
    @jakarta.validation.constraints.Min(0)
    @jakarta.validation.constraints.Max(2)
    private Integer publishStatus;
}
