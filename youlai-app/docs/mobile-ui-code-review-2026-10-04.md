# 移动端布局与工程一致性评审

**综合评分：6.5 / 10，按严格命名、职责和样式一致性标准评估。**

复核日期：2026-10-06。初版日期：2026-10-04。代码基线仍为 `1e3954c`。本文已根据命名长度与 UnoCSS 使用边界的反馈再次修订，文件名保留初次创建日期；目标名称、目录和代码片段都是后续调整建议。评分沿用上一轮，不因这次风格约定修改而反复变动。

我认可初版的大部分事实判断，但不完全认可其评价尺度。扫码异常处理、旧组件参数、重复内边距、模板检查缺口都有代码依据；退出按钮位置、社区卡片顺序、圆角和阴影则存在产品取舍。不能将一种审美偏好包装成客观缺陷，也不能将未实测的遮挡写成已发生的故障。

初版的综合 6.8 分适用于一般维护标准，“命名一致性 8 分”对本项目的严格要求偏宽。本版将文件命名、函数语义、状态模型、样式归属和例外管理放进同一套标准重新评价。分数变化来自评价标准调整，不代表这两天代码变差。分数属于评审判断，不是自动测评或行业排名。

## 1. 评分、范围与判断方式

| 维度                  | 得分 / 10 | 主要依据                                                         |
| --------------------- | --------: | ---------------------------------------------------------------- |
| 布局职责              |       7.0 | 三类 layout 有合理分工，页面与壳的尺寸责任仍有重叠               |
| 交互完整性            |       6.0 | 退出确认和分页状态具备基础，扫码能力、异常分类与操作互斥存在缺口 |
| 文件、方法与类型命名  |       6.0 | 能读懂，但词汇、动作副作用、实体标识和显示名称没有稳定约定       |
| 样式归属与设计变量    |       6.5 | 有语义色及可读的局部 BEM，全局穿透、工具类别名与使用边界需治理   |
| Vue / TypeScript 约束 |       6.0 | 脚本严格模式存在，模板检查关闭、部分 ref 和 shim 过宽            |
| 注释质量              |       7.5 | 有解释约束的好注释，也有名实不符和重复代码的说明                 |

六项等权平均为 6.5。严格标准下最需要提高的是一致性，不是注释数量或目录数量。

评审以本地源码和安装的 `@wot-ui/ui@2.3.2` 为依据。覆盖首页、工作台、个人中心、扫码确认、代表性设置与管理页面，以及 layouts、composables、公共样式、主题和配置。第三方图表代码不纳入项目自身的命名评分。

没有新增浏览器截图、微信开发者工具或 App 真机记录。本文用以下标记避免扩大结论：

- **事实**：能从当前源码或本地依赖直接确认。
- **风险**：有具体触发条件，实际表现需要运行端验证。
- **约定**：适合本项目严格要求的推荐标准，不宣称是唯一行业规范。

优先级：P1 优先处理行为错误与约束缺口；P2 统一职责和命名；P3 整理低风险细节。代码风格问题不会仅因影响观感而升级为 P1。

## 2. 严格标准的核心：名称、行为、归属一致

对这个项目，我建议采用以下六条，而不是简单要求“全部名字更长”：

1. **同一层级、同一概念使用稳定词汇。** 业务导航与界面显隐有稳定动词，登录状态与在线状态分开；CSS 可使用已约定的短 block，不要求逐层展开完整领域名。
2. **名称必须准确表达能力。** `background` 可以包含渐变，`backgroundColor` 不应暗示可以传任意 background 简写；扫码获取票据也不等于完成登录。
3. **由完整使用方式判断是否清楚。** `UserAPI.getPage()`、`countdown.start()`已经有上下文，不需要重复成 `UserAPI.getUserPage()`、`countdown.startCountdown()`。
4. **一个规则有一个负责者。** 页面 gutter、主题变量、导航占位、错误提示都要有确定来源。
5. **约束优先于注释。** 有限菜单用联合类型；互斥动作使用共享状态；不会执行的参数应删除，不能只补一句说明。
6. **例外集中、可解释。** 框架入口、第三方 API、生成文件可以遵循自身规则。不要为了表面统一破坏路由或组件契约。

名称明确、状态正确、依赖可见、规则可检查，比制造大量小文件和转发函数更符合严格维护需求。

## 3. 先定业务词汇，避免改完又混用

以下用于区分业务含义，不要求所有名称复制整段词汇。页面标识、局部样式和对象方法可以使用已有上下文。

| 概念                   | 项目代码建议用词           | 说明                                       |
| ---------------------- | -------------------------- | ------------------------------------------ |
| 个人中心页面           | `mine`                     | 沿用现有页面标识，避免只为名称长度迁移词汇 |
| 昵称、头像、部门等资料 | `profile`                  | 不用来泛指所有账号功能                     |
| 密码、手机、邮箱绑定   | `accountSecurity`          | 当前 `openAccount()` 打开的实际内容        |
| 登录态和退出           | `session / authentication` | `isAuthenticated` 不等于在线或权限可用     |
| PC 二维码授权流程      | `qrLogin`                  | 统一方法与类型中的业务词汇                 |
| 相机扫描阶段           | `scanner / scan`           | 只负责获得二维码内容及进入后续流程         |
| 设置菜单               | `settingsMenu`             | 与后台权限菜单 `MenuItem` 区分             |
| 更多操作               | `actionSheet`              | 展示名称与动作 ID 独立                     |
| 导航栏                 | `navbar`                   | 避免自有名称中 `navBar/navbar` 无规则交替  |
| 导航测量数据           | `navbarMetrics`            | 与导航行为、路由跳转区分                   |
| 公众号介绍             | `officialAccount`          | 当前社区卡片实际跳转到公众号页             |

`mine`、`work`、`subPages` 保留现有路由含义；`mine` 也可以直接作为个人中心页面样式 block。`qr/dept/perm/bg/desc/nav` 等熟悉缩写纳入项目词汇表，保持一致，不机械展开。第三方 DTO 字段按协议保留。

## 4. 文件命名：按文件角色统一，减少无意义入口层

