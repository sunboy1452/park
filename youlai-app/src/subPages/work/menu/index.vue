<template>
  <view>
    <view>
      <wd-search
        v-model="queryParams.keywords"
        placeholder="搜索菜单名称"
        hide-cancel
        @search="loadMenuList"
      />
    </view>

    <!-- 菜单树形列表 -->
    <view class="mt-16rpx">
      <tree-view
        :data="treeData"
        :default-expand-all="true"
        :show-action="true"
        @action="handleNodeAction"
      >
        <!-- 自定义节点内容：ID + 名称 + 状态 -->
        <template #content="{ node }">
          <view class="flex-1 flex-start gap-16rpx">
            <text class="w-120rpx text-24rpx color-text-secondary">{{ node.id }}</text>
            <wd-icon v-if="node.icon" :name="node.icon" size="16" class="color-primary" />
            <text class="flex-1 truncate">{{ node.name }}</text>
            <wd-tag class="flex-shrink-0" :type="getMenuTypeTag(node.type)" size="small">
              {{ getMenuTypeText(node.type) }}
            </wd-tag>
            <wd-tag
              class="flex-shrink-0"
              :type="node.visible === 1 ? 'success' : 'primary'"
              size="small"
            >
              {{ node.visible === 1 ? "显示" : "隐藏" }}
            </wd-tag>
          </view>
        </template>
      </tree-view>

      <wd-empty v-if="menuList.length === 0" icon="search-line" tip="暂无数据" />
    </view>

    <!-- 弹窗表单 -->
    <wd-popup
      v-model="dialog.visible"
      position="bottom"
      custom-class="popup-bottom-scroll"
      @close="closeMenuDialog"
    >
      <view class="p-4">
        <view class="popup-title">
          {{ formData.id ? "编辑菜单" : "新增菜单" }}
        </view>
        <scroll-view scroll-y class="max-h-60vh">
          <wd-form ref="formRef" :model="formData" :schema="rules">
            <!-- 上级菜单选择：触发交 wd-form-item，选择器只负责弹出 -->
            <wd-form-item
              title="上级菜单"
              prop="parentId"
              required
              is-link
              :value="parentLabel"
              placeholder="请选择上级菜单"
              @click="showParentPicker = true"
            />
            <wd-cascader
              v-model="parentSelected"
              v-model:visible="showParentPicker"
              :options="parentCascaderOptions"
              text-key="label"
              @confirm="handleParentConfirm"
            />
            <wd-form-item prop="name" title="菜单名称" required>
              <wd-input v-model="formData.name" placeholder="请输入菜单名称" />
            </wd-form-item>
            <wd-form-item prop="type" title="菜单类型" required>
              <wd-radio-group v-model="formData.type" type="button">
                <wd-radio
                  v-for="option in typeOptions"
                  :key="option.value"
                  :value="option.value"
                  :disabled="option.disabled"
                >
                  {{ option.label }}
                </wd-radio>
              </wd-radio-group>
            </wd-form-item>
            <wd-form-item
              v-if="formData.type === 'C' || formData.type === 'M'"
              prop="routePath"
              title="路由路径"
            >
              <wd-input v-model="formData.routePath" placeholder="system 或 /system" />
            </wd-form-item>
            <wd-form-item v-if="formData.type === 'E'" prop="externalUrl" title="外链地址">
              <wd-input v-model="formData.externalUrl" placeholder="https://example.com" />
            </wd-form-item>
            <wd-form-item v-if="formData.type === 'M'" prop="component" title="组件路径">
              <wd-input v-model="formData.component" placeholder="system/menu/index" />
            </wd-form-item>
            <wd-form-item v-if="formData.type === 'B'" prop="perm" title="权限标识">
              <wd-input v-model="formData.perm" placeholder="sys:menu:create" />
            </wd-form-item>
            <wd-form-item prop="icon" title="图标">
              <wd-input v-model="formData.icon" placeholder="请输入图标名" />
            </wd-form-item>
            <wd-form-item prop="sort" title="排序">
              <wd-input-number v-model="formData.sort!" :min="0" />
            </wd-form-item>
            <wd-form-item prop="visible" title="状态">
              <wd-switch v-model="formData.visible" :active-value="1" :inactive-value="0" />
            </wd-form-item>
            <wd-form-item
              v-if="formData.type === 'M' && !formData.id"
              prop="buttonPermPrefix"
              title="按钮权限"
            >
              <view class="w-full">
                <wd-checkbox v-model="formData.generateCrudButtons" type="square">
                  生成增删改查按钮
                </wd-checkbox>
                <wd-input
                  v-if="formData.generateCrudButtons"
                  v-model="formData.buttonPermPrefix"
                  placeholder="权限前缀，如 sys:user"
                  class="mt-8rpx"
                />
              </view>
            </wd-form-item>
          </wd-form>
        </scroll-view>
        <view class="popup-actions">
          <wd-button type="info" variant="plain" block @click="closeMenuDialog">取消</wd-button>
          <wd-button :loading="isSubmitting" block @click="submitMenuForm">保存</wd-button>
        </view>
      </view>
    </wd-popup>

    <!-- 浮动新增按钮 -->
    <wd-fab
      v-if="hasPermission('sys:menu:create') && !dialog.visible"
      :expandable="false"
      :gap="{ bottom: 32 }"
    >
      <template #trigger>
        <view class="work-fab-trigger" @click="openMenuDialog()">
          <wd-icon name="plus" size="20" color="var(--color-text-inverse)" />
        </view>
      </template>
    </wd-fab>

    <!-- 操作菜单 -->
    <ActionSheet ref="actionSheetRef" />
  </view>
