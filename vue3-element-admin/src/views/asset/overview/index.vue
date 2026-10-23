<!-- @page-id: asset-overview -->
<!-- @page-name: 园区概览 -->
<!-- @page-route: /building/overview -->
<template>
  <div class="page-container asset-overview">
    <el-card class="page-search overview-toolbar-card" shadow="never">
    <div class="asset-toolbar">
      <div>
        <h2>园区概览</h2>
        <span class="subtle">空间分布与房源使用情况</span>
      </div>
      <div class="toolbar-actions">
        <el-select v-model="parkId" placeholder="选择园区" class="park-select" @change="loadOverview">
          <el-option v-for="park in parks" :key="park.id" :label="park.name" :value="park.id" />
        </el-select>
        <el-button class="page-icon-btn" :loading="loading" aria-label="刷新" @click="loadOverview">
          <el-icon><Refresh /></el-icon>
        </el-button>
        <el-button v-hasPerm="'asset:building:update'" :type="editingLayout ? 'primary' : 'default'" @click="toggleLayoutEdit">
          {{ editingLayout ? "完成布局" : "调整图面" }}
        </el-button>
      </div>
    </div>
    </el-card>

    <el-card class="overview-metrics-card" shadow="never">
      <div class="metric-grid">
        <div v-for="item in metrics" :key="item.label" class="metric-item">
          <span>{{ item.label }}</span>
          <strong>{{ item.value }}</strong>
          <small>{{ item.note }}</small>
        </div>
      </div>
    </el-card>

    <el-card class="overview-map-card" shadow="never">
    <div class="overview-grid">
      <section class="map-section">
        <div class="section-heading">
          <div>
            <h3>{{ currentPark?.name || "园区示意图" }}</h3>
            <span>{{ currentPark?.address || "园区空间分布" }}</span>
          </div>
          <div class="map-legend"><i class="legend-region" />区域<i class="legend-building" />楼栋</div>
        </div>
        <div class="map-frame" :class="{ 'is-editing': editingLayout }">
          <svg
            ref="mapRef"
            class="park-map"
            viewBox="0 0 1000 600"
            role="img"
            aria-label="园区建筑分布示意图"
            @pointermove="moveBuilding"
            @pointerup="finishBuildingDrag"
            @pointercancel="finishBuildingDrag"
          >
            <defs>
              <pattern id="mapGrid" width="40" height="40" patternUnits="userSpaceOnUse">
                <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#e6ece7" stroke-width="1" />
              </pattern>
            </defs>
            <rect width="1000" height="600" rx="8" fill="#f7faf7" />
            <rect width="1000" height="600" rx="8" fill="url(#mapGrid)" />
            <path d="M0 474 H1000 M510 0 V600" stroke="#d8ded9" stroke-width="26" />
            <path d="M0 474 H1000 M510 0 V600" stroke="#fbfcfb" stroke-width="3" stroke-dasharray="12 12" />
            <g v-for="(region, index) in overview?.regions ?? []" :key="region.id">
              <rect
                :x="region.mapX"
                :y="region.mapY"
                :width="region.mapWidth"
                :height="region.mapHeight"
                rx="10"
                :fill="regionColors[index % regionColors.length]"
                stroke="#9aada0"
                stroke-width="2"
                stroke-dasharray="7 5"
              />
              <text :x="region.mapX + 12" :y="region.mapY + 24" class="region-label">{{ region.name }}</text>
            </g>
            <g
              v-for="building in overview?.buildings ?? []"
              :key="building.id"
              class="building-mark"
              :class="{
                'is-selected': selectedBuilding?.id === building.id,
                'is-draggable': editingLayout,
              }"
              :transform="`translate(${building.mapX}, ${building.mapY})`"
              @click="selectBuilding(building)"
              @pointerdown.stop.prevent="startBuildingDrag($event, building)"
            >
              <rect :width="building.mapWidth" :height="building.mapHeight" rx="5" />
              <text :x="building.mapWidth / 2" :y="building.mapHeight / 2 - 2" text-anchor="middle">
                {{ building.name }}
              </text>
              <text :x="building.mapWidth / 2" :y="building.mapHeight / 2 + 15" text-anchor="middle" class="building-code">
                {{ building.code }}
              </text>
            </g>
            <text x="950" y="570" text-anchor="end" class="north-label">N ↑</text>
          </svg>
        </div>
        <div class="map-caption">
          <span v-if="editingLayout">拖动楼栋调整示意位置，松开后自动保存</span>
          <span v-else>当前为示意布局，位置不代表测绘比例</span>
          <span>{{ overview?.regions.length ?? 0 }} 个区域 · {{ overview?.buildings.length ?? 0 }} 栋楼</span>
        </div>
      </section>

      <aside class="building-aside">
        <div class="section-heading">
          <div><h3>楼栋列表</h3><span>按图面位置查看</span></div>
          <el-button link type="primary" @click="goBuildings">管理楼栋</el-button>
        </div>
        <el-scrollbar class="building-list-scroll">
          <button
            v-for="building in overview?.buildings ?? []"
            :key="building.id"
            class="building-row"
            :class="{ active: selectedBuilding?.id === building.id }"
            @click="selectBuilding(building)"
          >
            <span class="building-dot" />
            <span class="building-row-main"><strong>{{ building.name }}</strong><small>{{ building.code }} · {{ building.buildingType || "未分类" }}</small></span>
            <span class="building-area">{{ building.area ? `${building.area} m²` : "-" }}</span>
          </button>
          <el-empty v-if="!overview?.buildings.length" description="暂无楼栋" :image-size="88" />
        </el-scrollbar>
        <div v-if="selectedBuilding" class="selected-building">
          <div class="selected-heading"><strong>{{ selectedBuilding.name }}</strong><el-tag size="small" :type="selectedBuilding.status === 1 ? 'success' : 'info'">{{ selectedBuilding.status === 1 ? "使用中" : "停用" }}</el-tag></div>
          <div>{{ selectedBuilding.code }} · {{ selectedBuilding.area ? `${selectedBuilding.area} m²` : "面积未录入" }}</div>
          <div>{{ selectedRegionName || "未分配区域" }}</div>
          <el-button link type="primary" @click="goBuildingDetail">查看楼层与房源</el-button>
        </div>
      </aside>
    </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ElMessage } from "element-plus";
