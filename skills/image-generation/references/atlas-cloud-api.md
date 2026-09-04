# Atlas Cloud API Fallback

Use this path when the built-in Codex image path is unavailable and `ATLASCLOUD_API_KEY` is configured, or when the user explicitly requests Atlas Cloud.

## Requirements

- `ATLASCLOUD_API_KEY` must be set.
- The default model is `qwen-image-3.0/text-to-image`.
- The script submits one asynchronous generation request, polls the prediction endpoint with a fixed limit, and downloads the completed image without forwarding the API credential.

## Command

```bash
python <skill-root>/scripts/generate_image.py \
  --provider atlas \
  --prompt "your prompt here" \
  --output "/path/to/save/image.png"
```

To include Atlas Cloud after the OpenAI and Gemini paths:

```bash
python <skill-root>/scripts/generate_image.py \
  --provider auto \
  --prompt "your prompt here" \
  --output "/path/to/save/image.png"
```

## Options

```text
--atlas-model     Atlas Cloud image model ID
--aspect-ratio    1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 9:16, 16:9, 21:9, etc.
--image-size      512, 1K, 2K, 4K (mapped within the model's 512-2048 pixel range)
--style-prefix    Custom style prefix
--no-style        Skip the default style prefix
```

The Atlas path does not automatically retry the generation `POST`. Only prediction `GET` polling is repeated, with a bounded wait.
