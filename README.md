# Z-Image Turbo for RunPod Serverless

Serverless worker serving **Z-Image Turbo** (Tongyi-MAI, 6B, Apache-2.0) through ComfyUI on RunPod: flat input `{prompt, seed, guidance, width, height}` in → `{"image": "<base64 PNG>"}` out.

Forked from [wlsdml1114/Flux-krea_Runpod_hub](https://github.com/wlsdml1114/Flux-krea_Runpod_hub) (zimage branch). Adaptations: `guidance` accepted as an alias for `cfg` (keeps the flat input contract with the zimg CLI), ComfyUI pinned to `v0.34.1`, metadata renamed.

## Deploy (Runpod GitHub integration)

1. Connect GitHub in Runpod console: **Settings → Connections → GitHub** → authorize, allow this repo.
2. **New Endpoint → Import Git Repository** → select this repo → branch `main`.
3. Endpoint type **Queue**; GPU 4090-class (`ADA_24`) or better; flashboot on; default timeouts.
4. **Deploy Endpoint**; watch the **Builds** tab. The docker build must finish ≤ 30 min (~20 GB model download, HF transfer enabled).

## Input

Flat object; only `prompt` is expected, everything else has a default.

| Param | Type | Default | Notes |
|-------|------|---------|-------|
| `prompt` | string | `""` | text to render |
| `seed` | int | `533303727624653` | fixed seed for reproducible output |
| `steps` | int | `9` | Z-Image turbo runs in ~8–9 steps |
| `cfg` | float | `1.0` | classifier-free guidance; distilled model — keep 1 |
| `guidance` | float | `1.0` | alias for `cfg` (zimg sends `guidance`) |
| `width` / `height` | int | `1024` | adjusted to the nearest multiple of 16 |
| `negative_prompt` | string | `""` | accepted; text-only workflow zeroes conditioning anyway |
| `condition_image` | string | — | base64 / URL / path → control workflow (requires the ControlNet model) |
| `lora` | array | — | `[[path, strength]]` → lora workflow (needs model on a network volume) |

## Output

```json
{ "image": "data:image/png;base64,..." }
```

On failure: `{ "error": "..." }`.

## Model files (downloaded at build time by `download_models.py`)

- `Comfy-Org/z_image_turbo`: `z_image_turbo_bf16.safetensors`, `qwen_3_4b.safetensors`, `ae.safetensors`
- `alibaba-pai/Z-Image-Turbo-Fun-Controlnet-Union` (control workflow only)

Model license: Apache-2.0. Worker template code follows the original project's license.

## Layout

- `handler.py` — runpod worker: loads a workflow (`workflow/z_image.json` text-only, `z_image_control.json`, `z_image_lora.json`), fills prompt/seed/steps/cfg/width/height, queues to ComfyUI, returns the first image base64.
- `Dockerfile` — builds ComfyUI (pinned `v0.34.1`) + downloads the weights directly with `wget` (avoids HF-cache symlink issues).
- `entrypoint.sh` — starts ComfyUI, waits for readiness, then runs the worker.