import { Refresh } from "@element-plus/icons-vue";
import AssetAPI, { type AssetBuilding, type AssetId, type AssetOverview, type AssetPark } from "@/api/asset";

defineOptions({ name: "AssetOverview", inheritAttrs: false });

const router = useRouter();
const parks = ref<AssetPark[]>([]);
const parkId = ref<AssetId>();
const overview = ref<AssetOverview>();
const currentPark = computed(() => parks.value.find((park) => park.id === parkId.value));
const selectedBuilding = ref<AssetBuilding>();
const selectedRegionName = computed(
  () => overview.value?.regions.find((region) => region.id === selectedBuilding.value?.regionId)?.name
);
const loading = ref(false);
const editingLayout = ref(false);
const mapRef = ref<SVGSVGElement>();
const regionColors = ["#e8f1e7", "#eef1e8", "#e5efed", "#f0f2e9", "#e8eee5"];
const dragState = ref<{ building: AssetBuilding; startX: number; startY: number; initialX: number; initialY: number }>();

const metrics = computed(() => [
  { label: "园区", value: overview.value?.parkCount ?? 0, note: "当前租户" },
  { label: "区域", value: overview.value?.regionCount ?? 0, note: "功能分区" },
  { label: "楼栋", value: overview.value?.buildingCount ?? 0, note: "已建档" },
  { label: "楼层", value: overview.value?.floorCount ?? 0, note: "楼栋内管理" },
  { label: "可用房源", value: overview.value?.availableSpaceCount ?? 0, note: `共 ${overview.value?.spaceCount ?? 0} 套` },
  { label: "已出租", value: overview.value?.leasedSpaceCount ?? 0, note: "房源状态统计" },
]);