### 4.1 推荐规则

| 文件角色                      | 推荐规则                     | 示例                                           |
| ----------------------------- | ---------------------------- | ---------------------------------------------- |
| 普通 Vue 组件                 | PascalCase，体现职责         | `ProfileCard.vue`                              |
| 路由页面入口                  | 沿用现有目录及 `index.vue`   | `pages/mine/index.vue`                         |
| layout 注册文件               | 保留现有小写标识             | `default.vue / tabbar.vue / blank.vue`         |
| composable                    | `useXxx.ts`                  | `useNavbarMetrics.ts`                          |
| API、工具、配置、领域类型模块 | kebab-case；简单领域名可单词 | `user.ts / settings-menu.ts / storage-keys.ts` |
| 样式模块                      | kebab-case，体现作用         | `theme.scss / layouts.scss`                    |
| 类型、接口                    | PascalCase，领域明确         | `SettingsMenuItem / NavbarMetrics`             |
| 第三方和生成文件              | 保持上游规则                 | `qiun-data-charts.vue / auto-imports.d.ts`     |

PascalCase 组件文件名是本项目建议采用的约定，不是说现有 kebab-case 本身错误。如果采用这套规则，应覆盖自有普通组件，而不是只改几个喜欢的文件。

路由与 layout 入口不应盲目改名。也不必为每个 `index.vue` 再加一个只负责转发的 `AccountCenterPage.vue`，这种拆分增加跳转阅读成本。

### 4.2 建议的具体文件调整

以下把“统一文件格式”和“纠正语义”分开。已有名称准确时，只调整约定的大小写，不追加业务前缀。

| 现有文件                                                                                      | 推荐目标或处理                                           | 原因                                                           |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------------- | -------------------------------------------------------------- |
| [components/app-provider/index.vue](../src/components/app-provider/index.vue)                 | 采用普通组件文件规则时用 `AppProvider.vue`，保留组件名称 | 负责应用主题和反馈策略；页面实例作用域写进契约，不必靠改名解决 |
| [components/custom-navbar/index.vue](../src/components/custom-navbar/index.vue)               | `AppNavbar.vue`                                          | `custom` 只说明不是库组件，`App` 说明是项目导航栏              |
| [mine/components/profile-card.vue](../src/pages/mine/components/profile-card.vue)             | `ProfileCard.vue`                                        | `profile-card` 已准确，无需追加 `Summary` 或 `Account`         |
| [mine/components/quick-cards.vue](../src/pages/mine/components/quick-cards.vue)               | `QuickActions.vue`                                       | 表达快捷操作，不把当前卡片排布固化为组件职责                   |
| [mine/components/menu-section.vue](../src/pages/mine/components/menu-section.vue)             | `MenuSection.vue`                                        | 页面私有目录已经提供上下文，不必追加 `Settings`                |
| [mine/components/community-card.vue](../src/pages/mine/components/community-card.vue)         | `OfficialAccountCard.vue`                                | 实际内容及导航目标是公众号，`community` 范围过宽               |
| [login/components/bind-mobile-popup.vue](../src/pages/login/components/bind-mobile-popup.vue) | `BindMobilePopup.vue`                                    | 当前名称可读，统一格式即可；不要无理由切换 `mobile/phone`      |
| [work/components/custom-tree.vue](../src/subPages/work/components/custom-tree.vue)            | `TreeView.vue`                                           | 已被部门、菜单、权限页面复用，移除无意义的 `custom`            |
| [useNavbar.ts](../src/composables/useNavbar.ts)                                               | `useNavbarMetrics.ts`                                    | 输出设备尺寸与胶囊信息，确实需要区分测量和导航行为             |
| [useScanLogin.ts](../src/composables/useScanLogin.ts)                                         | 保留 `useScanLogin.ts`                                   | 已说明扫码登录入口；公开方法和注释说明扫描后进入确认页         |
| [useCacheCleaner.ts](../src/composables/useCacheCleaner.ts)                                   | 保留 `useCacheCleaner.ts`                                | 命名已经说明能力，没必要只为词性偏好替换成 Cleanup             |

不再推荐 `ProfileSummaryCard / AccountQuickActions / SettingsMenuSection` 这一组扩展名称。目录、组件名和接口应共同提供上下文，不必各自重复完整业务背景。导出到公共目录后出现实际歧义，再补足必要的领域词。

`UserAPI`、`Storage` 不需要仅因个人偏好统一改成另一种大小写。已有文件夹入口也不需要为了“全部扁平”立即迁移；目录内有配套资源时可以保留目录。

### 4.3 目录归属与拆文件条件

- 仅个人中心使用的组件、菜单配置和视图类型留在 `pages/mine` 附近。
- 跨多个工作台页面使用的 `TreeView` 留在工作分包，避免只为通用外观移进主包。移动文件时还需检查分包构建产物。
- 跨不同页面领域使用的导航与 Provider 放 `src/components`。
- 同一领域多个调用方共享的类型放就近模块；组件私有 Props、内部状态类型留在组件内。
- `index.ts` 只作为确有价值的模块导出入口，不给每个单文件组件增加一层目录。
- 不以固定行数作为拆分标准；按独立状态、独立依赖、复用范围和是否可单独理解决定。

本文推荐布局保留现有三类。现有 `useTheme()` 大部分方法只转发到 store，应先明确它是否提供额外的组件契约；如果没有，直接使用 store 更清楚，不要因为“所有业务都要有 hook”而保留转发层。

## 5. 方法命名：让读者预判副作用

### 5.1 动词约定

