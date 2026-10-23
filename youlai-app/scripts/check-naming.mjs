import { readdirSync } from "node:fs";
import { join, relative, sep } from "node:path";

/**
 * 文件命名检查
 *
 * 自有 Vue 文件用 PascalCase；pages / subPages 下的 index.vue 是路由入口，按目录命名；
 * App.vue、layouts 与第三方目录（qiun-*）不参与检查。
 */
const SRC = join(process.cwd(), "src");

// 路由入口目录：其中的 index.vue 是页面
const ROUTE_DIRS = ["pages", "subPages"];

const PASCAL_CASE = /^[A-Z][A-Za-z0-9]*\.vue$/;

function walk(dir, files = []) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const fullPath = join(dir, entry.name);
    if (entry.isDirectory()) walk(fullPath, files);
    else if (entry.name.endsWith(".vue")) files.push(fullPath);
  }
  return files;
}

const offenders = [];

for (const file of walk(SRC)) {
  const rel = relative(SRC, file).split(sep).join("/");
  const segments = rel.split("/");
  const name = segments[segments.length - 1];

  // 第三方组件与框架文件
  if (segments.some((segment) => segment.startsWith("qiun-"))) continue;
  if (rel === "App.vue" || rel.startsWith("layouts/")) continue;

  // 路由入口 index.vue，其余 index.vue 视为组件目录入口
  if (name === "index.vue") {
    if (!ROUTE_DIRS.includes(segments[0])) offenders.push(rel);
    continue;
  }

  if (!PASCAL_CASE.test(name)) offenders.push(rel);
}

if (offenders.length > 0) {
  console.log("文件名不符合 PascalCase：");
  for (const file of offenders) console.log(`  ${file}`);
  console.log("\n自有 Vue 组件用 PascalCase；路由入口保持 index.vue。");
  process.exit(1);
}

console.log("文件名检查通过（自有 Vue 文件均为 PascalCase）");
