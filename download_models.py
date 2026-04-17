import os
import shutil
from huggingface_hub import hf_hub_download

downloads = [
    ("Comfy-Org/z_image_turbo", "split_files/diffusion_models/z_image_turbo_bf16.safetensors", "/ComfyUI/models/unet/z_image_turbo_bf16.safetensors"),
    ("Comfy-Org/z_image_turbo", "split_files/text_encoders/qwen_3_4b.safetensors", "/ComfyUI/models/clip/qwen_3_4b.safetensors"),
    ("Comfy-Org/z_image_turbo", "split_files/vae/ae.safetensors", "/ComfyUI/models/vae/ae.safetensors"),
    ("alibaba-pai/Z-Image-Turbo-Fun-Controlnet-Union", "Z-Image-Turbo-Fun-Controlnet-Union.safetensors", "/ComfyUI/models/model_patches/Z-Image-Turbo-Fun-Controlnet-Union.safetensors")
]

print("Starting model downloads...")
for repo, filename, dest in downloads:
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    print(f"Downloading {filename} from {repo}...")
    
    # 캐시에 다운로드
    cached_file = hf_hub_download(repo_id=repo, filename=filename)
    
    # 이동 (도커 이미지 용량 중복 방지)
    try:
        shutil.move(cached_file, dest)
        print(f"Moved to {dest}")
    except Exception as e:
        shutil.copy(cached_file, dest)
        print(f"Copied to {dest} (Move failed: {e})")

print("All models downloaded successfully!")