</template>

<script lang="ts" setup>
import { onLoad } from "@dcloudio/uni-app";
import { toFormSchema, type WdFormRef } from "@/utils/form-schema";
import { findOptionChain, toTree } from "@/utils/tree";
import { useToast } from "@wot-ui/ui";
import ActionSheet, { type ActionSheetCommand } from "@/subPages/work/components/ActionSheet.vue";
import { useConfirmAction } from "@/composables/useConfirmAction";
import MenuAPI, { type MenuQuery, type MenuItem, type MenuForm, type MenuType } from "@/api/menu";
import { hasPermission } from "@/utils/permission";
import { PERM } from "@/constants/permissions";
import { getErrorMessage } from "@/utils/error";
import TreeView, { type TreeOption } from "@/subPages/work/components/TreeView.vue";
import type { CascaderOption } from "@wot-ui/ui/components/wd-cascader/types";

definePage({
  name: "menu",
  style: { navigationBarTitleText: "菜单管理" },
});

const toast = useToast();
const { confirmAction } = useConfirmAction();
const actionSheetRef = ref<InstanceType<typeof ActionSheet>>();
const formRef = ref<WdFormRef>();
const isSubmitting = ref(false);

const queryParams = reactive<MenuQuery>({ keywords: "" });
const menuList = ref<MenuItem[]>([]);
const dialog = reactive({ visible: false });

// 表单初始值：新增默认建菜单，排序在打开弹窗时按同级末尾补齐
const initialFormData: MenuForm = {
  id: undefined,
  parentId: "0",
  name: undefined,
  type: "M",
  routePath: undefined,
  component: undefined,
  externalUrl: undefined,
  perm: undefined,
  icon: undefined,
  sort: 1,
  visible: 1,
  generateCrudButtons: false,
  buttonPermPrefix: undefined,
};

const formData = reactive<MenuForm>({ ...initialFormData });

// 树组件节点：菜单实体字段 + 树节点要求的 value/label
interface MenuTreeOption extends TreeOption {
  id?: string;
  name?: string;
  type?: MenuType;
  icon?: string;
  visible?: number;
  perm?: string;
  children?: MenuTreeOption[];
}

// 菜单类型在列表里的标签颜色
const MENU_TYPE_TAG: Record<MenuType, "primary" | "success" | "warning" | "danger"> = {
  C: "warning",
  M: "success",
  E: "primary",
  B: "danger",
};

// 菜单类型的中文名称
const MENU_TYPE_TEXT: Record<MenuType, string> = {
  C: "目录",
  M: "菜单",
  E: "外链",
  B: "按钮",
};

// 菜单列表转树节点：value/label 供树组件使用，业务字段随节点透传给操作菜单
const treeData = computed<MenuTreeOption[]>(() =>
  toTree(
    menuList.value,
    (menu) => menu.children,
    (menu, children) => ({
      value: menu.id ?? "",
      label: menu.name ?? "",
      id: menu.id,
      name: menu.name,
      type: menu.type,
      icon: menu.icon,
      visible: menu.visible,
      perm: menu.perm,
      children,
    })
  )
);

// 菜单类型对应的标签颜色，类型缺失时按主色展示
function getMenuTypeTag(type?: MenuType) {
  return (type && MENU_TYPE_TAG[type]) || "primary";
}

// 菜单类型对应的中文名称，类型缺失时按「菜单」展示
function getMenuTypeText(type?: MenuType) {
  return (type && MENU_TYPE_TEXT[type]) || "菜单";
}

// 上级菜单选择器
const showParentPicker = ref(false);
const parentSelected = ref<string | number>("");
const parentOptions = ref<OptionType[]>([]);
const parentLabel = ref("");

