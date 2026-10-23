<template>
  <wd-action-sheet v-model="visible" :actions="options" cancel-text="取消" @select="handleSelect" />
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useToast } from "@wot-ui/ui";
import { getErrorMessage } from "@/utils/error";

/**
 * 操作菜单命令
 *
 * id 是分发身份，label 只用于展示，两者不共用。
 */
export interface ActionSheetCommand {
  id: string;
  label: string;
  color?: string;
  /** 选中后执行的动作，返回的 Promise 会被分发处捕获 */
  execute: () => void | Promise<void>;
}

const toast = useToast();

/** 菜单显隐 */
const visible = ref(false);
/** 展示给 wd-action-sheet 的选项，name 填展示文案 */
const options = ref<{ name: string; color?: string }[]>([]);
// 与 options 同序的命令表，选中后按索引取回
let commands: ActionSheetCommand[] = [];

/**
 * 展示操作菜单
 *
 * 列表为空说明当前账号没有可用操作，提示后不再弹出空菜单。
 *
 * @param list - 按当前账号权限拼装的操作命令
 */
function open(list: ActionSheetCommand[]) {
  if (list.length === 0) {
    toast.warning("暂无操作权限");
    return;
  }

  commands = list;
  options.value = list.map(({ label, color }) => ({ name: label, color }));
  visible.value = true;
}

// 组件回传的是选项索引，按索引取回命令，不按展示文案反查；执行失败在此统一提示
function handleSelect({ index }: { index: number }) {
  const command = commands[index];
  if (!command) return;

  Promise.resolve(command.execute()).catch((error) => {
    toast.error(getErrorMessage(error, "操作失败"));
  });
}

defineExpose({ open, visible });
</script>
