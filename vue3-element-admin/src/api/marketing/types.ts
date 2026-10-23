import type { BaseQueryParams } from "@/api/common";

export type MarketingId = string | number;

export interface MarketingQueryParams extends BaseQueryParams {
  keyword?: string;
  status?: number;
}

export interface MarketingLeadQueryParams extends MarketingQueryParams {
  stage?: string;
  channelId?: MarketingId;
  assigneeId?: MarketingId;
}

export interface MarketingChannelQueryParams extends MarketingQueryParams {
  channelType?: string;
}

export interface MarketingSpaceQueryParams extends MarketingQueryParams {
  availability?: string;
  publishStatus?: number;
  projectName?: string;
  parkId?: MarketingId;
  buildingId?: MarketingId;
}

export interface MarketingLead {
  id: MarketingId;
  customerName: string;
  companyName?: string;
  contactName?: string;
  phone: string;
  email?: string;
  channelId?: MarketingId;
  channelName?: string;
  projectName?: string;
  spaceId?: MarketingId;
  intendedArea?: number;
  budget?: number;
  stage: string;
  assigneeId?: MarketingId;
  assigneeName?: string;
  remark?: string;
  createBy?: MarketingId;
  updateBy?: MarketingId;
  createTime?: string;
  updateTime?: string;
}

export interface MarketingLeadForm {
  customerName: string;
  companyName?: string;
  contactName?: string;
  phone: string;
  email?: string;
  channelId?: MarketingId;
  projectName?: string;
  spaceId?: MarketingId;
  intendedArea?: number;
  budget?: number;
  stage: string;
  assigneeId?: MarketingId;
  remark?: string;
}

export interface MarketingLeadFollowUp {
  id: MarketingId;
  leadId: MarketingId;
  followType: string;
  content: string;
  nextFollowAt?: string;
  createBy?: MarketingId;
  updateBy?: MarketingId;
  createTime?: string;
}

export type MarketingFollowUpQueryParams = Pick<BaseQueryParams, "pageNum" | "pageSize">;

export interface MarketingFollowUpForm {
  followType: string;
  content: string;
  nextFollowAt?: string;
}

export interface MarketingChannel {
  id: MarketingId;
  code: string;
  name: string;
  channelType: string;
  contactName?: string;
  contactPhone?: string;
  status: number;
  remark?: string;
  createBy?: MarketingId;
  updateBy?: MarketingId;
  createTime?: string;
  updateTime?: string;
}

export interface MarketingChannelForm {
  code: string;
  name: string;
  channelType: string;
  contactName?: string;
  contactPhone?: string;
  status: number;
  remark?: string;
}

export interface MarketingSpace {
  id: MarketingId;
  spaceCode: string;
  projectName: string;
  parkId?: MarketingId;
  regionId?: MarketingId;
  buildingId?: MarketingId;
  floorId?: MarketingId;
  parkName?: string;
  regionName?: string;
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
  publishStatus: number;
  createBy?: MarketingId;
  updateBy?: MarketingId;
  createTime?: string;
  updateTime?: string;
}

export interface MarketingSpaceForm {
  spaceCode: string;
  projectName: string;
  parkId?: MarketingId;
  regionId?: MarketingId;
  buildingId?: MarketingId;
  floorId?: MarketingId;
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
  publishStatus: number;
}

export interface MarketingOverview {
  leadTotal: number;
  newLeadCount: number;
  pendingFollowUpCount: number;
  visitCount: number;
  intentionCount: number;
  convertedCount: number;
  channelConversion: {
    channelId: MarketingId;
    channelName: string;
    leadCount: number;
    convertedCount: number;
  }[];
}
