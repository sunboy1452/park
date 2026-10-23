package com.youlai.boot.module.marketing.controller;

import com.youlai.boot.common.result.PageResult;
import com.youlai.boot.common.result.Result;
import com.youlai.boot.module.marketing.model.query.MarketingSpacePageQuery;
import com.youlai.boot.module.marketing.model.vo.PublicMarketingSpaceVO;
import com.youlai.boot.module.marketing.service.MarketingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "公开房源展示")
@RestController
@RequestMapping("/api/v1/public/marketing/spaces")
@RequiredArgsConstructor
public class PublicMarketingController {

    private final MarketingService marketingService;

    @Operation(summary = "已发布可租房源分页")
    @GetMapping
    public PageResult<PublicMarketingSpaceVO> getSpacePage(@Valid MarketingSpacePageQuery query) {
        return PageResult.success(marketingService.getPublicSpacePage(query));
    }

    @Operation(summary = "公开房源详情")
    @GetMapping("/{id}")
    public Result<PublicMarketingSpaceVO> getSpace(@PathVariable Long id) {
        return Result.success(marketingService.getPublicSpace(id));
    }
}
