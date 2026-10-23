<template>
  <view>
    <app-navbar title="工作台" :show-back="false" placeholder />
    <!-- tabbar 壳为全出血（index/mine 的沉浸式头需要贴边），工作台网格需要自己补横向留白 -->
    <view class="px-32rpx pt-16rpx">
      <template v-for="(item, index) in visibleGroups" :key="index">
        <wd-card :title="item.title">
          <wd-grid clickable :column="4">
            <wd-grid-item
              v-for="(child, childIndex) in item.children"
              :key="childIndex"
              @click="navigate(child)"
            >
              <view class="p-2">
                <image class="w-72rpx h-72rpx rounded-8rpx" :src="child.icon" />
              </view>
              <view>{{ child.title }}</view>
            </wd-grid-item>
          </wd-grid>
        </wd-card>
      </template>
    </view>
  </view>
</template>

<script lang="ts" setup>
import { computed } from "vue";
import { useNavigation } from "@/composables/useNavigation";
import { workMenuGroups } from "@/config/work-menu";
import { isMenuAllowed } from "@/utils/permission";

definePage({
  name: "work",
  style: {
    navigationStyle: "custom",
    navigationBarTitleText: "工作台",
  },
  layout: "tabbar",
});

const { navigate } = useNavigation();

// 根据权限过滤后的菜单分组，未授权分组整体不展示
const visibleGroups = computed(() => {
  return workMenuGroups
    .map((group) => ({
      ...group,
      children: group.children.filter((item) => isMenuAllowed(item.perm)),
    }))
    .filter((group) => group.children.length > 0);
});
</script>
