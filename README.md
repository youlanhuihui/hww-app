HWW-app
一、项目概览
HWW（Hardware Wallet Web） 是一个基于 Next.js + Supabase 的全栈 AI 应用，集成了多语言、认证、技能市场、智能任务引擎、IM 任务、工单系统和管理后台等能力。
项目名（package.json）: my-v0-project
对外品牌: HWW - Hardware Wallet Web
技术栈: Next.js 16、React 19、TypeScript、Tailwind CSS 4、Supabase、shadcn/ui
二、技术栈
类别	技术
框架	Next.js 16、React 19
语言	TypeScript
样式	Tailwind CSS 4、PostCSS、tw-animate
UI	shadcn/ui（Radix）、Lucide Icons、Recharts、@xyflow/react
后端/数据	Supabase（PostgreSQL、Auth、Storage）
表单/校验	React Hook Form、Zod、@hookform/resolvers
状态	Zustand
LLM	自研统一客户端，支持 DashScope、Coze、Ollama、Mock
监控	Sentry、Vercel Analytics / Speed Insights
测试	Vitest、Testing Library、fast-check（属性测试）
工程	ESLint、Prettier、Husky、lint-staged、Commitlint
三、目录与模块结构
1. 应用层 app/
路由: 根 /、/admin、/skills（含 [skillId]、developer、editor、test）
API:
/api/agent、/api/agents/*（analyze、code、document、execute、file、image、scrape、translate）
/api/coze（chat、health）
/api/npc（conversations、workflows）
/api/orders、/api/tasks
/api/task-engine（含 stream、upload）
全局: layout.tsx、globals.css、loading.tsx、global-error.tsx、sitemap.ts
2. 组件层 components/
admin: 管理端布局与页面（仪表盘、用户、技能、工单、合规、设置）
auth: 登录、注册、忘记密码、用户菜单
hww: 主应用布局、侧边栏、移动导航、各业务页（Chat、Model、Data Vault、Analytics、Tasks、Agent Builder、Community、Credits、Developer、模板市场等）
hww/task-dialog: 任务弹窗、计划编辑/可视化、进度、结果、子任务列表、文件上传等
im-task: 通知面板、技能选择、任务卡片
ui: 通用 UI 组件（shadcn 风格，约 50+ 个）
theme-provider、error-boundary 等
3. 核心库 lib/
模块	路径	作用
任务引擎	task-engine/	意图分类、任务分解、规划、执行、状态管理、统一 Agent 适配
技能市场	skills/	技能校验、注册、匹配、沙箱、执行器、权限审计、与任务引擎/IM 适配
IM 任务	im-task/	任务意图/提取、卡片生成、IM 桥接、协作、通知、线程、技能调用
LLM	llm/	统一 LLM 客户端、多 Provider（DashScope/Coze/Ollama/Mock）、限流、熔断、重试
安全	security/	CSP、CORS 等安全策略与头
Supabase	supabase/	服务端客户端与工具
缓存	cache/	缓存抽象与实现
国际化	i18n/	多语言（en/zh/ko）
Agent	agents/	Agent 相关逻辑
离线	offline/	离线能力
性能	performance/	性能监控/优化
实时	realtime/	实时能力
稳定性	stability/	错误处理、重试等
校验	validation/	Schema、中间件
UX	ux/	错误信息、表单校验等
共享类型	shared/	状态映射、校验、事件等通用类型
4. 数据库（Supabase Migrations）
管理端表、IM 模块、社区、profiles、项目模板
任务引擎（007_task_engine.sql）、技能市场（008_skills_marketplace.sql）
IM 与任务引擎集成（009_im_task_integration.sql）、统一执行日志（010_unified_execution_logs.sql）
NPC 任务、订单/任务相关表（20260201_*）
四、三大核心模块关系（来自 MODULE_INTEGRATION_ANALYSIS.md）
任务引擎 ↔ 技能市场
通过 SkillProvider 接口与 SkillProviderAdapter 集成，任务引擎可调用技能市场的技能执行。
任务引擎 ↔ IM 任务
通过 IMModuleHook、TaskEngineEventListener 和 TaskEngineIntegration 等，把任务状态、执行进度同步到 IM。
技能市场 ↔ IM 任务
通过 SkillInvoker 在 IM 场景中调用技能、搜索技能、格式化结果。
文档中这三处集成状态均标注为「完整实现」。
五、安全与运维
Middleware: CORS 白名单、OPTIONS 预检、CSP（lib/security/csp）、X-Frame-Options、X-Content-Type-Options、Referrer-Policy、Permissions-Policy，生产环境 HSTS。
Next 配置: API 路由 CORS 头、安全头、图片优化与域名、Sentry（source maps、tunnel、Vercel Monitors）。
六、脚本与开发流程
pnpm dev — 开发
pnpm build / pnpm start — 构建与启动
pnpm lint / pnpm lint:fix — ESLint
pnpm format / pnpm format:check — Prettier
pnpm test / pnpm test:run — Vitest
prepare — Husky（Git hooks），配合 lint-staged、Commitlint 做提交前检查
七、总结与特点
全栈: Next.js App Router + Supabase，前后端一体。
AI 与任务: 统一 LLM 层 + 智能任务引擎 + 技能市场 + IM 任务，模块间有明确接口与适配器。
多端: 用户端（Chat、Model、Data Vault、Analytics、Tasks、技能市场等）+ 管理端（仪表盘、用户、技能审核、工单、合规、设置）。
工程化: TypeScript、ESLint、Prettier、Vitest（含属性测试）、Husky、Sentry、Vercel 部署。
合规与安全: CORS、CSP、安全头、权限与审计（技能权限审计等）。
