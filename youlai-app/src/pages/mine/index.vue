<template>
  <view class="mine">
    <view class="mine__hero" :style="{ paddingTop: `${navbar.totalHeightPx.value}px` }">
      <view class="mine__hero-bg" :style="{ background: heroGradient }" />

      <app-navbar
        :background="isScrolled ? heroGradient : 'transparent'"
        title-color="var(--color-text-inverse)"
        icon-color="var(--color-text-inverse)"
        :show-back="false"
        :placeholder="false"
      >
        <template #center>
          <text class="mine__navbar-title">个人中心</text>
        </template>
      </app-navbar>

      <view class="mine__hero-content">
        <profile-card
          :is-authenticated="isAuthenticated"
          :avatar="avatar"
          :display-name="displayName"
          :username="username"
          :dept-name="deptName"
          @profile="navigateToProfile"
          @login="navigateToLogin"
          @scan="scanForLogin"
        />

        <view class="mine__community">
          <official-account-card @open="navigateToOfficialAccount" />
        </view>

        <quick-actions
          v-if="isAuthenticated"
          @profile="navigateToProfile"
          @account="navigateToAccountSecurity"
        />
      </view>
    </view>

    <view class="mine__body">
      <menu-section title="系统工具" :items="toolMenuItems" @select="handleMenuSelect" />
      <menu-section title="帮助与支持" :items="helpMenuItems" @select="handleMenuSelect" />

      <wd-button
        v-if="isAuthenticated"
        type="danger"
        variant="plain"
        size="large"
        block
        :disabled="isLoggingOut"
        @click="requestLogout"
      >
        退出登录
      </wd-button>
    </view>

    <view v-if="isClearing" class="mine__cache-loading">
      <wd-loading text="正在清理..." inherit-color />
    </view>
  </view>
</template>

<script lang="ts" setup>
import { computed, ref } from "vue";
import { onPageScroll, onShow } from "@dcloudio/uni-app";
import { storeToRefs } from "pinia";
import { useUserStore, useThemeStore } from "@/store";
import { useNavbarMetrics } from "@/composables/useNavbarMetrics";
import { useScanLogin } from "@/composables/useScanLogin";
import { useLogout } from "@/composables/useLogout";
import { useCacheCleaner } from "@/composables/useCacheCleaner";
import ProfileCard from "./components/ProfileCard.vue";
import OfficialAccountCard from "./components/OfficialAccountCard.vue";
import QuickActions from "./components/QuickActions.vue";
import MenuSection, { type SettingsMenuItem } from "./components/MenuSection.vue";

definePage({
  name: "mine",
  style: { navigationStyle: "custom" },
  layout: "tabbar",
});

// 菜单项：route 跳转页面，action 执行本地动作
type SettingsMenuEntry = SettingsMenuItem &
  ({ kind: "route"; target: string; requiresAuth?: boolean } | { kind: "action" });

const userStore = useUserStore();
const themeStore = useThemeStore();
const navbar = useNavbarMetrics();
const { scanForLogin } = useScanLogin();
const { isLoggingOut, requestLogout } = useLogout();

// 滚动后导航栏补上背景，否则内容会从透明导航栏下穿过
const isScrolled = ref(false);
onPageScroll(({ scrollTop }) => {
  isScrolled.value = scrollTop > 0;
});

const { isAuthenticated } = storeToRefs(userStore);
const userInfo = computed(() => userStore.userInfo);
const defaultAvatar = "/static/images/default-avatar.png";

const avatar = computed(() =>
  isAuthenticated.value && userInfo.value?.avatar ? userInfo.value.avatar : defaultAvatar
);
const displayName = computed(() =>
  isAuthenticated.value ? userInfo.value?.nickname || "匿名用户" : "欢迎使用"
);
const username = computed(() => userInfo.value?.username || "未设置账号");
const deptName = computed(() => (isAuthenticated.value ? userInfo.value?.deptName || "" : ""));

// 主色渐变：Hero 画布与滚动后的导航栏共用一份，主题色为 6 位十六进制时叠加透明度
const heroGradient = computed(() => {
  const color = themeStore.themeVars.colorTheme || "var(--color-primary)";
  const heroStartColor = color.length === 7 ? `${color}E6` : color;
  const heroEndColor = color.length === 7 ? `${color}CC` : color;
  return `linear-gradient(135deg, ${heroStartColor} 0%, ${heroEndColor} 100%)`;
});

// 版本号：构建时注入，小程序端会被发布版本覆盖
const appVersion = ref(import.meta.env.VITE_APP_VERSION);
const { usageText: storageUsageText, isClearing, loadUsage, clearCache } = useCacheCleaner();

