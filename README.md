# Cezar 套件(团队可分发版)

一套可直接拿走的 Cezar 环境:一键安装脚本、便携启动器、通用全流程 workflow、配套技能、使用手册。

## 目录结构

```
cezar-kit/
├── setup.cmd            ← 新机器一键环境安装(检测依赖→永久安装→环境变量→PATH)
├── start-cezar.cmd      ← 便携启动器(自动探测 codex/opencode 路径,修复 Windows 误报"未安装")
├── sync.cmd             ← 把母本 workflow + 流程技能分发到目标项目(项目列表在脚本内改)
├── workflows/
│   ├── dev-pipeline.yaml   ← 通用全流程母本(改这里,然后跑 sync.cmd)
│   └── archive/            ← 旧版 workflow 存档
├── skills/              ← 流程依赖的 9 个技能(sync.cmd 会复制到各项目)
└── docs/cezar-使用手册.md
```

## 前置条件

- Node.js 20+、git
- 至少一个 agent CLI 并完成登录(Codex / Claude Code / OpenCode 任一;Codex 推荐接 DeepSeek,见手册 2.3 节)
- 可选:GitHub CLI(`gh auth login`,仅自动建 PR 需要;GitLab 仓库走人工 MR)

## 五步上手(新机器)

```
1. 双击 setup.cmd                    ← 装好 Cezar + 环境变量 + PATH
2. 重新打开一个终端                    ← 让环境变量生效
3. 登录 agent CLI:codex login(或 claude)
4. cd 到你的 git 仓库 → 双击 start-cezar.cmd(或敲 cezar)
   首次把仓库注册进来:cezar projects add D:\path\to\repo
5. 驾驶舱 http://localhost:4321 → New task → 选 workflow: dev-pipeline → 写需求
```

## dev-pipeline 流程(单任务全流程)

```
需求分析+方案设计(claude)
  ↓ 评复杂度 [S]/[M]/[L],动态选技能(S/M=精简模板,L=specpowers-explore 多方案对比)
CEZ:ASK 人工确认门 ← 你点「批准」或给修改意见,原地继续
  ↓
编码(codex;[L] 档走 TDD)→ Code Review(claude;[L] 档走多 Pass 分级审查)
→ 测试自修(opencode;[L] 档走验证清单)→ mvn 编译门禁(失败回编码,最多 2 轮)
  ↓
审 worktree diff → 点 Land 落地到 base 分支(rebase + push)
```

⚠️ 建任务时**不要勾 Autonomous**(自主模式 = 永不暂停,人工确认门会失效)。

## 团队共享建议

- 把各仓库的 `.ai/cezar/workflows/` 与 `.ai/cezar/skills/` **提交进 git**:
  cezar 默认 .gitignore 只忽略运行时状态(runs/worktrees 等),这两类文件可安全提交;
  提交后同事拉代码即得同一套流程,且每个任务的 worktree 天然携带技能文件;
- 建任务时不要勾 Autonomous;不要勾选后把 base 分支选错(Land 会落到 base 分支);
- Land 会 push 到远端——重要分支先本地 `git merge` 验证。

## 常见问题

| 问题 | 处理 |
|---|---|
| codex/opencode 显示 Not installed 但明明装了 | Windows 下 Cezar 无法 spawn 裸 npm 垫片名;跑一次 setup.cmd(自动 setx CEZ_CODEX_BIN/CEZ_OPENCODE_BIN)或用 kit 的 start-cezar.cmd |
| 端口 4321 被占 | 有旧实例残留:找 PID kill,或 `cezar -p 4400` |
| 门禁 mvn 失败首跑很慢 | Maven 拉依赖,属正常;确保本机 mvn + Java 可用 |
| GitLab 仓库不能自动建 PR | Cezar 的 PR 走 gh(GitHub);GitLab 用人工 Land/merge |
| .cmd 脚本一跑满屏报错 | 脚本必须保持纯 ASCII;中文注释会被 GBK cmd 撕碎 |
| 项目里的 workflow/技能文件"消失" | 它们是未提交文件,`git clean -fd` 或 IDE 清理会删掉未跟踪文件。**重跑 sync.cmd 即恢复**;想彻底防丢且团队共享,就把 `.ai/cezar/workflows/` 与 `.ai/cezar/skills/` 提交进 git |
| 改了流程怎么生效 | 编辑 workflows/dev-pipeline.yaml → 双击 sync.cmd → 无需重启驾驶舱 |
