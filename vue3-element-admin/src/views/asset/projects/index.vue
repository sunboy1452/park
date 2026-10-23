<!-- @page-id: asset-projects -->
<!-- @page-name: 项目管理 -->
<!-- @page-route: /building/projects -->
<template>
  <div class="page-container asset-list-page">
    <el-card class="page-search" shadow="never">
      <el-form :model="query" inline @submit.prevent="applyQuery">
        <el-form-item label="关键字">
          <el-input v-model="query.keyword" class="asset-query-control" clearable placeholder="项目名称或编号" @keyup.enter="applyQuery" />
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
        <div class="page-toolbar__left"><el-button v-hasPerm="'asset:project:create'" type="primary" @click="openCreate"><el-icon><Plus /></el-icon>新增项目</el-button></div>
        <div class="page-toolbar__right"><el-button class="page-icon-btn" :loading="loading" aria-label="刷新" @click="loadData"><el-icon><Refresh /></el-icon></el-button></div>
      </div>
      <div class="page-table-wrapper">
      <VxeGrid class="page-vxe-grid" v-bind="gridOptions" :data="pageList" :loading="loading">
        <template #project-name="{ row }"><div class="name-cell"><strong>{{ row.name }}</strong><small>{{ row.code }}</small></div></template>
        <template #project-buildings="{ row }">
          <div class="building-labels">
            <el-tag v-for="label in row.buildingLabels.slice(0, 3)" :key="label" effect="plain">{{ label }}</el-tag>
            <el-tag v-if="row.buildingLabels.length > 3" type="info" effect="plain">+{{ row.buildingLabels.length - 3 }}</el-tag>
            <span v-if="!row.buildingLabels.length" class="muted">未关联楼栋</span>
          </div>
        </template>
        <template #project-parks="{ row }"><el-tag :type="parkCount(row as AssetProject) > 1 ? 'warning' : 'info'" effect="plain">{{ parkCount(row as AssetProject) }} 个</el-tag></template>
        <template #project-status="{ row }"><el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? "启用" : "停用" }}</el-tag></template>
        <template #project-actions="{ row }"><el-button v-hasPerm="'asset:project:update'" link type="primary" @click="openEdit(row as AssetProject)">编辑</el-button><el-button v-hasPerm="'asset:project:delete'" link type="danger" @click="removeRow(row as AssetProject)">删除</el-button></template>
      </VxeGrid>
      </div>
      <pagination
        v-if="filteredProjects.length > 0"
        :total="filteredProjects.length"
        v-model:page="pageNum"
        v-model:limit="pageSize"
        class="page-pagination"
      />
    </el-card>
    <el-dialog v-model="visible" :title="editingId ? '编辑项目' : '新增项目'" width="680px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="98px">
        <el-form-item label="项目编号" prop="code"><el-input v-model="form.code" maxlength="64" /></el-form-item>
        <el-form-item label="项目名称" prop="name"><el-input v-model="form.name" maxlength="150" /></el-form-item>
        <el-form-item label="关联楼栋" prop="buildingIds">
          <el-select v-model="form.buildingIds" multiple filterable collapse-tags collapse-tags-tooltip placeholder="按园区 / 楼栋搜索并选择" class="building-select">
            <el-option v-for="item in buildingOptions" :key="item.id" :label="`${item.parkName} / ${item.name} (${item.code})`" :value="item.id" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="selectedParks.length" label="覆盖园区"><div class="park-tags"><el-tag v-for="name in selectedParks" :key="name" effect="plain">{{ name }}</el-tag></div></el-form-item>
        <el-form-item label="状态"><el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="启用" inactive-text="停用" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" :rows="3" maxlength="500" show-word-limit /></el-form-item>
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
import AssetAPI, { type AssetBuildingOption, type AssetForm, type AssetId, type AssetProject } from "@/api/asset";
import { configureVxeUI } from "@/plugins/vxe-table";

defineOptions({ name: "AssetProjects", inheritAttrs: false });
configureVxeUI();

