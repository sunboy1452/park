<!-- @page-id: asset-buildings -->
<!-- @page-name: 楼栋管理 -->
<!-- @page-route: /building/buildings -->
<template>
  <div class="page-container asset-list-page">
    <el-card class="page-search" shadow="never">
      <el-form :model="query" inline @submit.prevent="applyQuery">
        <el-form-item label="所属园区">
          <el-select v-model="parkId" clearable placeholder="全部园区" class="asset-query-control" @change="handleParkChange">
            <el-option v-for="park in parks" :key="park.id" :label="park.name" :value="park.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="所属区域">
          <el-select v-model="regionId" clearable :disabled="!regions.length" placeholder="全部区域" class="asset-query-control">
            <el-option v-for="region in regions" :key="region.id" :label="region.name" :value="region.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键字">
          <el-input v-model="query.keyword" class="asset-query-control" clearable placeholder="楼栋名称或编号" @keyup.enter="applyQuery" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="query.status" clearable placeholder="全部状态" class="asset-query-control">
            <el-option label="启用" :value="1" />
            <el-option label="停用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="applyQuery">搜索</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    <el-alert v-if="!parks.length && !loading" title="请先创建园区和区域，再登记楼栋。" type="info" :closable="false" show-icon />
    <el-card class="page-content" shadow="never">
      <div class="page-toolbar">
        <div class="page-toolbar__left"><el-button v-hasPerm="'asset:building:create'" type="primary" :disabled="!parks.length || !regions.length" @click="openCreate"><el-icon><Plus /></el-icon>新增楼栋</el-button></div>
        <div class="page-toolbar__right"><el-button class="page-icon-btn" :loading="loading" aria-label="刷新" @click="loadBuildings"><el-icon><Refresh /></el-icon></el-button></div>
      </div>
      <div class="page-table-wrapper">
      <VxeGrid class="page-vxe-grid" v-bind="buildingGridOptions" :data="pageList" :loading="loading">
        <template #building-name="{ row }"><strong>{{ row.name }}</strong></template>
        <template #building-park="{ row }">{{ parkName(row.parkId) }}</template>
        <template #building-region="{ row }">{{ regionName(row.regionId) }}</template>
        <template #building-area="{ row }">{{ row.area ? `${row.area} m²` : "-" }}</template>
        <template #building-status="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? "启用" : "停用" }}</el-tag></template>
        <template #building-actions="{ row }">
          <el-button link type="primary" @click="openFloors(row as AssetBuilding)">楼层管理</el-button>
          <el-button v-hasPerm="'asset:building:update'" link type="primary" @click="openEdit(row as AssetBuilding)">编辑</el-button>
          <el-button v-hasPerm="'asset:building:delete'" link type="danger" @click="removeRow(row as AssetBuilding)">删除</el-button>
        </template>
      </VxeGrid>
      </div>
      <pagination
        v-if="filteredList.length > 0"
        :total="filteredList.length"
        v-model:page="pageNum"
        v-model:limit="pageSize"
        class="page-pagination"
      />
    </el-card>

    <el-dialog v-model="visible" :title="editingId ? '编辑楼栋' : '新增楼栋'" width="620px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="96px">
        <el-form-item label="所属园区" prop="parkId"><el-select v-model="form.parkId" placeholder="请选择园区" @change="handleFormParkChange"><el-option v-for="park in parks" :key="park.id" :label="park.name" :value="park.id" /></el-select></el-form-item>
        <el-form-item label="所属区域" prop="regionId"><el-select v-model="form.regionId" placeholder="请选择区域"><el-option v-for="region in formRegions" :key="region.id" :label="region.name" :value="region.id" /></el-select></el-form-item>
        <el-form-item label="楼栋编号" prop="code"><el-input v-model="form.code" maxlength="64" /></el-form-item>
        <el-form-item label="楼栋名称" prop="name"><el-input v-model="form.name" maxlength="100" /></el-form-item>
        <el-form-item label="建筑用途"><el-select v-model="form.buildingType" clearable placeholder="请选择用途"><el-option v-for="item in buildingTypes" :key="item" :label="item" :value="item" /></el-select></el-form-item>
        <el-form-item label="建筑面积"><el-input-number v-model="form.area" :min="0" :precision="2" controls-position="right" /><span class="unit">m²</span></el-form-item>
        <el-form-item label="示意位置"><div class="coordinate-grid"><el-input-number v-model="form.mapX" :min="0" :max="1000 - (form.mapWidth ?? 120)" controls-position="right" /><el-input-number v-model="form.mapY" :min="0" :max="600 - (form.mapHeight ?? 72)" controls-position="right" /></div><span class="unit">X / Y</span></el-form-item>
        <el-form-item label="示意尺寸"><div class="coordinate-grid"><el-input-number v-model="form.mapWidth" :min="40" :max="500" controls-position="right" /><el-input-number v-model="form.mapHeight" :min="32" :max="300" controls-position="right" /></div><span class="unit">宽 / 高</span></el-form-item>
        <el-form-item label="状态"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="启用" inactive-text="停用" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" maxlength="500" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="visible = false">取消</el-button><el-button type="primary" :loading="saving" @click="submit">保存</el-button></template>
    </el-dialog>

    <el-drawer v-model="floorVisible" :title="`${activeBuilding?.name ?? '楼栋'} · 楼层管理`" size="min(760px, 100vw)" destroy-on-close>
      <div class="floor-toolbar"><span>{{ parkName(activeBuilding?.parkId ?? "") }} / {{ regionName(activeBuilding?.regionId ?? "") }}</span><el-button v-hasPerm="'asset:building:create'" type="primary" @click="openFloorCreate"><el-icon><Plus /></el-icon>新增楼层</el-button></div>
      <VxeGrid class="page-vxe-grid" v-bind="floorGridOptions" :data="floors" :loading="floorLoading">
        <template #floor-caption="{ row }">{{ floorCaption(row.floorNumber) }}</template>
        <template #floor-area="{ row }">{{ row.area ? `${row.area} m²` : "-" }}</template>
        <template #floor-status="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? "启用" : "停用" }}</el-tag></template>
        <template #floor-actions="{ row }"><el-button v-hasPerm="'asset:building:update'" link type="primary" @click="openFloorEdit(row as AssetFloor)">编辑</el-button><el-button v-hasPerm="'asset:building:delete'" link type="danger" @click="removeFloor(row as AssetFloor)">删除</el-button></template>
      </VxeGrid>
    </el-drawer>

    <el-dialog v-model="floorFormVisible" :title="floorEditingId ? '编辑楼层' : '新增楼层'" width="500px" append-to-body destroy-on-close>
      <el-form ref="floorFormRef" :model="floorForm" :rules="floorRules" label-width="96px">
        <el-form-item label="楼层编号" prop="floorCode"><el-input v-model="floorForm.floorCode" maxlength="64" placeholder="如 B1、F1" /></el-form-item>
        <el-form-item label="楼层名称" prop="floorName"><el-input v-model="floorForm.floorName" maxlength="100" placeholder="如 地下一层、一层" /></el-form-item>
        <el-form-item label="楼层序号" prop="floorNumber"><el-input-number v-model="floorForm.floorNumber" :min="-20" :max="200" controls-position="right" /></el-form-item>
        <el-form-item label="建筑面积"><el-input-number v-model="floorForm.area" :min="0" :precision="2" controls-position="right" /><span class="unit">m²</span></el-form-item>
        <el-form-item label="状态"><el-switch v-model="floorForm.status" :active-value="1" :inactive-value="0" active-text="启用" inactive-text="停用" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="floorForm.remark" maxlength="500" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="floorFormVisible = false">取消</el-button><el-button type="primary" :loading="floorSaving" @click="submitFloor">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
