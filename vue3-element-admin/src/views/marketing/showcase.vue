<!-- @page-id: marketing-showcase -->
<!-- @page-name: 园区房源展示 -->
<!-- @page-route: /showcase -->
<template>
  <main class="showcase-page">
    <header class="showcase-header">
      <div class="showcase-header__inner">
        <div class="showcase-brand">
          <span class="showcase-brand__mark" aria-hidden="true">园</span>
          <span>园区招商</span>
        </div>
        <h1>可租房源</h1>
        <p>查看园区空间与 VR 实景</p>
      </div>
    </header>

    <section class="showcase-content" aria-label="房源列表">
      <div class="showcase-toolbar">
        <el-form :model="params" inline @submit.prevent="handleQuery">
          <el-form-item label="房源">
            <el-input
              v-model="params.keyword"
              placeholder="项目、楼栋、房号或标题"
              clearable
              @keyup.enter="handleQuery"
            />
          </el-form-item>
          <el-form-item label="项目">
            <el-input
              v-model="params.projectName"
              placeholder="输入项目名称"
              clearable
              @keyup.enter="handleQuery"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleQuery">搜索</el-button>
            <el-button @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>
        <el-button
          class="refresh-button"
          aria-label="刷新房源"
          :loading="loading"
          @click="fetchData"
        >
          <el-icon><Refresh /></el-icon>
        </el-button>
      </div>

      <el-alert
        v-if="listError"
        class="showcase-error"
        type="error"
        :title="listError"
        show-icon
        :closable="false"
      >
        <template #default>
          <el-button link type="primary" @click="fetchData">重试</el-button>
        </template>
      </el-alert>

      <el-row v-loading="loading" :gutter="16" class="space-grid">
        <el-col v-for="space in spaces" :key="String(space.id)" :xs="24" :sm="12" :lg="8">
          <article class="space-card">
            <el-image
              v-if="space.coverUrl"
              :src="space.coverUrl"
              :alt="space.displayTitle || locationTitle(space)"
              fit="cover"
              class="space-card__image"
              lazy
            >
              <template #error>
                <div class="space-card__image-fallback">房源图片暂不可用</div>
              </template>
            </el-image>
            <div v-else class="space-card__image-fallback">暂无房源图片</div>
            <div class="space-card__body">
              <div class="space-card__title-row">
                <h2>{{ space.displayTitle || locationTitle(space) }}</h2>
                <el-tag type="success" size="small">可租</el-tag>
              </div>
              <p class="space-card__location">{{ locationTitle(space) }}</p>
              <div class="space-card__facts">
                <span>{{ areaLabel(space.area) }}</span>
                <strong>{{ priceLabel(space.rentUnitPrice) }}</strong>
              </div>
              <p class="space-card__description">{{ space.description || "暂无房源介绍" }}</p>
              <div class="space-card__actions">
                <el-button type="primary" @click="openDetail(space)">查看详情</el-button>
                <el-button v-if="space.vrUrl" @click="openExternal(space.vrUrl)">
                  <el-icon><View /></el-icon>
                  VR 实景
                </el-button>
              </div>
            </div>
          </article>
        </el-col>
      </el-row>

      <el-empty
        v-if="!loading && !listError && spaces.length === 0"
        description="暂无符合条件的房源"
      />

      <div v-if="total > 0" class="showcase-pagination">
        <el-pagination
          v-model:current-page="params.pageNum"
          v-model:page-size="params.pageSize"
          :total="total"
          :page-sizes="[9, 18, 36]"
          layout="total, sizes, prev, pager, next"
          background
          @current-change="fetchData"
          @size-change="handleSizeChange"
        />
      </div>
    </section>

    <el-drawer v-model="detailVisible" title="房源详情" size="min(760px, 100vw)" append-to-body>
      <div v-loading="detailLoading" class="detail-content">
        <el-alert v-if="detailError" type="error" :title="detailError" show-icon :closable="false">
          <template #default>
            <el-button link type="primary" @click="retryDetail">重试</el-button>
          </template>
        </el-alert>
        <template v-if="detail">
          <el-image
            v-if="detail.coverUrl"
            :src="detail.coverUrl"
            :alt="detail.displayTitle || locationTitle(detail)"
            :preview-src-list="[detail.coverUrl]"
            preview-teleported
            fit="cover"
            class="detail-content__image"
          />
          <div class="detail-content__heading">
            <div>
              <h2>{{ detail.displayTitle || locationTitle(detail) }}</h2>
              <p>{{ locationTitle(detail) }}</p>
            </div>
            <el-tag type="success">可租</el-tag>
          </div>
          <div class="detail-facts">
            <div>
              <span>建筑面积</span>
              <strong>{{ areaLabel(detail.area) }}</strong>
            </div>
            <div>
              <span>租金单价</span>
              <strong>{{ priceLabel(detail.rentUnitPrice) }}</strong>
            </div>
          </div>
          <section v-if="detail.description" class="detail-description">
            <h3>空间介绍</h3>
            <p>{{ detail.description }}</p>
          </section>
          <el-button v-if="detail.vrUrl" type="primary" @click="openExternal(detail.vrUrl)">
            <el-icon><View /></el-icon>
            打开 VR 实景
          </el-button>
        </template>
      </div>
    </el-drawer>
  </main>
