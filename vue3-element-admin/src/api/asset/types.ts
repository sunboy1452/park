export type AssetId = string | number;

export interface AssetRecord {
  id: AssetId;
  code: string;
  name: string;
  status: number;
  area?: number;
  address?: string;
  description?: string;
  remark?: string;
  createTime?: string;
  updateTime?: string;
}

export interface AssetPark extends AssetRecord {}

export interface AssetRegion extends AssetRecord {
  parkId: AssetId;
  regionType?: string;
  mapX: number;
  mapY: number;
  mapWidth: number;
  mapHeight: number;
  sort: number;
}

export interface AssetBuilding extends AssetRecord {
  parkId: AssetId;
  regionId: AssetId;
  buildingType?: string;
  mapX: number;
  mapY: number;
  mapWidth: number;
  mapHeight: number;
  sort: number;
}

export interface AssetBuildingOption {
  id: AssetId;
  code: string;
  name: string;
  parkId: AssetId;
  parkName: string;
  regionId: AssetId;
  regionName: string;
}

export interface AssetFloor {
  id: AssetId;
  buildingId: AssetId;
  floorCode: string;
  floorName: string;
  floorNumber: number;
  area?: number;
  status: number;
  sort: number;
  remark?: string;
}

export interface AssetProject {
  id: AssetId;
  code: string;
  name: string;
  status: number;
  remark?: string;
  updateTime?: string;
  buildingIds: AssetId[];
  buildingLabels: string[];
}

export interface AssetForm {
  code?: string;
  name?: string;
  address?: string;
  area?: number;
  status?: number;
  description?: string;
  remark?: string;
  parkId?: AssetId;
  regionId?: AssetId;
  buildingId?: AssetId;
  regionType?: string;
  buildingType?: string;
  mapX?: number;
  mapY?: number;
  mapWidth?: number;
  mapHeight?: number;
  sort?: number;
  floorCode?: string;
  floorName?: string;
  floorNumber?: number;
  buildingIds?: AssetId[];
}

export interface AssetOverview {
  parkId?: AssetId;
  parkCount: number;
  regionCount: number;
  buildingCount: number;
  floorCount: number;
  spaceCount: number;
  availableSpaceCount: number;
  leasedSpaceCount: number;
  regions: AssetRegion[];
  buildings: AssetBuilding[];
}
