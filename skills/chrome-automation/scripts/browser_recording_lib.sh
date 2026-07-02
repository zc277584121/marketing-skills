#!/usr/bin/env bash

# Shell helpers for Agent Browser viewport recordings.
# The caller must define an `ab` shell function, for example:
#   ab() { agent-browser --namespace demo --session flow --headed --profile "$PROFILE" "$@"; }

browser_recording_now_ms() {
  python3 -c 'import time; print(time.monotonic_ns() // 1_000_000)'
}

browser_recording_start_timer() {
  export BROWSER_RECORDING_START_MONO_MS
  BROWSER_RECORDING_START_MONO_MS="$(browser_recording_now_ms)"
}

browser_recording_elapsed_ms() {
  local now_ms
  now_ms="$(browser_recording_now_ms)"
  if [[ -z "${BROWSER_RECORDING_START_MONO_MS:-}" ]]; then
    echo 0
    return
  fi
  echo $((now_ms - BROWSER_RECORDING_START_MONO_MS))
}

browser_recording_json_quote() {
  python3 -c 'import json, sys; print(json.dumps(sys.argv[1]))' "$1"
}

browser_recording_mark() {
  local timeline="$1"
  local event="$2"
  local note="${3:-}"
  local elapsed_ms
  shift 3 || true
  elapsed_ms="$(browser_recording_elapsed_ms)"
  mkdir -p "$(dirname "$timeline")"
  python3 - "$timeline" "$event" "$note" "$elapsed_ms" "$@" <<'PY'
import datetime
import json
import sys

timeline, event, note, elapsed_ms, *pairs = sys.argv[1:]
if len(pairs) % 2:
    raise SystemExit("browser_recording_mark extras must be key/value pairs")

payload = {
    "ts": datetime.datetime.now(datetime.timezone.utc)
    .isoformat(timespec="milliseconds")
    .replace("+00:00", "Z"),
    "t_ms": int(elapsed_ms),
    "event": event,
}
if note:
    payload["note"] = note

for key, value in zip(pairs[0::2], pairs[1::2]):
    if value == "__true__":
        payload[key] = True
    elif value == "__false__":
        payload[key] = False
    elif value == "__null__":
        payload[key] = None
    elif value.startswith("@json:"):
        payload[key] = json.loads(value.removeprefix("@json:"))
    else:
        payload[key] = value

with open(timeline, "a", encoding="utf-8") as output:
    output.write(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n")
PY
}

browser_recording_mark_current() {
  if [[ -n "${BROWSER_RECORDING_TIMELINE:-}" ]]; then
    browser_recording_mark "$BROWSER_RECORDING_TIMELINE" "$@"
  fi
}

browser_recording_record_start() {
  local run_dir="$1"
  local video_path="$2"
  mkdir -p "$run_dir/snaps"
  export BROWSER_RECORDING_RUN_DIR="$run_dir"
  export BROWSER_RECORDING_TIMELINE="$run_dir/timeline.jsonl"
  browser_recording_start_timer
  : > "$BROWSER_RECORDING_TIMELINE"
  browser_recording_mark "$BROWSER_RECORDING_TIMELINE" "record_start_requested" "Starting Agent Browser viewport recording." "video" "$video_path"
  ab record restart "$video_path"
  browser_recording_mark "$BROWSER_RECORDING_TIMELINE" "record_started" "Agent Browser viewport recording started." "video" "$video_path"
}

browser_recording_record_stop() {
  local run_dir="${1:-${BROWSER_RECORDING_RUN_DIR:-}}"
  local timeline="${BROWSER_RECORDING_TIMELINE:-$run_dir/timeline.jsonl}"
  browser_recording_mark "$timeline" "record_stop_requested" "Stopping Agent Browser viewport recording."
  ab record stop
  browser_recording_mark "$timeline" "record_stopped" "Agent Browser viewport recording stopped."
}

browser_recording_install_click_cue() {
  local skill_root="$1"
  browser_recording_mark_current "cue_install_started" "Installing page-local click cue script." "script" "$skill_root/scripts/browser_click_cue.js"
  ab eval --stdin < "$skill_root/scripts/browser_click_cue.js" >/dev/null
  browser_recording_mark_current "cue_install_finished" "Page-local click cue script installed." "script" "$skill_root/scripts/browser_click_cue.js"
}

browser_recording_cue_selector() {
  local selector="$1"
  local note="${2:-Click cue for selector.}"
  browser_recording_mark_current "cue_started" "$note" "selector" "$selector"
  ab eval "window.browserClickCue.showForSelector($(browser_recording_json_quote "$selector"))" >/dev/null
  browser_recording_mark_current "cue_finished" "$note" "selector" "$selector"
}

browser_recording_cue_text() {
  local text="$1"
  local note="${2:-Click cue for visible text.}"
  browser_recording_mark_current "cue_started" "$note" "text" "$text"
  ab eval "window.browserClickCue.showForText($(browser_recording_json_quote "$text"))" >/dev/null
  browser_recording_mark_current "cue_finished" "$note" "text" "$text"
}

browser_recording_snapshot_to() {
  local run_dir="$1"
  local name="$2"
  local note="${3:-Snapshot saved.}"
  local timeline="${BROWSER_RECORDING_TIMELINE:-$run_dir/timeline.jsonl}"
  mkdir -p "$run_dir/snaps"
  browser_recording_mark "$timeline" "snapshot_started" "$note" "snapshot" "snaps/$name.txt"
  ab snapshot -i > "$run_dir/snaps/$name.txt"
  browser_recording_mark "$timeline" "snapshot_saved" "$note" "snapshot" "snaps/$name.txt"
}

browser_recording_ref_from_snapshot() {
  local file="$1"
  local pattern="$2"
  local token
  token="$(
    awk -v pat="$pattern" '$0 ~ pat {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /ref=e[0-9]+/) {
          gsub(/[\[\],]/, "", $i);
          print $i;
          exit;
        }
      }
    }' "$file"
  )"
  if [[ -z "$token" ]]; then
    echo "Could not find ref for pattern: $pattern in $file" >&2
    return 1
  fi
  echo "@${token#ref=}"
}