| 前缀或动词                          | 表达的行为                     | 约束                                                            |
| ----------------------------------- | ------------------------------ | --------------------------------------------------------------- |
| `is / has / can`                    | 查询或计算判断                 | 不发请求、不跳页面、不弹提示                                    |
| `get / format / parse / build`      | 获取已有数据或构造值           | 具体是否同步应由模块契约说明；项目 API 的 `getXxx` 允许远端请求 |
| `fetch`                             | 发起取数并返回结果             | 页面函数默认不隐式写多处 UI 状态                                |
| `load`                              | 取数并写入当前模块状态         | 命名明确加载对象                                                |
| `ensure`                            | 不满足前置条件时进行补齐或引导 | 返回结果及导航副作用要说明                                      |
| `navigateTo / switchTab / returnTo` | 页面导航                       | 不伪装成打开弹窗                                                |
| `open / close`                      | 显示或隐藏弹窗、操作面板       | 不同时用来指 URL 导航                                           |
| `reset`                             | 恢复初始值                     | 区分清空、取消和停止                                            |
| `sync`                              | 根据来源刷新已有状态           | 可重复执行，不暗示只初始化一次                                  |
| `handle`                            | 适配 UI 事件及其参数           | 不作为所有业务函数的统一前缀                                    |

业务动作可直接命名为 `logout / clearCache / confirmQrLogin`。不要为了满足 `handle` 规则再写一个同内容转发方法。

### 5.2 当前方法建议

| 当前名称                              | 推荐目标                      | 根据当前行为作出的判断                                    |
| ------------------------------------- | ----------------------------- | --------------------------------------------------------- |
| `openProfile()`                       | `navigateToProfile()`         | 实际跳资料页                                              |
| `openAccount()`                       | `navigateToAccountSecurity()` | 实际跳账号安全页                                          |
| `openOfficialAccount()`               | `navigateToOfficialAccount()` | 实际跳公众号页                                            |
| `scanLogin()`                         | `scanForLogin()`              | 扫码并进入确认页，尚未完成 PC 登录                        |
| `checkLogin()`                        | `ensureAuthenticated()`       | 缺少 token 时会跳登录页；`silent` 分支单独使用 store 判断 |
| `loadUserInfoIfNeeded()`              | `ensureUserInfoLoaded()`      | 已有资料时跳过，否则加载并写入 store                      |
| `initActive()`（tabbar）              | `syncActiveTab()`             | 在 mounted、onShow 都执行，是同步而非一次初始化           |
| `init()`（navbar metrics）            | `refreshMetrics()`            | 重读设备及胶囊数据，不承担应用初始化                      |
| `loadData()`（权限分配）              | `loadRolePermissions()`       | 明确页面所加载的业务组合                                  |
| `showActions()`                       | `openActionSheet()`           | 与打开界面动作统一                                        |
| `handleNavClick()`（导航 composable） | `navigate()`                  | 对外提供导航能力；UI 事件适配留在使用处                   |
| `clear()`（缓存 composable）          | `clearCache()`                | 避免 destructuring 后丢失对象上下文                       |

单表单组件内部的 `handleSubmit()` 可以保留；包含多个独立表单时应使用 `handlePasswordSubmit / handleEmailBindingSubmit`，或一个明确的业务分发函数。不是所有短名称都需要扩大。

`confirmLogout()` 当前弹确认框且执行退出，建议明确流程契约。若改名为 `requestLogout()`，它表示发起完整退出流程；若拆成 `confirmLogout()` 与 `logout()`，前者只返回确认结果，后者执行操作。不要只改名称而保留模糊的双重语义。

### 5.3 异步方法必须有一致的结果和错误责任

[useActionSheet](../src/composables/useActionSheet.ts) 的 `handler` 类型允许 Promise，但调用时未等待；`confirmAction()` 同一个 catch 覆盖确认取消和业务执行错误，注释却只说用户取消。名称干净也不能消除这个行为歧义。

推荐契约：明确谁等待执行、谁处理失败、谁显示提示。取消可静默；业务失败由既定责任方反馈。请求层已有提示时也应说明，不能把失败全部描述为取消。`Promise<boolean>` 只适合调用方只关心是否成功的场景；需要区分取消、失败和无权限时使用结果联合类型。

### 5.4 同类代码采用稳定的写法

建议命名业务函数使用函数声明，事件回调、数组回调及 computed getter 使用箭头函数；API 对象保留方法简写。这样可以减少同一文件中同类方法随意混用两种写法。这是项目约定，不是语言正确性要求。

SFC 统一按脚本、模板、样式排列；确有 uni-app 组件 options 需求时保留必要的第二个 script，并统一放置位置。脚本内部按依赖导入、页面声明、Props/事件、状态、派生值、动作、生命周期组织。只在段落较长时添加分节注释，不在每个 ref 前写“状态定义”。

格式细节交给现有 Prettier。不要再用人工规则与仓库已有的双引号、分号、缩进设置相互竞争。

## 6. 状态、类型与事件：标识不是显示文字

### 6.1 变量与类型调整

| 当前名称或模型                     | 推荐目标                                 | 说明                                                       |
| ---------------------------------- | ---------------------------------------- | ---------------------------------------------------------- |
| `name`（个人卡片 prop）            | `displayName`                            | 与账号 `username` 区分                                     |
| `avatar`（个人卡片 prop）          | 可保留；需要区分图片对象时用 `avatarUrl` | 在图片接口中含义明确，不要求所有字符串字段都加类型后缀     |
| `avatarShow`                       | `isCropperVisible`                       | 当前组件只有一个裁剪弹层，不必再重复 Avatar                |
| `active`（tabbar）                 | `activePath`                             | 当前值是路径；tabbar 已提供上下文                          |
| `visibleGridList`                  | `visibleGroups`                          | 表达筛选后的分组，不把当前 grid 排布写进数据名             |
| `MenuItem`（个人中心导出类型）     | `SettingsMenuItem`                       | 导出后可能与后台菜单实体混淆；纯私有类型可以用 `MenuItem`  |
| `DialogType / dialog`（账号页）    | `SecurityAction / popup`                 | 枚举表达安全动作，对象表达弹层；避免与 Wot Dialog 实例混淆 |
| `bgColor`（自有 navbar prop）      | `background`                             | 当前允许渐变，不能用 color 限定含义                        |
| `navBarHeight`（自有测量接口）     | `contentHeightPx`                        | 区分内容高度和包含状态栏的总高度                           |
| `totalHeight`（自有测量接口）      | `totalHeightPx`                          | 对外尺寸声明单位                                           |
| `menuButtonLeft`                   | `capsuleLeftPx`                          | 强调是坐标，不是左插槽宽度                                 |
| `countdown`（秒数 ref）            | `remainingSeconds`                       | 表达数值含义，区别于倒计时控制对象                         |
| `duration`（倒计时入参）           | `durationSeconds`                        | 公开参数明确单位                                           |
| `TOAST_DURATION`                   | `RETURN_DELAY_MS`                        | 实际控制延迟返回，没有设置 toast duration                  |
| `colorWithAlpha / colorWithAlpha2` | `heroStartColor / heroEndColor`          | 表达渐变端点，避免编号代表业务含义                         |