// 常用功能在前，维护操作在后
const toolMenuItems = computed<SettingsMenuEntry[]>(() => [
  {
    id: "notice",
    kind: "route",
    target: "/subPages/work/notice/index",
    requiresAuth: true,
    icon: "notification",
    tone: "primary",
    title: "消息通知",
    desc: "查看系统通知与公告",
  },
  {
    id: "theme",
    kind: "route",
    target: "/subPages/mine/settings/theme/index",
    icon: "settings",
    tone: "primary",
    title: "主题设置",
    desc: "主题色与明暗模式",
  },
  {
    id: "network",
    kind: "route",
    target: "/subPages/mine/settings/network/index",
    icon: "wifi",
    tone: "primary",
    title: "网络检测",
    desc: "检测网络与服务器连接",
  },
  {
    id: "clear-cache",
    kind: "action",
    icon: "delete",
    tone: "danger",
    title: "清理缓存",
    desc: "释放本地存储空间",
    value: storageUsageText.value,
  },
]);

const helpMenuItems = computed<SettingsMenuEntry[]>(() => [
  {
    id: "agreement",
    kind: "route",
    target: "/subPages/mine/settings/agreement/index",
    icon: "file",
    tone: "success",
    title: "用户协议",
    desc: "了解产品使用规则",
  },
  {
    id: "about",
    kind: "route",
    target: "/subPages/mine/about/index",
    icon: "info-circle",
    tone: "info",
    title: "关于系统",
    desc: "产品介绍与联系方式",
    value: `v${appVersion.value}`,
  },
]);

// 菜单分发：先按 id 找到配置，再按 kind 走跳转或本地动作
function handleMenuSelect(id: string) {
  const entry = [...toolMenuItems.value, ...helpMenuItems.value].find((item) => item.id === id);
  if (!entry) return;

  if (entry.kind === "action") {
    clearCache();
    return;
  }
  if (entry.requiresAuth && !isAuthenticated.value) {
    navigateToLogin();
    return;
  }
  uni.navigateTo({ url: entry.target });
}

// 登录页带回跳地址，登录成功后原路返回
function navigateToLogin() {
  const pages = getCurrentPages();
  const currentPage = pages[pages.length - 1];
  const currentPagePath = `/${currentPage.route}`;
  uni.navigateTo({
    url: `/pages/login/index?redirect=${encodeURIComponent(currentPagePath)}`,
  });
}

// 资料页要求登录，未登录先跳登录页
function navigateToProfile() {
  if (!isAuthenticated.value) {
    navigateToLogin();
    return;
  }
  uni.navigateTo({ url: "/subPages/mine/profile/index" });
}

// 账号安全页要求登录，未登录先跳登录页
function navigateToAccountSecurity() {
  if (!isAuthenticated.value) {
    navigateToLogin();
    return;
  }
  uni.navigateTo({ url: "/subPages/mine/account/index" });
}

// 公众号介绍页对游客开放，不需要登录
function navigateToOfficialAccount() {
  uni.navigateTo({
    url: "/subPages/mine/official/index",
  });
}

// 已登录但资料为空：token 在、userInfo 缺失的断档态由补拉修复
const hasUserProfile = computed(() => {
  const info = userInfo.value;
  return !!(info && (info.userId || info.username || info.nickname));
});

// 资料未加载时补拉一次，失败不阻塞页面渲染
async function ensureUserInfoLoaded() {
  if (!isAuthenticated.value || hasUserProfile.value) return;
  try {
    await userStore.loadUserInfo();
  } catch {
    // 补拉失败保持空态，下次 onShow 再试
  }
}

// 小程序端版本号以发布版本为准，其他端取构建时注入的包版本
function syncAppVersion() {
  // #ifdef MP-WEIXIN
  appVersion.value = uni.getAccountInfoSync().miniProgram.version || appVersion.value;
  // #endif
}

onShow(async () => {
  await ensureUserInfoLoaded();
  await loadUsage();
  syncAppVersion();
});
</script>

<style lang="scss" scoped>
.mine {
  min-height: 100vh;
}

.mine__hero {
  position: relative;
}

/* Hero 画布由页面拥有：固定高度从屏幕顶部铺到社区卡片中线，不随卡片显隐或文案换行变化 */
.mine__hero-bg {
  position: absolute;
  top: 0;
  right: 0;
  left: 0;
  z-index: var(--z-base);
  height: 480rpx;
  pointer-events: none;
}

.mine__hero-content {
  position: relative;
  z-index: var(--z-content);
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  padding: 20rpx 28rpx 0;
}

.mine__community {
  position: relative;
}

.mine__navbar-title {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--color-text-inverse);
  letter-spacing: 2rpx;
}

.mine__body {
  position: relative;
  z-index: var(--z-content);
  display: flex;
  flex-direction: column;
  gap: 24rpx;
  padding: 24rpx 28rpx 40rpx;
  background: var(--color-bg-page);
  border-top-left-radius: 48rpx;
  border-top-right-radius: 48rpx;
}

.mine__cache-loading {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: var(--z-overlay);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-text-inverse);
  background: var(--color-overlay);
}
</style>
