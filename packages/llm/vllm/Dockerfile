#---
# name: vllm
# group: vlm
# config: config.py
# depends: [transformers, torchaudio, openai-triton]
# requires: '>=34.1.0'
# test: test.py
# notes: https://github.com/vllm-project/vllm
#---
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG VLLM_VERSION \
    FORCE_BUILD=off

COPY build.sh install.sh patches /tmp/vllm/

RUN /tmp/vllm/install.sh || /tmp/vllm/build.sh
