import { ensureAuthenticated } from "@/utils/auth";

/**
 * 扫码登录 PC 端
 *
 * 调起相机扫描 PC 端登录二维码，只检查扫码结果非空；票据有效性与用户身份
 * 由扫码确认页调用服务端校验，本方法不完成登录。
 */
export function useScanLogin() {
  const toast = useToast();

  /**
   * 调起相机扫码并进入确认页
   *
   * 未登录先跳登录页；当前环境无扫码能力时给出可读提示；
   * 用户取消扫码静默结束，其余失败按原因提示。
   */
  const scanForLogin = async () => {
    if (!ensureAuthenticated()) return;

    if (!canScanCode()) {
      toast.info("当前环境不支持扫码，请在 App 或小程序中使用");
      return;
    }

    try {
      const res = await uni.scanCode({ scanType: ["qrCode"] });
      const ticket = (res.result || "").trim();
      if (!ticket) {
        toast.info("无效的二维码");
        return;
      }
      uni.navigateTo({
        url: `/subPages/mine/scan-confirm/index?ticket=${encodeURIComponent(ticket)}`,
      });
    } catch (error) {
      const message = getScanErrorMessage(error);
      if (message) toast.error(message);
    }
  };

  return { scanForLogin };
}

// 当前环境能否调起相机：H5 没有原生扫码能力
function canScanCode(): boolean {
  let supported = typeof uni.scanCode === "function";
  // #ifdef H5
  supported = false;
  // #endif
  return supported;
}

// 扫码失败提示文案：返回 null 表示用户主动取消，不做提示
function getScanErrorMessage(error: unknown): string | null {
  const errMsg = String((error as { errMsg?: string } | undefined)?.errMsg || "").toLowerCase();
  if (errMsg.includes("cancel")) return null;
  if (errMsg.includes("auth") || errMsg.includes("permission") || errMsg.includes("deny")) {
    return "未获得相机权限，请在系统设置中开启后重试";
  }
  if (errMsg.includes("not support") || errMsg.includes("unsupported")) {
    return "当前环境不支持扫码，请在 App 或小程序中使用";
  }
  return "扫码失败，请重试";
}
