<template>
  <view class="official-card" @click="emit('open')">
    <image class="official-card__bg" src="/static/images/official-bg.png" mode="aspectFill" />
    <view class="official-card__mask" />
    <view class="official-card__logo">
      <image class="official-card__logo-img" src="/static/images/logo.png" mode="aspectFit" />
    </view>
    <view class="official-card__body">
      <view class="official-card__title-row">
        <text class="official-card__title">关注有来技术</text>
        <wd-tag type="success" variant="plain" custom-class="official-card__tag">官方社区</wd-tag>
      </view>
      <text class="official-card__desc">开源更新、实战内容、交流群入口，统一在这里查看</text>
    </view>
    <view class="official-card__arrow">
      <wd-icon name="right" size="16" color="var(--color-text-secondary)" />
    </view>
  </view>
</template>

<script lang="ts" setup>
/** open：请求进入公众号介绍页，目标地址由父级决定 */
const emit = defineEmits<{
  open: [];
}>();
</script>

<style lang="scss" scoped>
.official-card {
  position: relative;
  display: flex;
  gap: 24rpx;
  align-items: center;
  padding: 36rpx;
  overflow: hidden;
  background: transparent;
  border-radius: 32rpx;
  box-shadow: var(--shadow-md);
}

.official-card__bg {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: var(--z-base);
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.official-card__mask {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: var(--z-mask);
  background: linear-gradient(
    90deg,
    var(--color-media-mask) 0%,
    var(--color-media-mask-light) 55%,
    var(--color-media-mask) 100%
  );
}

.official-card__logo {
  position: relative;
  z-index: var(--z-content);
  box-sizing: border-box;
  width: 84rpx;
  height: 84rpx;
  padding: 10rpx;
  background: var(--color-bg-card-alpha-95);
  border: 1rpx solid var(--color-border-glass);
  border-radius: 20rpx;
  box-shadow: var(--shadow-sm);
}

.official-card__logo-img {
  width: 100%;
  height: 100%;
}

.official-card__body {
  position: relative;
  z-index: var(--z-content);
  flex: 1;
  min-width: 0;
}

.official-card__arrow {
  position: relative;
  z-index: var(--z-content);
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44rpx;
  height: 44rpx;
  background: var(--color-glass);
  border-radius: 999rpx;
}

.official-card__title-row {
  display: flex;
  gap: 16rpx;
  align-items: center;
  margin-top: 14rpx;
}

.official-card__title {
  flex-shrink: 0;
  font-size: 32rpx;
  font-weight: 600;
  line-height: 1;
  color: var(--color-text);
  letter-spacing: 0.4rpx;
}

/* wd-tag 外层是自定义组件节点，压掉其行高避免与标题错位 */
.official-card__tag {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  line-height: 1;
}

.official-card__desc {
  display: -webkit-box;
  margin-top: 10rpx;
  overflow: hidden;
  font-size: 24rpx;
  line-height: 1.55;
  color: var(--color-text-secondary);
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
}
</style>
