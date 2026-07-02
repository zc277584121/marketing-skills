# 浏览器 viewport 录制

本文件只放通用浏览器页面录制机制。具体网站、页面顺序、危险按钮和选择器经验放到 `browser-playbooks/` 下的独立 playbook，例如 `browser-playbooks/github-fine-grained-token.md`。

## 目录

- 适用范围
- 版本 preflight
- 基本命令
- 登录态与 profile
- Wrapper 与 timeline
- 正式录制产物
- 通用脚本
- 动态控件
- 点击提示
- 画面内容目标
- 验证清单

## 适用范围

使用 Agent Browser `record` 录网页 viewport，适合 GitHub/GCP/Notion/控制台类页面演示。它录网页内容，不录 Chrome 地址栏、标签栏、自动化提示条或桌面。

不要用这条路径录 Finder、系统下载弹窗、桌面 app 或 Chrome 外壳；这些继续用 Mac 窗口/区域录制脚本。

## 版本 preflight

正式录制前先确认 Agent Browser 和 Google Chrome 都是最新稳定版，尤其是账号、凭证、云控制台流程。版本不一致时先升级，再重开专用录制 profile。

```bash
python3 <skill-root>/scripts/check_browser_recording_versions.py
```

检查来源：

- Agent Browser 最新版：`npm view agent-browser version`。
- Chrome mac stable 最新版：Google Chrome VersionHistory API。

升级建议：

- Agent Browser 不是最新版时，先运行 `agent-browser upgrade`，或按本机安装方式更新 npm/brew/cargo 包。
- Chrome 不是最新版时，打开 `chrome://settings/help` 让 Chrome 更新并 relaunch；如果 relaunch 会影响用户正在使用的普通 Chrome，先告知用户再重启。
- 升级后重新运行版本检查，只有检查通过才开始正式录制。

## 基本命令

账号、凭证、云控制台流程必须 headed，并显式指定专用 profile、namespace、session：

```bash
agent-browser --namespace browser-recorder --session demo-flow \
  --headed \
  --profile "${HOME}/.agent-browser-recorder-chrome" \
  open https://example.com
```

录制时把 `record restart`、关键动作、`record stop` 放在同一个 wrapper 或 batch 里，避免多轮 agent 等待被录进去。输出 WebM；交付 MP4/MOV/GIF 时再用 FFmpeg 转码。

## 登录态与 profile

- 使用专用持久 profile，例如 `${HOME}/.agent-browser-recorder-chrome`。具体项目可以换成更明确的 profile 名。
- 不要复用用户主 Chrome profile。
- 用户自己的日常 Chrome 可以同时打开；录制命令必须显式带 `--headed --profile ... --namespace ... --session ...`。
- Headless 只用于无账号风险的本地或公开页面验证，不用于账号、凭证、云控制台 demo。

## Wrapper 与 timeline

正式录制必须用 wrapper 维护 `timeline.jsonl`。Agent Browser `record` 只负责视频，不会自动生成 OCR、帧间差分、鼠标轨迹或键盘事件表；如果只保存 `.webm`，后期就不知道哪个时间点发生了点击、等待、快照或验证。

`timeline.jsonl` 每行是一个 JSON object，至少包含：

- `ts`：UTC wall-clock 时间。
- `t_ms`：相对 `record_start_requested` 的毫秒数。
- `event`：例如 `record_started`、`cue_started`、`action_started`、`action_succeeded`、`snapshot_saved`、`wait_started`、`verification_passed`、`record_stopped`。
- `note`：安全、可给后期剪辑脚本看的说明。
- 可选字段：`action`、`selector`、`text`、`ref`、`key`、`duration_ms`、`snapshot`、`video`、`value_redacted`。

输入内容默认不要写入 timeline。需要记录填表动作时，写 `value_redacted: true`，只记录目标、动作和安全说明。

## 正式录制产物

每个正式 browser recording run 目录至少包含：

- 原始 Agent Browser `.webm`。
- 最终 `.mp4`，需要时再加 `.mov`。
- `timeline.jsonl`：所有关键动作、cue、等待、快照、验证的相对时间。
- `snaps/`：关键动作前后的 `snapshot -i`，保存 ref 和安全文本。
- `final-state.json`：最终安全状态，例如是否停在提交按钮前。
- `ffprobe.json`：视频参数。
- `blackdetect.log`：黑屏检测。
- `storyboard/`：覆盖完整视频时长的多张拼图，不只看第一张。
- `finalize-manifest.json`：集中索引最终视频、检查结果、storyboard 和 timeline 摘要。

OCR、帧间差分、画面文字摘要可以作为后续脚本挂在 `finalize-manifest.json` 后面；没有这些扩展时，也必须先有 timeline 和全时长 storyboard。

## 通用脚本

优先复用 `scripts/` 里的通用资产，不要从旧 demo 复制硬编码 wrapper。

`scripts/browser_click_cue.js`：

- 注入页面内点击提示。
- 暴露 `window.browserClickCue.showForSelector(selector)` 和 `window.browserClickCue.showForText(text)`。
- 只负责视觉 cue，不触发业务 click。

`scripts/browser_recording_lib.sh`：

