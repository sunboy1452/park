package com.youlai.boot.module.asset.service.impl;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.youlai.boot.common.exception.BusinessException;
import com.youlai.boot.framework.security.util.SecurityUtils;
import com.youlai.boot.module.asset.mapper.*;
import com.youlai.boot.module.asset.model.entity.*;
import com.youlai.boot.module.asset.model.form.AssetForm;
import com.youlai.boot.module.asset.model.form.AssetLayoutForm;
import com.youlai.boot.module.asset.model.vo.AssetBuildingOptionVO;
import com.youlai.boot.module.asset.model.vo.AssetOverviewVO;
import com.youlai.boot.module.asset.model.vo.AssetProjectVO;
import com.youlai.boot.module.asset.service.AssetService;
import com.youlai.boot.module.marketing.mapper.MarketingSpaceMapper;
import com.youlai.boot.module.marketing.model.entity.MarketingSpace;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AssetServiceImpl implements AssetService {
    private final AssetParkMapper parkMapper;
    private final AssetRegionMapper regionMapper;
    private final AssetBuildingMapper buildingMapper;
    private final AssetFloorMapper floorMapper;
    private final AssetProjectMapper projectMapper;
    private final AssetProjectBuildingMapper projectBuildingMapper;
    private final MarketingSpaceMapper spaceMapper;

    @Override
    public AssetOverviewVO getOverview(Long parkId) {
        AssetOverviewVO vo = new AssetOverviewVO();
        vo.setParkId(parkId);
        vo.setParkCount(parkMapper.selectCount(new LambdaQueryWrapper<>()).intValue());
        vo.setRegionCount(regionMapper.selectCount(new LambdaQueryWrapper<AssetRegion>()
                .eq(parkId != null, AssetRegion::getParkId, parkId)).intValue());
        List<AssetBuilding> buildings = buildingMapper.selectList(new LambdaQueryWrapper<AssetBuilding>()
                .eq(parkId != null, AssetBuilding::getParkId, parkId)
                .orderByAsc(AssetBuilding::getSort, AssetBuilding::getId));
        vo.setBuildingCount(buildings.size());
        List<Long> buildingIds = buildings.stream().map(AssetBuilding::getId).toList();
        vo.setFloorCount(buildingIds.isEmpty() ? 0 : floorMapper.selectCount(new LambdaQueryWrapper<AssetFloor>()
                .in(AssetFloor::getBuildingId, buildingIds)).intValue());
        LambdaQueryWrapper<MarketingSpace> spaces = new LambdaQueryWrapper<MarketingSpace>()
                .eq(parkId != null, MarketingSpace::getParkId, parkId);
        vo.setSpaceCount(spaceMapper.selectCount(spaces).intValue());
        vo.setAvailableSpaceCount(spaceMapper.selectCount(new LambdaQueryWrapper<MarketingSpace>()
                .eq(parkId != null, MarketingSpace::getParkId, parkId)
                .eq(MarketingSpace::getAvailability, "AVAILABLE")).intValue());
        vo.setLeasedSpaceCount(spaceMapper.selectCount(new LambdaQueryWrapper<MarketingSpace>()
                .eq(parkId != null, MarketingSpace::getParkId, parkId)
                .eq(MarketingSpace::getAvailability, "LEASED")).intValue());
        vo.setRegions(regionMapper.selectList(new LambdaQueryWrapper<AssetRegion>()
                .eq(parkId != null, AssetRegion::getParkId, parkId)
                .orderByAsc(AssetRegion::getSort, AssetRegion::getId)));
        vo.setBuildings(buildings);
        return vo;
    }

    @Override
    public List<AssetPark> getParks() {
        return parkMapper.selectList(new LambdaQueryWrapper<AssetPark>().orderByAsc(AssetPark::getId));
    }

    @Override
    public boolean savePark(AssetForm form) {
        requireCodeName(form);
        validateArea(form.getArea());
        ensureCodeUnique(parkMapper.selectCount(new LambdaQueryWrapper<AssetPark>()
                .eq(AssetPark::getCode, clean(form.getCode()))), "园区编号已存在");
        AssetPark park = new AssetPark();
        park.setCode(clean(form.getCode()));
        park.setName(clean(form.getName()));
        park.setAddress(form.getAddress());
        park.setArea(form.getArea());
        park.setStatus(status(form.getStatus()));
        park.setDescription(form.getDescription());
        park.setCreateBy(SecurityUtils.getUserId());
        park.setUpdateBy(SecurityUtils.getUserId());
        return parkMapper.insert(park) > 0;
    }

    @Override
    public boolean updatePark(Long id, AssetForm form) {
        requireCodeName(form);
        validateArea(form.getArea());
        AssetPark park = requireParkEntity(id);
        ensureCodeUnique(parkMapper.selectCount(new LambdaQueryWrapper<AssetPark>()
                .eq(AssetPark::getCode, clean(form.getCode())).ne(AssetPark::getId, id)), "园区编号已存在");
        park.setCode(clean(form.getCode()));
        park.setName(clean(form.getName()));
        park.setAddress(form.getAddress());
        park.setArea(form.getArea());
        park.setStatus(status(form.getStatus()));
        park.setDescription(form.getDescription());
        park.setUpdateBy(SecurityUtils.getUserId());
        return parkMapper.updateById(park) > 0;
    }

    @Override
    public void deletePark(Long id) {
        requireParkEntity(id);
        if (regionMapper.selectCount(new LambdaQueryWrapper<AssetRegion>().eq(AssetRegion::getParkId, id)) > 0
                || buildingMapper.selectCount(new LambdaQueryWrapper<AssetBuilding>().eq(AssetBuilding::getParkId, id)) > 0
                || spaceMapper.selectCount(new LambdaQueryWrapper<MarketingSpace>().eq(MarketingSpace::getParkId, id)) > 0) {
            throw new BusinessException("园区下仍有区域、楼栋或房源，不能删除");
        }
        parkMapper.deleteById(id);
    }

    @Override
    public List<AssetRegion> getRegions(Long parkId) {
        return regionMapper.selectList(new LambdaQueryWrapper<AssetRegion>()
                .eq(parkId != null, AssetRegion::getParkId, parkId)
                .orderByAsc(AssetRegion::getSort, AssetRegion::getId));
    }

    @Override
    public boolean saveRegion(AssetForm form) {
        requireCodeName(form, 100);
        validateArea(form.getArea());
        requireParkId(form.getParkId());
        validateLayout(value(form.getMapX(), 40), value(form.getMapY(), 40), value(form.getMapWidth(), 280), value(form.getMapHeight(), 230));
        ensureCodeUnique(regionMapper.selectCount(new LambdaQueryWrapper<AssetRegion>()
                .eq(AssetRegion::getParkId, form.getParkId()).eq(AssetRegion::getCode, clean(form.getCode()))), "此园区已存在该区域编号");
        AssetRegion region = new AssetRegion();
        region.setParkId(form.getParkId());
        region.setCode(clean(form.getCode()));
        region.setName(clean(form.getName()));
        region.setRegionType(form.getRegionType());
        region.setArea(form.getArea());
        region.setMapX(value(form.getMapX(), 40));
        region.setMapY(value(form.getMapY(), 40));
        region.setMapWidth(value(form.getMapWidth(), 280));
        region.setMapHeight(value(form.getMapHeight(), 230));
        region.setStatus(status(form.getStatus()));
        region.setSort(value(form.getSort(), 0));
        region.setRemark(form.getRemark());
        region.setCreateBy(SecurityUtils.getUserId());
        region.setUpdateBy(SecurityUtils.getUserId());
        return regionMapper.insert(region) > 0;
    }

    @Override
    @Transactional
    public boolean updateRegion(Long id, AssetForm form) {
        requireCodeName(form, 100);
        validateArea(form.getArea());
        requireParkId(form.getParkId());
        AssetRegion region = requireRegion(id);
        if (!Objects.equals(region.getParkId(), form.getParkId())
                && buildingMapper.selectCount(new LambdaQueryWrapper<AssetBuilding>().eq(AssetBuilding::getRegionId, id)) > 0) {
            throw new BusinessException("区域下已有楼栋，不能直接调整所属园区");
        }
        int mapX = value(form.getMapX(), 40);
        int mapY = value(form.getMapY(), 40);
        int mapWidth = value(form.getMapWidth(), 280);
        int mapHeight = value(form.getMapHeight(), 230);
        validateLayout(mapX, mapY, mapWidth, mapHeight);
        int deltaX = mapX - region.getMapX();
        int deltaY = mapY - region.getMapY();
        List<AssetBuilding> childBuildings = buildingMapper.selectList(new LambdaQueryWrapper<AssetBuilding>()
                .eq(AssetBuilding::getRegionId, id));
        for (AssetBuilding building : childBuildings) {
            int nextX = building.getMapX() + deltaX;
            int nextY = building.getMapY() + deltaY;
            if (nextX < mapX || nextY < mapY || nextX + building.getMapWidth() > mapX + mapWidth
                    || nextY + building.getMapHeight() > mapY + mapHeight) {
                throw new BusinessException("调整后的区域尺寸无法容纳现有楼栋");
            }
            building.setMapX(nextX);
            building.setMapY(nextY);
            building.setUpdateBy(SecurityUtils.getUserId());
        }
        ensureCodeUnique(regionMapper.selectCount(new LambdaQueryWrapper<AssetRegion>()
                .eq(AssetRegion::getParkId, form.getParkId()).eq(AssetRegion::getCode, clean(form.getCode()))
                .ne(AssetRegion::getId, id)), "此园区已存在该区域编号");
        region.setParkId(form.getParkId());
        region.setCode(clean(form.getCode()));
        region.setName(clean(form.getName()));
        region.setRegionType(form.getRegionType());
        region.setArea(form.getArea());
        region.setMapX(mapX);
        region.setMapY(mapY);
        region.setMapWidth(mapWidth);
        region.setMapHeight(mapHeight);
        region.setStatus(status(form.getStatus()));
        region.setSort(value(form.getSort(), 0));
        region.setRemark(form.getRemark());
        region.setUpdateBy(SecurityUtils.getUserId());
        boolean updated = regionMapper.updateById(region) > 0;
        childBuildings.forEach(buildingMapper::updateById);
        return updated;
    }

    @Override
    public void deleteRegion(Long id) {
        requireRegion(id);
        if (buildingMapper.selectCount(new LambdaQueryWrapper<AssetBuilding>().eq(AssetBuilding::getRegionId, id)) > 0) {
            throw new BusinessException("区域下仍有楼栋，不能删除");
        }
        regionMapper.deleteById(id);
    }

    @Override
    public List<AssetBuilding> getBuildings(Long parkId, Long regionId) {
        return buildingMapper.selectList(new LambdaQueryWrapper<AssetBuilding>()
                .eq(parkId != null, AssetBuilding::getParkId, parkId)
                .eq(regionId != null, AssetBuilding::getRegionId, regionId)
                .orderByAsc(AssetBuilding::getSort, AssetBuilding::getId));
    }

    @Override
    public List<AssetBuildingOptionVO> getBuildingOptions(String keyword) {
        List<AssetBuilding> buildings = buildingMapper.selectList(new LambdaQueryWrapper<AssetBuilding>()
                .and(StrUtil.isNotBlank(keyword), w -> w.like(AssetBuilding::getCode, keyword)
                        .or().like(AssetBuilding::getName, keyword))
                .orderByAsc(AssetBuilding::getParkId, AssetBuilding::getName));
        Map<Long, AssetPark> parks = parkMapper.selectList(new LambdaQueryWrapper<>()).stream()
                .collect(Collectors.toMap(AssetPark::getId, p -> p));
        Map<Long, AssetRegion> regions = regionMapper.selectList(new LambdaQueryWrapper<>()).stream()
                .collect(Collectors.toMap(AssetRegion::getId, r -> r));
        return buildings.stream().map(building -> {
            AssetBuildingOptionVO option = new AssetBuildingOptionVO();
            option.setId(building.getId());
            option.setCode(building.getCode());
            option.setName(building.getName());
            option.setParkId(building.getParkId());
            option.setRegionId(building.getRegionId());
            AssetPark park = parks.get(building.getParkId());
            AssetRegion region = regions.get(building.getRegionId());
            option.setParkName(park == null ? "" : park.getName());
            option.setRegionName(region == null ? "" : region.getName());
            return option;
        }).toList();
    }

    @Override
    public boolean saveBuilding(AssetForm form) {
        requireCodeName(form, 100);
        validateArea(form.getArea());
        requireRegion(form.getParkId(), form.getRegionId());
        ensureCodeUnique(buildingMapper.selectCount(new LambdaQueryWrapper<AssetBuilding>()
                .eq(AssetBuilding::getParkId, form.getParkId()).eq(AssetBuilding::getCode, clean(form.getCode()))), "此园区已存在该楼栋编号");
        AssetBuilding building = new AssetBuilding();
        fillBuilding(building, form);
        validateBuildingPlacement(building);
        building.setCreateBy(SecurityUtils.getUserId());
        building.setUpdateBy(SecurityUtils.getUserId());
        return buildingMapper.insert(building) > 0;
    }

    @Override
    public boolean updateBuilding(Long id, AssetForm form) {
        requireCodeName(form, 100);
        validateArea(form.getArea());
        requireRegion(form.getParkId(), form.getRegionId());
        AssetBuilding building = requireBuilding(id);
        if ((!Objects.equals(building.getParkId(), form.getParkId()) || !Objects.equals(building.getRegionId(), form.getRegionId()))
                && spaceMapper.selectCount(new LambdaQueryWrapper<MarketingSpace>().eq(MarketingSpace::getBuildingId, id)) > 0) {
            throw new BusinessException("楼栋已有房源，不能直接调整所属园区或区域");
        }
        ensureCodeUnique(buildingMapper.selectCount(new LambdaQueryWrapper<AssetBuilding>()
                .eq(AssetBuilding::getParkId, form.getParkId()).eq(AssetBuilding::getCode, clean(form.getCode()))
                .ne(AssetBuilding::getId, id)), "此园区已存在该楼栋编号");
        fillBuilding(building, form);
        validateBuildingPlacement(building);
        building.setUpdateBy(SecurityUtils.getUserId());
        return buildingMapper.updateById(building) > 0;
    }

    @Override
    public boolean updateBuildingLayout(Long id, AssetLayoutForm form) {
        AssetBuilding building = requireBuilding(id);
        validateLayout(form.getMapX(), form.getMapY(), form.getMapWidth(), form.getMapHeight());
        building.setMapX(form.getMapX());
        building.setMapY(form.getMapY());
        building.setMapWidth(form.getMapWidth());
        building.setMapHeight(form.getMapHeight());
        validateBuildingPlacement(building);
        building.setUpdateBy(SecurityUtils.getUserId());
        return buildingMapper.updateById(building) > 0;
    }

    @Override
    public void deleteBuilding(Long id) {
        requireBuilding(id);
        if (floorMapper.selectCount(new LambdaQueryWrapper<AssetFloor>().eq(AssetFloor::getBuildingId, id)) > 0
                || spaceMapper.selectCount(new LambdaQueryWrapper<MarketingSpace>().eq(MarketingSpace::getBuildingId, id)) > 0
                || projectBuildingMapper.selectCount(new LambdaQueryWrapper<AssetProjectBuilding>().eq(AssetProjectBuilding::getBuildingId, id)) > 0) {
            throw new BusinessException("楼栋仍有关联楼层、房源或项目，不能删除");
        }
        buildingMapper.deleteById(id);
    }

    @Override
    public List<AssetFloor> getFloors(Long buildingId) {
        requireBuilding(buildingId);
        return floorMapper.selectList(new LambdaQueryWrapper<AssetFloor>().eq(AssetFloor::getBuildingId, buildingId)
                .orderByAsc(AssetFloor::getFloorNumber));
    }

    @Override
    public boolean saveFloor(AssetForm form) {
        requireFloorForm(form);
        validateArea(form.getArea());
        ensureCodeUnique(floorMapper.selectCount(new LambdaQueryWrapper<AssetFloor>()
                .eq(AssetFloor::getBuildingId, form.getBuildingId()).eq(AssetFloor::getFloorCode, clean(form.getFloorCode()))), "此楼栋已存在该楼层编号");
        AssetFloor floor = new AssetFloor();
        fillFloor(floor, form);
        floor.setCreateBy(SecurityUtils.getUserId());
        floor.setUpdateBy(SecurityUtils.getUserId());
        return floorMapper.insert(floor) > 0;
    }

    @Override
    public boolean updateFloor(Long id, AssetForm form) {
        requireFloorForm(form);
        validateArea(form.getArea());
        AssetFloor floor = requireFloor(id);
        if (!Objects.equals(floor.getBuildingId(), form.getBuildingId())
                && spaceMapper.selectCount(new LambdaQueryWrapper<MarketingSpace>().eq(MarketingSpace::getFloorId, id)) > 0) {
            throw new BusinessException("楼层已有房源，不能直接调整所属楼栋");
        }
        ensureCodeUnique(floorMapper.selectCount(new LambdaQueryWrapper<AssetFloor>()
                .eq(AssetFloor::getBuildingId, form.getBuildingId()).eq(AssetFloor::getFloorCode, clean(form.getFloorCode()))
                .ne(AssetFloor::getId, id)), "此楼栋已存在该楼层编号");
        fillFloor(floor, form);
        floor.setUpdateBy(SecurityUtils.getUserId());
        return floorMapper.updateById(floor) > 0;
    }

    @Override
    public void deleteFloor(Long id) {
        requireFloor(id);
        if (spaceMapper.selectCount(new LambdaQueryWrapper<MarketingSpace>().eq(MarketingSpace::getFloorId, id)) > 0) {
            throw new BusinessException("楼层下仍有房源，不能删除");
        }
        floorMapper.deleteById(id);
    }

    @Override
    public List<AssetProjectVO> getProjects() {
        List<AssetProject> projects = projectMapper.selectList(new LambdaQueryWrapper<AssetProject>().orderByAsc(AssetProject::getId));
        Map<Long, AssetBuildingOptionVO> options = getBuildingOptions(null).stream()
                .collect(Collectors.toMap(AssetBuildingOptionVO::getId, item -> item));
        return projects.stream().map(project -> {
            AssetProjectVO vo = new AssetProjectVO();
            vo.setId(project.getId());
            vo.setCode(project.getCode());
            vo.setName(project.getName());
            vo.setStatus(project.getStatus());
            vo.setRemark(project.getRemark());
            vo.setUpdateTime(project.getUpdateTime());
            List<Long> ids = projectBuildingMapper.selectList(new LambdaQueryWrapper<AssetProjectBuilding>()
                            .eq(AssetProjectBuilding::getProjectId, project.getId())).stream()
                    .map(AssetProjectBuilding::getBuildingId).toList();
            vo.setBuildingIds(ids);
            vo.setBuildingLabels(ids.stream().map(options::get).filter(Objects::nonNull)
                    .map(item -> item.getParkName() + " / " + item.getName()).toList());
            return vo;
        }).toList();
    }

    @Override
    @Transactional
    public boolean saveProject(AssetForm form) {
        requireCodeName(form);
        List<Long> buildingIds = normalizeBuildingIds(form.getBuildingIds());
        ensureCodeUnique(projectMapper.selectCount(new LambdaQueryWrapper<AssetProject>()
                .eq(AssetProject::getCode, clean(form.getCode()))), "项目编号已存在");
        AssetProject project = new AssetProject();
        project.setCode(clean(form.getCode()));
        project.setName(clean(form.getName()));
        project.setStatus(status(form.getStatus()));
        project.setRemark(form.getRemark());
        project.setCreateBy(SecurityUtils.getUserId());
        project.setUpdateBy(SecurityUtils.getUserId());
        projectMapper.insert(project);
        saveProjectBuildings(project.getId(), buildingIds);
        return true;
    }

    @Override
    @Transactional
    public boolean updateProject(Long id, AssetForm form) {
        requireCodeName(form);
        List<Long> buildingIds = normalizeBuildingIds(form.getBuildingIds());
        AssetProject project = requireProject(id);
        ensureCodeUnique(projectMapper.selectCount(new LambdaQueryWrapper<AssetProject>()
                .eq(AssetProject::getCode, clean(form.getCode())).ne(AssetProject::getId, id)), "项目编号已存在");
        project.setCode(clean(form.getCode()));
        project.setName(clean(form.getName()));
        project.setStatus(status(form.getStatus()));
        project.setRemark(form.getRemark());
        project.setUpdateBy(SecurityUtils.getUserId());
        projectMapper.updateById(project);
        projectBuildingMapper.delete(new LambdaQueryWrapper<AssetProjectBuilding>().eq(AssetProjectBuilding::getProjectId, id));
        saveProjectBuildings(id, buildingIds);
        return true;
    }

    @Override
    @Transactional
    public void deleteProject(Long id) {
        requireProject(id);
        projectBuildingMapper.delete(new LambdaQueryWrapper<AssetProjectBuilding>().eq(AssetProjectBuilding::getProjectId, id));
        projectMapper.deleteById(id);
    }

    private void fillBuilding(AssetBuilding building, AssetForm form) {
        building.setParkId(form.getParkId());
        building.setRegionId(form.getRegionId());
        building.setCode(clean(form.getCode()));
        building.setName(clean(form.getName()));
        building.setBuildingType(form.getBuildingType());
        building.setArea(form.getArea());
        building.setMapX(value(form.getMapX(), 80));
        building.setMapY(value(form.getMapY(), 80));
        building.setMapWidth(value(form.getMapWidth(), 120));
        building.setMapHeight(value(form.getMapHeight(), 72));
        validateLayout(building.getMapX(), building.getMapY(), building.getMapWidth(), building.getMapHeight());
        building.setStatus(status(form.getStatus()));
        building.setSort(value(form.getSort(), 0));
        building.setRemark(form.getRemark());
    }

    private void validateBuildingPlacement(AssetBuilding building) {
        AssetRegion region = requireRegion(building.getRegionId());
        if (!Objects.equals(region.getParkId(), building.getParkId())
                || building.getMapX() < region.getMapX() || building.getMapY() < region.getMapY()
                || building.getMapX() + building.getMapWidth() > region.getMapX() + region.getMapWidth()
                || building.getMapY() + building.getMapHeight() > region.getMapY() + region.getMapHeight()) {
            throw new BusinessException("楼栋示意位置需要在所属区域范围内");
        }
    }

    private void fillFloor(AssetFloor floor, AssetForm form) {
        floor.setBuildingId(form.getBuildingId());
        floor.setFloorCode(clean(form.getFloorCode()));
        floor.setFloorName(clean(form.getFloorName()));
        floor.setFloorNumber(form.getFloorNumber());
        floor.setArea(form.getArea());
        floor.setStatus(status(form.getStatus()));
        floor.setSort(value(form.getSort(), 0));
        floor.setRemark(form.getRemark());
    }

    private void saveProjectBuildings(Long projectId, List<Long> buildingIds) {
        List<AssetBuilding> buildings = buildingIds.isEmpty() ? List.of() : buildingMapper.selectList(
                new LambdaQueryWrapper<AssetBuilding>().in(AssetBuilding::getId, buildingIds));
        if (buildings.size() != buildingIds.size()) {
            throw new BusinessException("所选楼栋不存在或无权访问");
        }
        for (Long buildingId : buildingIds) {
            AssetProjectBuilding relation = new AssetProjectBuilding();
            relation.setProjectId(projectId);
            relation.setBuildingId(buildingId);
            relation.setCreateBy(SecurityUtils.getUserId());
            relation.setCreateTime(LocalDateTime.now());
            projectBuildingMapper.insert(relation);
        }
    }

    private List<Long> normalizeBuildingIds(List<Long> ids) {
        if (ids == null || ids.isEmpty()) throw new BusinessException("请至少选择一栋楼");
        List<Long> normalized = ids.stream().filter(Objects::nonNull).distinct().toList();
        if (normalized.isEmpty()) throw new BusinessException("请至少选择一栋楼");
        return normalized;
    }

    private void requireFloorForm(AssetForm form) {
        if (form.getBuildingId() == null || StrUtil.isBlank(form.getFloorCode()) || StrUtil.isBlank(form.getFloorName()) || form.getFloorNumber() == null) {
            throw new BusinessException("楼栋、楼层编号、楼层名称和楼层序号不能为空");
        }
        requireBuilding(form.getBuildingId());
    }

    private void requireRegion(Long parkId, Long regionId) {
        if (parkId == null || regionId == null) throw new BusinessException("请选择园区和所属区域");
        AssetRegion region = requireRegion(regionId);
        if (!Objects.equals(region.getParkId(), parkId)) throw new BusinessException("所选区域不属于该园区");
    }

    private void requireParkId(Long id) {
        if (id == null) throw new BusinessException("请选择所属园区");
        requireParkEntity(id);
    }

    private AssetPark requireParkEntity(Long id) {
        AssetPark park = parkMapper.selectById(id);
        if (park == null) throw new BusinessException("园区不存在");
        return park;
    }

    private AssetRegion requireRegion(Long id) {
        AssetRegion region = regionMapper.selectById(id);
        if (region == null) throw new BusinessException("区域不存在");
        return region;
    }

    private AssetBuilding requireBuilding(Long id) {
        AssetBuilding building = buildingMapper.selectById(id);
        if (building == null) throw new BusinessException("楼栋不存在");
        return building;
    }

    private AssetFloor requireFloor(Long id) {
        AssetFloor floor = floorMapper.selectById(id);
        if (floor == null) throw new BusinessException("楼层不存在");
        return floor;
    }

    private AssetProject requireProject(Long id) {
        AssetProject project = projectMapper.selectById(id);
        if (project == null) throw new BusinessException("项目不存在");
        return project;
    }

    private void validateLayout(Integer x, Integer y, Integer width, Integer height) {
        if (x == null || y == null || width == null || height == null || x < 0 || y < 0 || width < 40 || height < 32
                || x + width > 1000 || y + height > 600 || width > 500 || height > 300) {
            throw new BusinessException("示意图位置或尺寸超出允许范围");
        }
    }

    private void requireCodeName(AssetForm form) {
        requireCodeName(form, 150);
    }

    private void requireCodeName(AssetForm form, int maxNameLength) {
        if (StrUtil.isBlank(form.getCode()) || StrUtil.isBlank(form.getName())
                || form.getCode().trim().length() > 64 || form.getName().trim().length() > maxNameLength) {
            throw new BusinessException("编号或名称为空或超出长度限制");
        }
    }

    private void validateArea(java.math.BigDecimal area) {
        if (area != null && area.signum() < 0) throw new BusinessException("面积不能小于0");
    }

    private void ensureCodeUnique(Long count, String message) {
        if (count != null && count > 0) throw new BusinessException(message);
    }

    private String clean(String value) {
        return StrUtil.trim(value);
    }

    private Integer status(Integer value) {
        if (value != null && value != 0 && value != 1) throw new BusinessException("状态值无效");
        return value == null ? 1 : value;
    }

    private Integer value(Integer value, Integer fallback) {
        return value == null ? fallback : value;
    }
}
