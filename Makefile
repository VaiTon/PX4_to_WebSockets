DOCKER ?= docker
IMAGE ?= ros-server

.PHONY: launch
launch: build check_xargs check_docker
	@echo "🚀 Launching ROS development environment..."
	xhost +
	@$(DOCKER) run -it --rm --name ros \
        -e DISPLAY -e XDG_RUNTIME_DIR \
        -p 8888:8888 -p 9090:9090 \
        --volume='/tmp/.X11-unix:/tmp/.X11-unix:rw' \
        --security-opt label=type:container_runtime_t \
        $(IMAGE)

.PHONY: build
build: check_docker
	@echo "🔨 Building ROS development environment..."
	@$(DOCKER) build -t $(IMAGE) . -f Containerfile | tee build.log \
	   || (echo "Build failed. Check build.log for more information" && exit 1)


.PHONY: check_xhost
check_xargs:
	@echo "🔍 Checking xhost..."
	@which xhost > /dev/null || (echo "xhost is not installed. Please install xhost" && exit 1)

check_docker:
	@echo "🔍 Checking Docker..."
	@which $(DOCKER) > /dev/null || (echo "Docker is not installed. Please install Docker" && exit 1)
	@$(DOCKER) --version
