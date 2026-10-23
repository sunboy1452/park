import { ref, computed, onUnmounted, type Ref, type ComputedRef } from "vue";

/**
 * 导航栏几何测量
 *
 * 参考 uni-ui 官方实现：https://github.com/dcloudio/uni-ui
 *
 * 微信小程序按胶囊按钮位置推算内容区高度：
 * 状态栏 → 上边距 → 胶囊 → 下边距，上下边距相等，
 * 内容区高度 = capsule.height + (capsule.top - statusBarHeight) * 2。
 * H5 与 App 没有胶囊，直接取 fallbackContentHeightPx。
 */

// 胶囊按钮相对屏幕的矩形，单位 px
interface CapsuleRect {
  width: number;
  height: number;
  top: number;
  right: number;
  bottom: number;
  left: number;
}

/** 导航栏测量配置 */
export interface NavbarMetricsOptions {
  /** H5 / App 无胶囊时的内容区高度（px），默认 44 */
  contentHeightPx?: number;
}

/**
 * 导航栏测量结果
 *
 * 长度单位统一为 px，与系统几何 API 保持一致。
 */
export interface NavbarMetrics {
  /** 状态栏高度（px） */
  statusBarHeight: Ref<number>;
  /** 导航栏内容区高度（px），不含状态栏 */
  contentHeightPx: ComputedRef<number>;
  /** 导航栏总高度（px），含状态栏 */
  totalHeightPx: ComputedRef<number>;
  /** 胶囊左侧坐标（px），微信端即左侧可用宽度 */
  capsuleLeftPx: ComputedRef<number>;
  /** 胶囊右侧到屏幕右边缘的距离（px） */
  capsuleRightGapPx: ComputedRef<number>;
  /** 胶囊宽度（px） */
  capsuleWidthPx: ComputedRef<number>;
}

/**
 * 测量导航栏、状态栏与胶囊尺寸
 *
 * setup 阶段即完成首次读取，避免首屏闪烁；组件卸载时清理内部重试定时器。
 *
 * @param options - 无胶囊平台的内容区高度
 */
export function useNavbarMetrics(options: NavbarMetricsOptions = {}): NavbarMetrics {
  const { contentHeightPx: fallbackContentHeightPx = 44 } = options;

  const statusBarHeight = ref(0);
  const capsuleRect = ref<CapsuleRect | null>(null);
  const windowWidth = ref(375);

  // 胶囊矩形可能晚于首次渲染就绪，重试定时器在卸载与重新测量时清理
  let retryTimer: ReturnType<typeof setTimeout> | null = null;

  // 清理重试定时器
  const clearRetryTimer = () => {
    if (retryTimer !== null) {
      clearTimeout(retryTimer);
      retryTimer = null;
    }
  };

  // 导航栏内容区高度：微信端按胶囊推算，其余端用固定值
  const contentHeightPx = computed(() => {
    // #ifdef MP-WEIXIN
    const capsule = capsuleRect.value;
    if (capsule && capsule.height > 0 && capsule.top > 0) {
      const spaceHeight = capsule.top - statusBarHeight.value;
      return capsule.height + spaceHeight * 2;
    }
    // #endif

    return fallbackContentHeightPx;
  });

  const totalHeightPx = computed(() => statusBarHeight.value + contentHeightPx.value);

  const capsuleLeftPx = computed(() => {
    // #ifdef MP-WEIXIN
    if (capsuleRect.value) {
      return capsuleRect.value.left;
    }
    // #endif
    return 0;
  });

  // 微信端取窗口右边缘与胶囊右边缘的差值，其余端只留固定边距
  const capsuleRightGapPx = computed(() => {
    // #ifdef MP-WEIXIN
    if (capsuleRect.value && capsuleRect.value.right > 0) {
      return windowWidth.value - capsuleRect.value.right;
    }
    // #endif
    return 10;
  });

  const capsuleWidthPx = computed(() => {
    // #ifdef MP-WEIXIN
    if (capsuleRect.value) {
      return capsuleRect.value.width;
    }
    // #endif
    return 0;
  });

  // #ifdef MP-WEIXIN
  const isValidCapsuleRect = (rect: ReturnType<typeof uni.getMenuButtonBoundingClientRect>) => {
    return !!rect && rect.width > 0 && rect.height > 0 && rect.top > 0 && rect.right > 0;
  };

  // 有限次重试读取胶囊矩形，仍未取到则回落到默认尺寸，避免内容区高度为 0
  const readCapsuleRect = (maxRetry = 6, delayMs = 50) => {
    const applyDefaultCapsuleRect = () => {
      capsuleRect.value = {
        width: 87,
        height: 32,
        top: statusBarHeight.value + 6,
        right: windowWidth.value - 10,
        bottom: statusBarHeight.value + 38,
        left: windowWidth.value - 97,
      };
    };

    try {
      const rect = uni.getMenuButtonBoundingClientRect();

      if (isValidCapsuleRect(rect)) {
        capsuleRect.value = {
          width: rect.width,
          height: rect.height,
          top: rect.top,
          right: rect.right,
          bottom: rect.bottom,
          left: rect.left,
        };
        return;
      }

      if (maxRetry > 0) {
        retryTimer = setTimeout(() => {
          readCapsuleRect(maxRetry - 1, delayMs);
        }, delayMs);
      } else {
        applyDefaultCapsuleRect();
      }
    } catch {
      applyDefaultCapsuleRect();
    }
  };
  // #endif

  // 读取窗口与胶囊尺寸，取不到的值保留声明处默认值
  const refreshMetrics = () => {
    try {
      const windowInfo =
        typeof uni.getWindowInfo === "function" ? uni.getWindowInfo() : uni.getSystemInfoSync();

      statusBarHeight.value = windowInfo.statusBarHeight || 0;
      windowWidth.value = windowInfo.windowWidth || 375;

      // #ifdef MP-WEIXIN
      clearRetryTimer();
      readCapsuleRect();
      // #endif
    } catch {
      // 各字段已有声明处默认值兜底
    }
  };

  // setup 阶段同步读取一次，避免首屏按默认尺寸渲染后再跳动
  refreshMetrics();

  onUnmounted(clearRetryTimer);

  return {
    statusBarHeight,
    contentHeightPx,
    totalHeightPx,
    capsuleLeftPx,
    capsuleRightGapPx,
    capsuleWidthPx,
  };
}
