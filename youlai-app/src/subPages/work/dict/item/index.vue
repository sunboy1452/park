<template>
  <view>
    <view>
      <wd-search
        v-model="queryParams.keywords"
        placeholder="搜索字典标签/字典值"
        hide-cancel
        @search="handleSearch"
      />
    </view>

    <view class="mt-16rpx">
      <wd-card v-for="item in dictItems" :key="item.id" @click="openItemDialog(item.id)">
        <view class="flex-start">
          <view class="flex-1">
            <view class="flex-start">
              <wd-tag v-if="tagComponentType(item.tagType)" :type="tagComponentType(item.tagType)">
                {{ item.label }}
              </wd-tag>
              <text v-else class="text-32rpx font-semibold">{{ item.label }}</text>
            </view>
            <text class="text-24rpx color-text-secondary">
              字典值：{{ item.value }} · 排序：{{ item.sort }}
            </text>
          </view>
          <wd-tag :type="item.status === 1 ? 'success' : 'danger'">
            {{ item.status === 1 ? "启用" : "禁用" }}
          </wd-tag>
        </view>

        <view class="flex-between mt-16rpx">
          <text class="text-24rpx color-text-placeholder">{{ item.remark || "暂无备注" }}</text>
          <view
            class="item-action"
            hover-class="item-action--hover"
            @click.stop="openItemActions(item)"
          >
            <wd-icon name="more" size="18" class="color-text-secondary" />
          </view>
        </view>
      </wd-card>

      <wd-loadmore v-if="loadMoreState !== 'idle'" :state="loadMoreState" @reload="retry" />
      <wd-empty v-else-if="total === 0" icon="search-line" tip="暂无数据" />
    </view>

    <wd-popup
      v-model="dialog.visible"
      position="bottom"
      custom-class="popup-bottom"
      @close="closeItemDialog"
    >
      <view class="p-4">
        <view class="popup-title">
          {{ formData.id ? "编辑字典数据" : "新增字典数据" }}
        </view>
        <wd-form ref="formRef" :model="formData" :schema="rules">
          <wd-form-item prop="label" title="字典项标签" required>
            <wd-input v-model="formData.label" placeholder="请输入字典项标签" />
          </wd-form-item>
          <wd-form-item prop="value" title="字典项值" required>
            <wd-input v-model="formData.value" placeholder="请输入字典项值" />
          </wd-form-item>
          <wd-form-item prop="tagType" title="标签类型">
            <wd-radio-group v-model="formData.tagType" type="button">
              <wd-radio value="">无</wd-radio>
              <wd-radio
                v-for="option in TAG_TYPE_OPTIONS"
                :key="option.value"
                :value="option.value"
              >
                {{ option.label }}
              </wd-radio>
            </wd-radio-group>
          </wd-form-item>
          <wd-form-item prop="status" title="状态">
            <wd-switch v-model="formData.status" :active-value="1" :inactive-value="0" />
          </wd-form-item>
          <wd-form-item prop="sort" title="排序">
            <wd-input-number v-model="formData.sort!" :min="0" />
          </wd-form-item>
          <wd-form-item prop="remark" title="备注">
            <wd-textarea
              v-model="formData.remark"
              placeholder="请输入备注"
              :maxlength="100"
              show-word-limit
            />
          </wd-form-item>
        </wd-form>
        <view class="popup-actions">
          <wd-button type="info" variant="plain" block @click="closeItemDialog">取消</wd-button>
          <wd-button :loading="isSubmitting" block @click="submitItemForm">保存</wd-button>
        </view>
      </view>
    </wd-popup>

    <ActionSheet ref="actionSheetRef" />
    <wd-fab
      v-if="hasPermission('sys:dict-item:create') && !dialog.visible"
      :expandable="false"
      :gap="{ bottom: 32 }"
    >
      <template #trigger>
        <view class="work-fab-trigger" @click="openItemDialog()">
          <wd-icon name="plus" size="20" color="var(--color-text-inverse)" />
        </view>
      </template>
    </wd-fab>
  </view>
</template>

<script lang="ts" setup>
import { onLoad } from "@dcloudio/uni-app";
import { toFormSchema, type WdFormRef } from "@/utils/form-schema";
import { useToast } from "@wot-ui/ui";
import ActionSheet, { type ActionSheetCommand } from "@/subPages/work/components/ActionSheet.vue";
import { useConfirmAction } from "@/composables/useConfirmAction";
import { usePagedList } from "@/composables/usePagedList";
import DictAPI, { type DictItemForm, type DictItemPageQuery, type DictItem } from "@/api/dict";
import { hasPermission } from "@/utils/permission";
import { PERM } from "@/constants/permissions";
import { getErrorMessage } from "@/utils/error";
import type { TagType } from "@wot-ui/ui/components/wd-tag/types";

