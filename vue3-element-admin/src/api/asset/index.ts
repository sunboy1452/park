import request from "@/utils/request";
import type {
  AssetBuilding,
  AssetBuildingOption,
  AssetFloor,
  AssetForm,
  AssetId,
  AssetOverview,
  AssetPark,
  AssetProject,
  AssetRegion,
} from "./types";

const BASE_URL = "/api/v1/assets";

const AssetAPI = {
  getOverview(parkId?: AssetId) {
    return request<unknown, AssetOverview>({ url: `${BASE_URL}/overview`, method: "get", params: { parkId } });
  },
  getParks() {
    return request<unknown, AssetPark[]>({ url: `${BASE_URL}/parks`, method: "get" });
  },
  createPark(data: AssetForm) {
    return request({ url: `${BASE_URL}/parks`, method: "post", data });
  },
  updatePark(id: AssetId, data: AssetForm) {
    return request({ url: `${BASE_URL}/parks/${id}`, method: "put", data });
  },
  deletePark(id: AssetId) {
    return request({ url: `${BASE_URL}/parks/${id}`, method: "delete" });
  },
  getRegions(parkId?: AssetId) {
    return request<unknown, AssetRegion[]>({ url: `${BASE_URL}/regions`, method: "get", params: { parkId } });
  },
  createRegion(data: AssetForm) {
    return request({ url: `${BASE_URL}/regions`, method: "post", data });
  },
  updateRegion(id: AssetId, data: AssetForm) {
    return request({ url: `${BASE_URL}/regions/${id}`, method: "put", data });
  },
  deleteRegion(id: AssetId) {
    return request({ url: `${BASE_URL}/regions/${id}`, method: "delete" });
  },
  getBuildings(params: { parkId?: AssetId; regionId?: AssetId } = {}) {
    return request<unknown, AssetBuilding[]>({ url: `${BASE_URL}/buildings`, method: "get", params });
  },
  getBuildingOptions(keyword?: string) {
    return request<unknown, AssetBuildingOption[]>({
      url: `${BASE_URL}/buildings/options`,
      method: "get",
      params: { keyword },
    });
  },
  createBuilding(data: AssetForm) {
    return request({ url: `${BASE_URL}/buildings`, method: "post", data });
  },
  updateBuilding(id: AssetId, data: AssetForm) {
    return request({ url: `${BASE_URL}/buildings/${id}`, method: "put", data });
  },
  updateBuildingLayout(id: AssetId, data: Pick<AssetForm, "mapX" | "mapY" | "mapWidth" | "mapHeight">) {
    return request({ url: `${BASE_URL}/buildings/${id}/layout`, method: "put", data });
  },
  deleteBuilding(id: AssetId) {
    return request({ url: `${BASE_URL}/buildings/${id}`, method: "delete" });
  },
  getFloors(buildingId: AssetId) {
    return request<unknown, AssetFloor[]>({ url: `${BASE_URL}/buildings/${buildingId}/floors`, method: "get" });
  },
  createFloor(data: AssetForm) {
    return request({ url: `${BASE_URL}/floors`, method: "post", data });
  },
  updateFloor(id: AssetId, data: AssetForm) {
    return request({ url: `${BASE_URL}/floors/${id}`, method: "put", data });
  },
  deleteFloor(id: AssetId) {
    return request({ url: `${BASE_URL}/floors/${id}`, method: "delete" });
  },
  getProjects() {
    return request<unknown, AssetProject[]>({ url: `${BASE_URL}/projects`, method: "get" });
  },
  createProject(data: AssetForm) {
    return request({ url: `${BASE_URL}/projects`, method: "post", data });
  },
  updateProject(id: AssetId, data: AssetForm) {
    return request({ url: `${BASE_URL}/projects/${id}`, method: "put", data });
  },
  deleteProject(id: AssetId) {
    return request({ url: `${BASE_URL}/projects/${id}`, method: "delete" });
  },
};

export default AssetAPI;
export * from "./types";
