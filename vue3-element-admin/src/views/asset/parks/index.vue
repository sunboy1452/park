<!-- @page-id: asset-parks -->
<!-- @page-name: 园区管理 -->
<!-- @page-route: /building/parks -->
<template>
  <div class="page-container asset-list-page">
    <el-card class="page-search" shadow="never">
      <el-form :model="query" inline @submit.prevent="applyQuery">
        <el-form-item label="关键字">
          <el-input v-model="query.keyword" class="asset-query-control" clearable placeholder="园区名称或编号" @keyup.enter="applyQuery" />
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
    <el-card class="page-content" shadow="never">
      <div class="page-toolbar">
        <div class="page-toolbar__left"><el-button v-hasPerm="'asset:park:create'" type="primary" @click="openCreate"><el-icon><Plus /></el-icon>新增园区</el-button></div>
        <div class="page-toolbar__right"><el-tooltip content="刷新" placement="top"><el-button class="page-icon-btn" :loading="loading" aria-label="刷新" @click="loadData"><el-icon><Refresh /></el-icon></el-button></el-tooltip></div>
      </div>
      <div class="page-table-wrapper">
      <VxeGrid class="page-vxe-grid" v-bind="gridOptions" :data="pageList" :loading="loading">
        <template #park-name="{ row }"><strong>{{ row.name }}</strong></template>
        <template #park-area="{ row }">{{ row.area ? `${row.area} m²` : "-" }}</template>
        <template #park-status="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? "启用" : "停用" }}</el-tag></template>
        <template #park-actions="{ row }">
          <el-button v-hasPerm="'asset:park:update'" link type="primary" @click="openEdit(row as AssetPark)">编辑</el-button>
          <el-button v-hasPerm="'asset:park:delete'" link type="danger" @click="removeRow(row as AssetPark)">删除</el-button>
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
    <el-dialog v-model="visible" :title="editingId ? '编辑园区' : '新增园区'" width="560px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="园区编号" prop="code"><el-input v-model="form.code" maxlength="64" /></el-form-item>
        <el-form-item label="园区名称" prop="name"><el-input v-model="form.name" maxlength="150" /></el-form-item>
        <el-form-item label="地址"><el-input v-model="form.address" maxlength="255" /></el-form-item>
        <el-form-item label="占地面积"><el-input-number v-model="form.area" :min="0" :precision="2" controls-position="right" /><span class="unit">m²</span></el-form-item>
        <el-form-item label="状态"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="启用" inactive-text="停用" /></el-form-item>
        <el-form-item label="园区简介"><el-input v-model="form.description" type="textarea" :rows="3" maxlength="1000" show-word-limit /></el-form-item>
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
import AssetAPI, { type AssetForm, type AssetPark } from "@/api/asset";
import { configureVxeUI } from "@/plugins/vxe-table";

defineOptions({ name: "AssetParks", inheritAttrs: false });
configureVxeUI();

const list = ref<AssetPark[]>([]);
const query = reactive<{ keyword: string; status?: number }>({ keyword: "", status: undefined });
const appliedQuery = ref({ keyword: "", status: undefined as number | undefined });
const pageNum = ref(1);
const pageSize = ref(10);
const filteredList = computed(() => list.value.filter((park) => {
  const keyword = appliedQuery.value.keyword.trim().toLowerCase();
  const matchesKeyword = !keyword || `${park.name} ${park.code}`.toLowerCase().includes(keyword);
  const matchesStatus = appliedQuery.value.status === undefined || park.status === appliedQuery.value.status;
  return matchesKeyword && matchesStatus;
}));
const pageList = computed(() => {
  const start = (pageNum.value - 1) * pageSize.value;
  return filteredList.value.slice(start, start + pageSize.value);
});
const loading = ref(false);
const visible = ref(false);
const saving = ref(false);
const editingId = ref<AssetPark["id"]>();
const formRef = ref<FormInstance>();
const form = reactive<AssetForm>({ code: "", name: "", address: "", status: 1, area: undefined, description: "" });
const rules: FormRules = {
  code: [{ required: true, message: "请输入园区编号", trigger: "blur" }],
  name: [{ required: true, message: "请输入园区名称", trigger: "blur" }],
};
const gridOptions: VxeGridProps<AssetPark> = {
  columns: [
    { field: "name", title: "园区名称", minWidth: 180, slots: { default: "park-name" } },
    { field: "code", title: "园区编号", minWidth: 150 },
    { field: "address", title: "地址", minWidth: 220 },
    { field: "area", title: "占地面积", width: 130, align: "right", slots: { default: "park-area" } },
    { field: "status", title: "状态", width: 100, slots: { default: "park-status" } },
    { field: "updateTime", title: "最近更新", width: 170 },
    { field: "actions", title: "操作", width: 150, fixed: "right", showOverflow: false, slots: { default: "park-actions" } },
  ],
  rowConfig: { keyField: "id", isHover: true },
  columnConfig: { resizable: true, minWidth: 90 },
  emptyText: "暂无园区",
};

async function loadData(): Promise<void> {
  loading.value = true;
  try { list.value = await AssetAPI.getParks(); } catch { ElMessage.error("园区列表加载失败"); } finally { loading.value = false; }
}

function applyQuery(): void {
  appliedQuery.value = { keyword: query.keyword, status: query.status };
  pageNum.value = 1;
}

function resetQuery(): void {
  query.keyword = "";
  query.status = undefined;
  applyQuery();
}

function resetForm(): void {
  formRef.value?.clearValidate();
  Object.assign(form, { code: "", name: "", address: "", status: 1, area: undefined, description: "" });
  editingId.value = undefined;
}

function openCreate(): void { resetForm(); visible.value = true; }

function openEdit(row: AssetPark): void {
  resetForm();
  editingId.value = row.id;
  Object.assign(form, { code: row.code, name: row.name, address: row.address, area: row.area, status: row.status, description: row.description });
  visible.value = true;
}

async function submit(): Promise<void> {
  if (!formRef.value) return;
  await formRef.value.validate();
  saving.value = true;
  try {
    if (editingId.value) await AssetAPI.updatePark(editingId.value, form);
    else await AssetAPI.createPark(form);
    ElMessage.success("保存成功");
    visible.value = false;
    await loadData();
  } finally { saving.value = false; }
}

async function removeRow(row: AssetPark): Promise<void> {
  try {
    await ElMessageBox.confirm(`确定删除园区“${row.name}”吗？`, "确认删除", { type: "warning" });
    await AssetAPI.deletePark(row.id);
    ElMessage.success("删除成功");
    await loadData();
  } catch (error) {
    if (error !== "cancel") ElMessage.error(error instanceof Error ? error.message : "删除失败");
  }
}

onMounted(loadData);
</script>

<style scoped lang="scss">
.unit { margin-left: 8px; color: var(--el-text-color-secondary); }
.asset-list-page :deep(.page-table-wrapper) { min-height: 350px; }
@media (max-width: 700px) { .asset-list-page :deep(.page-search .el-form) { display: flex; flex-wrap: wrap; } }
</style>
