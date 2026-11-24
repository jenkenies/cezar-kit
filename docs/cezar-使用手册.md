# Cezar 使用手册(本机实测版)

> 适用环境:Windows + Node 24 + Cezar **v0.18.0** + Claude Code 2.1.81
> 本机工作目录:`D:\code\agent\cezar-playground` · 驾驶舱:`http://localhost:4321`
> 编写日期:2026-11-03,所有命令均在本机验证过

---

## 1. Cezar 是什么

一句话:**一个本地"驾驶舱",把你已经登录的 AI 编程 CLI(Claude Code、Codex、OpenCode 等)编排成可以并行干活的团队。**

核心机制,记住这三条就够了:

1. **Cezar 不碰大模型**——它只驱动你本机的 agent CLI,模型/账号由 CLI 自己决定(所以配 DeepSeek 是配到 CLI 上,不是配到 Cezar 上)。
2. **每个任务一个独立 git worktree**——多个 agent 同时改代码互不干扰;多余任务自动排队(extras queue)。
3. **永不自动合并(Nothing auto-merges)**——所有产出都以 diff 形式等你审阅,确认后才进主线。

没有数据库,所有状态都以普通文件存在仓库的 `.ai/cezar/` 目录里(删掉该目录 = 重置)。

---

## 2. 安装与本机现状

### 2.1 你已完成的部分(无需重做)

| 项目 | 状态 |
|---|---|
| Node.js 24.11.1 / git 2.55 | ✅ 已具备 |
| Cezar v0.18.0 | ✅ 通过 npx 使用(免安装,首次自动下载缓存) |
| Claude Code 2.1.81 | ✅ 已装且已登录(`C:\Users\004724\.local\bin\claude`) |
| 工作仓库 | ✅ `D:\code\agent\cezar-playground`(已 git init + 首提交) |
| 脚手架示例 | ✅ `cezar init` 已运行,含示例工作流 + 技能 |

### 2.2 启动 / 关闭

```bat
:: 方式一(推荐):双击
D:\code\agent\start-cezar.cmd

:: 方式二:手动
cd /d D:\code\agent\cezar-playground
npx cezar-run              :: 启动并自动打开浏览器
npx cezar-run --no-open    :: 不开浏览器(后台/远程场景)
npx cezar-run -p 4400      :: 换端口
```

关闭:在启动窗口按 `Ctrl+C`。
再次启动会自动**恢复上次未完成任务**("recovered N run(s)")。

> **2026-11-03 更新**:已改为永久安装(`~/.cezar`),新终端可直接敲 `cezar` 命令,
> `start-cezar.cmd` 已切换到永久版。脚本里还加了 `CEZ_CODEX_BIN` / `CEZ_OPENCODE_BIN`
> 环境变量——这是官方留的开关,修复 Windows 下 Cezar 探测不到 npm .cmd 垫片
> (codex/opencode 显示 ✗)的问题;opencode 已接 DeepSeek(模型名用新的 `deepseek-flash`)。

⚠️ 本机端口提示:8000/18000 被 Lodop 打印服务占用,8300 被 Clash Verge 占用——都不归 Cezar 管,但**不要**把 Cezar 或 OpenHands 配到这些端口上。

### 2.3 演示模式与 DeepSeek

- `CEZ_DRY_RUN=1`:内置 mock 代理,不消耗任何额度,随便点(当前 `start-cezar.cmd` 里已注释掉 = 真实模式)。
- 让 Claude Code 换 DeepSeek 大脑:取消 `start-cezar.cmd` 中 4 行注释并填入你的 Key:

```bat
set ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
set ANTHROPIC_AUTH_TOKEN=sk-你的DeepSeekKey
set ANTHROPIC_MODEL=deepseek-chat
set ANTHROPIC_SMALL_FAST_MODEL=deepseek-chat
```

只影响 Cezar 拉起的 Claude Code,不影响你平时直接用的 Claude Code。

**路线 ②:Codex runner + DeepSeek(已配置,2026-11-03 起为 codex 默认)**

Codex 的默认后端已直接改为 DeepSeek(`~/.codex/config.toml`,密钥写在
`[model_providers.deepseek]` 里,**零环境变量、零脚本**,裸敲 `codex` 即 DeepSeek):

- Cezar 里的 codex runner 自动跟随默认,无需额外配置;
- MiniMax 配置已移除(2026-11-03);推理档:`codex -p deepseek-r1`;
- 新版 Codex(≥0.166)只支持 `wire_api = "responses"`,DeepSeek 已兼容;
- `Model metadata for deepseek-chat not found` 警告无害;
- **回滚**:把 `~/.codex/config.toml.bak-20261103` 覆盖回去即可(恢复原托管代理默认);
- 遗留目录 `~/.codex-deepseek` 已不再使用,可删。

---

## 3. 驾驶舱 UI 模块总览

打开 `http://localhost:4321/p/cezar-playground/`,主要模块:

| 模块 | 用途 |
|---|---|
| **任务列表(Tasks)** | 并行/排队中的任务;新建任务入口;变体、子任务按层级展示 |
| **运行详情(Run)** | 实时流式看 agent 文本、工具调用、token 与费用 |
| **变体对比(Variants)** | 同一任务 ×2/×3 并行跑,并排对比 diff,保留最好的一个 |
| **工作流构建器(Workflows)** | 节点图方式编排:agent、检查、循环、门禁、PR、CI |
| **GitHub Issues** | 一键把 open issue 变成任务(需 gh CLI) |
| **Skills** | 查看技能库;点 **Skills → Refresh** 拉取 open-mercato 官方技能 |
| **Autonomous(自主模式)** | 开启后任务一跑到底、不中途停下来问 |
| **Dashboard / Usage** | 按项目统计用量与成本 |
| **Automations** | 定时与事件触发(日历视图、触发器、近期结果、可暂停) |
| **Settings → Webhooks** | 事件推送:签名 JSON、Slack/Discord 通知(需 `CEZ_WEBHOOKS=1`) |
| **Projects** | 一个驾驶舱管多个仓库 |

---

## 4. 任务:三种发起方式

### 4.1 UI 发起(最常用)
任务列表 → 新建 → 写清楚任务描述 → 选 Agent(`claude`)/ 选工作流 → 提交。
任务在独立 worktree 里执行;完成后审阅 diff,再决定合入/丢弃。

### 4.2 命令行(headless,不开浏览器)

```bash
cd /d/code/agent/cezar-playground
npx cezar-run run "给 export 命令加一个 --json 参数"           # 默认 quick-task 工作流
npx cezar-run run "重构登录页" --workflow fix-and-verify       # 指定工作流
npx cezar-run run "..." --repo /d/code/agent/某个仓库          # 指定仓库
```

### 4.3 从 GitHub issue 发起
驾驶舱 GitHub Issues 面板一键把 issue 变任务(需要 `gh auth login`)。

> 任务实在跑不完也没关系:cockpit 重启会自动恢复未完成的 run。

---

## 5. 工作流(Workflows)——`.ai/cezar/workflows/*.yaml`

内置 `quick-task`:零配置直接用。自定义就写一个小 YAML,你本机已有一个官方示例
(`.ai/cezar/workflows/fix-and-verify.yaml`,原文如下):

```yaml
name: fix-and-verify
description: Implement the task, then run your test command; on failure the agent retries with the failing output.
steps:
  - id: implement
    name: Implement
    prompt: "{{task}}"
  - id: verify
    name: Verify
    command: "echo 'replace me with: npm test / yarn test / pytest'"
    onFail:
      retry: implement
      max: 2
```

**字段说明:**

| 字段 | 含义 |
|---|---|
| `prompt: "{{task}}"` | 把任务描述作为提示词交给 agent;可写成任意指令模板 |
| `command:` | 验证门禁,跑 shell 命令,**exit 0 = 通过**(把示例换成 `npm test` / `pytest` 等) |
| `onFail.retry` | 验证失败时回到哪一步重跑,`max` 为最大重试次数(失败输出会喂回 agent) |
| `runner:` | 本步指定用哪个 agent,如 `runner: codex`;**不同步骤可用不同 agent** |
| `skill:` | 给本步附加一个技能(见第 6 节),如 `skill: project-conventions` |

验证门禁除了 shell 命令,还可以是**浏览器/端到端(agentic e2e)检查**。
保存 YAML 后驾驶舱立即可见,也可以在 Workflows 构建器里图形化编辑。

---

## 6. 技能(Skills)——`.ai/cezar/skills/*.md`

技能 = 给 agent 的"家规/规范" Markdown 文件,在工作流步骤里用 `skill: 名字` 引用。
你本机的官方示例(`.ai/cezar/skills/project-conventions.md`):

```markdown
---
name: project-conventions
description: House rules the agent should follow in this repo.
---

# Project conventions

- Describe your stack, style and testing conventions here.
- Reference this skill from a workflow step via `skill: project-conventions`.
```

把它改成你项目的真实规范(技术栈、代码风格、测试要求),然后在 `implement` 步骤加
`skill: project-conventions` 即可让 agent 遵守。

**官方技能库**:open-mercato 维护了一套通用技能(PR 创建、代码评审、CI 修复、写 spec 等),
Cezar 已内置加载;要拿最新版:驾驶舱 **Skills → Refresh**,或在仓库里:

```bash
npx skills add open-mercato/skills --skill '*'
```

---

## 7. 变体与子任务

- **变体(Variants)**:同一任务跑 ×2/×3(可混用不同 agent),并排比较 diff 留最好的。适合关键改动"货比三家"。
- **子任务(Child tasks)**:agent 可把独立工作委派给子任务,每个子任务自己的 worktree;
  - 一个父任务同时在飞的子任务**最多 4 个**;
  - 子任务共享父任务的预算,结果回报回父任务会话;
  - 子任务在任务列表里挂在父任务下面。
- **Autonomous 模式**:开启后 run 不会停下来等确认,直接干完(配合验证门禁使用更安全)。

---

## 8. 自动化(Automations)

让任务在"没有你"的时候自动发生:

