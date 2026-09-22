# ROS2 Jazzy & Neuromeka Indy Docker Environment

Ubuntu 24.04 기반의 ROS2 Jazzy 및 뉴로메카(Neuromeka) 로봇 제어 환경을 위한 Docker 설정 저장소입니다.

## 🛠️ 주요 포함 패키지 및 환경
- **Base OS:** Ubuntu 24.04 (LTS)
- **Middleware:** CycloneDDS (`rmw_cyclonedds_cpp`)
- **ROS2 Distro:** Jazzy Jalisco
- **Robot Packages:** 
  - Neuromeka `indy-ros2` (`jazzy-indyDCP3` 브랜치)
  - MoveIt 2 (Motion Planning & Servo)
  - Intel RealSense Driver (`realsense2-camera`, `librealsense2*`)
  - Gazebo & ROS2 Control / Controllers

## 🚀 사용 및 실행 방법

저장소를 클론한 후, 아래 명령어를 순서대로 실행하여 도커 이미지 빌드와 컨테이너 구동을 진행하세요.

```bash
# 1. 저장소 클론
git clone https://github.com/ggaho/docker-jazzy-neuromeka.git
cd docker-jazzy-neuromeka

# 2. 도커 이미지 빌드
docker build -t ros2-jazzy-desktop:latest .

# 3. 실행 스크립트 권한 부여 및 컨테이너 실행
chmod +x ros2_jazzy_v1.sh
./ros2_jazzy_v1.sh