const projects = ref<AssetProject[]>([]);
const buildingOptions = ref<AssetBuildingOption[]>([]);
const query = reactive<{ keyword: string; status?: number }>({ keyword: "", status: undefined });
const appliedQuery = ref({ keyword: "", status: undefined as number | undefined });
const pageNum = ref(1);
const pageSize = ref(10);
const filteredProjects = computed(() => projects.value.filter((project) => {
  const keyword = appliedQuery.value.keyword.trim().toLowerCase();
  const matchesKeyword = !keyword || `${project.name} ${project.code}`.toLowerCase().includes(keyword);
  const matchesStatus = appliedQuery.value.status === undefined || project.status === appliedQuery.value.status;
  return matchesKeyword && matchesStatus;
}));
const pageList = computed(() => {
  const start = (pageNum.value - 1) * pageSize.value;
  return filteredProjects.value.slice(start, start + pageSize.value);
});
const loading = ref(false);
const visible = ref(false);
const saving = ref(false);
const editingId = ref<AssetId>();
const formRef = ref<FormInstance>();
const form = reactive<AssetForm>({ code: "", name: "", buildingIds: [], status: 1, remark: "" });
const rules: FormRules = {
  code: [{ required: true, message: "请输入项目编号", trigger: "blur" }],
  name: [{ required: true, message: "请输入项目名称", trigger: "blur" }],
  buildingIds: [{ type: "array", required: true, min: 1, message: "请至少选择一栋楼", trigger: "change" }],
};
const gridOptions: VxeGridProps<AssetProject> = {
  columns: [
    { field: "name", title: "项目", minWidth: 190, slots: { default: "project-name" } },
    { field: "buildingLabels", title: "关联楼栋", minWidth: 320, slots: { default: "project-buildings" } },
    { field: "parkCount", title: "覆盖园区", width: 120, slots: { default: "project-parks" } },
    { field: "status", title: "状态", width: 95, slots: { default: "project-status" } },
    { field: "updateTime", title: "最近更新", width: 170 },
    { field: "actions", title: "操作", width: 145, fixed: "right", showOverflow: false, slots: { default: "project-actions" } },
  ],
  rowConfig: { keyField: "id", isHover: true },
  columnConfig: { resizable: true, minWidth: 90 },
  emptyText: "暂无项目",
};
const selectedParks = computed(() => {
  const selected = new Set(form.buildingIds ?? []);
  return [...new Set(buildingOptions.value.filter((item) => selected.has(item.id)).map((item) => item.parkName))];
});

function parkCount(project: AssetProject): number {
  const selected = new Set(project.buildingIds);
  return new Set(buildingOptions.value.filter((item) => selected.has(item.id)).map((item) => item.parkId)).size;
}

async function loadData(): Promise<void> {
  loading.value = true;
  try {
    const [projectRows, options] = await Promise.all([AssetAPI.getProjects(), AssetAPI.getBuildingOptions()]);
    projects.value = projectRows;
    buildingOptions.value = options;
  } catch { ElMessage.error("项目数据加载失败"); } finally { loading.value = false; }
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
  Object.assign(form, { code: "", name: "", buildingIds: [], status: 1, remark: "" });
  editingId.value = undefined;
}

function openCreate(): void { resetForm(); visible.value = true; }

function openEdit(row: AssetProject): void {
  resetForm(); editingId.value = row.id;
  Object.assign(form, { code: row.code, name: row.name, buildingIds: [...row.buildingIds], status: row.status, remark: row.remark });
  visible.value = true;
}

async function submit(): Promise<void> {
  if (!formRef.value) return;
  await formRef.value.validate(); saving.value = true;
  try {
    if (editingId.value) await AssetAPI.updateProject(editingId.value, form); else await AssetAPI.createProject(form);
    ElMessage.success("项目已保存"); visible.value = false; await loadData();
  } finally { saving.value = false; }
}

async function removeRow(row: AssetProject): Promise<void> {
  try {
    await ElMessageBox.confirm(`确定删除项目“${row.name}”吗？`, "确认删除", { type: "warning" });
    await AssetAPI.deleteProject(row.id); ElMessage.success("删除成功"); await loadData();
  } catch (error) { if (error !== "cancel") ElMessage.error(error instanceof Error ? error.message : "删除失败"); }
}

onMounted(loadData);
</script>

<style scoped lang="scss">
.name-cell { display: flex; flex-direction: column; gap: 4px; }
.name-cell small,.muted { color: var(--el-text-color-secondary); }
.building-labels,.park-tags { display: flex; flex-wrap: wrap; gap: 6px; }
.building-select { width: 100%; }
.asset-list-page :deep(.page-table-wrapper) { min-height: 350px; }
</style>
