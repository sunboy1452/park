package com.youlai.boot.module.asset.controller;

import com.youlai.boot.common.result.Result;
import com.youlai.boot.module.asset.model.entity.*;
import com.youlai.boot.module.asset.model.form.AssetForm;
import com.youlai.boot.module.asset.model.form.AssetLayoutForm;
import com.youlai.boot.module.asset.model.vo.AssetBuildingOptionVO;
import com.youlai.boot.module.asset.model.vo.AssetOverviewVO;
import com.youlai.boot.module.asset.model.vo.AssetProjectVO;
import com.youlai.boot.module.asset.service.AssetService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "15.建筑管理")
@RestController
@RequestMapping("/api/v1/assets")
@RequiredArgsConstructor
public class AssetController {
    private final AssetService assetService;

    @Operation(summary = "园区概览")
    @GetMapping("/overview")
    @PreAuthorize("@ss.hasPerm('asset:overview:list')")
    public Result<AssetOverviewVO> getOverview(@RequestParam(required = false) Long parkId) {
        return Result.success(assetService.getOverview(parkId));
    }

    @GetMapping("/parks")
    @PreAuthorize("@ss.hasPerm('asset:park:list')")
    public Result<List<AssetPark>> getParks() {
        return Result.success(assetService.getParks());
    }

    @PostMapping("/parks")
    @PreAuthorize("@ss.hasPerm('asset:park:create')")
    public Result<Void> savePark(@RequestBody AssetForm form) {
        return Result.judge(assetService.savePark(form));
    }

    @PutMapping("/parks/{id}")
    @PreAuthorize("@ss.hasPerm('asset:park:update')")
    public Result<Void> updatePark(@PathVariable Long id, @RequestBody AssetForm form) {
        return Result.judge(assetService.updatePark(id, form));
    }

    @DeleteMapping("/parks/{id}")
    @PreAuthorize("@ss.hasPerm('asset:park:delete')")
    public Result<Void> deletePark(@PathVariable Long id) {
        assetService.deletePark(id);
        return Result.success();
    }

    @GetMapping("/regions")
    @PreAuthorize("@ss.hasPerm('asset:region:list')")
    public Result<List<AssetRegion>> getRegions(@RequestParam(required = false) Long parkId) {
        return Result.success(assetService.getRegions(parkId));
    }

    @PostMapping("/regions")
    @PreAuthorize("@ss.hasPerm('asset:region:create')")
    public Result<Void> saveRegion(@RequestBody AssetForm form) {
        return Result.judge(assetService.saveRegion(form));
    }

    @PutMapping("/regions/{id}")
    @PreAuthorize("@ss.hasPerm('asset:region:update')")
    public Result<Void> updateRegion(@PathVariable Long id, @RequestBody AssetForm form) {
        return Result.judge(assetService.updateRegion(id, form));
    }

    @DeleteMapping("/regions/{id}")
    @PreAuthorize("@ss.hasPerm('asset:region:delete')")
    public Result<Void> deleteRegion(@PathVariable Long id) {
        assetService.deleteRegion(id);
        return Result.success();
    }

    @GetMapping("/buildings")
    @PreAuthorize("@ss.hasPerm('asset:building:list')")
    public Result<List<AssetBuilding>> getBuildings(
            @RequestParam(required = false) Long parkId,
            @RequestParam(required = false) Long regionId
    ) {
        return Result.success(assetService.getBuildings(parkId, regionId));
    }

    @GetMapping("/buildings/options")
    @PreAuthorize("@ss.hasPerm('asset:building:list')")
    public Result<List<AssetBuildingOptionVO>> getBuildingOptions(@RequestParam(required = false) String keyword) {
        return Result.success(assetService.getBuildingOptions(keyword));
    }

    @PostMapping("/buildings")
    @PreAuthorize("@ss.hasPerm('asset:building:create')")
    public Result<Void> saveBuilding(@RequestBody AssetForm form) {
        return Result.judge(assetService.saveBuilding(form));
    }

    @PutMapping("/buildings/{id}")
    @PreAuthorize("@ss.hasPerm('asset:building:update')")
    public Result<Void> updateBuilding(@PathVariable Long id, @RequestBody AssetForm form) {
        return Result.judge(assetService.updateBuilding(id, form));
    }

    @PutMapping("/buildings/{id}/layout")
    @PreAuthorize("@ss.hasPerm('asset:overview:list')")
    public Result<Void> updateBuildingLayout(@PathVariable Long id, @RequestBody AssetLayoutForm form) {
        return Result.judge(assetService.updateBuildingLayout(id, form));
    }

    @DeleteMapping("/buildings/{id}")
    @PreAuthorize("@ss.hasPerm('asset:building:delete')")
    public Result<Void> deleteBuilding(@PathVariable Long id) {
        assetService.deleteBuilding(id);
        return Result.success();
    }

    @GetMapping("/buildings/{buildingId}/floors")
    @PreAuthorize("@ss.hasPerm('asset:building:list')")
    public Result<List<AssetFloor>> getFloors(@PathVariable Long buildingId) {
        return Result.success(assetService.getFloors(buildingId));
    }

    @PostMapping("/floors")
    @PreAuthorize("@ss.hasPerm('asset:building:create')")
    public Result<Void> saveFloor(@RequestBody AssetForm form) {
        return Result.judge(assetService.saveFloor(form));
    }

    @PutMapping("/floors/{id}")
    @PreAuthorize("@ss.hasPerm('asset:building:update')")
    public Result<Void> updateFloor(@PathVariable Long id, @RequestBody AssetForm form) {
        return Result.judge(assetService.updateFloor(id, form));
    }

    @DeleteMapping("/floors/{id}")
    @PreAuthorize("@ss.hasPerm('asset:building:delete')")
    public Result<Void> deleteFloor(@PathVariable Long id) {
        assetService.deleteFloor(id);
        return Result.success();
    }

    @GetMapping("/projects")
    @PreAuthorize("@ss.hasPerm('asset:project:list')")
    public Result<List<AssetProjectVO>> getProjects() {
        return Result.success(assetService.getProjects());
    }

    @PostMapping("/projects")
    @PreAuthorize("@ss.hasPerm('asset:project:create')")
    public Result<Void> saveProject(@RequestBody AssetForm form) {
        return Result.judge(assetService.saveProject(form));
    }

    @PutMapping("/projects/{id}")
    @PreAuthorize("@ss.hasPerm('asset:project:update')")
    public Result<Void> updateProject(@PathVariable Long id, @RequestBody AssetForm form) {
        return Result.judge(assetService.updateProject(id, form));
    }

    @DeleteMapping("/projects/{id}")
    @PreAuthorize("@ss.hasPerm('asset:project:delete')")
    public Result<Void> deleteProject(@PathVariable Long id) {
        assetService.deleteProject(id);
        return Result.success();
    }
}
