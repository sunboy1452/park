import { useDialog, useToast } from "@wot-ui/ui";

/**
 * 危险操作确认流程
 *
 * 确认弹窗 → 执行 → 成功提示，与操作菜单、表单弹窗等界面无关。
 */
export function useConfirmAction() {
  const toast = useToast();
  const { confirm } = useDialog();

  /**
   * 确认后执行操作
   *
   * 用户取消时静默结束；执行失败会抛出，由调用方统一提示。
   *
   * @param options.msg - 确认弹窗的提示文案
   * @param options.action - 确认后执行的操作
   * @param options.title - 确认弹窗标题，默认「确认删除」
   * @param options.successText - 成功提示文案，默认「删除成功」
   */
  async function confirmAction(options: {
    msg: string;
    action: () => Promise<void>;
    title?: string;
    successText?: string;
  }): Promise<void> {
    const { msg, action, title = "确认删除", successText = "删除成功" } = options;

    try {
      await confirm({ title, msg, headerImage: "warning" });
    } catch {
      // 用户取消确认弹窗
      return;
    }

    await action();
    toast.success(successText);
  }

  return { confirmAction };
}