import { Plus, Refresh } from "@element-plus/icons-vue";
import { VxeGrid } from "vxe-table";
import type { VxeGridProps } from "vxe-table";
import AssetAPI, { type AssetBuilding, type AssetFloor, type AssetForm, type AssetId, type AssetPark, type AssetRegion } from "@/api/asset";
import { configureVxeUI } from "@/plugins/vxe-table";

defineOptions({ name: "AssetBuildings", inheritAttrs: false });
configureVxeUI();

const route = useRoute();
const parks = ref<AssetPark[]>([]);
const regions = ref<AssetRegion[]>([]);
const formRegions = ref<AssetRegion[]>([]);
const list = ref<AssetBuilding[]>([]);
const parkId = ref<AssetId>();
const regionId = ref<AssetId>();
const query = reactive<{ keyword: string; status?: number }>({ keyword: "", status: undefined });
const appliedQuery = ref({ keyword: "", status: undefined as number | undefined });
const pageNum = ref(1);
const pageSize = ref(10);
const filteredList = computed(() => list.value.filter((building) => {
  const keyword = appliedQuery.value.keyword.trim().toLowerCase();
  const matchesKeyword = !keyword || `${building.name} ${building.code}`.toLowerCase().includes(keyword);
  const matchesStatus = appliedQuery.value.status === undefined || building.status === appliedQuery.value.status;
  return matchesKeyword && matchesStatus;
}));
const pageList = computed(() => {
  const start = (pageNum.value - 1) * pageSize.value;
  return filteredList.value.slice(start, start + pageSize.value);
});
const loading = ref(false);
const visible = ref(false);
const saving = ref(false);
const editingId = ref<AssetId>();
const formRef = ref<FormInstance>();
const buildingTypes = ["研发办公", "生产厂房", "仓储物流", "配套服务", "综合楼"];
const form = reactive<AssetForm>({ code: "", name: "", parkId: undefined, regionId: undefined, buildingType: "", area: undefined, status: 1, mapX: 80, mapY: 80, mapWidth: 120, mapHeight: 72, sort: 0, remark: "" });
const rules: FormRules = {
  parkId: [{ required: true, message: "请选择园区", trigger: "change" }],
  regionId: [{ required: true, message: "请选择区域", trigger: "change" }],
  code: [{ required: true, message: "请输入楼栋编号", trigger: "blur" }],
  name: [{ required: true, message: "请输入楼栋名称", trigger: "blur" }],
};
const floorVisible = ref(false);
const floorFormVisible = ref(false);
const floorLoading = ref(false);
const floorSaving = ref(false);
const activeBuilding = ref<AssetBuilding>();
const floors = ref<AssetFloor[]>([]);
const floorEditingId = ref<AssetId>();
const floorFormRef = ref<FormInstance>();
const floorForm = reactive<AssetForm>({ floorCode: "", floorName: "", floorNumber: 1, status: 1, area: undefined, remark: "" });
const floorRules: FormRules = {
  floorCode: [{ required: true, message: "请输入楼层编号", trigger: "blur" }],
  floorName: [{ required: true, message: "请输入楼层名称", trigger: "blur" }],
  floorNumber: [{ required: true, message: "请输入楼层序号", trigger: "change" }],
};
const buildingGridOptions: VxeGridProps<AssetBuilding> = {
  columns: [
    { field: "name", title: "楼栋名称", minWidth: 170, slots: { default: "building-name" } },
    { field: "code", title: "楼栋编号", minWidth: 160, showOverflow: "tooltip" },
    { field: "parkId", title: "园区", minWidth: 145, slots: { default: "building-park" } },
    { field: "regionId", title: "所属区域", minWidth: 140, slots: { default: "building-region" } },
    { field: "buildingType", title: "用途", width: 120 },
    { field: "area", title: "建筑面积", width: 125, align: "right", slots: { default: "building-area" } },
    { field: "status", title: "状态", width: 95, slots: { default: "building-status" } },
    { field: "actions", title: "操作", width: 230, fixed: "right", showOverflow: false, slots: { default: "building-actions" } },
  ],
  rowConfig: { keyField: "id", isHover: true },
  columnConfig: { resizable: true, minWidth: 90 },
  emptyText: "暂无楼栋",
};
const floorGridOptions: VxeGridProps<AssetFloor> = {
  columns: [
    { field: "floorNumber", title: "序号", width: 90, slots: { default: "floor-caption" } },
    { field: "floorName", title: "楼层名称", minWidth: 150 },
    { field: "floorCode", title: "楼层编号", minWidth: 130 },
    { field: "area", title: "建筑面积", width: 120, align: "right", slots: { default: "floor-area" } },
    { field: "status", title: "状态", width: 90, slots: { default: "floor-status" } },
    { field: "actions", title: "操作", width: 130, showOverflow: false, slots: { default: "floor-actions" } },
  ],
  rowConfig: { keyField: "id", isHover: true },
  columnConfig: { resizable: true, minWidth: 90 },
  pagerConfig: { align: "right", pageSize: 10, pageSizes: [10, 20, 50] },
  emptyText: "暂无楼层",
};

