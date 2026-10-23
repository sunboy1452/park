<template>
  <view class="profile-card">
    <view class="profile-card__header">
      <view class="profile-card__avatar-wrap" @click="emit('profile')">
        <image class="profile-card__avatar" :src="avatar" mode="aspectFill" lazy-load />
        <view v-if="isAuthenticated" class="profile-card__auth-dot" />
      </view>

      <view class="profile-card__info" @click="emit('profile')">
        <view class="profile-card__top">
          <text class="profile-card__name">{{ displayName }}</text>
        </view>

        <view v-if="isAuthenticated" class="profile-card__tags">
          <view class="profile-card__tag">
            <wd-icon name="user" size="12" color="var(--color-text-inverse)" />
            <text>{{ username }}</text>
          </view>
          <view class="profile-card__tag">
            <wd-icon
              :name="deptName ? 'home' : 'safe'"
              size="12"
              color="var(--color-text-inverse)"
            />
            <text>{{ deptName || "安全可靠" }}</text>
          </view>
        </view>

        <text v-else class="profile-card__hint">登录使用更多功能</text>
      </view>

      <!-- 组件内唯一的扫描入口：调起相机扫 PC 端登录二维码，登录在扫码确认页完成 -->
      <view v-if="isAuthenticated" class="profile-card__scan" @click.stop="emit('scan')">
        <wd-icon name="scan" size="18" color="var(--color-text-inverse)" />
      </view>

      <view v-else class="profile-card__login" @click.stop="emit('login')">
        <wd-button custom-class="profile-card__login-button" size="small">立即登录</wd-button>
      </view>
    </view>
  </view>
</template>

<script lang="ts" setup>
defineProps<{
  /** 已登录时展示账号与部门，未登录展示登录入口 */
  isAuthenticated: boolean;
  avatar: string;
  /** 展示用昵称，区别于账号 username */
  displayName: string;
  username: string;
  deptName: string;
}>();

/**
 * profile / login / scan：只上报点击意图
 *
 * scan 表示请求调起扫码流程，票据校验与登录在扫码确认页完成。
 */
const emit = defineEmits<{
  profile: [];
  login: [];
  scan: [];
}>();
</script>

<style lang="scss" scoped>
/* 卡片落在 Hero 主色渐变上，前景固定白色：背景始终用半透明玻璃色，
   不支持 backdrop-filter 时只是少了模糊，不会退化成白底白字 */
.profile-card {
  position: relative;
  display: flex;
  padding: 28rpx 28rpx;
  overflow: hidden;
  background: linear-gradient(135deg, var(--color-glass) 0%, var(--color-glass-light) 100%);
  border: 1rpx solid var(--color-border-glass);
  border-radius: 28rpx;
  box-shadow: var(--shadow-md);

  @supports (backdrop-filter: blur(20px)) or (-webkit-backdrop-filter: blur(20px)) {
    -webkit-backdrop-filter: blur(20px);
    backdrop-filter: blur(20px);
  }
}

.profile-card__header {
  display: flex;
  gap: 28rpx;
  align-items: center;
  width: 100%;
}

.profile-card__avatar-wrap {
  position: relative;
  flex-shrink: 0;
  width: 120rpx;
  height: 120rpx;
}

.profile-card__avatar {
  box-sizing: border-box;
  flex-shrink: 0;
  width: 120rpx;
  height: 120rpx;
  border: 3rpx solid var(--color-border-glass-strong);
  border-radius: 50%;
  box-shadow: var(--shadow-sm);
}

/* 认证状态标识：依据登录态，不表示实时在线 */
.profile-card__auth-dot {
  position: absolute;
  right: 4rpx;
  bottom: 4rpx;
  width: 16rpx;
  height: 16rpx;
  background: var(--color-success);
  border: 2rpx solid var(--color-bg-card);
  border-radius: 50%;
}

.profile-card__info {
  flex: 1;
  min-width: 0;
}

.profile-card__top {
  display: flex;
  gap: 16rpx;
  align-items: center;
  margin-bottom: 18rpx;
}

.profile-card__name {
  flex: 1;
  min-width: 0;
  font-size: 38rpx;
  font-weight: 700;
  color: var(--color-text-inverse);
}

.profile-card__hint {
  display: block;
  margin-top: 14rpx;
  font-size: 24rpx;
  color: var(--color-text-inverse);
}

.profile-card__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}

.profile-card__scan {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  align-self: flex-start;
  justify-content: center;
  width: 88rpx;
  height: 88rpx;
  margin-left: auto;
  background: var(--color-glass-light);
  border: 1rpx solid var(--color-border-glass);
  border-radius: 999rpx;
}

.profile-card__login {
  flex-shrink: 0;
  align-self: center;
  margin-left: auto;
}

.profile-card__login-button {
  flex-shrink: 0;
  min-width: 156rpx;
  height: 72rpx;
  padding: 0 24rpx;
  font-size: 24rpx;
  font-weight: 600;
  border: 0;
  border-radius: 999rpx;
}

.profile-card__tag {
  display: inline-flex;
  gap: 8rpx;
  align-items: center;
  justify-content: center;
  padding: 8rpx 14rpx;
  font-size: 22rpx;
  color: var(--color-text-inverse);
  background: var(--color-glass-light);
  border: 1rpx solid var(--color-border-glass);
  border-radius: 12rpx;
}
</style>
