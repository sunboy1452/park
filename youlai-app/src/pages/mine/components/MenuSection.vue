<template>
  <view class="menu-section">
    <text class="menu-section__title">{{ title }}</text>
    <view class="menu-section__list">
      <view v-for="item in items" :key="item.id" class="menu-row" @click="emit('select', item.id)">
        <view class="menu-row__icon" :class="`menu-row__icon--${item.tone}`">
          <wd-icon :name="item.icon" size="18" :color="iconColors[item.tone]" />
        </view>
        <view class="menu-row__main">
          <text class="menu-row__title">{{ item.title }}</text>
          <text class="menu-row__desc">{{ item.desc }}</text>
        </view>
        <text v-if="item.value" class="menu-row__value">{{ item.value }}</text>
        <wd-icon name="right" size="16" color="var(--color-text-placeholder)" />
      </view>
    </view>
  </view>
</template>

<script lang="ts" setup>
/**
 * 设置菜单项
 *
 * 只描述展示所需字段，跳转目标与动作由调用方的配置补充。
 */
export interface SettingsMenuItem {
  /** 稳定标识，用于分发，不用展示文案 */
  id: string;
  icon: string;
  tone: "primary" | "warning" | "danger" | "success" | "info";
  title: string;
  desc: string;
  value?: string;
}

// 语义色映射：tone 决定图标底色变体与图标颜色
const iconColors: Record<SettingsMenuItem["tone"], string> = {
  primary: "var(--color-primary)",
  warning: "var(--color-warning)",
  danger: "var(--color-danger)",
  success: "var(--color-success)",
  info: "var(--color-info)",
};

defineProps<{
  title: string;
  items: SettingsMenuItem[];
}>();

/**
 * select：上报被点击项
 *
 * 载荷是菜单项 id 而不是标题，展示文案可能重复，不能作为标识。
 */
const emit = defineEmits<{
  select: [id: string];
}>();
</script>

<style lang="scss" scoped>
.menu-section {
  padding: 28rpx;
  background: var(--color-bg-card);
  border-radius: 32rpx;
  box-shadow: var(--shadow-md);

  &__title {
    display: block;
    margin-bottom: 18rpx;
    font-size: 26rpx;
    font-weight: 600;
    color: var(--color-text);
  }
}

.menu-section__list {
  overflow: hidden;
}

.menu-row {
  display: flex;
  gap: 20rpx;
  align-items: center;
  padding: 24rpx 20rpx;
  background: transparent;
}

.menu-row + .menu-row {
  border-top: 1rpx solid var(--color-border-light);
}

.menu-row__icon {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  width: 72rpx;
  height: 72rpx;
  border-radius: 22rpx;

  &--primary {
    background: var(--color-primary-alpha-15);
  }

  &--warning {
    background: var(--color-warning-light);
  }

  &--danger {
    background: var(--color-danger-light);
  }

  &--success {
    background: var(--color-success-light);
  }

  &--info {
    background: var(--color-info-light);
  }
}

.menu-row__main {
  flex: 1;
  min-width: 0;
}

.menu-row__title {
  display: block;
  font-size: 26rpx;
  font-weight: 500;
  color: var(--color-text);
}

.menu-row__desc {
  display: block;
  margin-top: 8rpx;
  font-size: 22rpx;
  color: var(--color-text-secondary);
}

.menu-row__value {
  margin-left: 12rpx;
  font-size: 22rpx;
  color: var(--color-text-placeholder);
}
</style>
