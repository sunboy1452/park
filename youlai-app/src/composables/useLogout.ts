import { ref } from "vue";
import { useToast } from "@wot-ui/ui";
import { useUserStore } from "@/store";

/**
 * 退出登录流程
 *
 * 会话清理与跳转登录页由 userStore.logout 负责，这里只做二次确认、进行中反馈与防重入。
 */
export function useLogout() {
  const toast = useToast();
  const userStore = useUserStore();
  /** 退出流程进行中，用于禁用入口并挡住重复触发 */
  const isLoggingOut = ref(false);

  /**
   * 发起退出登录
   *
   * 用户取消弹窗时不产生任何请求；确认后进入 isLoggingOut，
   * 期间再次触发直接忽略，避免重复调用退出接口。
   */
  const requestLogout = () => {
    if (isLoggingOut.value) return;

    uni.showModal({
      title: "退出登录",
      content: "确定要退出登录吗？",
      confirmText: "退出",
      confirmColor: "#f53f3f",
      success: async (res) => {
        if (!res.confirm) return;

        isLoggingOut.value = true;
        toast.loading("正在退出...");
        try {
          await userStore.logout();
        } finally {
          toast.close();
          isLoggingOut.value = false;
        }
      },
    });
  };

  return { isLoggingOut, requestLogout };
}
