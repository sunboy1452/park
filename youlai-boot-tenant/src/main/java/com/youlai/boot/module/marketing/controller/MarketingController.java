package com.youlai.boot.module.marketing.controller;

import com.youlai.boot.common.annotation.Log;
import com.youlai.boot.common.enums.ActionTypeEnum;
import com.youlai.boot.common.enums.LogModuleEnum;
import com.youlai.boot.common.result.PageResult;
import com.youlai.boot.common.result.Result;
import com.youlai.boot.framework.web.repeatsubmit.RepeatSubmit;
import com.youlai.boot.module.marketing.model.entity.MarketingChannel;
import com.youlai.boot.module.marketing.model.entity.MarketingFollowUp;
import com.youlai.boot.module.marketing.model.entity.MarketingLead;
import com.youlai.boot.module.marketing.model.entity.MarketingSpace;
import com.youlai.boot.module.marketing.model.form.MarketingChannelForm;
import com.youlai.boot.module.marketing.model.form.MarketingFollowUpForm;
import com.youlai.boot.module.marketing.model.form.MarketingLeadAssignForm;
import com.youlai.boot.module.marketing.model.form.MarketingLeadForm;
import com.youlai.boot.module.marketing.model.form.MarketingSpaceForm;
import com.youlai.boot.module.marketing.model.query.MarketingChannelPageQuery;
import com.youlai.boot.module.marketing.model.query.MarketingFollowUpPageQuery;
import com.youlai.boot.module.marketing.model.query.MarketingLeadPageQuery;
import com.youlai.boot.module.marketing.model.query.MarketingSpacePageQuery;
import com.youlai.boot.module.marketing.model.vo.MarketingOverviewVO;
import com.youlai.boot.module.marketing.service.MarketingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@Tag(name = "14.招商营销")
@RestController
@RequestMapping("/api/v1/marketing")
@RequiredArgsConstructor
public class MarketingController {

    private final MarketingService marketingService;