是否补词取决于歧义，不取决于名称是否足够“完整”。公开单位接口、多个单位共存或脱离上下文使用的值优先加单位；局部清楚的 `width` 可以保留。

`isLoading` 不是禁用词。单一取数模块可以用它；扫码确认页有加载、确认、取消等阶段，建议用一个有限状态 `status` 管理互斥关系，只有存在多个状态对象时再加 `qrLogin` 前缀。

### 6.2 两处比大小写更重要的问题

**问题一：在线与登录混淆。** [个人卡片](../src/pages/mine/components/profile-card.vue) 第 6 行用 `isAuthenticated` 控制 `profile-card__online-dot`。有 token 不证明用户在线。若保留这个装饰，应命名为认证状态标识；若用户可能理解成实时在线状态，建议删除，除非接入真实在线数据。

**问题二：操作菜单把 label 当作 ID。** [useActionSheet](../src/composables/useActionSheet.ts) 第 34 行使用 `menu.name` 构建 handler 映射，同名项会覆盖，文案调整也改变分发键。这是身份模型的问题，不只是把 `name` 改成 `label` 就能解决。

建议采用稳定的 `id`、可展示的 `label`、负责执行的 `execute`。Wot 的 `name` 字段在适配时填写 label；选中后按稳定 ID 或与 ID 关联的索引分发，不能再次按文案查找。

```ts
// 目标模型示意，不是现有实现。
interface ActionSheetCommand {
  id: string;
  label: string;
  execute: () => void | Promise<void>;
}
```

个人中心菜单 key 同样应定义为有限联合类型。导航项与操作项用判别字段区分，例如 `kind: 'route' | 'action'`。将 ID、显示信息、导航目标或业务动作放在同一个受类型约束的配置中，避免 `toolMenus` 和 `menuRoutes` 两份表独立维护。

### 6.3 事件用最短、准确的用户意图

当前 `<profile-card @profile="..." @login="..." @scan="..." />` 已经易读，可以保留。无需统一拉长成 `profile-click / qr-login-click`：组件上下文已说明来源，`click` 也不应把事件限定为某一种输入方式。

事件用 kebab-case；单词事件保持单词。多个不同扫描入口才区分 `login-scan / payment-scan`。父页面决定导航或业务动作，第三方 `click / select / confirm / update:modelValue` 按库契约保留。

组件同时 emit 返回事件并立即调用 `navigateBack()` 时，必须说明事件仅供通知。如果希望父页接管返回，提供明确接管契约，不能让双方都以为自己负责导航。

## 7. 样式类：短 block、准确元素、稳定规则

上一版将 `profile-card` 扩成 `profile-summary-card`、将个人中心类名全部扩成 `account-center-page__...`，增加了重复信息；“类名完整复制组件名”“每个组件只能一个 block”也过于机械。这些建议收回。严格维护应要求名称准确、归属清楚，而不是名称越长越好。

### 7.1 本项目采用的紧凑规则

| 对象       | 推荐规则                                           | 示例                                                    |
| ---------- | -------------------------------------------------- | ------------------------------------------------------- |
| 页面 block | 沿用短而明确的页面标识，不默认追加 `-page`         | `home / mine / permissions`                             |
| 组件 block | 通常 1–2 个词，保留已有准确名称                    | `profile-card / menu-section / quick-card / app-navbar` |
| 元素       | `block__element`，优先一个角色词，需要区分时再补词 | `profile-card__info / profile-card__avatar-wrap`        |
| 状态或变体 | `block--modifier` 或 `block__element--modifier`    | `profile-card--guest / quick-card__icon--primary`       |
| 缩写       | 使用小范围固定词汇，避免自造缩写                   | `qr / dept / perm / bg / desc / nav`                    |

“通常 1–2 个词”是控制重复信息的提示，不是硬性词数上限。确有必要的领域名可以更长。CSS block 不必机械复制组件文件名，例如 `QuickActions.vue` 内已有明确的 `quick-card` 可以保留。

`body / main / content / wrap / actions` 都是可用的结构词；只有不能区分用途或错误绑定布局方向时才需要改。`desc` 不必强行展开成 `description`，`bg` 不必一律展开成 `background`。同一含义保持一种写法即可；公开 prop 的 `background` 则需要准确表达可传渐变的能力。

一个 Vue 文件可以拥有 `menu-section` 和 `menu-row` 两个职责清楚的 block，不需要为了 BEM 拆出两个组件，也无需登记额外审批。避免同一批节点随意混用数套名字，而不是禁止多个 block。

SCSS 可用 `&__info` 等一层展开；避免生成 `block__body__title`，也不要依赖深层 DOM 链来表达元素身份。`scoped` 用于隔离，短 block 用于辨认归属。公共样式、Wot `custom-class`、小程序 shared 样式尤其应使用有辨识度的类名，不裸用 `.header/.button`。

### 7.2 修订后的具体类名建议

