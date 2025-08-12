FROM l3tnun/epgstation:master-debian AS epgstation
FROM ubuntu:24.04 AS base
COPY --from=epgstation /usr/local/include/ /usr/local/include/
COPY --from=epgstation /usr/local/lib/ /usr/local/lib/
COPY --from=epgstation /usr/local/bin/ /usr/local/bin/
COPY --from=epgstation /opt/yarn* /opt/yarn
RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn && \
    ln -fs /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg
COPY --from=epgstation /app/ /app/
COPY --from=epgstation /app/client/ /app/client/

ENV DEV="make gcc git g++ automake curl wget autoconf build-essential libass-dev libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev"
ENV QSVDEV="wget git cmake intel-media-va-driver-non-free libva-drm2 libva-x11-2 libva-glx2 libx11-dev libva-dev libigfxcmrt7 libdrm-dev opencl-headers libavcodec60 libavcodec-dev libavutil58 libavutil-dev libavformat60 libavformat-dev libswresample4 libswresample-dev libavfilter9 libavfilter-dev libavdevice60 libavdevice-dev libavfilter-dev libass9 libass-dev"
ENV TSREPDEV="wget git pkg-config python3 build-essential libavcodec-dev libavutil-dev libavformat-dev libswresample-dev libavfilter-dev"
ENV FFMPEG_VERSION=7.0

RUN apt-get update && \
    apt-get -y install $DEV && \
    apt-get -y install yasm libx264-dev libmp3lame-dev libopus-dev libvpx-dev && \
    apt-get -y install libx265-dev libnuma-dev && \
    apt-get -y install libasound2t64 libass9 libvdpau1 libva-x11-2 libva-drm2 libxcb-shm0 libxcb-xfixes0 libxcb-shape0 libvorbisenc2 libtheora0 libaribb24-dev && \
    apt-get -y install $QSVDEV && \
    apt-get -y install $TSREPDEV

# ffmpeg build
RUN mkdir /tmp/ffmpeg_sources && \
    cd /tmp/ffmpeg_sources && \
    curl -fsSL http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 | tar -xj --strip-components=1 && \
    ./configure \
      --prefix=/usr/local \
      --disable-shared \
      --pkg-config-flags=--static \
      --enable-gpl \
      --enable-libass \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-version3 \
      --enable-libaribb24 \
      --enable-nonfree \
      --disable-debug \
      --disable-doc \
    && \
    make -j$(nproc) && \
    make install

# QSVEnc
RUN bash -c "curl -s https://api.github.com/repos/rigaya/QSVEnc/releases/latest | \
    grep 'browser_download_url.*qsvencc_.*_Ubuntu24.04_amd64.deb' | \
    cut -d : -f 2,3 | tr -d '\"' | sed 's/^ *//' | \
    xargs curl -fsSL -o qsvencc_Ubuntu24.04_amd64.deb" && \
    apt-get -y install ./qsvencc_Ubuntu24.04_amd64.deb

# tsreplace
RUN bash -c "curl -s https://api.github.com/repos/rigaya/tsreplace/releases/latest | \
    grep 'browser_download_url.*tsreplace_.*_Ubuntu24.04_amd64.deb' | \
    cut -d : -f 2,3 | tr -d '\"' | sed 's/^ *//' | \
    xargs curl -fsSL -o tsreplace_Ubuntu24.04_amd64.deb" && \
    apt-get -y install ./tsreplace_Ubuntu24.04_amd64.deb

# 不要なパッケージを削除
RUN apt-get -y remove $DEV && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

WORKDIR /app
ENTRYPOINT ["npm"]
CMD ["start"]


