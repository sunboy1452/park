<!-- @page-id: marketing-leads -->
<!-- @page-name: 招商线索 -->
<!-- @page-route: /marketing/leads -->
<template>
  <div class="page-container marketing-page">
    <el-row :gutter="12" class="summary-row">
      <el-col v-for="item in summaryItems" :key="item.label" :xs="12" :sm="8" :lg="4">
        <el-card shadow="never" class="summary-item" v-loading="overviewLoading">
          <span class="summary-item__label">{{ item.label }}</span>
          <strong class="summary-item__value">{{ item.value }}</strong>
        </el-card>
      </el-col>
    </el-row>

    <el-alert
      v-if="overviewError"
      class="page-alert"
      type="error"
      :title="overviewError"
      show-icon
      :closable="false"
    >
      <template #default>
        <el-button link type="primary" @click="fetchOverview">重试</el-button>
      </template>
    </el-alert>
    <el-alert
      v-if="optionsError"
      class="page-alert"
      type="warning"
      :title="optionsError"
      show-icon
      :closable="false"
    >
      <template #default>
        <el-button link type="primary" @click="loadOptions">重试</el-button>
      </template>
    </el-alert>

    <el-card class="page-search" shadow="never">
      <el-form :model="params" inline @submit.prevent="handleQuery">
        <el-form-item label="关键字">
          <el-input
            v-model="params.keyword"
            placeholder="客户、企业、联系人或电话"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="渠道">
          <el-select v-model="params.channelId" placeholder="全部渠道" clearable filterable>
            <el-option
              v-for="channel in channelOptions"
              :key="String(channel.id)"
              :label="channel.name"
              :value="channel.id as string | number"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="阶段">
          <el-select v-model="params.stage" placeholder="全部阶段" clearable>
            <el-option
              v-for="stage in leadStageOptions"
              :key="stage.value"
              :label="stage.label"
              :value="stage.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="负责人">
          <el-select v-model="params.assigneeId" placeholder="全部负责人" clearable filterable>
            <el-option
              v-for="user in userOptions"
              :key="String(user.value)"
              :label="user.label"
              :value="user.value"
            />
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
          <el-button v-hasPerm="'marketing:lead:create'" type="primary" @click="openCreate">
            <el-icon><Plus /></el-icon>
            新增线索
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

      <div class="page-table-wrapper">
        <el-table v-loading="loading" :data="list" height="100%" border>
          <el-table-column label="客户 / 企业" min-width="190" fixed>
            <template #default="{ row }">
              <div class="lead-customer">
                <strong>{{ row.customerName || row.companyName || "未命名客户" }}</strong>
                <span v-if="row.companyName && row.customerName">{{ row.companyName }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="联系人" prop="contactName" width="110" />
          <el-table-column label="联系电话" prop="phone" min-width="130" />
          <el-table-column label="来源渠道" prop="channelName" min-width="130" />
          <el-table-column label="项目 / 房源" min-width="190" show-overflow-tooltip>
            <template #default="{ row }">
              {{ formatLeadSpace(row as MarketingLead) }}
            </template>
          </el-table-column>
          <el-table-column label="意向面积" width="110" align="right">
            <template #default="{ row }">{{ formatArea(row.intendedArea) }}</template>
          </el-table-column>
          <el-table-column label="阶段" width="110" align="center">
            <template #default="{ row }">
              <el-tag :type="stageOption(row.stage).type" effect="light">
                {{ stageOption(row.stage).label }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="负责人" prop="assigneeName" width="120" />
          <el-table-column label="更新时间" prop="updateTime" width="170" />
          <el-table-column label="操作" fixed="right" width="240">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="openDetail(row as MarketingLead)">
                详情
              </el-button>
              <el-button
                v-hasPerm="'marketing:lead:update'"
                link
                type="primary"
                size="small"
                @click="openEdit(row as MarketingLead)"
              >
                编辑
              </el-button>
              <el-button
                v-hasPerm="'marketing:lead:delete'"
                link
                type="danger"
                size="small"
                @click="deleteLead(row as MarketingLead)"
              >
                删除
              </el-button>
            </template>
          </el-table-column>
          <template #empty>
            <el-empty :description="listError ? '加载失败' : '暂无线索数据'" />
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
      :title="editingId === undefined ? '新增线索' : '编辑线索'"
      width="760px"
      append-to-body
      destroy-on-close
      @closed="resetLeadForm"
    >
      <el-form ref="leadFormRef" :model="formData" :rules="leadRules" label-width="100px">
        <el-row :gutter="16">
          <el-col :xs="24" :sm="12">
            <el-form-item label="客户名称" prop="customerName">
              <el-input v-model="formData.customerName" maxlength="100" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="企业名称" prop="companyName">
              <el-input v-model="formData.companyName" maxlength="150" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="联系人" prop="contactName">
              <el-input v-model="formData.contactName" maxlength="60" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="联系电话" prop="phone">
              <el-input v-model="formData.phone" maxlength="32" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="电子邮箱" prop="email">
              <el-input v-model="formData.email" maxlength="120" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="来源渠道" prop="channelId">
              <el-select v-model="formData.channelId" filterable clearable placeholder="请选择渠道">
                <el-option
                  v-for="channel in channelOptions"
                  :key="String(channel.id)"
                  :label="channel.name"
                  :value="channel.id as string | number"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="关联房源" prop="spaceId">
              <el-select
                v-model="formData.spaceId"
                clearable
                filterable
                placeholder="可选"
                @change="handleSpaceChange"
              >
                <el-option
                  v-for="space in spaceOptions"
                  :key="String(space.id)"
                  :label="formatSpace(space)"
                  :value="space.id as string | number"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="项目名称" prop="projectName">
              <el-input v-model="formData.projectName" maxlength="120" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="意向阶段" prop="stage">
              <el-select v-model="formData.stage">
                <el-option
                  v-for="stage in leadStageOptions"
                  :key="stage.value"
                  :label="stage.label"
                  :value="stage.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="意向面积" prop="intendedArea">
              <el-input-number
                v-model="formData.intendedArea"
                :min="0"
                :precision="2"
                controls-position="right"
              />
              <span class="unit-label">m²</span>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="预算" prop="budget">
              <el-input-number
                v-model="formData.budget"
                :min="0"
                :precision="2"
                controls-position="right"
              />
              <span class="unit-label">元</span>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="负责人" prop="assigneeId">
              <el-select v-model="formData.assigneeId" clearable filterable placeholder="待分配">
                <el-option
                  v-for="user in userOptions"
                  :key="String(user.value)"
                  :label="user.label"
                  :value="user.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input
                v-model="formData.remark"
                type="textarea"
                :rows="3"
                maxlength="500"
                show-word-limit
              />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button :loading="saving" @click="formVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitLead">保存</el-button>
      </template>
    </el-dialog>

    <el-drawer v-model="detailVisible" title="线索详情" size="min(680px, 100vw)" append-to-body>
      <template v-if="activeLead">
        <el-descriptions :column="2" border class="detail-block">
          <el-descriptions-item label="客户名称">
            {{ activeLead.customerName || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="企业名称">
            {{ activeLead.companyName || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="联系人">
            {{ activeLead.contactName || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="联系电话">
            {{ activeLead.phone || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="电子邮箱">
            {{ activeLead.email || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="来源渠道">
            {{ activeLead.channelName || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="项目 / 房源" :span="2">
            {{ formatLeadSpace(activeLead) }}
          </el-descriptions-item>
          <el-descriptions-item label="意向面积">
            {{ formatArea(activeLead.intendedArea) }}
          </el-descriptions-item>
          <el-descriptions-item label="预算">
            {{ formatBudget(activeLead.budget) }}
          </el-descriptions-item>
          <el-descriptions-item label="阶段">
            <el-tag :type="stageOption(activeLead.stage).type">
              {{ stageOption(activeLead.stage).label }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="创建时间">
            {{ activeLead.createTime || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">
            {{ activeLead.remark || "-" }}
          </el-descriptions-item>
        </el-descriptions>

        <section class="detail-section">
          <div class="detail-section__heading">
            <h3>负责人</h3>
          </div>
          <div class="assignment-row">
            <el-select v-model="assignmentId" placeholder="选择负责人" filterable clearable>
              <el-option
                v-for="user in userOptions"
                :key="String(user.value)"
                :label="user.label"
                :value="user.value"
              />
            </el-select>
            <el-button
              v-hasPerm="'marketing:lead:assign'"
              type="primary"
              :loading="assigning"
              @click="assignLead"
            >
              分配
            </el-button>
          </div>
        </section>

        <section class="detail-section">
          <div class="detail-section__heading">
            <h3>跟进记录</h3>
            <el-button
              v-hasPerm="'marketing:follow-up:create'"
              type="primary"
              link
              @click="followUpFormVisible = !followUpFormVisible"
            >
              {{ followUpFormVisible ? "收起" : "新增跟进" }}
            </el-button>
          </div>

          <el-alert
            v-if="followUpError"
            type="error"
            :title="followUpError"
            :closable="false"
            show-icon
          >
            <template #default>
              <el-button link type="primary" @click="fetchFollowUps">重试</el-button>
            </template>
          </el-alert>

          <el-form
            v-if="followUpFormVisible"
            ref="followUpFormRef"
            :model="followUpForm"
            :rules="followUpRules"
            label-position="top"
            class="follow-up-form"
          >
            <el-form-item label="跟进方式" prop="followType">
              <el-select v-model="followUpForm.followType">
                <el-option label="电话" value="CALL" />
                <el-option label="拜访" value="VISIT" />
                <el-option label="邮件" value="EMAIL" />
                <el-option label="其他" value="OTHER" />
              </el-select>
            </el-form-item>
            <el-form-item label="跟进内容" prop="content">
              <el-input v-model="followUpForm.content" type="textarea" :rows="3" maxlength="1000" />
            </el-form-item>
            <el-form-item label="下次跟进时间" prop="nextFollowAt">
              <el-date-picker
                v-model="followUpForm.nextFollowAt"
                type="datetime"
                value-format="YYYY-MM-DD HH:mm:ss"
                placeholder="可选"
                style="width: 100%"
              />
            </el-form-item>
            <div class="follow-up-form__actions">
              <el-button :loading="followUpSaving" type="primary" @click="submitFollowUp">
                保存跟进
              </el-button>
            </div>
          </el-form>

          <el-timeline
            v-if="followUpsLoading || followUps.length"
            v-loading="followUpsLoading"
            class="follow-up-timeline"
          >
            <el-timeline-item
              v-for="item in followUps"
              :key="String(item.id ?? `${item.createTime}-${item.content}`)"
              :timestamp="item.createTime || item.nextFollowAt || '时间未记录'"
              placement="top"
              type="primary"
            >
              <div class="follow-up-item__meta">
                <strong>{{ followTypeLabel(item.followType) }}</strong>
              </div>
              <p>{{ item.content || "-" }}</p>
              <small v-if="item.nextFollowAt">下次跟进：{{ item.nextFollowAt }}</small>
            </el-timeline-item>
          </el-timeline>
          <el-empty
            v-if="!followUpsLoading && !followUpError && !followUps.length"
            description="暂无跟进记录"
          />
          <el-pagination
            v-if="followUpsTotal > followUpParams.pageSize"
            v-model:current-page="followUpParams.pageNum"
            :page-size="followUpParams.pageSize"
            :total="followUpsTotal"
            layout="prev, pager, next, total"
            small
            @current-change="fetchFollowUps"
          />
        </section>
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import {
  ElMessage,
  ElMessageBox,
  type FormInstance,
  type FormRules,
  type TagProps,
} from "element-plus";
import { Plus, Refresh } from "@element-plus/icons-vue";

import type { OptionItem } from "@/api/common";
import MarketingAPI from "@/api/marketing";
import type {
  MarketingChannel,
  MarketingFollowUpForm,
  MarketingFollowUpQueryParams,
  MarketingLead,
  MarketingLeadForm,
  MarketingLeadFollowUp,
  MarketingLeadQueryParams,
  MarketingOverview,
  MarketingSpace,
} from "@/api/marketing";
import UserAPI from "@/api/system/user";
import { leadStageOptions } from "../options";

defineOptions({ name: "MarketingLeads", inheritAttrs: false });

const list = ref<MarketingLead[]>([]);
const total = ref(0);
const loading = ref(false);
const listError = ref("");
const params = reactive<MarketingLeadQueryParams>({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  stage: undefined,
  channelId: undefined,
  assigneeId: undefined,
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
const summaryItems = computed(() => [
  { label: "累计线索", value: overview.value.leadTotal ?? 0 },
  { label: "新线索", value: overview.value.newLeadCount ?? 0 },
  { label: "待跟进", value: overview.value.pendingFollowUpCount ?? 0 },
  { label: "已带看", value: overview.value.visitCount ?? 0 },
  { label: "意向客户", value: overview.value.intentionCount ?? 0 },
  { label: "已转化", value: overview.value.convertedCount ?? 0 },
]);

const channelOptions = ref<MarketingChannel[]>([]);
const spaceOptions = ref<MarketingSpace[]>([]);
const userOptions = ref<OptionItem[]>([]);
const optionsError = ref("");
const formVisible = ref(false);
const saving = ref(false);
const leadFormRef = ref<FormInstance>();
const editingId = ref<string | number>();
const initialLeadForm: MarketingLeadForm = { customerName: "", phone: "", stage: "NEW" };
const formData = reactive<MarketingLeadForm>({ ...initialLeadForm });
const leadRules: FormRules<MarketingLeadForm> = {
  customerName: [{ required: true, message: "请输入客户名称", trigger: "blur" }],
  phone: [{ required: true, message: "请输入联系电话", trigger: "blur" }],
  stage: [{ required: true, message: "请选择意向阶段", trigger: "change" }],
};

const detailVisible = ref(false);
const activeLead = ref<MarketingLead>();
const assignmentId = ref<string | number>();
const assigning = ref(false);
const followUps = ref<MarketingLeadFollowUp[]>([]);
const followUpsTotal = ref(0);
const followUpParams = reactive<MarketingFollowUpQueryParams>({ pageNum: 1, pageSize: 10 });
const followUpsLoading = ref(false);
const followUpError = ref("");
const followUpFormVisible = ref(false);
const followUpSaving = ref(false);
const followUpFormRef = ref<FormInstance>();
const followUpForm = reactive<MarketingFollowUpForm>({ followType: "CALL", content: "" });
const followUpRules: FormRules<MarketingFollowUpForm> = {
  followType: [{ required: true, message: "请选择跟进方式", trigger: "change" }],
  content: [{ required: true, message: "请输入跟进内容", trigger: "blur" }],
};

function errorText(error: unknown): string {
  return error instanceof Error ? error.message : "请求失败，请重试";
}

async function fetchData(): Promise<void> {
  loading.value = true;
  listError.value = "";
  try {
    const result = await MarketingAPI.getLeadPage(params);
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
    stage: undefined,
    channelId: undefined,
    assigneeId: undefined,
  });
  fetchData();
}

async function loadOptions(): Promise<void> {
  optionsError.value = "";
  const [channels, spaces, users] = await Promise.allSettled([
    MarketingAPI.getChannelPage({ pageNum: 1, pageSize: 200, status: 1 }),
    MarketingAPI.getSpacePage({ pageNum: 1, pageSize: 200 }),
    UserAPI.getOptions(),
  ]);
  const errors: string[] = [];
  if (channels.status === "fulfilled") channelOptions.value = channels.value.list ?? [];
  else errors.push(`渠道选项：${errorText(channels.reason)}`);
  if (spaces.status === "fulfilled") spaceOptions.value = spaces.value.list ?? [];
  else errors.push(`房源选项：${errorText(spaces.reason)}`);
  if (users.status === "fulfilled") userOptions.value = users.value ?? [];
  else errors.push(`负责人选项：${errorText(users.reason)}`);
  optionsError.value = errors.join("；");
}

function stageOption(value?: string) {
  return (
    leadStageOptions.find((option) => option.value === value) ?? {
      label: value || "未设置",
      type: "info" as TagProps["type"],
    }
  );
}

function formatSpace(item: MarketingSpace): string {
  const location = [item.projectName, item.buildingName, item.floorName, item.roomNo]
    .filter(Boolean)
    .join(" / ");
  return location || item.spaceCode || "未关联房源";
}

function formatLeadSpace(lead: MarketingLead): string {
  const space = spaceOptions.value.find((item) => String(item.id) === String(lead.spaceId));
  return (space && formatSpace(space)) || lead.projectName || "未关联房源";
}

function formatArea(value?: number): string {
  return value === undefined || value === null ? "-" : `${value} m²`;
}

function formatBudget(value?: number): string {
  return value === undefined || value === null ? "-" : `${value.toLocaleString()} 元`;
}

function followTypeLabel(value?: string): string {
  const labels: Record<string, string> = {
    CALL: "电话",
    VISIT: "拜访",
    EMAIL: "邮件",
    OTHER: "其他",
  };
  return value ? (labels[value] ?? value) : "跟进";
}

function resetLeadForm(): void {
  leadFormRef.value?.clearValidate();
  Object.keys(formData).forEach((key) => delete (formData as Record<string, unknown>)[key]);
  Object.assign(formData, initialLeadForm);
  editingId.value = undefined;
}

function openCreate(): void {
  resetLeadForm();
  formVisible.value = true;
}

function openEdit(row: MarketingLead): void {
  resetLeadForm();
  editingId.value = row.id;
  Object.assign(formData, {
    customerName: row.customerName,
    companyName: row.companyName,
    contactName: row.contactName,
    phone: row.phone,
    email: row.email,
    channelId: row.channelId,
    projectName: row.projectName,
    spaceId: row.spaceId,
    intendedArea: row.intendedArea,
    budget: row.budget,
    stage: row.stage || "NEW",
    assigneeId: row.assigneeId,
    remark: row.remark,
  });
  formVisible.value = true;
}

function handleSpaceChange(spaceId?: string | number): void {
  const space = spaceOptions.value.find((item) => String(item.id) === String(spaceId));
  if (space) formData.projectName = space.projectName;
}

async function submitLead(): Promise<void> {
  const valid = await leadFormRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;

  saving.value = true;
  try {
    if (editingId.value !== undefined) {
      await MarketingAPI.updateLead(editingId.value, formData);
      ElMessage.success("线索已更新");
    } else {
      await MarketingAPI.createLead(formData);
      ElMessage.success("线索已创建");
    }
    formVisible.value = false;
    await Promise.all([fetchData(), fetchOverview()]);
  } finally {
    saving.value = false;
  }
}

async function deleteLead(row: MarketingLead): Promise<void> {
  if (row.id === undefined) return;
  try {
    await ElMessageBox.confirm(
      `确认删除“${row.customerName || row.companyName || "该线索"}”吗？`,
      "删除线索",
      {
        type: "warning",
        confirmButtonText: "删除",
        cancelButtonText: "取消",
      }
    );
  } catch {
    return;
  }
  await MarketingAPI.deleteLead(row.id);
  ElMessage.success("线索已删除");
  await Promise.all([fetchData(), fetchOverview()]);
}

async function openDetail(row: MarketingLead): Promise<void> {
  activeLead.value = row;
  assignmentId.value = row.assigneeId;
  followUps.value = [];
  followUpParams.pageNum = 1;
  followUpsTotal.value = 0;
  followUpError.value = "";
  followUpFormVisible.value = false;
  detailVisible.value = true;
  await fetchFollowUps();
}

async function fetchFollowUps(): Promise<void> {
  if (activeLead.value?.id === undefined) return;
  followUpsLoading.value = true;
  followUpError.value = "";
  try {
    const result = await MarketingAPI.getFollowUps(activeLead.value.id, followUpParams);
    followUps.value = result.list ?? [];
    followUpsTotal.value = result.total ?? 0;
  } catch (error) {
    followUpError.value = errorText(error);
  } finally {
    followUpsLoading.value = false;
  }
}

async function assignLead(): Promise<void> {
  if (activeLead.value?.id === undefined) return;
  assigning.value = true;
  try {
    await MarketingAPI.assignLead(activeLead.value.id, assignmentId.value ?? null);
    const user = userOptions.value.find(
      (option) => String(option.value) === String(assignmentId.value)
    );
    activeLead.value.assigneeId = assignmentId.value;
    activeLead.value.assigneeName = user?.label;
    ElMessage.success(assignmentId.value === undefined ? "负责人已清除" : "线索已分配");
    await fetchData();
  } finally {
    assigning.value = false;
  }
}

async function submitFollowUp(): Promise<void> {
  if (activeLead.value?.id === undefined) return;
  const valid = await followUpFormRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;
  followUpSaving.value = true;
  try {
    await MarketingAPI.createFollowUp(activeLead.value.id, followUpForm);
    ElMessage.success("跟进已记录");
    Object.assign(followUpForm, { followType: "CALL", content: "", nextFollowAt: undefined });
    followUpFormRef.value?.clearValidate();
    followUpParams.pageNum = 1;
    await Promise.all([fetchFollowUps(), fetchData(), fetchOverview()]);
  } finally {
    followUpSaving.value = false;
  }
}

onMounted(() => {
  fetchData();
  fetchOverview();
  loadOptions();
});
</script>

<style lang="scss" scoped>
.marketing-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 0;
}

.summary-row {
  row-gap: 12px;
}

.summary-item {
  min-height: 80px;

  :deep(.el-card__body) {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 14px 16px;
  }

  &__label {
    color: var(--el-text-color-secondary);
    font-size: 13px;
  }

  &__value {
    color: var(--el-text-color-primary);
    font-size: 22px;
    font-weight: 600;
  }
}

.page-alert {
  margin-bottom: 0;
}

.page-table-wrapper {
  min-height: 280px;
}

.lead-customer {
  display: flex;
  flex-direction: column;
  gap: 3px;
  min-width: 0;

  strong,
  span {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  span {
    color: var(--el-text-color-secondary);
    font-size: 12px;
  }
}

.unit-label {
  margin-left: 8px;
  color: var(--el-text-color-secondary);
}

.detail-block {
  margin-bottom: 24px;
}

.detail-section {
  margin-top: 24px;

  &__heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;

    h3 {
      margin: 0;
      font-size: 15px;
      font-weight: 600;
    }
  }
}

.assignment-row {
  display: flex;
  gap: 8px;

  .el-select {
    flex: 1;
    min-width: 0;
  }
}

.follow-up-form {
  padding: 14px;
  margin-bottom: 18px;
  background: var(--el-fill-color-lighter);
  border-radius: 6px;

  &__actions {
    display: flex;
    justify-content: flex-end;
  }
}

.follow-up-timeline {
  padding: 8px 4px 0;

  p {
    margin: 8px 0;
    white-space: pre-wrap;
    overflow-wrap: anywhere;
  }

  small {
    color: var(--el-text-color-secondary);
  }
}

.follow-up-item__meta {
  display: flex;
  justify-content: space-between;
  gap: 10px;

  span {
    color: var(--el-text-color-secondary);
  }
}

@media (max-width: 768px) {
  .page-table-wrapper {
    min-height: 360px;
  }
}
</style>
