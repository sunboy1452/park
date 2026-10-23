# 命名与注释审计（2026-10-16）

对未提交改动文件的命名、类型与注释核查，标准依据 `mobile-ui-code-review-2026-10-04.md` 与 Vue 官方风格指南。
全部修复后 `pnpm check`（type-check / templates / eslint+prettier / stylelint）通过，旧名残留扫描为 0。

## 1. 方法命名（已修复）

| 文件 | 原名 | 现名 | 依据 |
| --- | --- | --- | --- |
| work/config/index.vue | `showConfigActions` | `openConfigActions` | 打开弹窗用 open |
| work/dict/index.vue | `showDictActions` | `openDictActions` | 同上 |
| work/dict/item/index.vue | `showItemActions` | `openItemActions` | 同上 |
| work/notice/index.vue | `showNoticeActions` | `openNoticeActions` | 同上 |
| work/role/index.vue | `showRoleActions` | `openRoleActions` | 同上 |
| work/user/index.vue | `showUserActions` | `openUserActions` | 同上 |
| work/dict/index.vue | `openDictItemPage` | `navigateToDictItem` | 页面导航不用 open |
| work/role/index.vue | `handleAssignPerm` | `navigateToAssignPerm` | 导航伪装 + handle 滥用 |
| work/dept/index.vue | `handleAddChild` | `openChildDeptDialog` | 打开弹窗，与 `openDeptDialog` 对齐 |
| work/menu/index.vue | `handleAddChild` | `openChildMenuDialog` | 同上 |
| pages/login/index.vue | `handleWechatSilentLogin` | `doWechatSilentLogin` | 与 `doFormLogin` / `doWechatPhoneLogin` 统一 |
| work/user/index.vue | `handleUserSubmit` | `submitUserForm` | 与其余 7 页 `submitXxxForm` 统一 |
| subPages/mine/about/index.vue | `openUrl` | `openExternalUrl` | 非 H5 端实际是复制链接，补行为注释 |
| subPages/mine/settings/theme/index.vue | `showCustomInput` | `openCustomColorInput` | 打开弹窗用 open，与 ref 名区分 |
| subPages/mine/account/index.vue | `handleOpenDialog` | `handleOpenPopup` | 打开的是 wd-popup，术语修正 |
| subPages/mine/profile/index.vue | `openDialog` | `openProfilePopup` | 同上 |

## 2. 变量与类型（已修复）

| 文件 | 原名 | 现名 | 依据 |
| --- | --- | --- | --- |
| subPages/mine/profile/complete-profile/index.vue | `cropperVisible` | `isCropperVisible` | 与 profile 页同名概念统一 |
| subPages/mine/settings/theme/index.vue | `showCustomColorInput` | `customColorInputVisible` | 布尔 ref 谓语风格 |
| subPages/mine/profile/index.vue | `dialogState` | `popup` | 与 account 页弹层状态统一 |
| pages/work/index.vue | 本地 `hasPermission` | `isMenuAllowed` | 与 utils 同名但空 perm 语义相反（本地视为公开入口），import 恢复 `hasPermission` 原名 |
| api/notice.ts | `level: string \| number` | `level: string` | 后端 NoticePageVO 为 String；`getLevelText` 参数同步收窄 |

## 3. api/notice.ts 类型与注释（已修复）

- 删除 `NoticeItem.priority`：后端 `NoticePageVO` 无此字段，前端零消费。
- 删除 `NoticeItem.content`：同上，详情内容来自 `NoticeDetail`。
- `targetType` 注释 `0-全体 1-指定` 改为 `1-全体 2-指定`，对齐 `NoticeTargetEnum`。
- `publishStatus` 注释 `2已撤回` 改为 `-1-已撤回`，对齐 `NoticePublishStatusEnum` 与页面判断逻辑。

## 4. 注释与死代码（已修复）

- subPages/mine/profile/index.vue：3 条复述变量名的行尾注释（`//用户信息` 等）删除。
- subPages/mine/profile/index.vue：`profile-last-cell-wrap` 死类名及包裹 view 删除。
- utils/storage.ts：挂在 `set` 上且不准确的 `/** localStorage 存储 */` 删除。
- subPages/mine/settings/theme/index.vue：`// 使用主题组合函数` 复述 import 的注释删除。

## 5. 保持原样（审计判定不改）

- `useTheme()` 转发层：是否保留属架构决策，命名本身合规。
- `usePagedList.fetchPage`：写多处状态但为模块私有实现，注释完备。
- `OfficialAccountCard` 的 `@open` 事件：注释已声明目标地址由父级决定，事件表达用户意图。
- `.is-active` / `.is-checked` 状态类：常见实践，与 BEM 并存。
- 头像选择三处命名（`chooseAvatar` / `handleChooseAvatar` / `handleAvatarUpload`）：choose 与 upload 语义有别。
- account 页 catch 静默取消与解绑失败：行为缺口，非注释错误。
- 两处文件私有 `interface NavItem`：同名不同构，均为局部类型。
- `sendVerificationCode` 的 `contactType`：可收窄为 `"MOBILE" | "EMAIL"`，影响小。
- mine 页 `router.push` 与 `uni.navigateTo` 并存：API 选择，非命名问题。
- menu 页 `@search` 直绑 `loadMenuList`：规范未强制事件回调必须 handle。
- dict/item 的 `tagComponentType`：可加 get 前缀，影响小。

