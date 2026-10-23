import { spawnSync } from "node:child_process";
import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";

/**
 * 模板类型检查
 *
 * 开启 strictTemplates 后 @wot-ui/ui 内部 SFC 模板会报错，工程无法只针对自有文件检查，
 * 因此这里跑 tsconfig.templates.json 并只统计 src 下的错误，第三方报错不参与退出码。
 *
 * 组件声明由 vite 插件在 build / dev 时生成，这里只做一次新鲜度提示，避免用过期声明误判。
 */
const componentsDts = join(process.cwd(), "src", "types", "components.d.ts");

// 递归找出 src 下最新的 .vue 修改时间
function latestVueMtime(dir) {
  let latest = 0;
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const fullPath = join(dir, entry.name);
    if (entry.isDirectory()) {
      latest = Math.max(latest, latestVueMtime(fullPath));
    } else if (entry.name.endsWith(".vue")) {
      latest = Math.max(latest, statSync(fullPath).mtimeMs);
    }
  }
  return latest;
}

try {
  const dtsMtime = statSync(componentsDts).mtimeMs;
  if (latestVueMtime(join(process.cwd(), "src")) > dtsMtime) {
    console.log("提示：src 下有比 src/types/components.d.ts 更新的 .vue，组件声明可能过期");
    console.log("      先执行 pnpm build:h5 或 pnpm dev:h5 重新生成声明\n");
  }
} catch {
  console.log("提示：未找到 src/types/components.d.ts，请先执行 pnpm build:h5 生成声明\n");
}

const vueTscBin = join(process.cwd(), "node_modules", "vue-tsc", "bin", "vue-tsc.js");
const result = spawnSync(
  process.execPath,
  [vueTscBin, "--noEmit", "-p", "tsconfig.templates.json"],
  { encoding: "utf-8" }
);

const output = `${result.stdout || ""}${result.stderr || ""}`;
const errors = output.split(/\r?\n/).filter((line) => /^src[/\\].*error TS/.test(line));

if (errors.length > 0) {
  console.log(errors.join("\n"));
  console.log(`\n模板类型检查未通过：src 下共 ${errors.length} 处错误`);
  process.exit(1);
}

console.log("模板类型检查通过（只统计 src 下的文件）");
