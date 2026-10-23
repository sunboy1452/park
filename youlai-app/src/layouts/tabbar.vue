<template>
  <app-provider>
    <view class="page page--tabbar">
      <slot />
      <wd-tabbar
        v-model="activePath"
        bordered
        safe-area-inset-bottom
        fixed
        @change="handleTabbarChange"
      >
        <wd-tabbar-item
          v-for="item in tabbarList"
          :key="item.name"
          :name="item.name"
          :title="item.title"
          :icon="item.icon"
        />
      </wd-tabbar>
    </view>
  </app-provider>
</template>

<script setup lang="ts">
import { ref, nextTick } from "vue";
import { onShow } from "@dcloudio/uni-app";

// tabbar 配置：name 与页面路径一一对应，切换时按 name 走 switchTab
const tabbarList = [
  { name: "/pages/index/index", title: "首页", icon: "home" },
  { name: "/pages/work/index", title: "工作台", icon: "apps" },
  { name: "/pages/mine/index", title: "我的", icon: "user" },
];

// 当前激活项的页面路径
const activePath = ref(tabbarList[0].name);

// 按当前页面同步激活项：mounted 与 onShow 都要执行，切回标签时不能停留在旧值
function syncActiveTab() {
  const pages = getCurrentPages();
  const currentPage = pages[pages.length - 1];
  const route = (currentPage?.route as string) || "";
  const matched = tabbarList.find((item) => item.name === `/${route}`);
  if (matched) {
    activePath.value = matched.name;
  }
}

// 切换标签：先更新选中态再跳转，避免切换过程中高亮回弹
function handleTabbarChange({ value }: { value: string }) {
  activePath.value = value;
  nextTick(() => {
    uni.switchTab({ url: value });
  });
}

onMounted(() => {
  syncActiveTab();

  // #ifdef APP-PLUS
  uni.hideTabBar();
  // #endif
});

onShow(() => {
  syncActiveTab();
});
</script>

<script lang="ts">
export default {
  options: {
    addGlobalClass: true,
    virtualHost: true,
    styleIsolation: "shared",
  },
};
</script>
