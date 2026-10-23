<!-- @page-id: asset-regions -->
<!-- @page-name: 区域管理 -->
<!-- @page-route: /building/regions -->
<template>
  <div class="page-container asset-list-page">
    <el-card class="page-search" shadow="never">
      <el-form :model="query" inline @submit.prevent="applyQuery">
        <el-form-item label="所属园区">
          <el-select v-model="parkId" clearable placeholder="全部园区" class="asset-query-control">
            <el-option v-for="park in parks" :key="park.id" :label="park.name" :value="park.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键字">
          <el-input v-model="query.keyword" class="asset-query-control" clearable placeholder="区域名称或编号" @keyup.enter="applyQuery" />
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
    <el-alert v-if="!parks.length && !loading" title="请先创建园区，再配置区域。" type="info" :closable="false" show-icon />
    <el-card class="page-content" shadow="never">
      <div class="page-toolbar">
        <div class="page-toolbar__left"><el-button v-hasPerm="'asset:region:create'" type="primary" :disabled="!parks.length" @click="openCreate"><el-icon><Plus /></el-icon>新增区域</el-button></div>
        <div class="page-toolbar__right"><el-button class="page-icon-btn" :loading="loading" aria-label="刷新" @click="loadRegions"><el-icon><Refresh /></el-icon></el-button></div>
      </div>
      <div class="page-table-wrapper">
      <VxeGrid class="page-vxe-grid" v-bind="gridOptions" :data="pageList" :loading="loading">
        <template #region-name="{ row }"><strong>{{ row.name }}</strong></template>
        <template #region-park="{ row }">{{ parkName(row.parkId) }}</template>
        <template #region-area="{ row }">{{ row.area ? `${row.area} m²` : "-" }}</template>
        <template #region-status="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? "启用" : "停用" }}</el-tag></template>
        <template #region-actions="{ row }"><el-button v-hasPerm="'asset:region:update'" link type="primary" @click="openEdit(row as AssetRegion)">编辑</el-button><el-button v-hasPerm="'asset:region:delete'" link type="danger" @click="removeRow(row as AssetRegion)">删除</el-button></template>
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
    <el-dialog v-model="visible" :title="editingId ? '编辑区域' : '新增区域'" width="620px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="96px">
        <el-form-item label="所属园区" prop="parkId"><el-select v-model="form.parkId" placeholder="请选择园区"><el-option v-for="park in parks" :key="park.id" :label="park.name" :value="park.id" /></el-select></el-form-item>
        <el-form-item label="区域编号" prop="code"><el-input v-model="form.code" maxlength="64" /></el-form-item>
        <el-form-item label="区域名称" prop="name"><el-input v-model="form.name" maxlength="100" /></el-form-item>
        <el-form-item label="功能类型"><el-select v-model="form.regionType" clearable placeholder="请选择或输入"><el-option v-for="type in regionTypes" :key="type" :label="type" :value="type" /></el-select><el-input v-model="form.regionType" class="custom-type" maxlength="32" placeholder="自定义" /></el-form-item>
        <el-form-item label="区域面积"><el-input-number v-model="form.area" :min="0" :precision="2" controls-position="right" /><span class="unit">m²</span></el-form-item>
        <el-form-item label="图面位置"><div class="coordinate-grid"><el-input-number v-model="form.mapX" :min="0" :max="1000 - (form.mapWidth ?? 280)" controls-position="right" /><el-input-number v-model="form.mapY" :min="0" :max="600 - (form.mapHeight ?? 230)" controls-position="right" /></div><span class="unit">X / Y</span></el-form-item>
        <el-form-item label="图面尺寸"><div class="coordinate-grid"><el-input-number v-model="form.mapWidth" :min="100" :max="500" controls-position="right" /><el-input-number v-model="form.mapHeight" :min="100" :max="300" controls-position="right" /></div><span class="unit">宽 / 高</span></el-form-item>
        <el-form-item label="显示顺序"><el-input-number v-model="form.sort" :min="0" controls-position="right" /></el-form-item>
        <el-form-item label="状态"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="启用" inactive-text="停用" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" maxlength="500" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="visible = false">取消</el-button><el-button type="primary" :loading="saving" @click="submit">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
import { Plus, Refresh } from "@element-plus/icons-vue";
import { VxeGrid } from "vxe-table";
import type { VxeGridProps } from "vxe-table";
import AssetAPI, { type AssetForm, type AssetId, type AssetPark, type AssetRegion } from "@/api/asset";
import { configureVxeUI } from "@/plugins/vxe-table";

defineOptions({ name: "AssetRegions", inheritAttrs: false });
configureVxeUI();