function parkName(id: AssetId): string { return parks.value.find((park) => park.id === id)?.name ?? "-"; }
function regionName(id: AssetId): string { return regions.value.find((region) => region.id === id)?.name ?? "-"; }
function floorCaption(number: number): string { return number < 0 ? `B${Math.abs(number)}` : `F${number}`; }

async function loadBase(): Promise<void> {
  try {
    parks.value = await AssetAPI.getParks();
    const selectedBuildingId = route.query.buildingId;
    if (selectedBuildingId) {
      const match = (await AssetAPI.getBuildings()).find((item) => String(item.id) === String(selectedBuildingId));
      if (match) { parkId.value = match.parkId; regionId.value = match.regionId; }
    } else if (route.query.parkId) parkId.value = String(route.query.parkId);
    await handleParkChange();
    if (selectedBuildingId) {
      const row = list.value.find((item) => String(item.id) === String(selectedBuildingId));
      if (row) await openFloors(row);
    }
  } catch { ElMessage.error("楼栋数据加载失败"); }
}

async function handleParkChange(): Promise<void> {
  pageNum.value = 1;
  try {
    regions.value = await AssetAPI.getRegions(parkId.value);
    if (regionId.value && !regions.value.some((region) => region.id === regionId.value)) regionId.value = undefined;
    await loadBuildings();
  } catch { ElMessage.error("区域列表加载失败"); }
}

