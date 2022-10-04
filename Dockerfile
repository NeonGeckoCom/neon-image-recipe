FROM python:3.8-slim

RUN apt update && \
    apt install -y wget

RUN mkdir /build && \
    cd /build && \
    wget https://2222.us/app/files/neon_images/pi/ubuntu_22_04.img.xz && \
    wget https://2222.us/app/files/neon_images/pi/debian-base-image-rpi4.img.xz

RUN apt install -y sudo qemu-user-static xz-utils git fdisk mount

RUN pip install pytz requests

COPY docker_overlay/ /
RUN chmod ugo+x /scripts/install_and_build.sh

ENV OUTPUT_DIR=/output
ENV BUILD_DIR=/build

CMD ["/scripts/install_and_build.sh"]