# BigQuery Console 录制参考

本文件只记录 BigQuery Console 的通用页面结构、控件位置和录制坑位。先读 `../browser-recording.md` 获取通用录制机制。具体 project、dataset、table、字段名、查询语句和讲解顺序应放在当次项目脚本里，不写进这个站点级参考。

## 页面区域

- 左侧 `Explorer`：project / dataset / table 树。展开节点后再进入表详情；如果列表很长，先用搜索或 project selector 缩小范围。
- 中间 `Query editor`：SQL 输入区、`Run` 按钮、查询状态。适合录“在 BigQuery 里查看/验证数据”的只读镜头。
- 下方面板 `Query results`：查询完成后展示结果表格、job 状态和分页信息。结果表格可能横向滚动。
- 表详情页 tabs：常见有 `Schema`、`Details`、`Preview`。`Schema` 适合展示字段结构；`Preview` 适合快速确认表里有数据，但列顺序不一定适合镜头。
- 右侧或弹层区域：query settings、save/share/schedule 等操作可能出现弹层；正式录制前先探索，不要在正式 take 里临场找位置。

## 录制策略

- 需要控制首屏可见列时，优先用 `Query editor` 写只读 `SELECT` 并调整列顺序；不要把正式镜头建立在横向拖动结果表格滚动条上。
- 如果只需要证明表存在，录 `Explorer` 展开到 table，再切 `Schema` 或 `Preview` 即可。
- 如果需要展示数据含义，先在项目脚本里定义“观众必须看到哪些列/文本”，再用 snapshot/storyboard 验证这些内容确实出现在画面中。
- `Query results` 和 `Preview` 都可能异步加载；等待要通过 timeline 记录，不要把长时间无变化的 loading 原样交付。
- 页面空间紧张时，先折叠不相关侧栏或调大 viewport，再开始正式录制。

## 常见坑位

- BigQuery sandbox / free tier 可能拒绝 DML，例如 `INSERT` 报 `DML queries are not allowed in the free tier`。需要构造临时演示表时，优先考虑 `CREATE OR REPLACE TABLE ... AS SELECT ...`、load job 或预置数据。
- `Preview` tab 的列顺序来自表结构，未必适合视频说明；结果表格横向滚动也容易让关键内容不在首屏。
- GCP Console 可能启用 Trusted Types；页面内 click cue 不能用 `innerHTML` 注入 SVG，必须使用 DOM API / `createElementNS`。
- GCP SPA 的 ref 会随 tab 切换、查询完成、弹层打开而变化；每次页面状态变化后重新 `snapshot -i`。
- `Run` 后查询状态可能先显示 running，再显示 completed；需要把等待、结果出现、最终 snapshot 分别记入 timeline。

## 安全边界

- 可以录 demo project、dataset、table、schema、虚构数据、用户名和头像。
- 不要录 service account JSON、private key、access token、真实客户数据、billing 信息或 IAM 真实成员列表。
- 凭证创建、key 下载、API 启用、IAM 授权这些镜头应按独立凭证流程处理，并停在安全边界前。
- 如果页面出现敏感弹层、下载文件内容、真实权限列表或 billing 详情，停录或切换镜头。

## 最终验证

- `timeline.jsonl` 有查询、等待、tab 切换、snapshot 和验证事件的相对时间。
- storyboard 覆盖完整时长，并能看出 Explorer/table、Schema/Preview 或 Query results 的主要状态。
- 最终 snapshot 或截图证明关键 UI 状态可见，且没有 secret、key、token、private key、真实客户数据或 billing 内容。