- 场景:每天早上检查依赖升级、每周五起草发布说明、每个新 PR 自动评审;
- 触发源:**定时计划**、**GitHub 事件轮询**、**Jira/Linear 工单事件**;
- 每次触发 = 发起一个普通任务(工作流、agent 都由你指定);
- 创建方式:UI 的 Automations 里建,或直接用一句话让 agent 帮你建;
- 支持触发器预览、日历视图、近期执行结果、**暂停**。

---

## 9. 命令行参考(v0.18.0 实测)

| 命令 | 作用 |
|---|---|
| `npx cezar-run` | 启动驾驶舱(server + GUI) |
| `npx cezar-run run "<任务>"` | 无界面跑一个任务(`--workflow`/`--model`/`--repo` 可选) |
| `npx cezar-run init` | 脚手架:示例工作流 + 技能 |
| `npx cezar-run projects` | 列出/添加/移除本驾驶舱管理的仓库 |
| `npx cezar-run task <create\|report\|list>` | 在任务运行中派发/汇报子任务(任务内自动可用,`CEZ_DISPATCH=0` 关闭) |
| `npx cezar-run runs list` | 从 shell 查看运行中的任务(`CEZ_API_URL=http://127.0.0.1:4321`) |
| `npx cezar-run automation <add\|check\|run\|list\|…>` | 管理自动化 |
| `npx cezar-run secrets <list\|set NAME\|unset NAME>` | 项目级密钥(`--workspace` 为用户级);**agent 拿不到密钥明文** |
| `npx cezar-run tracker-connections <list\|remove ID>` | 查看/删除 Jira、Linear 等本地凭据 |
| `npx cezar-run telemetry [status\|disable]` | 用量遥测(默认关闭) |
| `npx cezar-run install` / `update` / `versions` | 永久安装到 `~/.cezar` / 升级(`--channel nightly`)/ 多版本管理 |
| `npx cezar-run server-install --platform ubuntu-vps` | 部署到 VPS(HTTPS + 登录 + 系统服务,手机可访问) |

**常用环境变量:** `CEZ_DRY_RUN=1`(mock)· `CEZ_API_URL`(CLI 连驾驶舱)· `CEZ_DISPATCH=0` · `CEZ_WEBHOOKS=1`

---

## 10. 本机目录地图

```
D:\code\agent\
├── start-cezar.cmd              ← 一键启动(含 DeepSeek 可选配置)
├── start-openhands.cmd          ← 另一个项目的启动脚本
└── cezar-playground\            ← Cezar 工作仓库(git)
    ├── .ai\cezar\
    │   ├── workflows\fix-and-verify.yaml    ← 示例工作流
    │   ├── skills\project-conventions.md    ← 示例技能
    │   ├── runs.json / runs\ / worktrees\   ← 运行状态与任务工作树(别手动删)
    │   └── ui-state.json / layouts\         ← 界面布局记忆
    └── (你的业务代码)
```

---

## 11. 故障排查 FAQ

| 现象 | 处理 |
|---|---|
| 启动报 `port 4321 was busy` | 有旧实例残留:`netstat -ano | findstr :4321` 找 PID 后 `taskkill /F /PID <pid>`;或直接用 `-p 4400` 换端口 |
| Agent 显示 `✗ codex/opencode…` | 那是"可选 runner",装了对应 CLI 并登录才会亮;只用 claude 没问题 |
| Agent 显示 `✓ claude (mock)` | 你在 `CEZ_DRY_RUN=1` 演示模式,去掉该环境变量重启 |
| 任务产出怎么进主分支 | 永不自动合并:在任务 diff 里审阅 → 手动 apply/merge |
| 想清空全部状态 | 关闭 cockpit 后删除 `.ai/cezar/`(任务历史、worktrees 一起清掉) |
| CLI 连不上驾驶舱 | 确认 cockpit 在跑,并设置 `CEZ_API_URL=http://127.0.0.1:4321` |
| 新建任务在哪选 Workflow | 点输入框上方 **+ Skill** 按钮(实为"技能或 workflow"二合一选择器),或在输入框打 `/`;选了 workflow 后,agent 下拉只影响未钉死 runner 的步骤 |
| 任务产出怎么合入分支 | 任务详情里审 diff → 勾选改动 → 点 **Land**:自动 rebase 到建任务时选的 base 分支并 push 到远端;或手动 `git worktree list` 找到任务分支后在主检出 `git merge` |

---

## 12. 五分钟上手路径(建议)

1. 打开驾驶舱 → 新建一个简单任务(比如"在 README 里加一节使用说明"),Agent 选 `claude`,用内置 `quick-task` → 观察 worktree、流式输出、diff 审阅全流程;
2. 把 `fix-and-verify.yaml` 里的 `command` 改成你真实的测试命令,再跑一次,体验"失败自动重试";
3. 把 `project-conventions.md` 改成你的项目规范,并挂到 implement 步骤;
4. 试一次 Variants ×2 对比,再试 Automations 建一个每日任务;
5. 需要省额度时,启用 `start-cezar.cmd` 里的 DeepSeek 四行配置。