| 现有类名                                    | 推荐目标或处理                                 | 原因                                                       |
| ------------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------- |
| `.mine-hero / .mine-body`                   | `.mine__hero / .mine__body`                    | 在页面根补 `.mine`，统一页面元素写法，保留现有短词         |
| `.community-slot`                           | `.mine__community`                             | 属于个人中心页面的摆放区域，无需另造 slot block            |
| `.community-slot__bg`                       | `.mine__hero-bg`                               | 背景真实归属应移到 Hero，仅改名称不能解决定位依赖          |
| `.loading-center`                           | `.mine__cache-loading`                         | 标明用途，避免只有对齐方式的信息                           |
| `.profile-card`                             | **保留**                                       | 已经清楚，无需扩成 profile-summary-card                    |
| `.profile-card__left`                       | `.profile-card__avatar-wrap`                   | 实际是头像及状态点的容器，避免绑定左侧位置                 |
| `.profile-card__main`                       | `.profile-card__info`                          | 该处明确展示用户信息；main 本身不是禁用词                  |
| `.profile-card__scan`                       | **保留**                                       | 组件内只有一个扫描入口，按钮文案及事件契约说明扫码登录用途 |
| `.profile-card__action`                     | `.profile-card__login`                         | 是未登录入口，不是任意操作区                               |
| `.profile-card__button`                     | `.profile-card__login-button`                  | 区分入口容器与其中按钮                                     |
| `.profile-card__online-dot`                 | `.profile-card__auth-dot`，或删除              | 当前显示依据是登录态，没有在线状态数据                     |
| `.menu-list`                                | `.menu-section__list`                          | 容器归属明确，其余菜单行 block 可以保留                    |
| `.menu-row / .menu-row__desc`               | **保留**                                       | 行与说明都有明确含义，无需统一扩成 settings-menu-section   |
| `.quick-card__icon--info`                   | `.quick-card__icon--primary`                   | 修正真实颜色语义即可，不扩大整个 block                     |
| `.header / .bottom-bar`（权限页）           | `.permissions__header / .permissions__actions` | 增加短页面归属，actions 表达操作区域                       |
| `.tree-container / .node-content`（权限页） | `.permissions__tree / .permissions__node`      | 用途清楚，无需重复 role、page、container                   |
| `.custom-navbar`                            | `.app-navbar`                                  | 项目导航栏名称短且明确                                     |

保留 `mine-hero` 也不构成运行错误；本表的 BEM 调整是今后整理该模块时统一采用的约定，不建议单独做一轮全项目字符串替换。表中目标均写出完整类名，实际代码不使用省略前缀。

### 7.3 跨组件覆盖规则

[全局样式](../src/styles/index.scss) 的 `.page .wd-card` 覆盖所有该壳下的 Wot 卡片；`.popup-actions .wd-button`、筛选栏内部 `.wd-*` 规则也依赖库的内部节点。

建议依次选择：公开 props → CSS 变量 → `custom-class/custom-style` → 必要且局部限定的深度覆盖。深度覆盖说明具体原因及依赖的内部结构；整理时核对所用库版本。Wot 的 `custom-class` 是组件的样式入口，不能将它等同于普通 view 的 class，需确认目标节点和隔离规则。

公共模式只有在确实共享且含义稳定时才抽出。几行重复样式不自动要求新组件、新文件、`pattern-` 前缀或全局 shortcut。全局类使用清楚的业务或模式名，避免为了前缀而加前缀。

## 8. UnoCSS：默认最多 3 个工具项，复杂样式进局部类

### 8.1 先明确阈值的性质

