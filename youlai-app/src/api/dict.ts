import request from "@/utils/request";

const DICT_BASE_URL = "/api/v1/dicts";

/** 标签样式的语义名 */
const TAG_TYPE_NAMES = ["primary", "success", "warning", "danger", "info"];

/** 历史单字母标签样式对应的语义名 */
const LEGACY_TAG_TYPES: Record<string, string> = {
  P: "primary",
  S: "success",
  W: "warning",
  D: "danger",
  I: "info",
};

/**
 * 归一标签样式，把历史单字母值转成语义名
 *
 * 无样式或无法识别时返回空串
 */
function normalizeTagType(tagType?: string): string {
  const name = String(tagType ?? "")
    .trim()
    .toLowerCase();
  if (!name || name === "n" || name === "default") return "";
  return TAG_TYPE_NAMES.includes(name) ? name : (LEGACY_TAG_TYPES[name.toUpperCase()] ?? "");
}

const DictAPI = {
  /** 获取字典类型分页数据 */
  getPage(queryParams: DictTypePageQuery) {
    return request<PageResult<DictTypeItem>>({
      url: `${DICT_BASE_URL}`,
      method: "GET",
      data: queryParams,
    });
  },

  /** 获取字典类型表单数据 */
  getFormData(id: string | number) {
    return request<DictTypeForm>({
      url: `${DICT_BASE_URL}/${id}/form`,
      method: "GET",
    });
  },

  /** 新增字典类型 */
  create(data: DictTypeForm) {
    return request({
      url: `${DICT_BASE_URL}`,
      method: "POST",
      data,
    });
  },

  /** 修改字典类型 */
  update(id: string | number, data: DictTypeForm) {
    return request({
      url: `${DICT_BASE_URL}/${id}`,
      method: "PUT",
      data,
    });
  },

  /**
   * 删除字典类型
   *
   * @param ids 字典类型ID，多个以英文逗号(,)分隔
   */
  deleteByIds(ids: string) {
    return request({
      url: `${DICT_BASE_URL}/${ids}`,
      method: "DELETE",
    });
  },

  /** 获取字典数据分页列表 */
  getItemPage(dictCode: string, queryParams: DictItemPageQuery) {
    return request<PageResult<DictItem>>({
      url: `${DICT_BASE_URL}/${dictCode}/items`,
      method: "GET",
      data: queryParams,
    }).then((data) => ({
      ...data,
      list: (data.list ?? []).map((item) => ({ ...item, tagType: normalizeTagType(item.tagType) })),
    }));
  },

  /** 获取字典数据表单数据 */
  getItemFormData(dictCode: string, id: string | number) {
    return request<DictItemForm>({
      url: `${DICT_BASE_URL}/${dictCode}/items/${id}/form`,
      method: "GET",
    }).then((data) => ({ ...data, tagType: normalizeTagType(data.tagType) }));
  },

  /** 新增字典数据 */
  createItem(dictCode: string, data: DictItemForm) {
    return request({
      url: `${DICT_BASE_URL}/${dictCode}/items`,
      method: "POST",
      data,
    });
  },

  /** 修改字典数据 */
  updateItem(dictCode: string, id: string | number, data: DictItemForm) {
    return request({
      url: `${DICT_BASE_URL}/${dictCode}/items/${id}`,
      method: "PUT",
      data,
    });
  },

  /**
   * 删除字典数据
   *
   * @param ids 字典数据ID，多个以英文逗号(,)分隔
   */
  deleteItems(dictCode: string, ids: string) {
    return request({
      url: `${DICT_BASE_URL}/${dictCode}/items/${ids}`,
      method: "DELETE",
    });
  },
};

export default DictAPI;

/** 字典类型分页查询参数 */
export interface DictTypePageQuery extends PageQuery {
  keywords?: string;
  status?: number;
}

/** 字典类型表单对象 */
export interface DictTypeForm {
  id?: string;
  name?: string;
  dictCode?: string;
  status?: number;
  remark?: string;
}

/** 字典类型分页对象 */
export interface DictTypeItem {
  id?: string;
  name?: string;
  dictCode?: string;
  status?: number;
  remark?: string;
}

/** 字典数据分页查询参数 */
export interface DictItemPageQuery extends PageQuery {
  keywords?: string;
}

/** 字典数据表单对象 */
export interface DictItemForm {
  id?: string;
  dictCode?: string;
  label?: string;
  value?: string;
  sort?: number;
  status?: number;
  remark?: string;
  /** 标签样式(primary/success/warning/danger/info，空为无样式) */
  tagType?: string;
}

/** 字典数据分页对象 */
export interface DictItem {
  id?: string;
  dictCode?: string;
  label?: string;
  value?: string;
  sort?: number;
  status?: number;
  remark?: string;
  /** 标签样式(primary/success/warning/danger/info，空为无样式) */
  tagType?: string;
}
