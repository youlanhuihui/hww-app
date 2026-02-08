# HWW - AI Chat Platform

基于 Next.js + Supabase 的 AI 聊天平台，支持本地大模型部署。

## 功能

### 首页 — AI 引导助手
- 由阿里百炼 qwen-max 驱动的 AI 助手
- 帮助用户了解平台功能、指导本地模型部署

### 聊天 — 用户间即时通讯 + AI 辅助
- 私聊、群聊，基于 Supabase Realtime 实时消息
- **@AI 机器人**：在对话中输入 `@AI 你的问题` 调用本地 AI
- **AI 自动回复**：开启后 AI 自动代替你回复对方
- **AI 草稿模式**：AI 生成回复草稿，确认后发送
- **AI 辅助工具**：翻译（中英）、润色、总结上文

### 模型 — 本地大模型部署管理
- Ollama 安装部署指南（Windows/macOS/Linux）
- 连接配置（Base URL、默认模型）
- 实时状态看板（连接状态、已安装模型、运行中模型）

### 社区
- 用户发帖、互动

## 技术栈

- **前端**: Next.js 16, React 19, TypeScript, Tailwind CSS 4
- **后端**: Supabase (PostgreSQL, Auth, Realtime, Storage)
- **AI**: 阿里百炼 DashScope (qwen-max) + 用户本地 Ollama
- **UI**: shadcn/ui (Radix), Lucide Icons
- **状态**: Zustand + React Context

## 快速开始

### 1. 安装依赖

```bash
pnpm install
```

### 2. 配置环境变量

复制 `.env.example` 为 `.env.local`：

```bash
cp .env.example .env.local
```

填写以下变量：

| 变量 | 说明 |
|------|------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase 项目 URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase 匿名 Key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase 服务角色 Key（服务端） |
| `DASHSCOPE_API_KEY` | 阿里百炼 API Key |
| `DASHSCOPE_MODEL` | 默认模型（可选，默认 qwen-max） |

### 3. 初始化数据库

在 Supabase Dashboard 中执行 `supabase/migrations/` 下的 SQL 文件。

### 4. 启动开发服务器

```bash
pnpm dev
```

访问 http://localhost:3000

## 本地大模型部署（Ollama）

1. 从 [ollama.com](https://ollama.com/download) 下载安装 Ollama
2. 打开终端，运行：
   ```bash
   ollama pull qwen2.5:7b
   ```
3. 在 HWW 平台的「模型」页面配置连接（默认 `http://localhost:11434`）
4. 在「聊天」页面使用 @AI 或 AI 辅助功能

## 项目结构

```
app/
  api/ai/chat/      — 阿里百炼代理 API
  layout.tsx         — 根布局
  page.tsx           — 入口页面
components/
  hww/pages/         — 各页面组件（home, chat, model, community）
  hww/               — 应用壳（侧边栏、导航、弹窗）
  auth/              — 认证组件（登录、注册）
  ui/                — shadcn UI 组件库
lib/
  app-context.tsx    — 全局状态 (Context)
  ollama-client.ts   — Ollama API 客户端（浏览器端）
  hooks/use-ollama.ts — Ollama 连接管理 Hook
  hooks/use-chat-ai.ts — 聊天 AI 功能 Hook
  services/im-service.ts — IM 即时通讯服务
  supabase/          — Supabase 客户端（浏览器端 + 服务端）
  i18n.ts            — 多语言（中文/英文/韩文）
```

## 许可证

MIT