browser_recording_click_ref_from_snapshot() {
  local run_dir="$1"
  local timeline="$2"
  local snap_name="$3"
  local pattern="$4"
  local note="$5"
  local snap_file="$run_dir/snaps/$snap_name.txt"
  local ref
  ref="$(browser_recording_ref_from_snapshot "$snap_file" "$pattern")"
  browser_recording_mark "$timeline" "action_started" "$note" "action" "click" "ref" "$ref" "snapshot" "snaps/$snap_name.txt" "pattern" "$pattern"
  ab click "$ref"
  browser_recording_mark "$timeline" "action_succeeded" "$note" "action" "click" "ref" "$ref"
}

browser_recording_click_ref() {
  local ref="$1"
  local note="${2:-Click ref.}"
  browser_recording_mark_current "action_started" "$note" "action" "click" "ref" "$ref"
  ab click "$ref"
  browser_recording_mark_current "action_succeeded" "$note" "action" "click" "ref" "$ref"
}

browser_recording_fill_ref() {
  local ref="$1"
  local value="$2"
  local note="${3:-Fill ref.}"
  browser_recording_mark_current "action_started" "$note" "action" "fill" "ref" "$ref" "value_redacted" "__true__"
  ab fill "$ref" "$value"
  browser_recording_mark_current "action_succeeded" "$note" "action" "fill" "ref" "$ref" "value_redacted" "__true__"
}

browser_recording_press() {
  local key="$1"
  local note="${2:-Press key.}"
  browser_recording_mark_current "action_started" "$note" "action" "press" "key" "$key"
  ab press "$key"
  browser_recording_mark_current "action_succeeded" "$note" "action" "press" "key" "$key"
}

browser_recording_wait_ms() {
  local duration_ms="$1"
  local note="${2:-Wait.}"
  browser_recording_mark_current "wait_started" "$note" "duration_ms" "$duration_ms"
  ab wait "$duration_ms"
  browser_recording_mark_current "wait_finished" "$note" "duration_ms" "$duration_ms"
}

browser_recording_assert_snapshot_contains() {
  local run_dir="$1"
  local snap_name="$2"
  local pattern="$3"
  local note="${4:-Snapshot contains required text.}"
  local timeline="${BROWSER_RECORDING_TIMELINE:-$run_dir/timeline.jsonl}"
  local snap_file="$run_dir/snaps/$snap_name.txt"
  if grep -Eq "$pattern" "$snap_file"; then
    browser_recording_mark "$timeline" "verification_passed" "$note" "snapshot" "snaps/$snap_name.txt" "pattern" "$pattern"
    return 0
  fi
  browser_recording_mark "$timeline" "verification_failed" "$note" "snapshot" "snaps/$snap_name.txt" "pattern" "$pattern"
  return 1
}
