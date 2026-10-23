import { ref } from "vue";
import { useToast } from "@wot-ui/ui";
import { Storage } from "@/utils/storage";
import { formatBytes } from "@/utils/format";

/**
 * 缓存体积统计与清理
 *
 * 统计与清理的范围都是「保留名单之外的全部本地键」：登录态与主题偏好保留，
 * 其余键（用户信息缓存等）一并删除。
 */
export function useCacheCleaner() {
  const toast = useToast();
  /** 缓存体积的展示文案，未统计完成前为「计算中...」 */
  const usageText = ref("计算中...");
  /** 是否正在清理，用于展示遮罩并挡住重复触发 */
  const isClearing = ref(false);

  /**
   * 统计可清理的缓存体积
   *
   * 读取失败时展示「获取失败」，避免把异常状态当成 0B。
   */
  async function loadUsage() {
    try {
      usageText.value = formatBytes(Storage.getClearableBytes());
    } catch {
      usageText.value = "获取失败";
    }
  }

  /**
   * 清理缓存并刷新体积
   *
   * 体积获取失败或无缓存时不发起删除，成功删除后才提示清理成功。
   */
  async function clearCache() {
    if (usageText.value === "获取失败") {
      toast.info("获取缓存信息失败，请稍后重试");
      return;
    }
    if (isClearing.value) {
      return;
    }
    if (usageText.value === "0B") {
      toast.info("暂无缓存需要清理");
      return;
    }

    try {
      isClearing.value = true;
      const removed = Storage.clearCache();
      await loadUsage();
      if (removed > 0) {
        toast.success("清理成功");
      } else {
        toast.info("暂无缓存需要清理");
      }
    } catch {
      toast.error("清理失败");
    } finally {
      isClearing.value = false;
    }
  }

  return { usageText, isClearing, loadUsage, clearCache };
}
