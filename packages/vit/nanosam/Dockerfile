#---
# name: nanosam
# group: vit
# depends: [pytorch, torch2trt, transformers]
# requires: '>=34.1.0'
# docs: docs.md
#---
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

WORKDIR /opt

# 1. Install the dependencies
# 
# PyTorch and torch2trt are specified in the header yaml part (under "depends:")
#
RUN git clone https://github.com/NVIDIA-AI-IOT/trt_pose && \
    cd trt_pose && \
    python3 setup.py develop --user

# 2. Install the NanoSAM Python package
RUN git clone https://github.com/NVIDIA-AI-IOT/nanosam && \
    cd nanosam && \
    python3 setup.py develop --user

# 3. Build the TensorRT engine for the mask decoder
RUN pip3 install --verbose --no-cache-dir timm

#RUN cd /opt/nanosam && \
#    mkdir data && \
#    python3 -m nanosam.tools.export_sam_mask_decoder_onnx \
#        --model-type=vit_t \
#        --checkpoint=assets/mobile_sam.pt \
#        --output=data/mobile_sam_mask_decoder.onnx

RUN mkdir /opt/nanosam/data && \
    wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate \
	 https://files.anjara.eu/f/bbcdc90c2fa20cf4e56b4a8ee08568db9168a892233baecf9548ac880efb0c8c \
	 -O /opt/nanosam/data/mobile_sam_mask_decoder.onnx

RUN cd /opt/nanosam && \
    /usr/src/tensorrt/bin/trtexec \
        --onnx=data/mobile_sam_mask_decoder.onnx \
        --saveEngine=data/mobile_sam_mask_decoder.engine \
        --minShapes=point_coords:1x1x2,point_labels:1x1 \
        --optShapes=point_coords:1x1x2,point_labels:1x1 \
        --maxShapes=point_coords:1x10x2,point_labels:1x10

# 4. Build the TensorRT engine for the NanoSAM image encoder
RUN wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate \
        https://files.anjara.eu/f/f596fde1c958781f32c0dc47574ab659fce4fd29c2847ea4ed90497a7233c3e5 \
        -O /opt/nanosam/data/resnet18_image_encoder.onnx && \
    cd /opt/nanosam/ && \
    /usr/src/tensorrt/bin/trtexec \
        --onnx=data/resnet18_image_encoder.onnx \
        --saveEngine=data/resnet18_image_encoder.engine \
        --fp16

# 5. Run the basic usage example
RUN pip3 install --no-cache-dir -U matplotlib
RUN cd /opt/nanosam/ && \
    python3 examples/basic_usage.py \
        --image_encoder=data/resnet18_image_encoder.engine \
        --mask_decoder=data/mobile_sam_mask_decoder.engine

COPY benchmark.py /opt/nanosam/