// 菜单 ID 索引，供上级类型判断和同级排序使用
const menuMap = computed(() => {
  const map = new Map<string, MenuItem>();
  const walk = (menus: MenuItem[]) => {
    menus.forEach((menu) => {
      if (menu.id) map.set(String(menu.id), menu);
      if (menu.children?.length) walk(menu.children);
    });
  };
  walk(menuList.value);
  return map;
});

// 已选上级是否为菜单：菜单下只能挂按钮，顶级或目录下只能挂目录/菜单/外链
const parentIsMenu = computed(() => menuMap.value.get(String(formData.parentId))?.type === "M");

// 按钮只能挂在菜单下，其余类型只能挂在顶级或目录下
const typeOptions = computed(() => [
  { value: "C", label: "目录", disabled: parentIsMenu.value },
  { value: "M", label: "菜单", disabled: parentIsMenu.value },
  { value: "E", label: "外链", disabled: parentIsMenu.value },
  { value: "B", label: "按钮", disabled: !parentIsMenu.value },
]);

// 编辑菜单的下级 ID，避免把菜单挂到自己的子级下
const descendantIds = computed(() => {
  const ids = new Set<string>();
  const walk = (menus: MenuItem[]) => {
    menus.forEach((menu) => {
      if (menu.id) ids.add(String(menu.id));
      if (menu.children?.length) walk(menu.children);
    });
  };
  walk(menuMap.value.get(String(formData.id))?.children ?? []);
  return ids;
});

// 上级选项：按当前类型禁用不兼容的层级
const parentCascaderOptions = computed(() => markParentDisabled(parentOptions.value));

// 递归标记上级选项：禁用项在级联选择器里不可选，但仍会展示层级
function markParentDisabled(options: OptionType[]): CascaderOption[] {
  return options.map((option) => ({
    ...option,
    disabled: isDisabledParent(option),
    children: option.children?.length ? markParentDisabled(option.children) : undefined,
  }));
}

// 上级选项是否禁用：自身与下级不可选，按钮只能挂菜单下，其余类型只能挂顶级或目录下
function isDisabledParent(option: OptionType): boolean {
  const value = String(option.value);
  if (formData.id && (value === String(formData.id) || descendantIds.value.has(value))) return true;

  const optionIsMenu = menuMap.value.get(value)?.type === "M";
  return formData.type === "B" ? !optionIsMenu : optionIsMenu;
}

// 同级菜单的下一个排序值，新增菜单默认排在末尾
function resolveNextSort(parentId?: string): number {
  const siblings =
    !parentId || parentId === "0"
      ? menuList.value
      : (menuMap.value.get(String(parentId))?.children ?? []);
  return siblings.reduce((max, menu) => Math.max(max, menu.sort ?? 0), 0) + 1;
}

// 同级按钮权限里出现次数最多的模块名，用作新增页面的按钮前缀
function deriveButtonPermPrefix(parentId: string): string {
  const siblings =
    !parentId || parentId === "0"
      ? menuList.value
      : (menuMap.value.get(String(parentId))?.children ?? []);
  const counter = new Map<string, number>();
  siblings.forEach((menu) => {
    if (menu.type !== "B" || !menu.perm) return;
    const module = menu.perm.split(":").slice(0, -1).join(":");
    if (module) counter.set(module, (counter.get(module) ?? 0) + 1);
  });

  let prefix = "";
  let maxCount = 0;
  counter.forEach((count, module) => {
    if (count > maxCount) {
      maxCount = count;
      prefix = module;
    }
  });
  return prefix;
}

// 选择上级后收敛菜单类型：挂到菜单下只能是按钮，否则按钮要退回菜单
const handleParentConfirm = ({
  value,
  selectedOptions,
}: {
  value: string | number;
  selectedOptions: CascaderOption[];
}) => {
  parentSelected.value = value;
  formData.parentId = String(value) || "0";
  parentLabel.value = selectedOptions.map((item) => String(item.label ?? "")).join("/");

  // 上级类型变了，把当前类型收敛到允许的范围
  if (parentIsMenu.value) {
    formData.type = "B";
  } else if (formData.type === "B") {
    formData.type = "M";
  }
};

// 勾选生成按钮时用同级已有按钮补全前缀，已填内容不覆盖
watch(
  () => formData.generateCrudButtons,
  (checked) => {
    if (!checked || formData.buttonPermPrefix?.trim()) return;
    formData.buttonPermPrefix = deriveButtonPermPrefix(formData.parentId);
  }
);

const rules = toFormSchema({
  name: [{ required: true, message: "请输入菜单名称" }],
  type: [{ required: true, message: "请选择菜单类型" }],
  parentId: [{ required: true, message: "请选择上级菜单" }],
});