</template>

<script setup lang="ts">
import { ElMessage } from "element-plus";
import { Refresh, View } from "@element-plus/icons-vue";

import PublicMarketingAPI, {
  type PublicMarketingSpace,
  type PublicMarketingSpaceQuery,
} from "@/api/marketing/public";

defineOptions({ name: "MarketingShowcase", inheritAttrs: false });

const spaces = ref<PublicMarketingSpace[]>([]);
const total = ref(0);
const loading = ref(false);
const listError = ref("");
const params = reactive<PublicMarketingSpaceQuery>({
  pageNum: 1,
  pageSize: 9,
  keyword: "",
  projectName: "",
});

const detailVisible = ref(false);
const detailLoading = ref(false);
const detailError = ref("");
const detail = ref<PublicMarketingSpace>();
const detailId = ref<string | number>();

function errorText(error: unknown): string {
  return error instanceof Error ? error.message : "请求失败，请重试";
}

async function fetchData(): Promise<void> {
  loading.value = true;
  listError.value = "";
  try {
    const result = await PublicMarketingAPI.getSpacePage(params);
    spaces.value = result.list ?? [];
    total.value = result.total ?? 0;
  } catch (error) {
    listError.value = errorText(error);
  } finally {
    loading.value = false;
  }
}

function handleQuery(): void {
  params.pageNum = 1;
  fetchData();
}

function resetQuery(): void {
  Object.assign(params, { pageNum: 1, pageSize: 9, keyword: "", projectName: "" });
  fetchData();
}

function handleSizeChange(): void {
  params.pageNum = 1;
  fetchData();
}

function locationTitle(space: Partial<PublicMarketingSpace>): string {
  return (
    [space.projectName, space.buildingName, space.floorName, space.roomNo]
      .filter(Boolean)
      .join(" / ") || "房源位置待完善"
  );
}

function areaLabel(area?: number): string {
  return area === undefined || area === null ? "面积待定" : `${area} m²`;
}

function priceLabel(price?: number): string {
  return price === undefined || price === null ? "租金面议" : `${price.toLocaleString()} 元/m²·月`;
}

function openDetail(space: PublicMarketingSpace): void {
  detailId.value = space.id;
  detail.value = undefined;
  detailError.value = "";
  detailVisible.value = true;
  fetchDetail();
}

async function fetchDetail(): Promise<void> {
  if (detailId.value === undefined) return;
  detailLoading.value = true;
  detailError.value = "";
  try {
    detail.value = await PublicMarketingAPI.getSpace(detailId.value);
  } catch (error) {
    detailError.value = errorText(error);
  } finally {
    detailLoading.value = false;
  }
}

function retryDetail(): void {
  fetchDetail();
}

function openExternal(url?: string): void {
  if (!url) return;
  try {
    const target = new URL(url, window.location.origin);
    if (target.protocol !== "http:" && target.protocol !== "https:")
      throw new Error("unsupported protocol");
    window.open(target.href, "_blank", "noopener,noreferrer");
  } catch {
    ElMessage.warning("房源 VR 地址无效");
  }
}

onMounted(fetchData);
</script>

<style lang="scss" scoped>
.showcase-page {
  min-height: 100vh;
  color: var(--el-text-color-primary);
  background: var(--el-bg-color-page);
}

.showcase-header {
  color: #fff;
  background: #1b5146;

  &__inner {
    width: min(1180px, calc(100% - 40px));
    padding: 22px 0 26px;
    margin: 0 auto;
  }

  h1 {
    margin: 20px 0 4px;
    font-size: 26px;
    font-weight: 600;
  }

  p {
    margin: 0;
    color: rgb(255 255 255 / 78%);
    font-size: 14px;
  }
}

