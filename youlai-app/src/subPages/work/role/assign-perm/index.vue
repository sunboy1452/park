<template>
  <view class="permissions">
    <!-- 固定头部：搜索栏 + 操作栏 -->
    <view class="permissions__header">
      <view class="role-bar">
        <text class="role-bar__label">角色</text>
        <text class="role-bar__value">{{ roleName || "-" }}</text>
      </view>

      <view class="action-bar">
        <view class="action-bar__left">
          <wd-button size="small" variant="plain" @click="handleSelectAll">全选</wd-button>
          <wd-button size="small" variant="plain" @click="handleClearAll">取消全选</wd-button>
        </view>
      </view>
    </view>

    <!-- 可滚动区域：权限树 -->
    <scroll-view class="permissions__tree" scroll-y>
      <tree-view
        :data="menuTree"
        :checkable="true"
        :checked-keys="checkedKeys"
        :default-expand-all="true"
        value-key="id"
        label-key="name"
        children-key="children"
        @check="handleCheck"
      >
        <template #content="{ node, checked }">
          <view class="permissions__node">
            <view class="permissions__node-info">
              <wd-icon
                v-if="node.type === 'C'"
                name="folder"
                size="18"
                :color="checked ? 'var(--color-primary)' : 'var(--color-text-secondary)'"
              />
              <wd-icon
                v-else-if="node.type === 'M'"
                name="menu"
                size="18"
                :color="checked ? 'var(--color-primary)' : 'var(--color-text-secondary)'"
              />
              <wd-icon
                v-else
                name="tag"
                size="16"
                :color="checked ? 'var(--color-primary)' : 'var(--color-text-secondary)'"
              />
              <text class="permissions__node-label" :class="{ 'is-checked': checked }">
                {{ node.name }}
              </text>
            </view>
            <wd-tag
              v-if="node.type"
              size="small"
              :type="node.type === 'C' ? 'primary' : node.type === 'M' ? 'success' : 'warning'"
              variant="plain"
            >
              {{ node.type === "C" ? "目录" : node.type === "M" ? "菜单" : "按钮" }}
            </wd-tag>
          </view>
        </template>
      </tree-view>

      <wd-empty v-if="menuTree.length === 0" icon="search-line" tip="暂无菜单数据" />
    </scroll-view>

    <!-- 固定底部操作栏 -->
    <view class="permissions__actions">
      <wd-button type="info" variant="plain" block @click="handleCancel">取消</wd-button>
      <wd-button :loading="isSubmitting" block @click="handleSubmit">保存</wd-button>
    </view>
  </view>
</template>

<script lang="ts" setup>
import { onLoad } from "@dcloudio/uni-app";
import MenuAPI, { type MenuItem, type MenuType } from "@/api/menu";
import { toTree } from "@/utils/tree";
import RoleAPI from "@/api/role";
import { getErrorMessage } from "@/utils/error";
import TreeView from "@/subPages/work/components/TreeView.vue";
import type { TreeOption } from "@/subPages/work/components/TreeView.vue";

definePage({
  name: "role-assign-perm",
  style: { navigationBarTitleText: "分配权限" },
  layout: "blank",
});

const toast = useToast();
const isSubmitting = ref(false);
const roleId = ref<number>(0);
const roleName = ref("");
const menuList = ref<MenuItem[]>([]);
const checkedKeys = ref<string[]>([]);

// 树组件节点：菜单实体字段 + 树节点要求的 value/label
interface PermissionTreeOption extends TreeOption {
  id: string;
  name: string;
  type?: MenuType;
  children?: PermissionTreeOption[];
}

// 转换菜单为树组件格式，叶子节点不携带 children 字段
const menuTree = computed<PermissionTreeOption[]>(() =>
  toTree(
    menuList.value,
    (menu) => menu.children,
    (menu, children) => ({
      value: String(menu.id),
      label: menu.name ?? "",
      id: String(menu.id),
      name: menu.name ?? "",
      type: menu.type,
      children: menu.children ? children : undefined,
    })
  )
);