## 6. 已确认合规的类别

- 谓词查询无副作用：`hasPermission`、`isValidMobile`、`isValidCapsuleRect`、`isExpanded` 等。
- `ensure`：`ensureAuthenticated`、`ensureUserInfoLoaded`。
- 导航：`navigateToProfile` / `navigateToAccountSecurity` / `navigateToOfficialAccount` 等。
- 弹窗 open/close：`openXxxDialog` / `closeXxxDialog` / `openResetPwdDialog` / `BindMobilePopup.open`。
- sync / reset / load / fetch / get / build / format 系列动词与行为一致。
- `handle` 全部用于模板事件绑定。
- API 层 `getXxx` 与业务动词（`publish` / `revoke` / `bindMobile` / `unbindSocial` 等）与行为一致。
- 布尔 ref 谓语风格、单位后缀（`contentHeightPx` 等）、枚举名词化、接口无 I 前缀。
- BEM 紧凑规则：`app-navbar__content--fixed`、`profile-card__login`、`quick-card__icon--primary`、`permissions__header` 等。
- 高价值注释保留：usePagedList 迟到响应策略、storage PRESERVED_KEYS 边界、useScanLogin 失败分类等。

## 7. 遗留问题（youlai-boot，未改）

- `NoticeDetailVO.java:36` 注释写「2已撤回」，与 `NoticePublishStatusEnum` 的 `-1` 及实体、查询对象注释矛盾。按约定不动 youlai-boot，需要修复时单独提交。

## 8. 评审文档 R1–R12 验收核对（2026-10-16）

| 编号 | 问题 | 结论 | 证据 |
| --- | --- | --- | --- |
| R1 | 扫码平台能力及错误被吞 | 已关闭 | `useScanLogin.ts` 按平台判断能力并提示，失败区分取消/权限/能力/其他 |
| R2 | 确认与取消并发 | 已关闭 | `scan-confirm` 单一 status 状态机，非 ready 直接返回，finished 后不再接受提交 |
| R3 | Button 旧参数 | 已关闭 | 全量扫描无裸 `plain`、无 `type="error"`，均为 `variant="plain"` |
| R4 | 模板检查关闭、shim 过宽 | 已关闭 | `tsconfig.templates.json` + `scripts/check-templates.mjs` 只统计 src；`wot-ui-component-shims.d.ts` 已删除 |
| R5 | 玻璃卡片降级与层级 | 已关闭 | ProfileCard 恒定玻璃底、`@supports` 内叠加模糊；theme.scss 标注层级表，普通内容 5 / 导航 15 / 全局遮罩 90 |
| R6 | 退出无过程反馈 | 已关闭 | `useLogout` 的 `isLoggingOut` 防重入 + `toast.loading` 过程反馈 |
| R7 | 重复 gutter、navbar 责任 | 已关闭 | 网络页去除重复 `px-32rpx`；`NavbarMetrics` 收缩为实际被消费的 6 项 |
| R8 | 登录与无权限混判 | 已关闭 | 首页未登录展示入口引导、已登录按权限过滤；工作台 `isMenuAllowed` 保留公开入口语义 |
| R9 | 网络检测文案与行为 | 已关闭 | 探测指向接口服务地址，不可达显示「不可访问」，耗时与失败状态分开 |
| R10 | ActionSheet label 兼作 ID | 已关闭 | 命令模型 `id / label / execute`，按索引分发（本轮重构为 `ActionSheet` 组件） |
| R11 | font-bold 重定义、主色衍生、warning 错配 | 已关闭 | `unocss.config.ts` 无 font-bold shortcut；主色衍生由 AppProvider 按所选主色注入；MenuSection 的 tone 映射 `--color-warning` |
| R12 | 命名与注释缺统一约定 | 已关闭 | 本文档 1–4 节；文件名检查落地为 `scripts/check-naming.mjs` |

## 9. 已接入的自动检查

- `scripts/check-templates.mjs`：模板类型检查，只统计 src 下的错误。
- `scripts/check-naming.mjs`：自有 Vue 文件 PascalCase；路由 `index.vue`、`App.vue`、`layouts`、第三方 `qiun-*` 除外。
- 两者已加入 `pnpm check`。

评审 13 节其余可自动检查项（BEM 选择器格式、旧 Wot 参数、宽泛全局选择器、UnoCSS 工具项阈值提示）暂未实现，保留为人工审阅。
