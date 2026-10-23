import { Storage } from "./storage";
import { ACCESS_TOKEN_KEY, REFRESH_TOKEN_KEY } from "@/constants";

/**
 * 认证工具函数
 *
 * 登录态的唯一事实来源是 user store 的 isAuthenticated（由 accessToken 派生）；
 * 需要静默判断登录态时直接读 store，本模块只负责令牌持久化与缺令牌时的跳转。
 */

/**
 * 获取访问令牌
 *
 * @returns 访问令牌，未登录时为 null
 */
export function getAccessToken(): string | null {
  return Storage.get<string>(ACCESS_TOKEN_KEY) || null;
}

/**
 * 保存访问令牌
 *
 * @param token - 登录接口返回的访问令牌
 */
export function setAccessToken(token: string): void {
  Storage.set(ACCESS_TOKEN_KEY, token);
}

/** 清除全部令牌 */
export function clearTokens(): void {
  Storage.remove(ACCESS_TOKEN_KEY);
  Storage.remove(REFRESH_TOKEN_KEY);
}

// 当前页面路径（含查询参数），用于登录后跳回原页面
function getCurrentPagePath(): string {
  const pages = getCurrentPages();
  if (pages.length === 0) return "/pages/index/index";

  const currentPage = pages[pages.length - 1];
  const route = currentPage.route || "";
  const options = (currentPage as { options?: Record<string, string> }).options || {};

  const query = Object.entries(options)
    .map(([key, value]) => `${key}=${value}`)
    .join("&");

  return query ? `/${route}?${query}` : `/${route}`;
}

/**
 * 确保已登录
 *
 * 缺少令牌时跳转登录页并带上来路地址，navigateTo 失败（页面栈已满）时改用 reLaunch。
 *
 * @returns 是否已登录
 */
export function ensureAuthenticated(): boolean {
  if (getAccessToken()) return true;

  const redirect = encodeURIComponent(getCurrentPagePath());
  uni.navigateTo({
    url: `/pages/login/index?redirect=${redirect}`,
    fail: () => {
      uni.reLaunch({ url: "/pages/login/index" });
    },
  });

  return false;
}
