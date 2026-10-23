import request from "@/utils/request";

const MENU_BASE_URL = "/api/v1/menus";

const MenuAPI = {
  /** 获取菜单列表 */
  getList(queryParams?: MenuQuery) {
    return request<MenuItem[]>({
      url: `${MENU_BASE_URL}`,
      method: "GET",
      data: queryParams,
    });
  },

  /**
   * 获取菜单下拉选项
   *
   * @param params 查询参数，types 多个菜单类型以英文逗号分隔
   */
  getOptions(params?: { types?: string }) {
    return request<OptionType[]>({
      url: `${MENU_BASE_URL}/options`,
      method: "GET",
      data: params,
    });
  },

  /** 获取可作为上级菜单的下拉选项（按钮不能有子级，不返回） */
  getParentOptions() {
    // uni.request 对数组的序列化格式不确定，这里用逗号串（后端 List<String> 按英文逗号拆分）
    return this.getOptions({ types: "C,M" });
  },

  /** 获取菜单表单数据 */
  getFormData(id: string) {
    return request<MenuForm>({
      url: `${MENU_BASE_URL}/${id}/form`,
      method: "GET",
    });
  },

  /** 新增菜单 */
  create(data: MenuForm) {
    return request({
      url: `${MENU_BASE_URL}`,
      method: "POST",
      data,
    });
  },

  /** 修改菜单 */
  update(id: string, data: MenuForm) {
    return request({
      url: `${MENU_BASE_URL}/${id}`,
      method: "PUT",
      data,
    });
  },

  /**
   * 删除菜单
   *
   * @param ids 菜单ID，多个以英文逗号(,)分隔
   */
  deleteByIds(ids: string) {
    return request({
      url: `${MENU_BASE_URL}/${ids}`,
      method: "DELETE",
    });
  },
};

export default MenuAPI;

/** 菜单查询参数 */
export interface MenuQuery {
  keywords?: string;
}

/**
 * 菜单类型
 *
 * 与后端 MenuTypeEnum 一致：C 目录、M 菜单、E 外链、B 按钮。
 */
export type MenuType = "C" | "M" | "E" | "B";

/** 菜单实体 */
export interface MenuItem {
  children?: MenuItem[];
  component?: string;
  createTime?: Date;
  externalUrl?: string;
  icon?: string;
  id?: string;
  name?: string;
  parentId?: string;
  perm?: string;
  routeName?: string;
  routePath?: string;
  sort?: number;
  /** 状态(1:显示；0:隐藏) */
  visible?: number;
  /** 菜单类型 */
  type?: MenuType;
}

/** 菜单表单类型 */
export interface MenuForm {
  /** 菜单ID(新增不填) */
  id?: string;
  name?: string;
  parentId: string;
  /** 菜单类型 */
  type: MenuType;
  routeName?: string;
  routePath?: string;
  component?: string;
  perm?: string;
  externalUrl?: string;
  icon?: string;
  sort?: number;
  /** 状态(1:显示；0:隐藏) */
  visible?: number;
  /** 新增页面菜单时是否生成增删改查按钮 */
  generateCrudButtons?: boolean;
  /** 按钮权限标识前缀，如 sys:user */
  buttonPermPrefix?: string;
}