async function loadOverview(): Promise<void> {
  loading.value = true;
  try {
    const [parkList, data] = await Promise.all([AssetAPI.getParks(), AssetAPI.getOverview(parkId.value)]);
    parks.value = parkList;
    if (parkId.value === undefined && parkList.length) {
      parkId.value = parkList[0].id;
      overview.value = await AssetAPI.getOverview(parkId.value);
    } else {
      overview.value = data;
    }
    if (!overview.value?.buildings.some((building) => building.id === selectedBuilding.value?.id)) {
      selectedBuilding.value = overview.value?.buildings[0];
    }
  } catch {
    ElMessage.error("园区概览加载失败");
  } finally {
    loading.value = false;
  }
}

function selectBuilding(building: AssetBuilding): void {
  selectedBuilding.value = building;
}

function startBuildingDrag(event: PointerEvent, building: AssetBuilding): void {
  selectBuilding(building);
  if (!editingLayout.value || !mapRef.value) return;
  (event.currentTarget as SVGGElement).setPointerCapture(event.pointerId);
  dragState.value = {
    building,
    startX: event.clientX,
    startY: event.clientY,
    initialX: building.mapX,
    initialY: building.mapY,
  };
}

function moveBuilding(event: PointerEvent): void {
  if (!dragState.value || !mapRef.value) return;
  const rect = mapRef.value.getBoundingClientRect();
  const dx = ((event.clientX - dragState.value.startX) / rect.width) * 1000;
  const dy = ((event.clientY - dragState.value.startY) / rect.height) * 600;
  const building = dragState.value.building;
  const region = overview.value?.regions.find((item) => item.id === building.regionId);
  const minX = region?.mapX ?? 0;
  const minY = region?.mapY ?? 0;
  const maxX = region ? region.mapX + region.mapWidth - building.mapWidth : 1000 - building.mapWidth;
  const maxY = region ? region.mapY + region.mapHeight - building.mapHeight : 600 - building.mapHeight;
  building.mapX = Math.round(Math.max(minX, Math.min(maxX, dragState.value.initialX + dx)));
  building.mapY = Math.round(Math.max(minY, Math.min(maxY, dragState.value.initialY + dy)));
}

async function finishBuildingDrag(): Promise<void> {
  if (!dragState.value) return;
  const { building, initialX, initialY } = dragState.value;
  dragState.value = undefined;
  if (building.mapX === initialX && building.mapY === initialY) return;
  try {
    await AssetAPI.updateBuildingLayout(building.id, {
      mapX: building.mapX,
      mapY: building.mapY,
      mapWidth: building.mapWidth,
      mapHeight: building.mapHeight,
    });
  } catch {
    building.mapX = initialX;
    building.mapY = initialY;
    ElMessage.error("图面位置保存失败");
  }
}

function toggleLayoutEdit(): void {
  editingLayout.value = !editingLayout.value;
}

function goBuildings(): void {
  router.push({ path: "/building/buildings", query: { parkId: parkId.value } });
}

function goBuildingDetail(): void {
  if (!selectedBuilding.value) return;
  router.push({ path: "/building/buildings", query: { buildingId: selectedBuilding.value.id } });
}

onMounted(loadOverview);
</script>

<style scoped lang="scss">
.asset-overview {
  display: flex;
  flex-direction: column;
  gap: var(--page-gap);
}

.overview-toolbar-card,
.overview-metrics-card { flex-shrink: 0; }
.overview-toolbar-card :deep(.el-card__body) { padding: 12px 16px; }
.overview-metrics-card :deep(.el-card__body) { padding: 0 16px; }
.overview-map-card { flex: 1 1 0; min-height: 0; overflow: hidden; }
.overview-map-card :deep(.el-card__body) { height: 100%; padding: 0; }

.asset-toolbar,
.toolbar-actions,
.section-heading,
.map-legend,
.selected-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.asset-toolbar h2,
.section-heading h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.subtle,
.section-heading span,
.map-caption,
.selected-building {
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.toolbar-actions { justify-content: flex-end; }
.park-select { width: 220px; }

.metric-grid {
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
}

.metric-item {
  display: flex;
  min-height: 86px;
  flex-direction: column;
  justify-content: center;
  gap: 5px;
  padding: 16px 20px;
  border-right: 1px solid var(--el-border-color-lighter);
}

.metric-item:last-child { border-right: 0; }
.metric-item span,
.metric-item small { color: var(--el-text-color-secondary); font-size: 12px; }
.metric-item strong { color: var(--el-text-color-primary); font-size: 24px; line-height: 1.1; }

.overview-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 330px;
  height: 100%;
  min-height: 360px;
  overflow: hidden;
}

