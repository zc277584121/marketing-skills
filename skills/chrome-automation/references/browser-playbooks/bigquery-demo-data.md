# BigQuery demo data 录制

本文件只放 BigQuery demo data 页面 playbook。先读 `../browser-recording.md` 获取通用录制机制。

## 目标

录制一个可讲解的“demo 数据已经在 BigQuery 里”的镜头：观众能看到项目、dataset/table、schema 或 query results，并且能看到自然语言字段里的虚构样例，而不是只看到 id、时间戳、状态这类 metadata。

## 安全边界

- 可以录 demo project、demo dataset、demo table、虚构数据、用户名和头像。
- 不要录 service account JSON、private key、access token、真实客户数据或 billing 信息。
- 凭证下载、API key、secret、权限授予这类页面要按对应凭证 playbook 单独录，且停在安全边界前。
- 如果页面出现 IAM 真实成员列表、Billing、organization policy、downloaded key 内容，停录或切换镜头。

## 数据导入方式

BigQuery sandbox / free tier 可能拒绝 DML，例如 `INSERT` 会报 `DML queries are not allowed in the free tier`。录制前先确认数据已经存在；需要现场构造 demo 数据时，优先使用：

- `CREATE OR REPLACE TABLE ... AS SELECT ... UNION ALL SELECT ...`
- BigQuery 控制台的 load job / 上传 CSV
- 预先准备好的 seed job

不要在正式录制里临场调试 DML 限制。

## 推荐镜头

1. 打开 BigQuery Console，进入目标 project。
2. 在 Explorer 展开 demo dataset 和 table，短暂停留让观众看到这是 BigQuery 里的表。
3. 如果要展示字段结构，点 `Schema`，停留 1-2 秒。
4. 展示数据内容时，优先用 Query editor，而不是 raw `Preview`：

   ```sql
   SELECT
     notes,
     project_repo,
     occurrence_count,
     trigger_type,
     created_at
   FROM `<project>.<dataset>.<table>`
   ORDER BY created_at
   LIMIT 10;
   ```

5. 录 Query results，确保 `notes` 或其他自然语言列在画面左侧可见。
6. 停在安全、只读状态，不打开凭证文件、不下载 key、不修改权限。

## 控件经验

- Query editor 和结果表格可能加载慢；用 `browser_recording_wait_ms` 记录等待，不要让长时间无变化的视频混进成片。
- 如果必须展示 raw `Preview`，先确认关键自然语言列在首屏；否则改用 SELECT 重新排序。
- BigQuery/GCP 页面启用 Trusted Types；click cue 脚本必须使用 DOM API 创建 SVG，不能用 `innerHTML`。
- 业务动作使用 Agent Browser 原生 `click` / `fill` / `press`，页面 JS 只用于视觉 cue。

## 最终验证

最终 storyboard 和 snapshot 应至少证明：

- 目标 dataset/table 可见。
- Query results 或 Preview 中有自然语言 demo 字段，例如 `notes`、`subject`、`body`、`description`。
- 画面没有 service account key、secret、token、private key 或真实客户数据。
- `timeline.jsonl` 有 query run、等待、结果展示、snapshot 的相对时间。