    @Operation(summary = "渠道分页")
    @GetMapping("/channels")
    @PreAuthorize("@ss.hasPerm('marketing:channel:list')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.LIST)
    public PageResult<MarketingChannel> getChannelPage(@Valid MarketingChannelPageQuery query) {
        return PageResult.success(marketingService.getChannelPage(query));
    }

    @Operation(summary = "渠道详情")
    @GetMapping("/channels/{id}")
    @PreAuthorize("@ss.hasPerm('marketing:channel:list')")
    public Result<MarketingChannel> getChannel(@PathVariable Long id) {
        return Result.success(marketingService.getChannel(id));
    }

    @Operation(summary = "新增渠道")
    @PostMapping("/channels")
    @PreAuthorize("@ss.hasPerm('marketing:channel:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.INSERT)
    public Result<Void> saveChannel(@Valid @RequestBody MarketingChannelForm form) {
        return Result.judge(marketingService.saveChannel(form));
    }

    @Operation(summary = "修改渠道")
    @PutMapping("/channels/{id}")
    @PreAuthorize("@ss.hasPerm('marketing:channel:update')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateChannel(@PathVariable Long id, @Valid @RequestBody MarketingChannelForm form) {
        return Result.judge(marketingService.updateChannel(id, form));
    }

    @Operation(summary = "删除渠道")
    @DeleteMapping("/channels/{ids}")
    @PreAuthorize("@ss.hasPerm('marketing:channel:delete')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteChannels(@PathVariable String ids) {
        marketingService.deleteChannels(ids);
        return Result.success();
    }

    @Operation(summary = "线索分页")
    @GetMapping("/leads")
    @PreAuthorize("@ss.hasPerm('marketing:lead:list')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.LIST)
    public PageResult<MarketingLead> getLeadPage(@Valid MarketingLeadPageQuery query) {
        return PageResult.success(marketingService.getLeadPage(query));
    }

    @Operation(summary = "线索详情")
    @GetMapping("/leads/{id}")
    @PreAuthorize("@ss.hasPerm('marketing:lead:list')")
    public Result<MarketingLead> getLead(@PathVariable Long id) {
        return Result.success(marketingService.getLeadDetail(id));
    }

    @Operation(summary = "新增线索")
    @PostMapping("/leads")
    @PreAuthorize("@ss.hasPerm('marketing:lead:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.INSERT)
    public Result<Void> saveLead(@Valid @RequestBody MarketingLeadForm form) {
        return Result.judge(marketingService.saveLead(form));
    }

    @Operation(summary = "修改线索")
    @PutMapping("/leads/{id}")
    @PreAuthorize("@ss.hasPerm('marketing:lead:update')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateLead(@PathVariable Long id, @Valid @RequestBody MarketingLeadForm form) {
        return Result.judge(marketingService.updateLead(id, form));
    }

    @Operation(summary = "删除线索")
    @DeleteMapping("/leads/{ids}")
    @PreAuthorize("@ss.hasPerm('marketing:lead:delete')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteLeads(@PathVariable String ids) {
        marketingService.deleteLeads(ids);
        return Result.success();
    }

    @Operation(summary = "分配线索")
    @PutMapping("/leads/{id}/assign")
    @PreAuthorize("@ss.hasPerm('marketing:lead:assign')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.UPDATE, title = "分配线索")
    public Result<Void> assignLead(@PathVariable Long id, @RequestBody @Valid MarketingLeadAssignForm form) {
        return Result.judge(marketingService.assignLead(id, form));
    }

    @Operation(summary = "线索跟进分页")
    @GetMapping("/leads/{leadId}/follow-ups")
    @PreAuthorize("@ss.hasPerm('marketing:follow-up:list')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.LIST)
    public PageResult<MarketingFollowUp> getFollowUpPage(
            @PathVariable Long leadId,
            @Valid MarketingFollowUpPageQuery query
    ) {
        return PageResult.success(marketingService.getFollowUpPage(leadId, query));
    }

    @Operation(summary = "线索跟进详情")
    @GetMapping("/leads/{leadId}/follow-ups/{followUpId}")
    @PreAuthorize("@ss.hasPerm('marketing:follow-up:list')")
    public Result<MarketingFollowUp> getFollowUpDetail(
            @PathVariable Long leadId,
            @PathVariable Long followUpId
    ) {
        return Result.success(marketingService.getFollowUpDetail(leadId, followUpId));
    }

    @Operation(summary = "新增线索跟进")
    @PostMapping("/leads/{leadId}/follow-ups")
    @PreAuthorize("@ss.hasPerm('marketing:follow-up:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.INSERT)
    public Result<Void> saveFollowUp(@PathVariable Long leadId, @Valid @RequestBody MarketingFollowUpForm form) {
        return Result.judge(marketingService.saveFollowUp(leadId, form));
    }

    @Operation(summary = "修改线索跟进")
    @PutMapping("/leads/{leadId}/follow-ups/{followUpId}")
    @PreAuthorize("@ss.hasPerm('marketing:follow-up:update')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateFollowUp(
            @PathVariable Long leadId,
            @PathVariable Long followUpId,
            @Valid @RequestBody MarketingFollowUpForm form
    ) {
        return Result.judge(marketingService.updateFollowUp(leadId, followUpId, form));
    }

    @Operation(summary = "删除线索跟进")
    @DeleteMapping("/leads/{leadId}/follow-ups/{ids}")
    @PreAuthorize("@ss.hasPerm('marketing:follow-up:delete')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteFollowUps(@PathVariable Long leadId, @PathVariable String ids) {
        marketingService.deleteFollowUps(leadId, ids);
        return Result.success();
    }

    @Operation(summary = "房源分页")
    @GetMapping("/spaces")
    @PreAuthorize("@ss.hasPerm('marketing:space:list')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.LIST)
    public PageResult<MarketingSpace> getSpacePage(@Valid MarketingSpacePageQuery query) {
        return PageResult.success(marketingService.getSpacePage(query));
    }

    @Operation(summary = "房源详情")
    @GetMapping("/spaces/{id}")
    @PreAuthorize("@ss.hasPerm('marketing:space:list')")
    public Result<MarketingSpace> getSpace(@PathVariable Long id) {
        return Result.success(marketingService.getSpace(id));
    }

    @Operation(summary = "新增房源")
    @PostMapping("/spaces")
    @PreAuthorize("@ss.hasPerm('marketing:space:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.INSERT)
    public Result<Void> saveSpace(@Valid @RequestBody MarketingSpaceForm form) {
        return Result.judge(marketingService.saveSpace(form));
    }

    @Operation(summary = "修改房源")
    @PutMapping("/spaces/{id}")
    @PreAuthorize("@ss.hasPerm('marketing:space:update')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateSpace(@PathVariable Long id, @Valid @RequestBody MarketingSpaceForm form) {
        return Result.judge(marketingService.updateSpace(id, form));
    }

    @Operation(summary = "删除房源")
    @DeleteMapping("/spaces/{ids}")
    @PreAuthorize("@ss.hasPerm('marketing:space:delete')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteSpaces(@PathVariable String ids) {
        marketingService.deleteSpaces(ids);
        return Result.success();
    }

    @Operation(summary = "营销概览")
    @GetMapping("/overview")
    @PreAuthorize("@ss.hasPerm('marketing:overview:list')")
    @Log(module = LogModuleEnum.MARKETING, value = ActionTypeEnum.LIST)
    public Result<MarketingOverviewVO> getOverview() {
        return Result.success(marketingService.getOverview());
    }
}
