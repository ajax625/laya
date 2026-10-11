FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    USE_TF=0 \
    HF_HOME=/models \
    LAYA_HOST=0.0.0.0 \
    LAYA_PORT=8000

# CPU-only torch keeps the image far smaller than the default CUDA wheel on x86_64
RUN pip install --index-url https://download.pytorch.org/whl/cpu torch \
 && pip install "laya[serve]"

# Run as a non-root user; models cache to /models (mount a volume there)
RUN useradd -m laya && mkdir -p /models && chown laya /models
USER laya

EXPOSE 8000
CMD ["laya-serve"]
