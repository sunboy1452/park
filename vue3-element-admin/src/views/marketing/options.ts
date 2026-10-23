export const leadStageOptions = [
  { label: "新线索", value: "NEW", type: "info" },
  { label: "已联系", value: "CONTACTED", type: "primary" },
  { label: "已带看", value: "VISITED", type: "warning" },
  { label: "意向客户", value: "INTENTION", type: "success" },
  { label: "已转化", value: "CONVERTED", type: "success" },
  { label: "已关闭", value: "LOST", type: "info" },
] as const;

export const channelTypeOptions = [
  { label: "线上", value: "ONLINE" },
  { label: "线下", value: "OFFLINE" },
  { label: "经纪人", value: "BROKER" },
  { label: "合作方", value: "PARTNER" },
  { label: "其他", value: "OTHER" },
] as const;

export const availabilityOptions = [
  { label: "可租", value: "AVAILABLE", type: "success" },
  { label: "已预定", value: "RESERVED", type: "warning" },
  { label: "已出租", value: "LEASED", type: "info" },
  { label: "维护中", value: "MAINTENANCE", type: "danger" },
] as const;

export const publishStatusOptions = [
  { label: "草稿", value: 0, type: "info" },
  { label: "已发布", value: 1, type: "success" },
  { label: "已下线", value: 2, type: "warning" },
] as const;

export function getOptionLabel(
  options: readonly { label: string; value: string | number }[],
  value?: string | number
) {
  return options.find((option) => option.value === value)?.label ?? value ?? "-";
}