.map-section { min-width: 0; padding: 16px; border-right: 1px solid var(--el-border-color-lighter); }
.section-heading { margin-bottom: 12px; }
.section-heading > div:first-child { display: flex; flex-direction: column; gap: 4px; }
.map-legend { justify-content: flex-end; color: var(--el-text-color-secondary); font-size: 12px; }
.map-legend i { width: 12px; height: 12px; margin-left: 10px; border-radius: 2px; }
.legend-region { border: 1px dashed #7e9a82; background: #e8f1e7; }
.legend-building { border: 1px solid #6f9691; background: #dcebe8; }

.map-frame { overflow: hidden; width: 100%; border: 1px solid #dfe7e1; background: #f7faf7; }
.park-map { display: block; width: 100%; height: auto; aspect-ratio: 5 / 3; touch-action: none; }
.region-label { fill: #5b7261; font-size: 15px; font-weight: 600; }
.building-mark rect { fill: #dcebe8; stroke: #6f9691; stroke-width: 2; transition: fill 0.15s, stroke-width 0.15s; }
.building-mark text { fill: #2f5652; font-size: 14px; font-weight: 600; pointer-events: none; }
.building-mark text.building-code { fill: #67807d; font-size: 10px; font-weight: 400; }
.building-mark.is-selected rect { fill: #f8e8c8; stroke: #c28b38; stroke-width: 3; }
.building-mark.is-draggable { cursor: move; }
.is-editing .building-mark rect { stroke-dasharray: 5 3; }
.north-label { fill: #718078; font-size: 12px; }
.map-caption { display: flex; justify-content: space-between; gap: 10px; margin-top: 10px; }

.building-aside { display: flex; min-height: 0; flex-direction: column; padding: 18px 16px; }
.building-list-scroll { flex: 1; min-height: 180px; }
.building-row {
  display: flex;
  width: 100%;
  min-height: 62px;
  align-items: center;
  gap: 10px;
  padding: 9px 8px;
  border: 0;
  border-bottom: 1px solid var(--el-border-color-lighter);
  background: transparent;
  color: inherit;
  text-align: left;
  cursor: pointer;
}

.building-row:hover,
.building-row.active { background: #f3f7f4; }
.building-dot { width: 9px; height: 9px; flex: 0 0 auto; border: 2px solid #6f9691; background: #dcebe8; }
.building-row-main { display: flex; min-width: 0; flex: 1; flex-direction: column; gap: 4px; }
.building-row-main strong { overflow: hidden; color: var(--el-text-color-primary); font-size: 13px; text-overflow: ellipsis; white-space: nowrap; }
.building-row-main small,.building-area { color: var(--el-text-color-secondary); font-size: 12px; }
.building-area { white-space: nowrap; }
.selected-building { display: flex; flex-direction: column; gap: 8px; padding: 14px 8px 0; border-top: 1px solid var(--el-border-color-lighter); }
.selected-heading strong { color: var(--el-text-color-primary); font-size: 14px; }
.selected-heading { justify-content: flex-start; }

@media (max-width: 1100px) {
  .metric-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); }
  .metric-item:nth-child(3) { border-right: 0; }
  .metric-item:nth-child(n + 4) { border-top: 1px solid var(--el-border-color-lighter); }
}

@media (max-width: 820px) {
  .overview-grid { grid-template-columns: minmax(0, 1fr); }
  .map-section { border-right: 0; border-bottom: 1px solid var(--el-border-color-lighter); }
  .building-aside { min-height: 380px; }
}

@media (max-width: 600px) {
  .asset-toolbar { align-items: flex-start; flex-direction: column; }
  .toolbar-actions { width: 100%; justify-content: flex-start; }
  .park-select { min-width: 0; flex: 1; }
  .metric-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .metric-item:nth-child(odd) { border-right: 1px solid var(--el-border-color-lighter); }
  .metric-item:nth-child(even) { border-right: 0; }
  .metric-item:nth-child(n + 3) { border-top: 1px solid var(--el-border-color-lighter); }
  .map-caption { align-items: flex-start; flex-direction: column; }
}
</style>
