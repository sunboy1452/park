import { ensureAuthenticated } from "@/utils/auth";

// 导航目标：kind 区分站内路由与站外链接，url 为空表示功能未开放
interface NavTarget {
  kind: "route" | "link";
  url?: string;
}

/**
 * 业务菜单导航
 *
 * 站外链接在 H5 新开标签、其余端进内置 webview，站内路由走 navigateTo。
 */
export function useNavigation() {
  const toast = useToast();

  /**
   * 按菜单配置跳转
   *
   * 未登录先跳登录页并带上来路；地址缺失或页面不存在时给出提示。
   *
   * @param target - 菜单项
   */
  const navigate = (target: NavTarget) => {
    if (!target.url) {
      toast.info("功能开发中");
      return;
    }

    if (!ensureAuthenticated()) return;

    if (target.kind === "link") {
      // #ifdef H5
      window.open(target.url, "_blank");
      // #endif
      // #ifndef H5
      uni.navigateTo({
        url: `/pages/webview/index?url=${encodeURIComponent(target.url)}`,
      });
      // #endif
      return;
    }

    uni.navigateTo({
      url: target.url,
      fail: () => {
        toast.info("页面不存在");
      },
    });
  };

  return { navigate };
}
