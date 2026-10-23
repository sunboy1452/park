/** 工作台菜单配置 */

import { PERM } from "@/constants/permissions";

export interface WorkMenuItem {
  /** 入口类型：route 站内路由、link 站外链接 */
  kind: "route" | "link";
  icon: string;
  title: string;
  url: string;
  perm: string;
}

export interface WorkMenuGroup {
  title: string;
  children: WorkMenuItem[];
}

export const workMenuGroups: WorkMenuGroup[] = [
  {
    title: "系统管理",
    children: [
      {
        kind: "route",
        icon: "/static/icons/user.svg",
        title: "用户管理",
        url: "/subPages/work/user/index",
        perm: PERM.user.list,
      },
      {
        kind: "route",
        icon: "/static/icons/role.svg",
        title: "角色管理",
        url: "/subPages/work/role/index",
        perm: PERM.role.list,
      },
      {
        kind: "route",
        icon: "/static/icons/company.svg",
        title: "部门管理",
        url: "/subPages/work/dept/index",
        perm: PERM.dept.list,
      },
      {
        kind: "route",
        icon: "/static/icons/settings.svg",
        title: "系统配置",
        url: "/subPages/work/config/index",
        perm: PERM.config.list,
      },
      {
        kind: "route",
        icon: "/static/icons/file.svg",
        title: "字典管理",
        url: "/subPages/work/dict/index",
        perm: PERM.dict.list,
      },
      {
        kind: "route",
        icon: "/static/icons/menu.svg",
        title: "菜单管理",
        url: "/subPages/work/menu/index",
        perm: PERM.menu.list,
      },
      {
        kind: "route",
        icon: "/static/icons/bell.svg",
        title: "通知公告",
        url: "/subPages/work/notice/index",
        perm: PERM.notice.list,
      },
      {
        kind: "route",
        icon: "/static/icons/log.svg",
        title: "系统日志",
        url: "/subPages/work/log/index",
        perm: PERM.log.list,
      },
    ],
  },
  {
    title: "项目链接",
    children: [
      {
        kind: "link",
        icon: "/static/icons/company.svg",
        title: "官网",
        url: "https://www.youlai.tech/",
        perm: "",
      },
      {
        kind: "link",
        icon: "/static/icons/file.svg",
        title: "文档",
        url: "https://youlai.blog.csdn.net/article/details/143222890",
        perm: "",
      },
      {
        kind: "link",
        icon: "/static/icons/api.svg",
        title: "接口",
        url: "https://youlai.apifox.cn/",
        perm: "",
      },
      {
        kind: "link",
        icon: "/static/icons/repo.svg",
        title: "仓库",
        url: "https://atomgit.com/youlai/youlai-app",
        perm: "",
      },
    ],
  },
];
