import { ref } from "vue";
import { useToast } from "@wot-ui/ui";
import { useCountdown } from "@/composables/useCountdown";
import { getErrorMessage } from "@/utils/error";
import AuthAPI from "@/api/auth";

/**
 * 判断手机号格式是否可用
 *
 * @param mobile - 待校验的手机号
 * @returns 是否为 1 开头的 11 位数字
 */
export function isValidMobile(mobile: string): boolean {
  return /^1\d{10}$/.test((mobile || "").trim());
}

/**
 * 登录短信验证码发送
 *
 * 含发送锁与 60 秒倒计时：请求返回前阻止重复点击，倒计时在发送成功后才启动。
 */
export function useSmsLoginCode() {
  const toast = useToast();
  const { remainingSeconds, start, stop } = useCountdown(60);
  /** 发送中标志，请求返回前阻止重复点击 */
  const isSending = ref(false);

  /**
   * 发送验证码
   *
   * 手机号格式与重复发送在这里拦下，接口失败提示也由这里统一处理。
   *
   * @param mobile - 接收验证码的手机号
   * @param fallback - 接口无错误信息时的兜底提示
   * @returns 是否发送成功
   */
  async function sendCode(mobile: string, fallback = "发送失败"): Promise<boolean> {
    if (isSending.value || remainingSeconds.value > 0) return false;
    if (!isValidMobile(mobile)) {
      toast.error("请输入正确的手机号");
      return false;
    }
    isSending.value = true;
    try {
      await AuthAPI.sendSmsLoginCode(mobile.trim());
      toast.success("验证码已发送");
      start();
      return true;
    } catch (error) {
      toast.error(getErrorMessage(error, fallback));
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /**
   * 重置倒计时
   *
   * 关闭弹窗等场景调用，让下次打开可以立即重新发送。
   */
  function resetCountdown() {
    stop();
  }

  return { remainingSeconds, isSending, sendCode, resetCountdown };
}
