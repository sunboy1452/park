<template>
  <view class="scan-confirm">
    <app-navbar title="扫码登录确认" placeholder />

    <view class="scan-confirm__body">
      <view class="scan-confirm__card">
        <image class="scan-confirm__logo" src="/static/images/logo.png" mode="aspectFit" />

        <template v-if="status === 'invalid'">
          <text class="scan-confirm__user">二维码不可用</text>
          <text class="scan-confirm__hint">二维码已过期或已被使用，请重新扫描</text>
          <view class="scan-confirm__actions">
            <wd-button block @click="handleBackToScan">重新扫码</wd-button>
          </view>
        </template>

        <template v-else>
          <text class="scan-confirm__tip">PC 端扫码登录</text>
          <wd-loading v-if="status === 'verifying'" text="正在校验二维码" />
          <template v-else>
            <text class="scan-confirm__user">{{ scanResult?.nickname || "未知用户" }}</text>
            <text class="scan-confirm__hint">是否确认在 PC 端登录？</text>
          </template>

          <view class="scan-confirm__actions">
            <wd-button
              type="danger"
              variant="plain"
              block
              :disabled="status !== 'ready'"
              :loading="status === 'cancelling'"
              @click="handleCancel"
            >
              取消登录
            </wd-button>
            <wd-button
              block
              :disabled="status !== 'ready'"
              :loading="status === 'confirming'"
              @click="handleConfirm"
            >
              确认登录
            </wd-button>
          </view>
        </template>
      </view>
    </view>
  </view>
</template>

<script lang="ts" setup>
import { onLoad, onUnload } from "@dcloudio/uni-app";
import { useToast } from "@wot-ui/ui";
import { getErrorMessage } from "@/utils/error";
import AuthAPI, { type QrCodeScanResult } from "@/api/auth";

definePage({
  name: "scan-confirm",
  style: { navigationStyle: "custom", navigationBarTitleText: "" },
  layout: "blank",
});

// 页面阶段：校验中 / 可操作 / 确认中 / 取消中 / 有效票据已处理完
// 确认与取消共用同一状态，任一请求进行中或已处理完时都不再接受新的提交
type ScanConfirmStatus =
  "verifying" | "ready" | "confirming" | "cancelling" | "finished" | "invalid";

const toast = useToast();

// 结果提示读完再返回上一页的延迟（毫秒）
const RETURN_DELAY_MS = 800;

const status = ref<ScanConfirmStatus>("verifying");
// 从扫码入口经 query 传入的票据
const ticket = ref("");
// scan 接口返回的脱敏用户信息
const scanResult = ref<QrCodeScanResult | null>(null);
// 返回定时器：页面卸载时清理，避免离开后仍触发 navigateBack
let returnTimer: ReturnType<typeof setTimeout> | null = null;

// 延迟返回上一页，让结果提示有可读时间
function scheduleReturn(delay = RETURN_DELAY_MS) {
  returnTimer = setTimeout(() => uni.navigateBack(), delay);
}

// 标记已扫码：让 PC 端立即显示「已扫码」并展示头像与昵称
async function markScanned(code: string) {
  try {
    scanResult.value = await AuthAPI.markQrLoginScanned(code);
    status.value = "ready";
  } catch (error) {
    status.value = "invalid";
    toast.error(getErrorMessage(error, "二维码无效或已过期"));
  }
}

// 确认登录：授权 PC 端用该票据换取会话，失败退回可重试状态
async function handleConfirm() {
  if (status.value !== "ready") return;
  status.value = "confirming";
  try {
    await AuthAPI.confirmQrLogin(ticket.value);
    status.value = "finished";
    toast.success("已确认登录");
    scheduleReturn();
  } catch (error) {
    toast.error(getErrorMessage(error, "确认失败"));
    status.value = "ready";
  }
}

// 取消登录：撤回扫码，无论接口成败都结束本次流程并返回
async function handleCancel() {
  if (status.value !== "ready") return;
  status.value = "cancelling";
  try {
    await AuthAPI.cancelQrLogin(ticket.value);
    toast.info("已取消登录");
  } catch {
    // 撤回失败不影响返回，PC 端二维码超时后自动失效
  } finally {
    status.value = "finished";
    scheduleReturn();
  }
}

// 无效二维码时返回扫码入口重新扫描
function handleBackToScan() {
  uni.navigateBack();
}

onLoad((options) => {
  const code = options?.ticket ? decodeURIComponent(options.ticket) : "";
  if (!code) {
    status.value = "invalid";
    toast.error("二维码无效");
    return;
  }
  ticket.value = code;
  markScanned(code);
});

onUnload(() => {
  if (returnTimer !== null) {
    clearTimeout(returnTimer);
    returnTimer = null;
  }
});
</script>

<style lang="scss" scoped>
.scan-confirm {
  min-height: 100vh;
  background: var(--color-bg-card);

  &__body {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 48rpx 64rpx 0;
  }

  &__card {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    padding: 64rpx 48rpx;
    background: var(--color-bg-card);
    border: 2rpx solid var(--color-border-light);
    border-radius: 32rpx;
    box-shadow: var(--shadow-float);
  }

  &__logo {
    width: 96rpx;
    height: 96rpx;
    margin-bottom: 24rpx;
  }

  &__tip {
    font-size: 28rpx;
    color: var(--color-text-secondary);
  }

  &__user {
    margin: 16rpx 0;
    font-size: 40rpx;
    font-weight: 700;
    color: var(--color-text);
  }

  &__hint {
    margin-bottom: 48rpx;
    font-size: 26rpx;
    color: var(--color-text-placeholder);
  }

  &__actions {
    display: flex;
    gap: 24rpx;
    width: 100%;
  }
}
</style>