// 处理选中变化
function handleCheck(keys: string[]) {
  checkedKeys.value = keys;
}

// 全选：包含所有层级的菜单 id
function handleSelectAll() {
  const allIds = getAllMenuIds(menuList.value);
  checkedKeys.value = allIds;
}

// 取消全选：直接清空勾选集合，不逐层回退
function handleClearAll() {
  checkedKeys.value = [];
}

// 收集所有层级的菜单 id
function getAllMenuIds(menus: MenuItem[]): string[] {
  const ids: string[] = [];
  function traverse(list: MenuItem[]) {
    for (const menu of list) {
      if (menu.id) ids.push(String(menu.id));
      if (menu.children) traverse(menu.children);
    }
  }
  traverse(menus);
  return ids;
}

// 取消：不保存直接返回
function handleCancel() {
  uni.navigateBack();
}

// 提交：勾选结果是字符串 id，提交前转回数字
async function handleSubmit() {
  isSubmitting.value = true;
  try {
    await RoleAPI.assignMenus(roleId.value, checkedKeys.value.map(Number));
    toast.success("保存成功");
    uni.navigateBack();
  } catch (error) {
    toast.error(getErrorMessage(error, "保存失败"));
  } finally {
    isSubmitting.value = false;
  }
}

// 加载角色权限页所需的菜单树、已授权菜单与角色名
async function loadRolePermissions() {
  try {
    // 并行加载菜单列表和角色已有权限
    const [menus, roleMenuIds, roleForm] = await Promise.all([
      MenuAPI.getList(),
      RoleAPI.getMenuIds(roleId.value),
      RoleAPI.getFormData(roleId.value),
    ]);
    menuList.value = menus;
    checkedKeys.value = roleMenuIds.map(String);
    roleName.value = roleForm?.name ?? "";
  } catch {
    toast.error("加载失败");
  }
}

onLoad((query) => {
  if (query?.id) {
    roleId.value = Number(query.id);
    loadRolePermissions();
  }
});
</script>

<script lang="ts">
export default { options: { styleIsolation: "shared" } };
</script>

<style lang="scss" scoped>
.permissions {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: var(--color-bg-card);
}

.permissions__header {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: space-between;
  padding: 12rpx 24rpx;
  background: var(--color-bg-card);
  border-bottom: 2rpx solid var(--color-border-light);
}

.role-bar {
  display: flex;
  gap: 16rpx;
  align-items: center;

  &__label {
    font-size: 24rpx;
    color: var(--color-text-secondary);
  }

  &__value {
    flex: 1;
    overflow: hidden;
    font-size: 28rpx;
    font-weight: 600;
    color: var(--color-text);
    text-overflow: ellipsis;
    white-space: nowrap;
  }
}

.action-bar {
  &__left {
    display: flex;
    gap: 16rpx;
  }
}

.permissions__tree {
  flex: 1;
  height: 0; // scroll-view 要拿到确定高度，flex 剩余空间才生效
  background: var(--color-bg-card);
}

.permissions__node {
  display: flex;
  flex: 1;
  gap: 16rpx;
  align-items: center;
  justify-content: flex-start;
  min-width: 0;
}

.permissions__node-info {
  display: flex;
  gap: 16rpx;
  min-width: 0;
}

.permissions__node-label {
  overflow: hidden;
  font-size: 28rpx;
  color: var(--color-text);
  text-overflow: ellipsis;
  white-space: nowrap;

  &.is-checked {
    color: var(--color-primary);
  }
}

// 类型标签右对齐，与左侧名称拉开
.permissions__node :deep(.wd-tag) {
  margin-left: auto;
}

// 按钮用 block 撑满，容器只负责排列、间距与底部安全区
.permissions__actions {
  display: flex;
  flex-shrink: 0;
  gap: 24rpx;
  padding: 24rpx 24rpx calc(24rpx + env(safe-area-inset-bottom));
  background: var(--color-bg-card);
  box-shadow: 0 -2rpx 16rpx rgba(0, 0, 0, 0.05);
}
</style>
