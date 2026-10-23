<!-- @page-id: marketing-spaces -->
<!-- @page-name: 房源管理 -->
<!-- @page-route: /building/spaces -->
<template>
  <div class="page-container marketing-page">
    <el-card class="page-search" shadow="never">
      <el-form :model="params" inline @submit.prevent="handleQuery">
        <el-form-item label="关键字">
          <el-input
            v-model="params.keyword"
            class="asset-query-control"
            placeholder="房源编号、楼栋、房号或展示标题"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="项目名称">
          <el-input
            v-model="params.projectName"
            class="asset-query-control"
            placeholder="全部项目"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="园区">
          <el-select v-model="params.parkId" class="asset-query-control" clearable placeholder="全部园区" @change="handleFilterParkChange">
            <el-option v-for="park in parks" :key="park.id" :label="park.name" :value="park.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="楼栋">
          <el-select v-model="params.buildingId" class="asset-query-control" clearable filterable placeholder="全部楼栋" @change="handleQuery">
            <el-option v-for="building in filteredBuildings" :key="building.id" :label="`${building.parkName} / ${building.name}`" :value="building.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="房源状态">
          <el-select v-model="params.availability" class="asset-query-control" placeholder="全部状态" clearable>
            <el-option
              v-for="item in availabilityOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="展示状态">
          <el-select v-model="params.publishStatus" class="asset-query-control" placeholder="全部状态" clearable>
            <el-option
              v-for="item in publishStatusOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
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
          <el-button v-hasPerm="'marketing:space:create'" type="primary" @click="openCreate">
            <el-icon><Plus /></el-icon>
            新增房源
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

      <div class="page-table-wrapper">
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
        <VxeGrid class="page-vxe-grid" v-bind="gridOptions" :data="list" :loading="loading">
          <template #space-cover="{ row }">
            <el-image
              v-if="row.coverUrl"
              :src="row.coverUrl"
              :preview-src-list="[row.coverUrl]"
              preview-teleported
              fit="cover"
              class="space-cover"
            />
            <span v-else class="color-text-placeholder">暂无</span>
          </template>
          <template #space-main="{ row }">
            <div class="space-main">
              <strong>{{ row.displayTitle || row.spaceCode || "未命名房源" }}</strong>
              <span>{{ formatLocation(row) }}</span>
            </div>
          </template>
          <template #space-area="{ row }">{{ row.area === undefined ? "-" : `${row.area} m²` }}</template>
          <template #space-rent="{ row }">{{ row.rentUnitPrice === undefined ? "-" : `${row.rentUnitPrice} 元/m²·月` }}</template>
          <template #space-availability="{ row }">
            <el-tag :type="availabilityOption(row.availability).type">
              {{ availabilityOption(row.availability).label }}
            </el-tag>
          </template>
          <template #space-publish="{ row }">
            <el-tag :type="publishOption(row.publishStatus).type">
              {{ publishOption(row.publishStatus).label }}
            </el-tag>
          </template>
          <template #space-vr="{ row }">
            <el-tooltip v-if="row.vrUrl" content="打开 VR 展示" placement="top">
              <el-button class="page-icon-btn" aria-label="打开 VR 展示" @click="openExternal(row.vrUrl)">
                <el-icon><View /></el-icon>
              </el-button>
            </el-tooltip>
            <span v-else class="color-text-placeholder">-</span>
          </template>
          <template #space-actions="{ row }">
            <el-button link type="primary" size="small" @click="showDetail(row as MarketingSpace)">详情</el-button>
            <el-button v-hasPerm="'marketing:space:update'" link type="primary" size="small" @click="openEdit(row as MarketingSpace)">编辑</el-button>
            <el-button v-hasPerm="'marketing:space:delete'" link type="danger" size="small" @click="deleteSpace(row as MarketingSpace)">删除</el-button>
          </template>
        </VxeGrid>
      </div>

      <pagination
        v-if="total > 0"
        v-model:total="total"
        v-model:page="params.pageNum"
        v-model:limit="params.pageSize"
        class="page-pagination"
        @pagination="fetchData"
      />
    </el-card>

    <el-dialog
      v-model="formVisible"
      :title="editingId === undefined ? '新增房源' : '编辑房源'"
      width="780px"
      append-to-body
      destroy-on-close
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="105px">
        <el-row :gutter="16">
          <el-col :xs="24" :sm="12">
            <el-form-item label="房源编号" prop="spaceCode">
              <el-input v-model="formData.spaceCode" maxlength="80" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="项目名称" prop="projectName">
              <el-input v-model="formData.projectName" maxlength="120" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="园区">
              <el-select v-model="formData.parkId" clearable placeholder="不关联园区" @change="handleFormParkChange">
                <el-option v-for="park in parks" :key="park.id" :label="park.name" :value="park.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="区域">
              <el-select v-model="formData.regionId" clearable :disabled="!regionOptions.length" placeholder="选择区域" @change="handleFormRegionChange">
                <el-option v-for="region in regionOptions" :key="region.id" :label="region.name" :value="region.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="楼栋">
              <el-select v-model="formData.buildingId" clearable filterable :disabled="!formBuildingOptions.length" placeholder="选择楼栋" @change="handleFormBuildingChange">
                <el-option v-for="building in formBuildingOptions" :key="building.id" :label="building.name" :value="building.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="楼层">
              <el-select v-model="formData.floorId" clearable :disabled="!floorOptions.length" placeholder="选择楼层" @change="handleFormFloorChange">
                <el-option v-for="floor in floorOptions" :key="floor.id" :label="floor.floorName" :value="floor.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="房号" prop="roomNo">
              <el-input v-model="formData.roomNo" maxlength="80" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="面积" prop="area">
              <el-input-number
                v-model="formData.area"
                :min="0"
                :precision="2"
                controls-position="right"
              />
              <span class="unit-label">m²</span>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="租金单价" prop="rentUnitPrice">
              <el-input-number
                v-model="formData.rentUnitPrice"
                :min="0"
                :precision="2"
                controls-position="right"
              />
              <span class="unit-label">元/m²·月</span>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="可租状态" prop="availability">
              <el-select v-model="formData.availability">
                <el-option
                  v-for="item in availabilityOptions"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12">
            <el-form-item label="展示状态" prop="publishStatus">
              <el-select v-model="formData.publishStatus">
                <el-option
                  v-for="item in publishStatusOptions"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="展示标题" prop="displayTitle">
              <el-input v-model="formData.displayTitle" maxlength="150" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="房源介绍" prop="description">
              <el-input
                v-model="formData.description"
                type="textarea"
                :rows="4"
                maxlength="2000"
                show-word-limit
              />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="封面图片 URL" prop="coverUrl">
              <el-input v-model="formData.coverUrl" maxlength="500" />
            </el-form-item>
            <el-image
              v-if="formData.coverUrl"
              :src="formData.coverUrl"
              :preview-src-list="[formData.coverUrl]"
              preview-teleported
              fit="cover"
              class="form-cover"
            />
          </el-col>
          <el-col :span="24">
            <el-form-item label="VR 地址" prop="vrUrl">
              <el-input v-model="formData.vrUrl" maxlength="500">
                <template #append>
                  <el-button :disabled="!formData.vrUrl" @click="openExternal(formData.vrUrl)">
                    预览
                  </el-button>
                </template>
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button :loading="saving" @click="formVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitForm">保存</el-button>
      </template>
    </el-dialog>

    <el-drawer v-model="detailVisible" title="房源详情" size="min(760px, 100vw)" append-to-body>
      <template v-if="activeSpace">
        <el-image
          v-if="activeSpace.coverUrl"
          :src="activeSpace.coverUrl"
          :preview-src-list="[activeSpace.coverUrl]"
          preview-teleported
          fit="cover"
          class="detail-cover"
        />
        <el-descriptions :column="2" border>
          <el-descriptions-item label="展示标题" :span="2">
            {{ activeSpace.displayTitle || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="房源编号">
            {{ activeSpace.spaceCode || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="项目">
            {{ activeSpace.projectName || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="楼栋 / 楼层 / 房号" :span="2">
            {{ formatLocation(activeSpace) }}
          </el-descriptions-item>
          <el-descriptions-item label="面积">
            {{ activeSpace.area === undefined ? "-" : `${activeSpace.area} m²` }}
          </el-descriptions-item>
          <el-descriptions-item label="租金单价">
            {{
              activeSpace.rentUnitPrice === undefined
                ? "-"
                : `${activeSpace.rentUnitPrice} 元/m²·月`
            }}
          </el-descriptions-item>
          <el-descriptions-item label="可租状态">
            <el-tag :type="availabilityOption(activeSpace.availability).type">
              {{ availabilityOption(activeSpace.availability).label }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="展示状态">
            <el-tag :type="publishOption(activeSpace.publishStatus).type">
              {{ publishOption(activeSpace.publishStatus).label }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="房源介绍" :span="2">
            <div class="space-description">{{ activeSpace.description || "-" }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="VR 展示" :span="2">
            <el-button
              v-if="activeSpace.vrUrl"
              type="primary"
              link
              @click="openExternal(activeSpace.vrUrl)"
            >
              打开 VR
            </el-button>
            <span v-else>-</span>
          </el-descriptions-item>
        </el-descriptions>
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
import { Plus, Refresh, View } from "@element-plus/icons-vue";
import { VxeGrid } from "vxe-table";
import type { VxeGridProps } from "vxe-table";

import MarketingAPI from "@/api/marketing";
import AssetAPI, { type AssetBuildingOption, type AssetFloor, type AssetPark, type AssetRegion } from "@/api/asset";
import { configureVxeUI } from "@/plugins/vxe-table";
import type {
  MarketingSpace,
  MarketingSpaceForm,
  MarketingSpaceQueryParams,
} from "@/api/marketing";
import { availabilityOptions, publishStatusOptions } from "../options";

defineOptions({ name: "MarketingSpaces", inheritAttrs: false });
configureVxeUI();

const list = ref<MarketingSpace[]>([]);
const total = ref(0);
const loading = ref(false);
const listError = ref("");
const params = reactive<MarketingSpaceQueryParams>({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  projectName: "",
  parkId: undefined,
  buildingId: undefined,
  availability: undefined,
  publishStatus: undefined,
});
const parks = ref<AssetPark[]>([]);
const buildingOptions = ref<AssetBuildingOption[]>([]);
const regionOptions = ref<AssetRegion[]>([]);
const floorOptions = ref<AssetFloor[]>([]);
const filteredBuildings = computed(() =>
  buildingOptions.value.filter((building) => !params.parkId || building.parkId === params.parkId)
);
const gridOptions = computed<VxeGridProps<MarketingSpace>>(() => ({
  columns: [
    { field: "coverUrl", title: "封面", width: 94, slots: { default: "space-cover" } },
    { field: "displayTitle", title: "房源", minWidth: 220, fixed: "left", slots: { default: "space-main" } },
    { field: "projectName", title: "项目", minWidth: 130 },
    { field: "spaceCode", title: "房源编号", minWidth: 180, showOverflow: "tooltip" },
    { field: "area", title: "面积", width: 100, align: "right", slots: { default: "space-area" } },
    { field: "rentUnitPrice", title: "租金单价", width: 140, align: "right", slots: { default: "space-rent" } },
    { field: "availability", title: "可租状态", width: 110, slots: { default: "space-availability" } },
    { field: "publishStatus", title: "展示状态", width: 100, slots: { default: "space-publish" } },
    { field: "vrUrl", title: "VR", width: 76, slots: { default: "space-vr" } },
    { field: "actions", title: "操作", fixed: "right", width: 190, showOverflow: false, slots: { default: "space-actions" } },
  ],
  rowConfig: { keyField: "id", isHover: true },
  columnConfig: { resizable: true, minWidth: 90 },
  emptyText: listError.value ? "加载失败" : "暂无房源数据",
}));

const formVisible = ref(false);
const saving = ref(false);
const formRef = ref<FormInstance>();
const editingId = ref<string | number>();
const initialForm: MarketingSpaceForm = {
  spaceCode: "",
  projectName: "",
  parkId: undefined,
  regionId: undefined,
  buildingId: undefined,
  floorId: undefined,
  buildingName: "",
  floorName: "",
  roomNo: "",
  area: 0,
  rentUnitPrice: undefined,
  availability: "AVAILABLE",
  displayTitle: "",
  description: "",
  coverUrl: "",
  vrUrl: "",
  publishStatus: 0,
};
const formData = reactive<MarketingSpaceForm>({ ...initialForm });
const formBuildingOptions = computed(() =>
  buildingOptions.value.filter(
    (building) => building.parkId === formData.parkId && building.regionId === formData.regionId
  )
);
const rules: FormRules<MarketingSpaceForm> = {
  spaceCode: [{ required: true, message: "请输入房源编号", trigger: "blur" }],
  projectName: [{ required: true, message: "请输入项目名称", trigger: "blur" }],
  area: [{ required: true, message: "请输入房源面积", trigger: "change" }],
  availability: [{ required: true, message: "请选择可租状态", trigger: "change" }],
  displayTitle: [{ required: true, message: "请输入展示标题", trigger: "blur" }],
  publishStatus: [{ required: true, message: "请选择展示状态", trigger: "change" }],
};

const detailVisible = ref(false);
const activeSpace = ref<MarketingSpace>();

function errorText(error: unknown): string {
  return error instanceof Error ? error.message : "请求失败，请重试";
}

async function fetchData(): Promise<void> {
  loading.value = true;
  listError.value = "";
  try {
    const result = await MarketingAPI.getSpacePage(params);
    list.value = result.list ?? [];
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
  Object.assign(params, {
    pageNum: 1,
    pageSize: 10,
    keyword: "",
    projectName: "",
    parkId: undefined,
    buildingId: undefined,
    availability: undefined,
    publishStatus: undefined,
  });
  fetchData();
}

function formatLocation(space: Partial<MarketingSpace>): string {
  return (
    [space.parkName, space.regionName, space.buildingName, space.floorName, space.roomNo]
      .filter(Boolean)
      .join(" / ") || "位置未设置"
  );
}

async function loadLocationOptions(): Promise<void> {
  try {
    const [parkList, buildingList] = await Promise.all([AssetAPI.getParks(), AssetAPI.getBuildingOptions()]);
    parks.value = parkList;
    buildingOptions.value = buildingList;
  } catch {
    ElMessage.warning("园区和楼栋选项暂不可用");
  }
}

function handleFilterParkChange(): void {
  params.buildingId = undefined;
  handleQuery();
}

async function handleFormParkChange(): Promise<void> {
  formData.regionId = undefined;
  formData.buildingId = undefined;
  formData.floorId = undefined;
  formData.buildingName = "";
  formData.floorName = "";
  floorOptions.value = [];
  regionOptions.value = formData.parkId ? await AssetAPI.getRegions(formData.parkId) : [];
}

function handleFormRegionChange(): void {
  formData.buildingId = undefined;
  formData.floorId = undefined;
  formData.buildingName = "";
  formData.floorName = "";
  floorOptions.value = [];
}

async function handleFormBuildingChange(): Promise<void> {
  formData.floorId = undefined;
  formData.buildingName = formBuildingOptions.value.find((building) => building.id === formData.buildingId)?.name ?? "";
  formData.floorName = "";
  floorOptions.value = formData.buildingId ? await AssetAPI.getFloors(formData.buildingId) : [];
}

function handleFormFloorChange(): void {
  formData.floorName = floorOptions.value.find((floor) => floor.id === formData.floorId)?.floorName ?? "";
}

function availabilityOption(value?: string) {
  return (
    availabilityOptions.find((option) => option.value === value) ?? {
      label: value || "未设置",
      type: "info" as const,
    }
  );
}

function publishOption(value?: number) {
  return (
    publishStatusOptions.find((option) => option.value === value) ?? {
      label: "未设置",
      type: "info" as const,
    }
  );
}

function resetForm(): void {
  formRef.value?.clearValidate();
  Object.assign(formData, initialForm);
  regionOptions.value = [];
  floorOptions.value = [];
  editingId.value = undefined;
}

function openCreate(): void {
  resetForm();
  formVisible.value = true;
}

async function openEdit(space: MarketingSpace): Promise<void> {
  resetForm();
  editingId.value = space.id;
  Object.assign(formData, {
    spaceCode: space.spaceCode ?? "",
    projectName: space.projectName ?? "",
    parkId: space.parkId,
    regionId: space.regionId,
    buildingId: space.buildingId,
    floorId: space.floorId,
    buildingName: space.buildingName ?? "",
    floorName: space.floorName ?? "",
    roomNo: space.roomNo ?? "",
    area: space.area,
    rentUnitPrice: space.rentUnitPrice,
    availability: space.availability ?? "AVAILABLE",
    displayTitle: space.displayTitle ?? "",
    description: space.description ?? "",
    coverUrl: space.coverUrl ?? "",
    vrUrl: space.vrUrl ?? "",
    publishStatus: space.publishStatus ?? 0,
  });
  if (space.parkId) regionOptions.value = await AssetAPI.getRegions(space.parkId);
  if (space.buildingId) floorOptions.value = await AssetAPI.getFloors(space.buildingId);
  formVisible.value = true;
}

function showDetail(space: MarketingSpace): void {
  activeSpace.value = space;
  detailVisible.value = true;
}

function openExternal(url?: string): void {
  if (!url) return;
  try {
    const target = new URL(url, window.location.origin);
    if (target.protocol !== "http:" && target.protocol !== "https:")
      throw new Error("unsupported protocol");
    window.open(target.href, "_blank", "noopener,noreferrer");
  } catch {
    ElMessage.warning("请输入有效的 http 或 https 地址");
  }
}

async function submitForm(): Promise<void> {
  const valid = await formRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;
  const locationIds = [formData.parkId, formData.regionId, formData.buildingId, formData.floorId];
  if (locationIds.some(Boolean) && locationIds.some((id) => !id)) {
    ElMessage.warning("园区位置请完整选择到楼层，或全部留空");
    return;
  }
  saving.value = true;
  try {
    if (editingId.value !== undefined) {
      await MarketingAPI.updateSpace(editingId.value, formData);
      ElMessage.success("房源已更新");
    } else {
      await MarketingAPI.createSpace(formData);
      ElMessage.success("房源已创建");
    }
    formVisible.value = false;
    await fetchData();
  } finally {
    saving.value = false;
  }
}

async function deleteSpace(space: MarketingSpace): Promise<void> {
  if (space.id === undefined) return;
  try {
    await ElMessageBox.confirm(
      `确认删除房源“${space.displayTitle || space.spaceCode || "该房源"}”吗？`,
      "删除房源",
      {
        type: "warning",
        confirmButtonText: "删除",
        cancelButtonText: "取消",
      }
    );
  } catch {
    return;
  }
  await MarketingAPI.deleteSpace(space.id);
  ElMessage.success("房源已删除");
  await fetchData();
}

onMounted(() => {
  fetchData();
  loadLocationOptions();
});
</script>

<style lang="scss" scoped>
.marketing-page {
  display: flex;
  flex-direction: column;
  gap: var(--page-gap);
  min-height: 0;
}

.page-alert {
  margin-bottom: 8px;
}

.page-table-wrapper {
  min-height: 320px;
}

.space-cover {
  width: 62px;
  height: 44px;
  border-radius: 4px;
}

.space-main {
  display: flex;
  flex-direction: column;
  gap: 4px;
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
  white-space: nowrap;
}

.form-cover,
.detail-cover {
  display: block;
  width: min(100%, 420px);
  height: 210px;
  margin: -8px 0 18px 105px;
  border-radius: 4px;
}

.detail-cover {
  margin: 0 0 18px;
}

.space-description {
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}

@media (max-width: 768px) {
  .page-table-wrapper {
    min-height: 360px;
  }

  .form-cover {
    max-width: calc(100% - 105px);
  }
}
</style>