// 加载菜单树：接口直接返回树结构，前端只做展示映射
function loadMenuList() {
  MenuAPI.getList(queryParams)
    .then((data) => {
      menuList.value = data;
    })
    .catch((error) => {
      toast.error(getErrorMessage(error, "加载失败"));
    });
}

// 节点操作菜单：按钮节点不提供新增子菜单，其余命令按权限拼装
function handleNodeAction(node: MenuTreeOption) {
  const commands: ActionSheetCommand[] = [];

  // 按钮(B)类型节点不允许再有下级
  if (hasPermission(PERM.menu.create) && node.type !== "B") {
    commands.push({
      id: "add-child",
      label: "新增子菜单",
      execute: () => openChildMenuDialog(node),
    });
  }

  if (hasPermission(PERM.menu.update)) {
    commands.push({ id: "edit", label: "编辑", execute: () => openMenuDialog(node) });
  }

  if (hasPermission(PERM.menu.delete)) {
    commands.push({
      id: "delete",
      label: "删除",
      color: "var(--color-danger)",
      execute: () =>
        confirmAction({
          msg: `确定要删除菜单「${node.name}」吗？`,
          action: async () => {
            await MenuAPI.deleteByIds(node.id!);
            loadMenuList();
          },
        }),
    });
  }

  actionSheetRef.value?.open(commands);
}

// 打开弹窗（新增/编辑）
async function openMenuDialog(menu?: MenuItem) {
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
  parentSelected.value = "";
  parentLabel.value = "";
  dialog.visible = true;

  const data = await MenuAPI.getParentOptions();
  parentOptions.value = [{ value: "0", label: "顶级菜单" }, ...data];

  if (menu?.id) {
    formData.id = menu.id;
    const form = await MenuAPI.getFormData(menu.id);
    Object.assign(formData, form, { id: menu.id });

    // 编辑时回显上级菜单
    if (String(form.parentId) === "0") {
      parentSelected.value = "0";
      parentLabel.value = "顶级菜单";
    } else if (form.parentId) {
      parentSelected.value = form.parentId;
      const chain = findOptionChain(data, form.parentId);
      parentLabel.value = chain ? chain.map((option) => option.label).join("/") : "";
    }
  } else {
    // 新增菜单不填排序，默认排到同级末尾
    formData.sort = resolveNextSort(formData.parentId);
  }
}

// 新增子菜单：按新增流程打开弹窗，并预设上级菜单
function openChildMenuDialog(menu: MenuItem) {
  openMenuDialog();
  formData.parentId = menu.id!;
  parentSelected.value = menu.id!;
  parentLabel.value =
    findOptionChain(treeData.value, menu.id!)
      ?.map((option) => option.label)
      .join("/") ||
    menu.name ||
    "";
  // 菜单下只能挂按钮，目录下默认新增菜单
  formData.type = menu.type === "M" ? "B" : "M";
  formData.sort = resolveNextSort(menu.id!);
}

// 组装提交数据：按类型丢弃无关字段，避免把上次输入或不需要的字段提交给后端
function buildMenuPayload() {
  const payload: MenuForm = { ...formData };

  if (payload.type === "E") {
    payload.routePath = undefined;
    payload.component = undefined;
    payload.perm = undefined;
  } else {
    payload.externalUrl = undefined;
  }

  if (payload.type === "B") {
    payload.routePath = undefined;
    payload.component = undefined;
    payload.icon = undefined;
  }

  // 只有新增页面菜单才生成按钮权限
  if (payload.type !== "M" || payload.id) {
    payload.generateCrudButtons = undefined;
    payload.buttonPermPrefix = undefined;
  }

  return payload;
}

// 提交表单：校验通过后按 id 判断新增或修改，成功后刷新列表
function submitMenuForm() {
  formRef.value?.validate().then(({ valid }: { valid: boolean }) => {
    if (!valid) return;
    if (formData.generateCrudButtons && !formData.buttonPermPrefix?.trim()) {
      toast.error("请填写按钮权限前缀");
      return;
    }
    isSubmitting.value = true;
    const payload = buildMenuPayload();
    const action = formData.id ? MenuAPI.update(formData.id, payload) : MenuAPI.create(payload);
    action
      .then(() => {
        toast.success("操作成功");
        closeMenuDialog();
        loadMenuList();
      })
      .catch((error) => {
        toast.error(getErrorMessage(error, "保存失败"));
      })
      .finally(() => {
        isSubmitting.value = false;
      });
  });
}

// 关闭弹窗并重置表单，避免下次打开残留上次输入
function closeMenuDialog() {
  dialog.visible = false;
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
}

onLoad(() => {
  loadMenuList();
});
</script>

<script lang="ts">
export default { options: { styleIsolation: "shared" } };
</script>
