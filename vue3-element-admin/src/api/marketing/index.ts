import request from "@/utils/request";
import type { PageResult } from "@/api/common";
import type {
  MarketingChannel,
  MarketingChannelForm,
  MarketingChannelQueryParams,
  MarketingFollowUpForm,
  MarketingFollowUpQueryParams,
  MarketingId,
  MarketingLead,
  MarketingLeadForm,
  MarketingLeadFollowUp,
  MarketingLeadQueryParams,
  MarketingOverview,
  MarketingSpace,
  MarketingSpaceForm,
  MarketingSpaceQueryParams,
} from "./types";

const MARKETING_BASE_URL = "/api/v1/marketing";

const MarketingAPI = {
  getOverview() {
    return request<unknown, MarketingOverview>({
      url: `${MARKETING_BASE_URL}/overview`,
      method: "get",
    });
  },

  getLeadPage(params: MarketingLeadQueryParams) {
    return request<unknown, PageResult<MarketingLead>>({
      url: `${MARKETING_BASE_URL}/leads`,
      method: "get",
      params,
    });
  },
  createLead(data: MarketingLeadForm) {
    return request({ url: `${MARKETING_BASE_URL}/leads`, method: "post", data });
  },
  updateLead(id: MarketingId, data: MarketingLeadForm) {
    return request({ url: `${MARKETING_BASE_URL}/leads/${id}`, method: "put", data });
  },
  deleteLead(id: MarketingId) {
    return request({ url: `${MARKETING_BASE_URL}/leads/${id}`, method: "delete" });
  },
  assignLead(id: MarketingId, assigneeId: MarketingId | null) {
    return request({
      url: `${MARKETING_BASE_URL}/leads/${id}/assign`,
      method: "put",
      data: { assigneeId },
    });
  },
  getFollowUps(id: MarketingId, params: MarketingFollowUpQueryParams) {
    return request<unknown, PageResult<MarketingLeadFollowUp>>({
      url: `${MARKETING_BASE_URL}/leads/${id}/follow-ups`,
      method: "get",
      params,
    });
  },
  createFollowUp(id: MarketingId, data: MarketingFollowUpForm) {
    return request({
      url: `${MARKETING_BASE_URL}/leads/${id}/follow-ups`,
      method: "post",
      data,
    });
  },

  getChannelPage(params: MarketingChannelQueryParams) {
    return request<unknown, PageResult<MarketingChannel>>({
      url: `${MARKETING_BASE_URL}/channels`,
      method: "get",
      params,
    });
  },
  createChannel(data: MarketingChannelForm) {
    return request({ url: `${MARKETING_BASE_URL}/channels`, method: "post", data });
  },
  updateChannel(id: MarketingId, data: MarketingChannelForm) {
    return request({ url: `${MARKETING_BASE_URL}/channels/${id}`, method: "put", data });
  },
  deleteChannel(id: MarketingId) {
    return request({ url: `${MARKETING_BASE_URL}/channels/${id}`, method: "delete" });
  },

  getSpacePage(params: MarketingSpaceQueryParams) {
    return request<unknown, PageResult<MarketingSpace>>({
      url: `${MARKETING_BASE_URL}/spaces`,
      method: "get",
      params,
    });
  },
  createSpace(data: MarketingSpaceForm) {
    return request({ url: `${MARKETING_BASE_URL}/spaces`, method: "post", data });
  },
  updateSpace(id: MarketingId, data: MarketingSpaceForm) {
    return request({ url: `${MARKETING_BASE_URL}/spaces/${id}`, method: "put", data });
  },
  deleteSpace(id: MarketingId) {
    return request({ url: `${MARKETING_BASE_URL}/spaces/${id}`, method: "delete" });
  },
};

export default MarketingAPI;
export * from "./types";
