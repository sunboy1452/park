<!-- @page-id: marketing-overview -->
<!-- @page-name: 营销概览 -->
<!-- @page-route: /marketing/overview -->
<template>
  <div class="page-container marketing-overview">
    <header class="overview-header">
      <div>
        <h2>营销概览</h2>
        <p>招商线索与渠道转化</p>
      </div>
      <el-tooltip content="刷新" placement="top">
        <el-button
          class="page-icon-btn"
          :loading="loading"
          aria-label="刷新营销概览"
          @click="fetchOverview"
        >
          <el-icon><Refresh /></el-icon>
        </el-button>
      </el-tooltip>
    </header>

    <el-alert
      v-if="error"
      class="page-alert"
      type="error"
      :title="error"
      show-icon
      :closable="false"
    >
      <template #default>
        <el-button link type="primary" @click="fetchOverview">重试</el-button>
      </template>
    </el-alert>

    <el-row :gutter="12" class="overview-kpis">
      <el-col v-for="item in kpis" :key="item.label" :xs="12" :sm="8" :lg="4">
        <el-card shadow="never" class="overview-kpi" v-loading="loading">
          <span>{{ item.label }}</span>
          <strong>{{ item.value }}</strong>
        </el-card>
      </el-col>
    </el-row>

    <el-card class="page-content" shadow="never">
      <div class="conversion-heading">
        <h3>渠道转化</h3>
      </div>
      <el-table v-loading="loading" :data="overview.channelConversion" border>
        <el-table-column label="渠道名称" prop="channelName" min-width="180" />
        <el-table-column label="线索数" prop="leadCount" width="120" align="right" />
        <el-table-column label="已转化" prop="convertedCount" width="120" align="right" />
        <el-table-column label="转化率" width="130" align="right">
          <template #default="{ row }">
            {{ conversionRate(row.leadCount, row.convertedCount) }}
          </template>
        </el-table-column>
        <template #empty>
          <el-empty :description="error ? '加载失败' : '暂无渠道转化数据'" />
        </template>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ElMessage } from "element-plus";
import { Refresh } from "@element-plus/icons-vue";
import MarketingAPI from "@/api/marketing";
import type { MarketingOverview } from "@/api/marketing";

defineOptions({ name: "MarketingOverview", inheritAttrs: false });

const emptyOverview = (): MarketingOverview => ({
  leadTotal: 0,
  newLeadCount: 0,
  pendingFollowUpCount: 0,
  visitCount: 0,
  intentionCount: 0,
  convertedCount: 0,
  channelConversion: [],
});

const overview = ref<MarketingOverview>(emptyOverview());
const loading = ref(false);
const error = ref("");
const kpis = computed(() => [
  { label: "累计线索", value: overview.value.leadTotal },
  { label: "新线索", value: overview.value.newLeadCount },
  { label: "待跟进", value: overview.value.pendingFollowUpCount },
  { label: "已带看", value: overview.value.visitCount },
  { label: "意向客户", value: overview.value.intentionCount },
  { label: "已转化", value: overview.value.convertedCount },
]);

function errorText(reason: unknown): string {
  return reason instanceof Error ? reason.message : "营销概览加载失败，请重试";
}

function conversionRate(leadCount: number, convertedCount: number): string {
  return leadCount > 0 ? `${((convertedCount / leadCount) * 100).toFixed(1)}%` : "-";
}

async function fetchOverview(): Promise<void> {
  loading.value = true;
  error.value = "";
  try {
    overview.value = await MarketingAPI.getOverview();
  } catch (reason) {
    error.value = errorText(reason);
    ElMessage.error(error.value);
  } finally {
    loading.value = false;
  }
}

onMounted(fetchOverview);
</script>

<style lang="scss" scoped>
.marketing-overview {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 0;
}

.overview-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 42px;

  h2,
  p {
    margin: 0;
  }

  h2 {
    font-size: 18px;
    font-weight: 600;
    line-height: 26px;
  }

  p {
    margin-top: 2px;
    color: var(--el-text-color-secondary);
    font-size: 13px;
  }
}

.overview-kpis {
  row-gap: 12px;
}

.overview-kpi {
  min-height: 96px;

  :deep(.el-card__body) {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  span {
    color: var(--el-text-color-secondary);
    font-size: 13px;
  }

  strong {
    color: var(--el-text-color-primary);
    font-size: 24px;
    font-weight: 600;
    line-height: 28px;
  }
}

.conversion-heading {
  margin-bottom: 12px;

  h3 {
    margin: 0;
    font-size: 15px;
    font-weight: 600;
  }
}
</style>
