# Ubuntu 24.04(LTS) 버전을 기반으로 하는 Docker 이미지 사용
FROM ubuntu:24.04

# Docker 빌드 과정에서 사용할 셸을 bash로 지정 (RUN 명령어에 적용됨)
SHELL ["/bin/bash", "-c"]

# apt 설치 시 사용자 입력(타임존 등) 방지 & 타임존을 서울로 지정
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul

### 1. 기본 시스템 유틸리티 설치 ###
RUN apt-get update && apt-get install -y \
    software-properties-common \
    apt-utils \
    gedit \
    git \
    locales \
    lsb-release \
    gnupg2 \
    curl \
    tmux \
    vim \
    zip \
    iputils-ping \
    net-tools \
    python3-pip \
    python3-venv \
    && add-apt-repository universe \
    && rm -rf /var/lib/apt/lists/*

### 2. ROS2 Jazzy를 설치하기 위한 로케일 설정 ###
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

### 3. ROS2 APT 키 및 저장소 추가 ###
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

### 4. ROS2 Jazzy 패키지, 개발툴 및 추가 패키지 설치 ###
RUN apt-get update && apt-get install -y \
    ros-jazzy-desktop \
    ros-dev-tools \
    python3-colcon-common-extensions \
    python3-rosdep \
    ros-jazzy-ros2bag \
    ros-jazzy-rosbag2-storage-default-plugins \
    ros-jazzy-ament-cmake \
    ros-jazzy-xacro \
    ros-jazzy-ros-base \
    ros-jazzy-moveit \
    ros-jazzy-moveit-servo \
    ros-jazzy-moveit-visual-tools \
    ros-jazzy-moveit-resources \
    ros-jazzy-moveit-ros-move-group \
    ros-jazzy-moveit-planners-ompl \
    ros-jazzy-moveit-kinematics \
    ros-jazzy-moveit-ros-perception \
    ros-jazzy-ros2-control \
    ros-jazzy-ros2-controllers \
    ros-jazzy-controller-manager \
    ros-jazzy-joint-state-broadcaster \
    ros-jazzy-joint-state-publisher-gui \
    ros-jazzy-joint-trajectory-controller \
    ros-jazzy-rviz-visual-tools \
    ros-jazzy-geometric-shapes \
    ros-jazzy-gz-ros2-control \
    ros-jazzy-ros-gz \
    ros-jazzy-realsense2-camera \
    ros-jazzy-realsense2-description \
    ros-jazzy-librealsense2* \
    ros-jazzy-rmw-cyclonedds-cpp \
    && rm -rf /var/lib/apt/lists/*

# rosdep 초기화 및 업데이트
RUN rosdep init || true && rosdep update

# CycloneDDS를 기본 미들웨어로 설정
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Python 유틸 설치 (ROS2 CLI 자동완성 및 패키지 빌드 의존성)
RUN pip3 install --no-cache-dir --ignore-installed argcomplete catkin_pkg empy lark-parser pyyaml jinja2 typeguard neuromeka --break-system-packages

# ROS2 워크스페이스 생성 및 뉴로메카 패키지 클론 후 빌드
RUN mkdir -p /root/ros2_ws/src
WORKDIR /root/ros2_ws/src
RUN git clone https://github.com/neuromeka-robotics/indy-ros2 -b jazzy-indyDCP3

# ★ 추가된 부분: 클론된 파이썬 스크립트에 실행 권한 미리 부여
RUN find /root/ros2_ws/src/indy-ros2 -name "*.py" -exec chmod +x {} +

# rosdep을 통한 의존성 일괄 설치 및 colcon 전역 빌드 수행
WORKDIR /root/ros2_ws
RUN source /opt/ros/jazzy/setup.bash && \
    rosdep install --from-paths src --ignore-src -r -y && \
    colcon build --symlink-install --cmake-args -DBUILD_SHARED_LIBS=ON

### 5. bashrc 설정: ROS2 환경 자동 로드 및 alias 추가 ###
RUN echo "" >> /root/.bashrc && \
    echo "### ros2 jazzy" >> /root/.bashrc && \
    echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "if [ -f ~/ros2_ws/install/setup.bash ]; then source ~/ros2_ws/install/setup.bash; fi" >> /root/.bashrc && \
    echo "" >> /root/.bashrc && \
    echo "alias cs='cd ~/ros2_ws/src'" >> /root/.bashrc && \
    echo "alias cw='cd ~/ros2_ws'" >> /root/.bashrc && \
    echo "alias cm='cd ~/ros2_ws && colcon build --symlink-install --cmake-args -DBUILD_SHARED_LIBS=ON && source install/setup.bash'" >> /root/.bashrc && \
    echo "" >> /root/.bashrc

# 기본 작업 디렉토리를 워크스페이스 루트로 지정 (컨테이너 진입 시 시작 위치)
WORKDIR /root/ros2_ws

# 기본 bash 셸 실행
CMD ["/bin/bash"]