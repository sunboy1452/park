package com.youlai.boot.module.asset.service;

import com.youlai.boot.module.asset.model.entity.*;
import com.youlai.boot.module.asset.model.form.AssetForm;
import com.youlai.boot.module.asset.model.form.AssetLayoutForm;
import com.youlai.boot.module.asset.model.vo.AssetBuildingOptionVO;
import com.youlai.boot.module.asset.model.vo.AssetOverviewVO;
import com.youlai.boot.module.asset.model.vo.AssetProjectVO;

import java.util.List;

public interface AssetService {
    AssetOverviewVO getOverview(Long parkId);
    List<AssetPark> getParks();
    boolean savePark(AssetForm form);
    boolean updatePark(Long id, AssetForm form);
    void deletePark(Long id);
    List<AssetRegion> getRegions(Long parkId);
    boolean saveRegion(AssetForm form);
    boolean updateRegion(Long id, AssetForm form);
    void deleteRegion(Long id);
    List<AssetBuilding> getBuildings(Long parkId, Long regionId);
    List<AssetBuildingOptionVO> getBuildingOptions(String keyword);
    boolean saveBuilding(AssetForm form);
    boolean updateBuilding(Long id, AssetForm form);
    boolean updateBuildingLayout(Long id, AssetLayoutForm form);
    void deleteBuilding(Long id);
    List<AssetFloor> getFloors(Long buildingId);
    boolean saveFloor(AssetForm form);
    boolean updateFloor(Long id, AssetForm form);
    void deleteFloor(Long id);
    List<AssetProjectVO> getProjects();
    boolean saveProject(AssetForm form);
    boolean updateProject(Long id, AssetForm form);
    void deleteProject(Long id);
}