definePage({
  name: "dict-item",
  style: { navigationBarTitleText: "字典数据", enablePullDownRefresh: true },
});

const toast = useToast();
const { confirmAction } = useConfirmAction();
const actionSheetRef = ref<InstanceType<typeof ActionSheet>>();

const dictCode = ref<string>("");
const pageTitle = ref<string>("字典数据");

const formRef = ref<WdFormRef>();
const isSubmitting = ref(false);

const queryParams = reactive<DictItemPageQuery>({ pageNum: 1, pageSize: 10, keywords: "" });
const dialog = reactive({ visible: false });

/**
 * 分页加载（触底加载 + 下拉刷新统一由 usePagedList 维护）
 * dictCode 尚未就绪（onLoad 取参前）时返回空页
 */
const {
  items: dictItems,
  total,
  loadMoreState,
  reload,
  retry,
} = usePagedList(
  (query: DictItemPageQuery) =>
    dictCode.value
      ? DictAPI.getItemPage(dictCode.value, query)
      : Promise.resolve({ list: [], total: 0 }),
  queryParams
);

const initialFormData: DictItemForm = {
  id: undefined,
  dictCode: undefined,
  label: undefined,
  value: undefined,
  sort: 1,
  status: 1,
  remark: undefined,
  tagType: "",
};

// 标签类型选项：值用后端存储的语义名，label 仅用于展示
const TAG_TYPE_OPTIONS = [
  { value: "primary", label: "主要" },
  { value: "success", label: "成功" },
  { value: "info", label: "信息" },
  { value: "warning", label: "警告" },
  { value: "danger", label: "危险" },
];

// 语义名与 wd-tag 类型的对应关系：info 没有同名类型，走默认样式
const TAG_COMPONENT_TYPES: Record<string, TagType> = {
  primary: "primary",
  success: "success",
  warning: "warning",
  danger: "danger",
  info: "default",
};

// 字典项标签在 wd-tag 上的呈现类型，未配置标签类型时返回 undefined 走纯文本
function tagComponentType(tagType?: string): TagType | undefined {
  return TAG_COMPONENT_TYPES[tagType ?? ""];
}

const formData = reactive<DictItemForm>({ ...initialFormData });

const rules = toFormSchema({
  label: [{ required: true, message: "请输入字典项标签" }],
  value: [{ required: true, message: "请输入字典项值" }],
});

const handleSearch = () => loadItemList();

// 加载列表（回到第一页）
function loadItemList() {
  reload();
}

async function openItemDialog(id?: string) {
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
  dialog.visible = true;
  formData.dictCode = dictCode.value;

  if (id) {
    formData.id = id;
    const data = await DictAPI.getItemFormData(dictCode.value, id);
    Object.assign(formData, data, { id });
  }
}

function submitItemForm() {
  formRef.value?.validate().then(({ valid }: { valid: boolean }) => {
    if (!valid) return;
    if (!dictCode.value) {
      toast.error("缺少字典编码");
      return;
    }

    isSubmitting.value = true;
    const id = formData.id;
    const action = id
      ? DictAPI.updateItem(dictCode.value, id, formData)
      : DictAPI.createItem(dictCode.value, formData);

    action
      .then(() => {
        toast.success("操作成功");
        closeItemDialog();
        loadItemList();
      })
      .catch((error) => {
        toast.error(getErrorMessage(error, "保存失败"));
      })
      .finally(() => {
        isSubmitting.value = false;
      });
  });
}

function closeItemDialog() {
  dialog.visible = false;
  formRef.value?.reset();
  Object.assign(formData, initialFormData);
}

function openItemActions(item: DictItem) {
  const commands: ActionSheetCommand[] = [];

  if (hasPermission(PERM.dictItem.update)) {
    commands.push({ id: "edit", label: "编辑", execute: () => openItemDialog(item.id) });
  }

  if (hasPermission(PERM.dictItem.delete)) {
    commands.push({
      id: "delete",
      label: "删除",
      color: "var(--color-danger)",
      execute: () =>
        confirmAction({
          msg: `确定要删除字典数据「${item.label}」吗？`,
          action: async () => {
            if (!item.id) return;
            await DictAPI.deleteItems(dictCode.value, String(item.id));
            loadItemList();
          },
        }),
    });
  }

  actionSheetRef.value?.open(commands);
}

onLoad((query) => {
  dictCode.value = String(query?.dictCode || "");
  pageTitle.value = String(query?.title ? decodeURIComponent(query.title) : "字典数据");
  if (pageTitle.value) {
    uni.setNavigationBarTitle({ title: pageTitle.value });
  }
  loadItemList();
});
</script>

<script lang="ts">
export default { options: { styleIsolation: "shared" } };
</script>