- 给 Bash wrapper 提供 timeline、snapshot、ref 提取、click cue helper。
- 调用方必须自己定义 `ab()`，把 namespace/session/profile 写在当次 wrapper 里。
- 页面专用 wrapper 只保留页面步骤和当次参数，不内置到 skill 通用脚本。
- `browser_recording_record_start <run_dir> <webm>` 会初始化 timer、`timeline.jsonl` 和录制。
- `browser_recording_record_stop <run_dir>` 会停止录制并写入停止事件。
- `browser_recording_cue_text` / `browser_recording_cue_selector` 会写 `cue_started` / `cue_finished`，然后只画视觉提示。
- `browser_recording_click_ref_from_snapshot`、`browser_recording_click_ref`、`browser_recording_fill_ref`、`browser_recording_press`、`browser_recording_wait_ms` 会写动作时序。
- `browser_recording_snapshot_to` 和 `browser_recording_assert_snapshot_contains` 用于保存可交互状态和安全验证。

`scripts/finalize_browser_recording.py`：

- 把 Agent Browser WebM 转成 MP4/MOV。
- 生成覆盖完整时长的 storyboard、`ffprobe.json`、`blackdetect.log`、`finalize-manifest.json`。
- 不关心网页内容，不包含账号、URL、repo、token 等页面参数。

最小 wrapper 形状：

```bash
SKILL_ROOT=/path/to/chrome-automation
PROFILE_DIR="${HOME}/.agent-browser-recorder-chrome"
source "$SKILL_ROOT/scripts/browser_recording_lib.sh"

ab() {
  agent-browser --namespace demo --session flow --headed --profile "$PROFILE_DIR" "$@"
}

RUN_DIR=/tmp/browser-demo-run
WEBM="$RUN_DIR/browser-demo.webm"
mkdir -p "$RUN_DIR"

browser_recording_record_start "$RUN_DIR" "$WEBM"
browser_recording_install_click_cue "$SKILL_ROOT"
browser_recording_snapshot_to "$RUN_DIR" "before-create" "Before clicking Create."
browser_recording_cue_text "Create" "Cue the Create button."
browser_recording_click_ref_from_snapshot "$RUN_DIR" "$BROWSER_RECORDING_TIMELINE" "before-create" "Create" "Click Create."
browser_recording_record_stop "$RUN_DIR"

python3 "$SKILL_ROOT/scripts/finalize_browser_recording.py" \
  --input "$WEBM" \
  --output-dir "$RUN_DIR" \
  --basename browser-demo \
  --timeline "$RUN_DIR/timeline.jsonl"
```

## 动态控件

对下拉框、弹层、列表过滤器、GitHub ActionList 等会导致 ref 变化的控件：

- 动作前 `snapshot -i`，动作后重新 `snapshot -i`。
- 不要复用旧 ref。
- 搜索/过滤通常比直接点击长列表里的 offscreen option 更稳。
- 业务动作优先用 Agent Browser 原生 `click` / `fill` / `find` / snapshot ref。
- 不要把页面内 `element.click()` 当作正式业务动作；它在复杂控件上可能不触发真实交互路径。

## 点击提示

如果只需要观众知道“这里点了一下”，优先使用页面内 DOM click pulse 或静态 cursor arrow cue，而不是持续 fake cursor 或后期坐标换算。

推荐参数：

- 直径：`44px`。
- 边框：`3px`，可加白色外描边。
- 时长：`560ms`，箭头可保留到约 `680ms`。
- 动画：从 `scale(0.55)` 扩到 `scale(1.6-1.8)` 后淡出。
- 动作：先在目标 DOM 中心闪 pulse，再执行 Agent Browser 原生 click/fill。
- 可选箭头：在点击点短暂显示一个白色鼠标箭头，让箭头尖端对准目标中心；保留约 `680ms` 后移除，不做移动轨迹。
- timeline：每次 cue 必须先写 `cue_started`，cue 完成后写 `cue_finished`，然后再执行原生业务动作。

不要保留持续存在的假鼠标箭头，也不要做复杂轨迹动画。Retina DPR、滚动、分段录制和转码容易让持续光标出现左上角偏移或漂移观感。

GCP Console 等页面可能启用 Trusted Types，click cue 脚本不能用 `innerHTML` 注入 SVG；必须用 DOM API / `createElementNS` 创建箭头。

## 画面内容目标

录制前先写一句“这个镜头要让观众看到什么”。对表格、控制台和数据预览尤其重要：观众要看到的是业务含义，不只是 id、时间、状态这类 metadata。

- 如果关键列在右侧，优先用查询或视图把叙事列放在前面，而不是在正式录制里拖横向滚动条。
- BigQuery 这类表格 demo，优先录 Query results，把 `notes`、`subject`、`body`、`description` 等自然语言列选到最前面。
- 每段视频结束前用 snapshot、截图或 storyboard 确认关键文本确实出现在画面里。
- 如果 storyboard 看不出主要信息，不能交付；重新录或改查询/布局。

## 验证清单

交付前检查：

- 视频没有录到地址栏、标签栏或桌面。
- run 目录有 `.webm`、`.mp4`、`timeline.jsonl`、`snaps/`、`storyboard/`、`ffprobe.json`、`blackdetect.log`、`finalize-manifest.json`。
- `timeline.jsonl` 有 `t_ms`，每个 click cue 后面有对应的原生 `action_started` / `action_succeeded`。
- `ffprobe` 分辨率、时长、大小符合预期。
- `blackdetect` 没有真实黑屏段。
- storyboard 覆盖完整时长，并能看出主要页面状态变化和关键业务内容。
- `final-state.json` 和最终 `snapshot -i` 证明没有点击提交、生成、删除、发送等不可逆按钮。
