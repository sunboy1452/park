<template>
  <view v-if="fixed && placeholder" :style="{ height: totalHeightPx + 'px' }" />
  <view
    class="app-navbar"
    :class="{ 'app-navbar--fixed': fixed }"
    :style="{
      height: totalHeightPx + 'px',
      paddingTop: statusBarHeight + 'px',
      background,
    }"
  >
    <view class="app-navbar__content" :style="{ height: contentHeightPx + 'px' }">
      <view class="app-navbar__left" :style="{ width: leftSlotWidth + 'px' }">
        <view v-if="showBack" class="app-navbar__back" @click="handleBack">
          <wd-icon :name="backIcon" :size="backIconSize" :color="iconColor" />
        </view>

        <view v-if="showHome" class="app-navbar__home" @click="handleHome">
          <wd-icon name="home" :size="backIconSize" :color="iconColor" />
        </view>

        <slot name="left" />
      </view>

      <view class="app-navbar__center">
        <text v-if="title" class="app-navbar__title" :style="{ color: titleColor }">
          {{ title }}
        </text>
        <slot name="center" />
      </view>

      <view class="app-navbar__right" :style="{ width: rightSlotWidth + 'px' }">
        <slot name="right" />
        <!-- 微信端胶囊按钮占位，保证插槽内容不会顶到胶囊下方 -->
        <view class="app-navbar__capsule-space" :style="{ width: capsuleSpaceWidth + 'px' }" />
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useNavbarMetrics } from "@/composables/useNavbarMetrics";

interface Props {
  title?: string;
  titleColor?: string;
  /** 背景色或渐变，取值同 background 简写属性 */
  background?: string;
  showBack?: boolean;
  showHome?: boolean;
  backIcon?: string;
  /** 返回与首页图标尺寸（px），wd-icon 的 size 以 px 为单位 */
  backIconSize?: number;
  iconColor?: string;
  fixed?: boolean;
  /** 固定在顶部时为内容区补一个等高占位块 */
  placeholder?: boolean;
  /** H5 / App 下的导航栏内容区高度（px） */
  contentHeightPx?: number;
}

const props = withDefaults(defineProps<Props>(), {
  title: "",
  titleColor: "var(--color-text)",
  background: "var(--color-bg-card)",
  showBack: true,
  showHome: false,
  backIcon: "arrow-left",
  backIconSize: 20,
  iconColor: "var(--color-text)",
  fixed: true,
  placeholder: false,
  contentHeightPx: 44,
});

/**
 * back / home 事件仅用于通知挂载方，导航由组件自身完成：
 * 存在上一页时返回，否则回到首页
 */
const emit = defineEmits<{
  (e: "back"): void;
  (e: "home"): void;
}>();

const navbar = useNavbarMetrics({ contentHeightPx: props.contentHeightPx });

const statusBarHeight = computed(() => navbar.statusBarHeight.value);
const contentHeightPx = computed(() => navbar.contentHeightPx.value);
const totalHeightPx = computed(() => navbar.totalHeightPx.value);

const capsuleSpaceWidth = computed(() => {
  let width = 0;
  // #ifdef MP-WEIXIN
  if (navbar.capsuleWidthPx.value > 0) {
    width = navbar.capsuleWidthPx.value + navbar.capsuleRightGapPx.value;
  }
  // #endif
  return width;
});

// 右侧除胶囊外还要预留的插槽宽度（px）
const RIGHT_SLOT_WIDTH = 96;

// 左侧插槽宽度（px）：微信端取胶囊左侧空间，其余端给固定值
const leftSlotWidth = computed(() => {
  let width = 80;
  // #ifdef MP-WEIXIN
  width = navbar.capsuleLeftPx.value > 0 ? navbar.capsuleLeftPx.value : 80;
  // #endif
  return width;
});

const rightSlotWidth = computed(() => {
  let width = 80;
  // #ifdef MP-WEIXIN
  width = capsuleSpaceWidth.value + RIGHT_SLOT_WIDTH;
  // #endif
  return width;
});

function handleBack() {
  emit("back");

  const pages = getCurrentPages();
  if (pages.length > 1) {
    uni.navigateBack();
  } else {
    uni.switchTab({ url: "/pages/index/index" });
  }
}

function handleHome() {
  emit("home");
  uni.switchTab({ url: "/pages/index/index" });
}
</script>

<script lang="ts">
export default {
  name: "AppNavbar",
  options: {
    virtualHost: true,
    styleIsolation: "shared",
  },
};
</script>

<style lang="scss" scoped>
.app-navbar {
  position: relative;
  z-index: var(--z-navbar);
  box-sizing: border-box;
  background-color: var(--color-bg-card);

  &--fixed {
    position: fixed;
    top: 0;
    right: 0;
    left: 0;
  }
}

/* 导航栏高度来自设备信息（px），内部尺寸同样用 px，避免窗口变宽时 rpx 被放大撑破内容区 */
.app-navbar__content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 8px;
}

.app-navbar__left {
  display: flex;
  align-items: center;
}

.app-navbar__back,
.app-navbar__home {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  margin-right: 4px;
  border-radius: 50%;

  &:active {
    background-color: var(--color-fill-2);
  }
}

.app-navbar__center {
  position: absolute;
  top: 50%;
  left: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  max-width: 50%;
  overflow: hidden;
  transform: translate(-50%, -50%);
}

.app-navbar__title {
  overflow: hidden;
  font-size: 32rpx;
  color: var(--color-text);
  text-overflow: ellipsis;
  white-space: nowrap;
}

.app-navbar__right {
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.app-navbar__capsule-space {
  flex: 0 0 auto;
  height: 1px;
}
</style>
