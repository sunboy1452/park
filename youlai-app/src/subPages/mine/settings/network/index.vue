<template>
  <view class="network">
    <view class="pt-8rpx">
      <text class="network__tip-text">
        温馨提示：点击下方「开始测试」按钮，即可检测当前网络到接口服务的连接质量。
      </text>
    </view>

    <view class="mt-16rpx">
      <wd-button block variant="plain" :loading="isTesting" @click="startTest">开始测试</wd-button>
    </view>

    <view v-if="isTesting" class="network__loading">
      <wd-loading color="var(--wot-color-theme)" />
      <text class="network__loading-text">正在测试中...</text>
    </view>

    <view v-if="result" class="network__result">
      <view class="result-card">
        <view class="result-card__header">测试结果</view>
        <view class="result-card__row">
          <text class="result-card__label">接口服务</text>
          <text
            class="result-card__value"
            :class="result.reachable ? 'color-success' : 'color-danger'"
          >
            {{ result.reachable ? "可访问" : "不可访问" }}
          </text>
        </view>
        <view class="result-card__row">
          <text class="result-card__label">响应耗时</text>
          <text class="text-36rpx font-600" :class="statusColor">
            {{ result.costMs === null ? "--" : `${result.costMs}ms` }}
          </text>
        </view>
        <view class="result-card__row">
          <text class="result-card__label">网络状态</text>
          <text class="font-500" :class="statusColor">{{ statusText }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script lang="ts" setup>
definePage({
  name: "network",
  style: { navigationBarTitleText: "网络检测" },
});

// 一次探测的结果：可达性用布尔值，耗时单独记录，不可达时不参与质量分档
interface ProbeResult {
  reachable: boolean;
  costMs: number | null;
}

const result = ref<ProbeResult | null>(null);
const isTesting = ref(false);

// 耗时分档：100ms 以内优秀，300ms 以内良好，500ms 以内一般，其余较差
const statusText = computed(() => {
  if (!result.value) return "";
  if (!result.value.reachable) return "不可访问";
  const cost = result.value.costMs ?? 0;
  if (cost < 100) return "优秀";
  if (cost < 300) return "良好";
  if (cost < 500) return "一般";
  return "较差";
});

const statusColor = computed(() => {
  if (!result.value) return "";
  if (!result.value.reachable) return "color-danger";
  const cost = result.value.costMs ?? 0;
  if (cost < 100) return "color-success";
  if (cost < 300) return "color-primary";
  if (cost < 500) return "color-warning";
  return "color-danger";
});

// 探测目标：与请求层同源，微信端用完整地址，其余端走代理前缀
function getProbeUrl(): string {
  let baseUrl = import.meta.env.VITE_APP_BASE_API;
  // #ifdef MP-WEIXIN
  baseUrl = import.meta.env.VITE_APP_API_URL;
  // #endif
  return `${baseUrl}/`;
}

// 探测接口服务地址：拿到响应即视为可达，状态码不参与判断
async function startTest() {
  if (isTesting.value) return;

  isTesting.value = true;
  result.value = null;
  const startedAt = Date.now();

  try {
    await new Promise<void>((resolve, reject) => {
      uni.request({
        url: getProbeUrl(),
        method: "GET",
        timeout: 10000,
        // 接口服务地址本身没有业务数据，只要拿到响应即说明链路可达，状态码不参与判断
        success: () => resolve(),
        fail: (error) => reject(error),
      });
    });
    result.value = { reachable: true, costMs: Date.now() - startedAt };
  } catch {
    result.value = { reachable: false, costMs: null };
  } finally {
    isTesting.value = false;
  }
}
</script>

<style lang="scss" scoped>
.result-card {
  overflow: hidden;
  background: var(--color-bg-card);
  border: 1rpx solid var(--color-border);
  border-radius: 16rpx;

  &__header {
    padding: 24rpx;
    font-size: 32rpx;
    font-weight: 600;
    border-bottom: 1rpx solid var(--color-border);
  }

  &__row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 24rpx;

    & + & {
      border-top: 1rpx solid var(--color-border-light);
    }
  }

  &__label {
    color: var(--color-text-secondary);
  }

  &__value {
    font-weight: 500;
  }
}

.network__tip-text {
  font-size: 24rpx;
  color: var(--color-text-placeholder);
}

.network__loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40rpx 0;
}

.network__loading-text {
  margin-top: 16rpx;
  font-size: 24rpx;
  color: var(--color-text-secondary);
}

.network__result {
  margin-top: 24rpx;
}
</style>
