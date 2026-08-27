# Use specific version of nvidia cuda image
FROM wlsdml1114/multitalk-base:1.4 as runtime

# wget 설치 (URL 다운로드를 위해)
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN pip install runpod websocket-client boto3

WORKDIR /


RUN git clone --depth 1 --branch v0.34.1 https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
    pip install -r requirements.txt

# 모델 다운로드 — 직접 wget (HF 캐시 snapshots/ 심링크를 move하면 깨진 링크가 되어
# ComfyUI가 'exists but doesn't link anywhere'로 스킵하는 문제를 회피)
RUN rm -f /ComfyUI/models/unet/z_image_turbo_bf16.safetensors && \
    wget -q https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors -O /ComfyUI/models/unet/z_image_turbo_bf16.safetensors
RUN rm -f /ComfyUI/models/clip/qwen_3_4b.safetensors && \
    wget -q https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors -O /ComfyUI/models/clip/qwen_3_4b.safetensors
RUN rm -f /ComfyUI/models/vae/ae.safetensors && \
    wget -q https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors -O /ComfyUI/models/vae/ae.safetensors
RUN rm -f "/ComfyUI/models/model_patches/Z-Image-Turbo-Fun-Controlnet-Union.safetensors" && \
    wget -q https://huggingface.co/alibaba-pai/Z-Image-Turbo-Fun-Controlnet-Union/resolve/main/Z-Image-Turbo-Fun-Controlnet-Union.safetensors -O "/ComfyUI/models/model_patches/Z-Image-Turbo-Fun-Controlnet-Union.safetensors"




COPY . .
RUN mkdir -p /ComfyUI/user/default/ComfyUI-Manager
COPY config.ini /ComfyUI/user/default/ComfyUI-Manager/config.ini
COPY extra_model_paths.yaml /ComfyUI/extra_model_paths.yaml
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]