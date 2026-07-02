# GitHub fine-grained token 录制

本文件只放 GitHub fine-grained personal access token 页面 playbook。先读 `../browser-recording.md` 获取通用录制机制。

## 目标

录制一个可讲解的 GitHub 凭证配置流程：创建 fine-grained token、选择组织、选择指定 repo、给 `Contents` read-only 权限。永远停在 `Generate token` 前，不生成真实 token。

## 安全边界

- 可以录用户名、头像、组织名和 demo repo。
- 不要点击 `Generate token`。
- 不要录真实 token、secret、private key、恢复码或下载文件内容。
- 如果页面出现额外确认、SSO、密码、2FA、组织授权弹窗，停录并让用户处理或确认。

## 推荐顺序

1. 打开 `https://github.com/settings/personal-access-tokens/new`。
2. 先选择 `Resource owner`，过滤并选择目标组织或用户，例如 `<demo-owner>`。GitHub 切换 owner 可能重置表单，所以 owner 要先选。
3. 填 `Token name` 和 `Description`，使用明显的 demo 文案。
4. 在 `Repository access` 选择 `Only select repositories`。
5. 打开 `Select repositories`，搜索 demo repo，例如 `<demo-repo>`，选择唯一结果，关闭弹层。
6. 打开 `Add permissions`，选择 `Contents`。默认 `Access: Read-only` 即可。
7. 录到最终页面显示 `Select repositories 1`、repo 名、`Contents`、`Access:Read-only`、`Generate token` 可见，然后停止。

## 控件经验

- 复用 `browser-recording.md` 里的通用脚本；不要复制旧 GitHub demo wrapper 里的 profile、org、repo、token name 硬编码。
- GitHub 的 ActionList、repo selector、permission selector 要用 Agent Browser 原生 `click` / `fill` / snapshot ref。
- 页面内 JS 只用于画 click pulse 或 arrow cue，不用于触发业务 click。
- repo selector 先搜索再点结果，不要滚动长列表找 repo。
- `Close` 按钮可能只有 aria-label；pulse 找不到时可以跳过视觉提示，但业务 close 仍用 snapshot ref。

## 最终验证

最终 snapshot 应至少包含：

- `Token name` 为 demo 名称。
- `Only select repositories` checked。
- `Select repositories 1`。
- 目标 repo 名。
- `Contents`。
- `Access:Read-only`。
- `Generate token` 可见但未点击。