**采用“简单节点最多 3 个 UnoCSS 工具项，4 个及以上默认提取语义类”作为本项目约定。** 这个阈值服务于模板可读性，不能宣称是 UnoCSS 官方规定或所有项目的通用标准。UnoCSS 的机制支持原子类及组合 shortcut，何时提取由项目自行约定。[官方 Shortcuts 文档](https://unocss.dev/config/shortcuts)

适用范围是自有模板中新增或正在整理的节点；不用为了计数单独批量翻新整个项目。工具类少也可以使用语义类，尤其页面与组件的主要结构应该容易被定位。

### 8.2 具体判断与计数

| 场景                                                   | 项目规则                                            |
| ------------------------------------------------------ | --------------------------------------------------- |
| 1–3 个工具项，只表达简单间距、尺寸、排布或单一文字处理 | 可以直接写模板；已有语义类不必删除                  |
| 同一节点 4 个及以上工具项                              | 默认提取为局部语义类，由该类承担这一组样式          |
| 渐变、伪元素、动效、交互状态、复杂主题配色或平台适配   | 不等到第 4 个，直接用语义类与局部 SCSS              |
| 相同组合仅在一个页面内使用                             | 先在页面内复用类，不搬进全局配置                    |
| 跨组件反复使用且设计含义稳定的组合                     | 才考虑公共 shortcut、样式模式或组件；按需要选择一种 |
| 第三方组件已有尺寸、颜色、variant 等公开参数           | 优先使用参数和变量，避免用工具类绕过组件契约        |

计数规则统一如下：

1. 数的是**同一节点的 UnoCSS 工具项**，不是 DOM 子元素数、CSS 声明数或 class 总数。`mine__body`、BEM modifier、库自有类不算 UnoCSS 工具项。
2. 静态 class 与动态绑定一起看；互斥分支按一次渲染可能出现的最大工具项数判断，不能把两个互斥分支相加。例如固定 2 项、每次再选 1 项，仍为 3。
3. Attributify 的多个值按等价工具项计数，不能将 4 项搬到属性、数组或 computed 后声称只有 1 项。变体工具项本身算 1 项，但复杂交互仍按上表提前提取。
4. 已有且经过确认的公共 shortcut 算 1 项，因为它代表一个固定契约；不允许为了绕过阈值，把每串工具类临时起名搬进全局。只在一个页面使用的 4 项组合直接放该页面 SCSS。

这是可读性边界，不是越少生成 CSS 越好的性能结论。后续自动检查可提示超过阈值的节点，动态绑定、平台分支和真实语义仍需要人工判断。

### 8.3 项目现有写法怎么判断

| 当前写法及位置                                     | 判断                    | 后续建议                                               |
| -------------------------------------------------- | ----------------------- | ------------------------------------------------------ |
| 工作台 `class="px-32rpx pt-16rpx"`                 | 2 项，简单内容留白      | **保留**                                               |
| 工作台图片 `class="w-72rpx h-72rpx rounded-8rpx"`  | 3 项，简单尺寸及圆角    | **可以保留**；形成统一图标角色后再命名                 |
| 首页 `class="grid grid-cols-2 gap-16rpx m-24rpx"`  | 4 项                    | 整理时提取 `.home__stats`                              |
| 首页 `class="w-full h-600rpx px-20rpx box-border"` | 4 项                    | 整理时提取 `.chart-wrapper__canvas`                    |
| 首页 `class="notice-bar m-24rpx"`                  | 1 个工具项 + 1 个语义类 | **保留**；当前 notice-bar 管内侧视觉，工具项管外侧间距 |
| 个人卡片的渐变、背景滤镜、降级配色                 | 复杂视觉组合            | 继续局部 SCSS，不改写成大串工具类                      |

提取的意思是**把一组样式的责任放进有名字的类**，不是在原来的长工具类串前再加一个名字。以首页统计区为例，下面只是后续改法示意：

```vue
<template>
  <view class="home__stats">
    <!-- 统计卡片 -->
  </view>
</template>

<style lang="scss" scoped>
.home__stats {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16rpx;
  margin: 24rpx;
}
</style>
```

示例保留当前间距数值以说明等价提取；后续统一设计变量时再使用对应档位。`home` 作为页面 block，不要求为此新建组件或样式文件。

### 8.4 语义类、原子类、shortcut 的责任边界

允许“语义类 + 少量工具类”，但**同一属性只有一个负责来源**。例如 notice-bar 自己管理背景、圆角、内边距，父页面用 `m-24rpx` 决定它与其他区块的间距，职责清楚。若该类已经管理 margin，就不要再叠加同属性工具项；同时注意 padding、margin 等简写与单边属性的重叠。

组件稳定的背景、边框、尺寸状态放该组件样式；父页面管理外部排布。不是所有 CSS 声明都要变成 UnoCSS，也不是用了 UnoCSS 就不能写普通 SCSS。

当前 [unocss.config.ts](../unocss.config.ts) 只配置 attributify 和 weapp class transformer，没有接入 directives transformer。因此本文使用现有可用的 scoped SCSS，不把 `@apply` 当作已经可用的方案。UnoCSS 的 `@apply` 需要相应 transformer；若以后选择接入，再按项目实际版本验证构建及端侧效果。[官方 Directives transformer 文档](https://unocss.dev/transformers/directives)

已有 `.color-primary` 等语义工具类可保留。若迁移到 UnoCSS 规则，应从公共 SCSS 移除重复定义并核对生成结果，不能同名双定义。动态 UnoCSS 类用完整候选值映射，避免运行时拼接无法静态发现的工具类；本地 SCSS modifier 则不需要 UnoCSS safelist。[官方提取说明](https://unocss.dev/guide/extracting)

**事实：** 配置将 `font-bold` shortcut 指向 `font-semibold`，初版已实际验证其输出为 600。应删除这个重定义，需要 600 时写 `font-semibold`。这是名实不符，不是阈值或长度偏好。

`flex-center` 可以作为已约定的高频组合保留。`flex-start / flex-end / flex-between` 还隐含交叉轴居中，若继续使用，应明确固定的 flex 方向与含义；零星使用时直接写 `flex items-center justify-start` 三项即可。不再推荐用 `u-row-start-center` 这类更长的自造名称替代。

### 8.5 设计变量不只统一颜色

推荐先约束页面 gutter、区块间距、卡片内边距、字号层级、圆角档位和层级。保留少量真正有用途的档位，例如普通控件、普通卡片、沉浸 Hero。不要为每个现有数值造一个 token，从而将随意值永久化。

已有 `--color-primary / --color-text-secondary / --z-navbar` 可以保留。主色衍生背景建议使用 `--color-primary-soft` 表达角色，避免 `primary-light` 同时指浅色主题和浅底强度。主题切换时一起更新主色、柔和背景及主色上的前景文字。

**事实：** Provider 目前更新 primary 及两种 alpha 值，但 `--color-primary-light` 仍是固定蓝色衍生值。菜单组件的 warning 还映射为 primary，虽然当前配置未使用 warning，也应删除这个错误映射或补齐正确语义。

建议 `styles/index.scss` 只负责按顺序装配。基础规则、layout 规则和稳定公共模式有足够独立内容时再拆；`theme.scss` 继续负责明暗变量和明确的 Wot 映射。不创建空文件，也不新建无边界的 `common.scss`。

## 9. layout 和核心入口的调整建议

### 9.1 保留三类布局，并给尺寸责任定边界

| 层                             | 应负责                                     | 应避免                                      |
| ------------------------------ | ------------------------------------------ | ------------------------------------------- |
| `App.vue / main.ts`            | 应用初始化、样式引入、store 与路由接入     | 塞入各页面业务状态                          |
| `pages.config.ts / definePage` | 路由、原生导航、layout 选择                | 手工维护生成的 `pages.json`                 |
| `AppProvider`                  | 页面主题、反馈组件宿主，消费共享主题 store | 被误认为整个应用唯一常驻实例                |
| `default`                      | 标准背景、最小高度、统一内容 gutter        | 页面再次补同一层 gutter                     |
| `tabbar`                       | 主导航和底部内容避让                       | 组件 placeholder 与 layout padding 双重补偿 |
| `blank`                        | Provider；内容尺寸由页面自管               | 把 blank 理解成没有任何基础配置             |
| `AppNavbar + useNavbarMetrics` | 导航呈现、状态栏和胶囊指标                 | 同一页面多份互不一致的测量来源              |
| 页面组件                       | 内容顺序、局部留白、页面状态               | 借营销卡片管理整个 Hero 的背景范围          |

**事实：** [网络检测页](../src/subPages/mine/settings/network/index.vue) 在 default 壳的左右 32rpx 上，再加一级 `px-32rpx`，出现双重 gutter。工作台位于全出血 tabbar 壳，在自己的内容区补 32rpx 是合理例外。

**风险：** 权限页底部操作栏没有显式安全区处理；自管理页面使用 100vh 的键盘和底部表现需逐端确认。Tab 页已经有安全区及底部 padding，不能说项目没有处理安全区。当前 TabBar 没开 placeholder，也不能把现有补偿判成双重占位。

**风险：** 普通内容使用 z-index 200，Wot TabBar 默认 zIndex 为 10；是否遮挡取决于层叠上下文。建议减少普通内容高层级，核对 navbar、tabbar、popup 实际叠放关系，而不是直接将所有值再提高。

**事实与风险：** navbar 左容器使用胶囊 left 坐标当宽度、右容器再保留胶囊和操作空间，需核查窄屏收缩；`hasTabbar` 没被实现；重试定时器未清理。先调整真实测量边界，再改名，否则 `leftWidth` 只是变成一个更漂亮的错误名称。

### 9.2 退出登录

底部、登录后可见、红色描边、二次确认的方案基本合理。文档不再单独给按钮位置一个看似精确的分数，也不建议仅为隐藏退出入口新增设置页。

建议补 `isLoggingOut` 或完整退出状态，确认后立即反馈、禁用重复操作；确认框标题用“退出登录”，操作文字明确。远端请求默认可等待到 30 秒，页面不能在此期间完全没有反馈。保留 store 的本地会话清理入口。

### 9.3 扫码登录

[扫描 composable](../src/composables/useScanLogin.ts) 只检查内容非空；[确认页](../src/subPages/mine/scan-confirm/index.vue) 才调用服务端。入口名称建议“扫码登录”，职责分为扫描、票据验证、用户确认和完成，不增加不必要的中间页面。

优先补平台能力判断和错误分类。本地 H5 依赖将 `scanCode` 实现为不支持的 API，而当前入口仍可出现，异常全部被吞掉。取消、权限拒绝、能力不支持和识别失败应分别处理。

确认与取消共享互斥状态；完成后直到离开页面都不再允许提交。当前一边 loading 时另一边仍可点，确认成功又会在延迟返回前解除 loading，均可从源码确认。

64rpx 热区在 375px 视口下约 32px，建议增加可点击范围并检查窄屏；图标不必同步放大。初次校验应呈现加载态，过期/无效码给可读错误和重新扫码入口。热区目标属于可用性建议，本文不凭尺寸直接做完整可访问性认证。

### 9.4 个人中心信息层级

若保留开源项目展示定位，公众号卡片靠前有理由；若转为日常业务应用，先展示资料、账号安全和业务消息，再放社区与帮助。顺序应根据任务频率决定。

Hero 背景由页面拥有，不依附公众号卡片的中线并固定向上延伸 800rpx。卡片隐藏、改顺序或长文本时，画布不应跟着失去边界。

**样式事实：** 个人卡片在不支持 backdrop-filter 时回退到接近白色背景，文字仍固定白色。应将降级背景和前景成对设计，具体平台表现仍需实测。辅助文字多处为 22rpx，应结合真实使用检查可读性；不把所有小字、阴影或大圆角直接判为错误。

## 10. 注释：只说明契约、原因和限制

好的注释值得保留：[usePagedList](../src/composables/usePagedList.ts) 说明迟到响应和刷新失败策略；[request](../src/utils/request.ts) 说明避免 request/store 循环依赖；工作台解释额外 gutter；权限树解释 flex 与 scroll-view 的高度约束。

优先纠正以下内容：

| 位置                             | 注释或名称的问题               | 调整方向                                                 |
| -------------------------------- | ------------------------------ | -------------------------------------------------------- |
| `useScanLogin.ts:6`              | 声称跳转前已校验票据           | 说明仅做非空判断，服务端在确认页校验                     |
| `useScanLogin.ts:24`             | 所有失败都写成用户取消         | 先实现分类，再说明静默条件                               |
| `useActionSheet.ts:63` 附近      | 将确认取消和执行失败都归为取消 | 写清异步失败处理责任                                     |
| `app-provider/index.vue:9`       | 只写 default/tabbar 两种壳     | 包括 blank，说明页面实例作用域                           |
| `account/index.vue:235`          | 文档列出不存在的 ACCOUNT 枚举  | 删除过时成员说明                                         |
| `useNavbar.ts:43`                | hasTabbar 有说明无行为         | 删除无效选项，避免注释承诺不存在的能力                   |
| `useCacheCleaner.ts`             | 声称只清可重建缓存             | 当前实现是删除保留名单之外所有键，需要调整策略或说明边界 |
| `work/user/index.vue:12`         | 注释写 12rpx，公共规则为 16rpx | 不重复抄写可变数值，解释留白目的                         |
| `theme.scss / eslint.config.mjs` | 当前实现仍标旧包名             | 当前依赖说明用 @wot-ui/ui，历史说明才保留旧名            |

推荐公共函数注释只覆盖四项中真正需要的内容：输入单位/格式、返回结果、重要副作用、失败策略。Props 的单位和生命周期契约写在声明处，避免每一行再解释一次。

```ts
/**
 * 重新读取窗口与胶囊尺寸，公开尺寸单位为 px。
 * 微信端读取失败时有限次重试，卸载时清理重试任务。
 * 不执行页面导航。
 */
```

上例只能在行为实现后使用；当前代码尚未具备卸载清理，不能提前粘贴成现有说明。`#ifdef/#endif` 是编译指令，清理注释时必须保留。

## 11. 保留的重要问题与验收标准

| 编号 | 问题                                     | 级别 / 证据                  | 后续验收                                                              |
| ---- | ---------------------------------------- | ---------------------------- | --------------------------------------------------------------------- |
| R1   | 扫码平台能力及错误被吞                   | P1 / 事实                    | H5 无无响应入口；取消静默，其他失败可恢复                             |
| R2   | 确认/取消并发及成功后的再提交窗口        | P1 / 事实                    | 慢网交替点击只执行一种操作，完成后不可再次提交                        |
| R3   | Button 的 plain、type="error" 等旧写法   | P1 / 事实                    | 核对 v2 props，清除业务旧参数；Tag 默认样式看似正确不能证明旧参数有效 |
| R4   | 模板检查关闭、表单 ref 与部分 shim 过宽  | P1 / 事实                    | 缩小兼容范围，关键错误 prop/方法能被检查捕获                          |
| R5   | 玻璃卡片降级配色与导航/底部层级          | P1 验证 / 样式事实及运行风险 | 降级、滚动、胶囊、Home Indicator 和键盘场景有记录                     |
| R6   | 退出无过程反馈                           | P2 / 事实                    | 立即显示状态，重复点击不会重复请求，弱网后按既定策略退出              |
| R7   | 重复 gutter、navbar 责任及无效选项       | P2 / 事实                    | 页面对齐，指标来源明确，删除无行为 API                                |
| R8   | 登录、资料加载和无权限混为一类           | P2 / 事实                    | 已登录无权限不再要求重新登录，首页/工作台导航判断一致                 |
| R9   | 网络检测文案与行为不符                   | P2 / 事实                    | 检查业务服务；失败不显示优秀；耗时与失败状态分开                      |
| R10  | ActionSheet 的 label 兼作分发 ID         | P2 / 事实                    | 同名文案或更换文案不改变动作身份，异步错误责任明确                    |
| R11  | font-bold 重定义、主色衍生值和语义色错配 | P2 / 事实                    | 名称与生成样式一致，主色切换联动，warning 语义正确                    |
| R12  | 文件、方法、类名与注释缺少统一约定       | P2–P3 / 约定及名实不符事实   | 按本文词汇与所有权规则整理，例外有清单                                |

R3 证据包括扫码确认、账号安全、主题设置、网络检测和多个 Tag。R4 在 [tsconfig.json](../tsconfig.json) 可见 `strictTemplates: false / skipTemplateCodegen: true`；不能把脚本 type-check 成功解释成模板参数已验证。恢复检查应先复现并缩小兼容问题，不直接删除全部 shim。

R8 的首页将 `!isAuthenticated || !hasAnyPerm` 一起跳登录；R9 的微信网络检测 fail 分支仍 resolve，第三方站点耗时也不能证明业务服务可达。前端体验判断不代表后端授权已经审计。

## 12. 建议执行顺序：先确定规范，再按模块落地

1. **形成基准约定。** 固定短词汇表、文件角色规则、事件与方法语义、短 BEM block、UnoCSS 三项边界、自动导入范围及合法例外。对应 R12。
2. **先解决行为与类型问题。** R1–R4、R10 优先。更名涉及的实际副作用一起核对，不能只做替换。
3. **以个人中心作为样板模块。** 文件、Props、菜单模型、导航方法、BEM、Hero 背景归属一起整理，再验证退出和扫码。此时只保留一个命名体系。
4. **统一 layout 和公共样式。** 处理 gutter、指标、底部避让与组件覆盖边界，运行验证 R5–R7。
5. **推广到工作台与设置页。** 核对分包、导航权限和网络检测。避免为每个页面再复制一套变体。
6. **收尾注释和检查规则。** 业务变更之后再同步注释，清理遗留别名，并记录需要保留的第三方/框架例外。

提交按模块或独立契约拆分。组件文件迁移可以作为一批易审阅变更；状态重构与运行逻辑另有清晰验证。跨全项目的一次正则重命名容易遗漏自动导入、组件解析和分包引用，不推荐。

## 13. 将严格要求变成可执行检查

### 可以自动检查

- 自有非路由 Vue 文件遵循 PascalCase，排除 framework/layout、第三方与生成文件。
- 自有选择器遵循约定的 BEM 格式；block 清楚即可，不强制照抄文件名，不要求多 block 登记。
- 项目业务脚本命名规则按角色配置，避免同一套规则误伤 `UserAPI` 等合法名称。
- 检查旧 Wot 参数、无效公开字段、宽泛全局选择器，以及改变标准语义的工具类重定义；对超过 3 项的模板节点给出提取提示。
- 公共类型和事件参数保留检查，兼容例外限定版本和范围。

以上是后续检查建议，本次没有新增 lint 规则或 CI。

### 必须人工审阅

- 名称是否与真实行为一致，而不是只看是否匹配正则。
- `open` 是否在跳路由，`isOnline` 是否只有 token，`load` 是否悄悄负责多处状态。
- label 是否参与身份分发，状态组合是否允许矛盾，异步失败有没有明确处理方。
- gutter、背景、主题和弹层有没有唯一责任来源。
- 抽出的组件或 composable 是否降低依赖和理解成本。

推荐基础框架 hooks 可以保留自动导入；业务 API、store、composable 和工具使用显式 import。当前 [vite.config.ts](../vite.config.ts) 将这些业务目录都加入自动扫描，实际调用又混合显式与隐式导入。严格维护更需要可见依赖；但这项规则无需扩展成“Vue 的每个 ref 都必须显式导入”。

样式类检查只负责自有选择器，不能对 Wot 内部类、uni hover-class 和第三方图表施加自有 BEM 命名规则。

## 14. 验证记录与交付边界

以下记录来自 **2026-10-04 初版评审**，本次文档重写没有重新运行应用检查，也不把历史结果包装成新的测试：

| 检查                         | 初版结果             | 限制                                                |
| ---------------------------- | -------------------- | --------------------------------------------------- |
| `pnpm check` 中的 type-check | 通过                 | 模板生成检查关闭                                    |
| `pnpm check` 中的 ESLint     | 1 处错误             | `src/utils/storage.ts:6` import 换行不符合 Prettier |
| 单独 Stylelint               | 通过                 | 总检查因 ESLint 失败短路，故单独执行                |
| H5 生产构建                  | 通过                 | 不证明视觉、扫码及真机交互正确                      |
| UnoCSS font-bold 生成核对    | 输出 font-weight:600 | 确认 shortcut 的名实不符                            |

本次只修订同一份文档，核查源码、本地依赖、UnoCSS 官方机制说明、文档格式及引用。没有修改业务代码、配置、组件名或路由。

仍建议后续统一同一运行端的版本展示来源，以及提交应用锁文件；它们属于工程可重复性事项，不需要与命名整理捆绑升级依赖。

后续每个模块完成时至少回答四个问题：名称是否准确；职责是否有边界；规则是否只有一个来源；错误与运行端限制是否被正确处理。满足这些条件后，再以关键端的实际截图和操作记录验证布局。