.showcase-brand {
  display: flex;
  align-items: center;
  gap: 9px;
  font-size: 14px;
  font-weight: 600;

  &__mark {
    display: grid;
    width: 28px;
    height: 28px;
    place-items: center;
    color: #1b5146;
    background: #d4ecdf;
    border-radius: 6px;
  }
}

.showcase-content {
  width: min(1180px, calc(100% - 40px));
  padding: 22px 0 36px;
  margin: 0 auto;
}

.showcase-toolbar {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  padding-bottom: 4px;

  .el-form {
    display: flex;
    flex-wrap: wrap;
    gap: 0 10px;
  }

  .el-input {
    width: 220px;
  }
}

.refresh-button {
  flex: none;
}

.showcase-error {
  margin: 4px 0 16px;
}

.space-grid {
  min-height: 240px;
  row-gap: 16px;
}

.space-card {
  height: 100%;
  overflow: hidden;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 6px;

  &__image,
  &__image-fallback {
    display: grid;
    width: 100%;
    aspect-ratio: 16 / 9;
  }

  &__image-fallback {
    place-items: center;
    color: var(--el-text-color-secondary);
    background: var(--el-fill-color-light);
  }

  &__body {
    padding: 16px;
  }

  &__title-row {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;

    h2 {
      min-width: 0;
      margin: 0;
      font-size: 17px;
      font-weight: 600;
      line-height: 1.4;
      overflow-wrap: anywhere;
    }
  }

  &__location {
    margin: 7px 0 12px;
    color: var(--el-text-color-secondary);
    font-size: 13px;
    line-height: 1.5;
  }

  &__facts {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 8px;
    padding: 11px 0;
    border-top: 1px solid var(--el-border-color-lighter);
    border-bottom: 1px solid var(--el-border-color-lighter);

    span {
      color: var(--el-text-color-secondary);
      white-space: nowrap;
    }

    strong {
      color: #b64928;
      text-align: right;
      overflow-wrap: anywhere;
    }
  }

  &__description {
    display: -webkit-box;
    min-height: 40px;
    margin: 12px 0;
    overflow: hidden;
    color: var(--el-text-color-regular);
    font-size: 13px;
    line-height: 1.55;
    text-overflow: ellipsis;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 2;
  }

  &__actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;

    .el-button + .el-button {
      margin-left: 0;
    }
  }
}

.showcase-pagination {
  display: flex;
  justify-content: flex-end;
  padding-top: 18px;
}

.detail-content {
  min-height: 160px;

  &__image {
    display: block;
    width: 100%;
    max-height: 360px;
    aspect-ratio: 16 / 9;
    margin-bottom: 18px;
    border-radius: 6px;
  }

  &__heading {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 18px;

    h2 {
      margin: 0;
      font-size: 20px;
      line-height: 1.4;
      overflow-wrap: anywhere;
    }

    p {
      margin: 6px 0 0;
      color: var(--el-text-color-secondary);
    }
  }
}

.detail-facts {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
  padding: 14px;
  margin-bottom: 20px;
  background: var(--el-fill-color-lighter);
  border-radius: 6px;

  div {
    display: flex;
    flex-direction: column;
    gap: 5px;
    min-width: 0;
  }

  span {
    color: var(--el-text-color-secondary);
    font-size: 12px;
  }

  strong {
    overflow-wrap: anywhere;
  }
}

.detail-description {
  margin-bottom: 22px;

  h3 {
    margin: 0 0 8px;
    font-size: 15px;
  }

  p {
    margin: 0;
    line-height: 1.7;
    white-space: pre-wrap;
    overflow-wrap: anywhere;
  }
}

@media (max-width: 768px) {
  .showcase-header__inner,
  .showcase-content {
    width: calc(100% - 28px);
  }

  .showcase-toolbar {
    align-items: flex-start;

    .el-form {
      display: grid;
      grid-template-columns: minmax(0, 1fr);
      width: 100%;
    }

    .el-input {
      width: 100%;
    }
  }

  .showcase-toolbar :deep(.el-form-item) {
    margin-right: 0;
  }

  .refresh-button {
    margin-top: 0;
  }

  .showcase-pagination {
    justify-content: center;
    overflow-x: auto;
  }
}
</style>
