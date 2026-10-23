<template>
  <web-view :src="monitorUrl" />
</template>

<script setup lang="ts">
definePage({
  name: "monitor",
  style: { navigationBarTitleText: "应用监控" },
  layout: "blank",
});
// SpringBoot Admin 监控地址，生产环境在 .env.production 配置 VITE_APP_MONITOR_URL
const monitorUrl = import.meta.env.VITE_APP_MONITOR_URL || "http://localhost:9090/wallboard";
</script>
