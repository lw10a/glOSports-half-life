# syntax=docker/dockerfile:1

FROM debian:bookworm AS builder

RUN dpkg --add-architecture armhf && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        cmake \
        make \
        pkg-config \
        wget \
        rsync \
        zip \
        crossbuild-essential-armhf \
        libsdl2-dev:armhf \
        file && \
    rm -rf /var/lib/apt/lists/*

ENV PKG_CONFIG_PATH=/usr/lib/arm-linux-gnueabihf/pkgconfig
ENV PKG_CONFIG_LIBDIR=/usr/lib/arm-linux-gnueabihf/pkgconfig
ENV PKG_CONFIG_ALLOW_CROSS=1

RUN mkdir -p /output/ports/half-life /staging/xash3d /output/ports/half-life/valve/dlls /output/ports/half-life/valve/cl_dlls

# Download the latest xash3d armhf build, extract it to /staging/xash3d
WORKDIR /download
RUN wget https://github.com/FWGS/xash3d-fwgs/releases/download/continuous-freevgui/xash3d-fwgs-linux-armhf.tar.gz && \
    tar -xzf xash3d-fwgs-linux-armhf.tar.gz -C /staging/xash3d

# Copy to `output`, flattening all symlinks into real files
RUN rsync -a --copy-links /staging/xash3d/xash3d-fwgs-linux-armhf/ /output/ports/half-life/

# Build the latest hlsdk-portable
WORKDIR /build
RUN git clone --recursive https://github.com/FWGS/hlsdk-portable.git

COPY toolchain-armhf.cmake /build/toolchain-armhf.cmake

WORKDIR /build/hlsdk-portable

RUN cmake -B build -S . \
        -DCMAKE_TOOLCHAIN_FILE=/build/toolchain-armhf.cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DGOLDSOURCE_SUPPORT=OFF \
        -D64BIT=OFF \
        -DUSE_VGUI=OFF

RUN cmake --build build -j"$(nproc)"

# Copy the files from hlsdk-portable into the output directories where they belong.
RUN find build/dlls    -name '*.so' -exec cp -v {} /output/ports/half-life/valve/dlls/ \; && \
    find build/cl_dll  -name '*.so' -exec cp -v {} /output/ports/half-life/valve/cl_dlls/ \;

# Copy launcher assets to the output folder
RUN mkdir -p /output/.local/share/applications /output/.local/share/backgrounds
COPY half-life.desktop /output/.local/share/applications/half-life.desktop
COPY half-life.png /output/.local/share/backgrounds/half-life.png

# Copy the Half Life SDK license file into the output folder
RUN cp /build/hlsdk-portable/LICENSE /output/ports/half-life/HL1_SDK_LICENSE.txt


RUN echo "place your game files in here!" > /output/ports/half-life/valve/place-game-files-here.txt

# Delete all the SDL libs from /output.
# They don't seem to work with KMSDRM, and the SDL2 files that come with goodluckOS work just as well.
RUN rm -f /output/ports/half-life/libSDL*

WORKDIR /output
RUN zip -r /half-life-port.zip .

FROM scratch AS export
COPY --from=builder /half-life-port.zip /
