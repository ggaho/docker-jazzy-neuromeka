#!/bin/bash

# 1. 호스트 화면 접근 권한 허용 (Gazebo/RViz GUI 연동 필수)
xhost +local:docker > /dev/null

# 2. 변수 설정
CONTAINER_NAME=ros2_jazzy_container_v1
IMAGE_NAME=ros2-jazzy-desktop:latest

# 3. 새 도커 컨테이너 실행
docker run --name=${CONTAINER_NAME} \
--ipc=host \
--net=host \
--privileged \
--gpus all \
-it \
--device /dev/snd \
--device /dev/video0 \
--device /dev/video1 \
--device /dev/video2 \
-e DISPLAY=$DISPLAY \
-e QT_X11_NO_MITSHM=1 \
-e NVIDIA_VISIBLE_DEVICES=all \
-e NVIDIA_DRIVER_CAPABILITIES=all,display,graphics,utility \
-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
-v /dev/bus/usb:/dev/bus/usb \
-v /dev:/dev \
--group-add $(getent group audio | cut -d: -f3) \
${IMAGE_NAME} /bin/bash