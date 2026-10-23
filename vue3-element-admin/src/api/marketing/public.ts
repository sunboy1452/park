import type { PageResult } from "@/api/common";
import request from "@/utils/request";
import type { MarketingId } from "./types";

export interface PublicMarketingSpace {
  id: MarketingId;
  projectName: string;
  buildingName?: string;
  floorName?: string;
  roomNo?: string;
  area: number;
  rentUnitPrice?: number;
  availability: string;
  displayTitle: string;
  description?: string;
  coverUrl?: string;
  vrUrl?: string;
}

export interface PublicMarketingSpaceQuery {
  pageNum: number;
  pageSize: number;
  keyword?: string;
  projectName?: string;
}

const PUBLIC_SPACE_URL = "/api/v1/public/marketing/spaces";

const PublicMarketingAPI = {
  getSpacePage(params: PublicMarketingSpaceQuery) {
    return request<unknown, PageResult<PublicMarketingSpace>>({
      url: PUBLIC_SPACE_URL,
      method: "get",
      params,
      anonymous: true,
    });
  },
  getSpace(id: MarketingId) {
    return request<unknown, PublicMarketingSpace>({
      url: `${PUBLIC_SPACE_URL}/${id}`,
      method: "get",
      anonymous: true,
    });
  },
};

export default PublicMarketingAPI;
