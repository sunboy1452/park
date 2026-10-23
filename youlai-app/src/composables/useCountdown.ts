import { ref, onUnmounted } from "vue";

/**
 * 倒计时
 *
 * 按截止时间计算剩余秒数，页面隐藏或切后台再回来仍保持准确。
 *
 * @param durationSeconds - 倒计时总秒数，默认 60
 */
export function useCountdown(durationSeconds = 60) {
  /** 剩余秒数，未开始时为 0 */
  const remainingSeconds = ref(0);
  /** 是否正在倒计时 */
  const isRunning = ref(false);
  // 截止时间戳，tick 每次按它重算，避免定时器漂移累积
  let deadline = 0;
  let timer: ReturnType<typeof setInterval> | null = null;

  // 按剩余时间刷新秒数，归零时自行停止
  function tick() {
    const remain = Math.ceil((deadline - Date.now()) / 1000);
    remainingSeconds.value = Math.max(0, remain);
    if (remainingSeconds.value <= 0) stop();
  }

  /**
   * 开始倒计时
   *
   * 已在计时中重复调用会被忽略，不会重置截止时间。
   */
  const start = () => {
    if (isRunning.value) return;

    deadline = Date.now() + durationSeconds * 1000;
    isRunning.value = true;
    tick();
    timer = setInterval(tick, 1000);
  };

  /** 停止倒计时并把剩余秒数清零 */
  const stop = () => {
    if (timer) {
      clearInterval(timer);
      timer = null;
    }
    remainingSeconds.value = 0;
    isRunning.value = false;
  };

  onUnmounted(() => stop());

  return {
    remainingSeconds,
    isRunning,
    start,
    stop,
  };
}