async function loadBuildings(): Promise<void> {
  loading.value = true;
  try { list.value = await AssetAPI.getBuildings({ parkId: parkId.value, regionId: regionId.value }); }
  catch { ElMessage.error("楼栋列表加载失败"); } finally { loading.value = false; }
}

function applyQuery(): void {
  appliedQuery.value = { keyword: query.keyword, status: query.status };
  pageNum.value = 1;
  void loadBuildings();
}

function resetQuery(): void {
  parkId.value = undefined;
  regionId.value = undefined;
  query.keyword = "";
  query.status = undefined;
  appliedQuery.value = { keyword: "", status: undefined };
  pageNum.value = 1;
  void handleParkChange();
}

async function handleFormParkChange(): Promise<void> {
  form.regionId = undefined;
  formRegions.value = await AssetAPI.getRegions(form.parkId);
}

function resetForm(): void {
  formRef.value?.clearValidate();
  Object.assign(form, { code: "", name: "", parkId: parkId.value ?? parks.value[0]?.id, regionId: regionId.value, buildingType: "", area: undefined, status: 1, mapX: 80, mapY: 80, mapWidth: 120, mapHeight: 72, sort: list.value.length, remark: "" });
  formRegions.value = regions.value;
  editingId.value = undefined;
}

function openCreate(): void {
  resetForm();
  const region = regions.value.find((item) => item.id === form.regionId);
  const siblings = list.value.filter((item) => item.regionId === form.regionId);
  if (region) {
    const index = siblings.length;
    form.mapWidth = Math.max(40, Math.min(120, region.mapWidth - 36));
    form.mapHeight = Math.max(32, Math.min(72, region.mapHeight - 42));
    const width = form.mapWidth;
    const height = form.mapHeight;
    const columns = Math.max(1, Math.floor((region.mapWidth - 18 - width + 140) / 140));
    const x = region.mapX + 18 + (index % columns) * 140;
    const y = region.mapY + 42 + Math.floor(index / columns) * (height + 18);
    form.mapX = Math.min(x, region.mapX + region.mapWidth - width);
    form.mapY = Math.min(y, region.mapY + region.mapHeight - height);
  }
  visible.value = true;
}

