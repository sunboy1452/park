<!-- @page-id: marketing-channels -->
<!-- @page-name: 招商渠道 -->
<!-- @page-route: /marketing/channels -->
<template>
  <div class="page-container marketing-page">
    <el-card class="page-search" shadow="never">
      <el-form :model="params" inline @submit.prevent="handleQuery">
        <el-form-item label="关键字">
          <el-input
            v-model="params.keyword"
            placeholder="渠道名称或编码"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="渠道类型">
          <el-select v-model="params.channelType" placeholder="全部类型" clearable>
            <el-option
              v-for="item in channelTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="params.status" placeholder="全部状态" clearable>
            <el-option label="启用" :value="1" />
            <el-option label="停用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">搜索</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="page-content" shadow="never">
      <div class="page-toolbar">
        <div class="page-toolbar__left">
          <el-button v-hasPerm="'marketing:channel:create'" type="primary" @click="openCreate">
            <el-icon><Plus /></el-icon>
            新增渠道
          </el-button>
        </div>
        <div class="page-toolbar__right">
          <el-tooltip content="刷新" placement="top">
            <el-button class="page-icon-btn" :loading="loading" @click="fetchData">
              <el-icon><Refresh /></el-icon>
            </el-button>
          </el-tooltip>
        </div>
      </div>

      <el-alert
        v-if="listError"
        class="page-alert"
        type="error"
        :title="listError"
        show-icon
        :closable="false"
      >
        <template #default>
          <el-button link type="primary" @click="fetchData">重试</el-button>
        </template>
      </el-alert>
      <el-alert
        v-if="overviewError"
        class="page-alert"
        type="warning"
        :title="overviewError"
        show-icon
        :closable="false"
      />

      <div class="page-table-wrapper">
        <el-table v-loading="loading || overviewLoading" :data="list" height="100%" border>
          <el-table-column label="渠道名称" min-width="170" fixed>
            <template #default="{ row }">
              <el-button link type="primary" @click="showDetail(row as MarketingChannel)">
                {{ row.name }}
              </el-button>
            </template>
          </el-table-column>
          <el-table-column label="渠道编码" prop="code" min-width="140" />
          <el-table-column label="类型" width="110" align="center">
            <template #default="{ row }">{{ channelTypeLabel(row.channelType) }}</template>
          </el-table-column>
          <el-table-column label="联系人" prop="contactName" width="110" />
          <el-table-column label="联系电话" prop="contactPhone" min-width="130" />
          <el-table-column label="线索数" width="90" align="right">
            <template #default="{ row }">
              {{ conversionFor(row as MarketingChannel).leadCount ?? 0 }}
            </template>
          </el-table-column>
          <el-table-column label="已转化" width="90" align="right">
            <template #default="{ row }">
              {{ conversionFor(row as MarketingChannel).convertedCount ?? 0 }}
            </template>
          </el-table-column>
          <el-table-column label="状态" width="95" align="center">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'info'">
                {{ row.status === 1 ? "启用" : "停用" }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="更新时间" prop="updateTime" width="170" />
          <el-table-column label="操作" fixed="right" width="170">
            <template #default="{ row }">
              <el-button
                link
                type="primary"
                size="small"
                @click="showDetail(row as MarketingChannel)"
              >
                详情
              </el-button>
              <el-button
                v-hasPerm="'marketing:channel:update'"
                link
                type="primary"
                size="small"
                @click="openEdit(row as MarketingChannel)"
              >
                编辑
              </el-button>
              <el-button
                v-hasPerm="'marketing:channel:delete'"
                link
                type="danger"
                size="small"
                @click="deleteChannel(row as MarketingChannel)"
              >
                删除
              </el-button>
            </template>
          </el-table-column>
          <template #empty>
            <el-empty :description="listError ? '加载失败' : '暂无渠道数据'" />
          </template>
        </el-table>
      </div>

      <pagination
        v-if="total > 0"
        v-model:total="total"
        v-model:page="params.pageNum"
        v-model:limit="params.pageSize"
        @pagination="fetchData"
      />
    </el-card>

    <el-dialog
      v-model="formVisible"
      :title="editingId === undefined ? '新增渠道' : '编辑渠道'"
      width="620px"
      append-to-body
      destroy-on-close
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="96px">
        <el-form-item label="渠道名称" prop="name">
          <el-input v-model="formData.name" maxlength="100" />
        </el-form-item>
        <el-form-item label="渠道编码" prop="code">
          <el-input v-model="formData.code" maxlength="64" />
        </el-form-item>
        <el-form-item label="渠道类型" prop="channelType">
          <el-select v-model="formData.channelType" placeholder="请选择">
            <el-option
              v-for="item in channelTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="联系人" prop="contactName">
          <el-input v-model="formData.contactName" maxlength="60" />
        </el-form-item>
        <el-form-item label="联系电话" prop="contactPhone">
          <el-input v-model="formData.contactPhone" maxlength="32" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input
            v-model="formData.remark"
            type="textarea"
            :rows="3"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button :loading="saving" @click="formVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitForm">保存</el-button>
      </template>
    </el-dialog>

    <el-drawer v-model="detailVisible" title="渠道详情" size="min(560px, 100vw)" append-to-body>
      <el-descriptions v-if="activeChannel" :column="1" border>
        <el-descriptions-item label="渠道名称">{{ activeChannel.name }}</el-descriptions-item>
        <el-descriptions-item label="渠道编码">{{ activeChannel.code }}</el-descriptions-item>
        <el-descriptions-item label="渠道类型">
          {{ channelTypeLabel(activeChannel.channelType) }}
        </el-descriptions-item>
        <el-descriptions-item label="联系人">
          {{ activeChannel.contactName || "-" }}
        </el-descriptions-item>
        <el-descriptions-item label="联系电话">
          {{ activeChannel.contactPhone || "-" }}
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          {{ activeChannel.status === 1 ? "启用" : "停用" }}
        </el-descriptions-item>
        <el-descriptions-item label="累计线索">
          {{ conversionFor(activeChannel).leadCount ?? 0 }}
        </el-descriptions-item>
        <el-descriptions-item label="已转化线索">
          {{ conversionFor(activeChannel).convertedCount ?? 0 }}
        </el-descriptions-item>
        <el-descriptions-item label="备注">{{ activeChannel.remark || "-" }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">
          {{ activeChannel.updateTime || "-" }}
        </el-descriptions-item>
      </el-descriptions>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
import { Plus, Refresh } from "@element-plus/icons-vue";

import MarketingAPI from "@/api/marketing";
import type {
  MarketingChannel,
  MarketingChannelForm,
  MarketingChannelQueryParams,
  MarketingOverview,
} from "@/api/marketing";
import { channelTypeOptions, getOptionLabel } from "../options";

defineOptions({ name: "MarketingChannels", inheritAttrs: false });

const list = ref<MarketingChannel[]>([]);
const total = ref(0);
const loading = ref(false);
const listError = ref("");
const params = reactive<MarketingChannelQueryParams>({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  channelType: undefined,
  status: undefined,
});
const overview = ref<MarketingOverview>({
  leadTotal: 0,
  newLeadCount: 0,
  pendingFollowUpCount: 0,
  visitCount: 0,
  intentionCount: 0,
  convertedCount: 0,
  channelConversion: [],
});
const overviewLoading = ref(false);
const overviewError = ref("");
const conversionStats = computed(() => overview.value.channelConversion ?? []);

const formVisible = ref(false);
const saving = ref(false);
const formRef = ref<FormInstance>();
const editingId = ref<string | number>();
const initialForm: MarketingChannelForm = {
  code: "",
  name: "",
  channelType: "ONLINE",
  status: 1,
  contactName: "",
  contactPhone: "",
  remark: "",
};
const formData = reactive<MarketingChannelForm>({ ...initialForm });
const rules: FormRules<MarketingChannelForm> = {
  name: [{ required: true, message: "请输入渠道名称", trigger: "blur" }],
  code: [{ required: true, message: "请输入渠道编码", trigger: "blur" }],
  channelType: [{ required: true, message: "请选择渠道类型", trigger: "change" }],
};

const detailVisible = ref(false);
const activeChannel = ref<MarketingChannel>();

function errorText(error: unknown): string {
  return error instanceof Error ? error.message : "请求失败，请重试";
}

async function fetchData(): Promise<void> {
  loading.value = true;
  listError.value = "";
  try {
    const result = await MarketingAPI.getChannelPage(params);
    list.value = result.list ?? [];
    total.value = result.total ?? 0;
  } catch (error) {
    listError.value = errorText(error);
  } finally {
    loading.value = false;
  }
}

async function fetchOverview(): Promise<void> {
  overviewLoading.value = true;
  overviewError.value = "";
  try {
    overview.value = await MarketingAPI.getOverview();
  } catch (error) {
    overviewError.value = errorText(error);
  } finally {
    overviewLoading.value = false;
  }
}

function handleQuery(): void {
  params.pageNum = 1;
  fetchData();
}

function resetQuery(): void {
  Object.assign(params, {
    pageNum: 1,
    pageSize: 10,
    keyword: "",
    channelType: undefined,
    status: undefined,
  });
  fetchData();
}

function channelTypeLabel(value?: string): string {
  return String(getOptionLabel(channelTypeOptions, value));
}

function conversionFor(
  channel: MarketingChannel
): Partial<MarketingOverview["channelConversion"][number]> {
  return conversionStats.value.find((item) => String(item.channelId) === String(channel.id)) ?? {};
}

function resetForm(): void {
  formRef.value?.clearValidate();
  Object.assign(formData, initialForm);
  editingId.value = undefined;
}

function openCreate(): void {
  resetForm();
  formVisible.value = true;
}

function openEdit(channel: MarketingChannel): void {
  resetForm();
  editingId.value = channel.id;
  Object.assign(formData, {
    code: channel.code,
    name: channel.name,
    channelType: channel.channelType,
    contactName: channel.contactName ?? "",
    contactPhone: channel.contactPhone ?? "",
    status: channel.status,
    remark: channel.remark ?? "",
  });
  formVisible.value = true;
}

function showDetail(channel: MarketingChannel): void {
  activeChannel.value = channel;
  detailVisible.value = true;
}

async function submitForm(): Promise<void> {
  const valid = await formRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;
  saving.value = true;
  try {
    if (editingId.value !== undefined) {
      await MarketingAPI.updateChannel(editingId.value, formData);
      ElMessage.success("渠道已更新");
    } else {
      await MarketingAPI.createChannel(formData);
      ElMessage.success("渠道已创建");
    }
    formVisible.value = false;
    await Promise.all([fetchData(), fetchOverview()]);
  } finally {
    saving.value = false;
  }
}

async function deleteChannel(channel: MarketingChannel): Promise<void> {
  if (channel.id === undefined) return;
  try {
    await ElMessageBox.confirm(`确认删除渠道“${channel.name}”吗？`, "删除渠道", {
      type: "warning",
      confirmButtonText: "删除",
      cancelButtonText: "取消",
    });
  } catch {
    return;
  }
  await MarketingAPI.deleteChannel(channel.id);
  ElMessage.success("渠道已删除");
  await Promise.all([fetchData(), fetchOverview()]);
}

onMounted(() => {
  fetchData();
  fetchOverview();
});
</script>

<style lang="scss" scoped>
.marketing-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 0;
}

.page-alert {
  margin-bottom: 8px;
}

.page-table-wrapper {
  min-height: 320px;
}
</style>