const parks = ref<AssetPark[]>([]);
const list = ref<AssetRegion[]>([]);
const parkId = ref<AssetId>();
const query = reactive<{ keyword: string; status?: number }>({ keyword: "", status: undefined });
const appliedQuery = ref({ keyword: "", status: undefined as number | undefined });
const pageNum = ref(1);
const pageSize = ref(10);
const filteredList = computed(() => list.value.filter((region) => {
  const keyword = appliedQuery.value.keyword.trim().toLowerCase();
  const matchesKeyword = !keyword || `${region.name} ${region.code}`.toLowerCase().includes(keyword);
  const matchesStatus = appliedQuery.value.status === undefined || region.status === appliedQuery.value.status;
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
const regionTypes = ["生产制造", "研发办公", "仓储物流", "生活配套", "公共服务"];
const form = reactive<AssetForm>({ code: "", name: "", parkId: undefined, regionType: "", area: undefined, status: 1, mapX: 40, mapY: 40, mapWidth: 280, mapHeight: 230, sort: 0, remark: "" });
const rules: FormRules = {
  parkId: [{ required: true, message: "请选择园区", trigger: "change" }],
  code: [{ required: true, message: "请输入区域编号", trigger: "blur" }],
  name: [{ required: true, message: "请输入区域名称", trigger: "blur" }],
};
const gridOptions: VxeGridProps<AssetRegion> = {
  columns: [
    { field: "name", title: "区域名称", minWidth: 180, slots: { default: "region-name" } },
    { field: "code", title: "区域编号", minWidth: 160, showOverflow: "tooltip" },
    { field: "parkId", title: "园区", minWidth: 160, slots: { default: "region-park" } },
    { field: "regionType", title: "功能类型", width: 130 },
    { field: "area", title: "面积", width: 120, align: "right", slots: { default: "region-area" } },
    { field: "status", title: "状态", width: 100, slots: { default: "region-status" } },
    { field: "actions", title: "操作", width: 145, fixed: "right", showOverflow: false, slots: { default: "region-actions" } },
  ],
  rowConfig: { keyField: "id", isHover: true },
  columnConfig: { resizable: true, minWidth: 90 },
  emptyText: "暂无区域",
};

function parkName(id: AssetId): string { return parks.value.find((park) => park.id === id)?.name ?? "-"; }

async function loadRegions(): Promise<void> {
  loading.value = true;
  try {
    const [parkList, regionList] = await Promise.all([AssetAPI.getParks(), AssetAPI.getRegions(parkId.value)]);
    parks.value = parkList;
    list.value = regionList;
  } catch { ElMessage.error("区域列表加载失败"); } finally { loading.value = false; }
}

function applyQuery(): void {
  appliedQuery.value = { keyword: query.keyword, status: query.status };
  pageNum.value = 1;
  void loadRegions();
}

function resetQuery(): void {
  parkId.value = undefined;
  query.keyword = "";
  query.status = undefined;
  applyQuery();
}

function resetForm(): void {
  formRef.value?.clearValidate();
  const index = list.value.length;
  Object.assign(form, {
    code: "", name: "", parkId: parkId.value ?? parks.value[0]?.id, regionType: "", area: undefined, status: 1,
    mapX: 40 + (index % 3) * 320,
    mapY: 40 + (Math.floor(index / 3) % 2) * 280,
    mapWidth: 280,
    mapHeight: 230,
    sort: index,
    remark: "",
  });
  editingId.value = undefined;
}

function openCreate(): void { resetForm(); visible.value = true; }

function openEdit(row: AssetRegion): void {
  resetForm(); editingId.value = row.id;
  Object.assign(form, { parkId: row.parkId, code: row.code, name: row.name, regionType: row.regionType, area: row.area, status: row.status, mapX: row.mapX, mapY: row.mapY, mapWidth: row.mapWidth, mapHeight: row.mapHeight, sort: row.sort, remark: row.remark });
  visible.value = true;
}

async function submit(): Promise<void> {
  if (!formRef.value) return;
  await formRef.value.validate(); saving.value = true;
  try {
    if (editingId.value) await AssetAPI.updateRegion(editingId.value, form); else await AssetAPI.createRegion(form);
    ElMessage.success("保存成功"); visible.value = false; await loadRegions();
  } finally { saving.value = false; }
}

async function removeRow(row: AssetRegion): Promise<void> {
  try {
    await ElMessageBox.confirm(`确定删除区域“${row.name}”吗？`, "确认删除", { type: "warning" });
    await AssetAPI.deleteRegion(row.id); ElMessage.success("删除成功"); await loadRegions();
  } catch (error) { if (error !== "cancel") ElMessage.error(error instanceof Error ? error.message : "删除失败"); }
}

onMounted(loadRegions);
</script>

<style scoped lang="scss">
.unit { color: var(--el-text-color-secondary); }
.unit { margin-left: 8px; }
.custom-type { width: 130px; margin-left: 8px; }
.coordinate-grid { display: flex; gap: 8px; }
.coordinate-grid :deep(.el-input-number) { width: 130px; }
.asset-list-page :deep(.page-table-wrapper) { min-height: 320px; }
</style>