async function openEdit(row: AssetBuilding): Promise<void> {
  resetForm(); editingId.value = row.id;
  Object.assign(form, { parkId: row.parkId, regionId: row.regionId, code: row.code, name: row.name, buildingType: row.buildingType, area: row.area, status: row.status, mapX: row.mapX, mapY: row.mapY, mapWidth: row.mapWidth, mapHeight: row.mapHeight, sort: row.sort, remark: row.remark });
  formRegions.value = await AssetAPI.getRegions(row.parkId);
  visible.value = true;
}

async function submit(): Promise<void> {
  if (!formRef.value) return;
  await formRef.value.validate(); saving.value = true;
  try {
    if (editingId.value) await AssetAPI.updateBuilding(editingId.value, form); else await AssetAPI.createBuilding(form);
    ElMessage.success("保存成功"); visible.value = false; await loadBuildings();
  } finally { saving.value = false; }
}

async function removeRow(row: AssetBuilding): Promise<void> {
  try {
    await ElMessageBox.confirm(`确定删除楼栋“${row.name}”吗？`, "确认删除", { type: "warning" });
    await AssetAPI.deleteBuilding(row.id); ElMessage.success("删除成功"); await loadBuildings();
  } catch (error) { if (error !== "cancel") ElMessage.error(error instanceof Error ? error.message : "删除失败"); }
}

async function openFloors(row: AssetBuilding): Promise<void> {
  activeBuilding.value = row; floorVisible.value = true; await loadFloors();
}

async function loadFloors(): Promise<void> {
  if (!activeBuilding.value) return;
  floorLoading.value = true;
  try { floors.value = await AssetAPI.getFloors(activeBuilding.value.id); }
  catch { ElMessage.error("楼层列表加载失败"); } finally { floorLoading.value = false; }
}

function resetFloorForm(): void {
  floorFormRef.value?.clearValidate();
  Object.assign(floorForm, { floorCode: "", floorName: "", floorNumber: 1, status: 1, area: undefined, remark: "" });
  floorEditingId.value = undefined;
}

function openFloorCreate(): void { resetFloorForm(); floorFormVisible.value = true; }
function openFloorEdit(row: AssetFloor): void {
  resetFloorForm(); floorEditingId.value = row.id;
  Object.assign(floorForm, { floorCode: row.floorCode, floorName: row.floorName, floorNumber: row.floorNumber, status: row.status, area: row.area, remark: row.remark });
  floorFormVisible.value = true;
}

async function submitFloor(): Promise<void> {
  if (!floorFormRef.value || !activeBuilding.value) return;
  await floorFormRef.value.validate(); floorSaving.value = true;
  const data = { ...floorForm, buildingId: activeBuilding.value.id };
  try {
    if (floorEditingId.value) await AssetAPI.updateFloor(floorEditingId.value, data); else await AssetAPI.createFloor(data);
    ElMessage.success("楼层已保存"); floorFormVisible.value = false; await loadFloors();
  } finally { floorSaving.value = false; }
}

async function removeFloor(row: AssetFloor): Promise<void> {
  try {
    await ElMessageBox.confirm(`确定删除楼层“${row.floorName}”吗？`, "确认删除", { type: "warning" });
    await AssetAPI.deleteFloor(row.id); ElMessage.success("删除成功"); await loadFloors();
  } catch (error) { if (error !== "cancel") ElMessage.error(error instanceof Error ? error.message : "删除失败"); }
}

onMounted(loadBase);
</script>

<style scoped lang="scss">
.unit,.floor-toolbar span { color: var(--el-text-color-secondary); }
.unit { margin-left: 8px; }
.coordinate-grid { display: flex; gap: 8px; }
.coordinate-grid :deep(.el-input-number) { width: 130px; }
.floor-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 14px; }
.asset-list-page :deep(.page-table-wrapper) { min-height: 320px; }
</style>
