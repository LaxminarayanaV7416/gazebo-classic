# pull from base Ubuntu image
FROM ubuntu:24.04
LABEL maintainer="Laxminarayana Vadnala <lvadnala@nd.edu>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
   	g++ \
	gcc \
    pkg-config \
    sudo \
   	python3-dev \
	python3-pip \
    libboost-system-dev \
    libxml2-utils \
    ruby-dev \
    mesa-utils \
    ruby \
    tcpdump \
   	ant \
	binutils \
	bc \
	dirmngr \
   	gstreamer1.0-plugins-bad \
	gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-good \
	gstreamer1.0-plugins-ugly \
	libgstreamer-plugins-base1.0-dev \
	libimage-exiftool-perl \
	libopencv-dev \
	libxml2-utils \
    libfreeimage-dev \
    libtinyxml2-dev \
    uuid-dev \
    libgts-dev \
    libavdevice-dev \
    libavformat-dev \
    libavcodec-dev \
    libswscale-dev \
    libavutil-dev \
    libprotoc-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libzip-dev \
    libjsoncpp-dev \
    libcurl4-openssl-dev \
    libyaml-dev \
    lsb-release \
    wget \
    gnupg \
    python3-pybind11 \
    && apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# setup virtual X server
RUN mkdir /tmp/.X11-unix && \
		chmod 1777 /tmp/.X11-unix && \
		chown -R root:root /tmp/.X11-unix
ENV DISPLAY=:99

WORKDIR /tmp
# Installing the dependencies for the gazebo
# installing ign-cmake
RUN git clone https://github.com/ignitionrobotics/ign-cmake ign-cmake && \
    cd ign-cmake && \
    git checkout ign-cmake2 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_PREFIX_PATH=/usr/local .. && \
    make -j4 && \
    sudo make install

# installing ign-math
RUN git clone https://github.com/ignitionrobotics/ign-math ign-math && \
    cd ign-math && \
    git checkout ign-math6 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j4 && \
    sudo make install

# installing ign-common
RUN git clone https://github.com/ignitionrobotics/ign-common ign-common && \
    cd ign-common && \
    git checkout ign-common3 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j4 && \
    sudo make install

# install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-psutil \
    libtinyxml-dev \
    && apt-get -y autoremove \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

ENV CMAKE_PREFIX_PATH=/usr/local:$CMAKE_PREFIX_PATH
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH


# This libsdformat6 is required from source
RUN git clone https://github.com/osrf/sdformat sdformat && \
    cd sdformat && \
    git checkout sdf9 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j4 && \
    sudo make install

# This gz-msgs is required from source
RUN git clone https://github.com/ignitionrobotics/ign-msgs ign-msgs && \
    cd ign-msgs && \
    git checkout ign-msgs5 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j4 && \
    sudo make install

# This ign-fuel-tools is required from source
RUN git clone https://github.com/ignitionrobotics/ign-fuel-tools ign-fuel-tools && \
    cd ign-fuel-tools && \
    git checkout ign-fuel-tools4 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j4 && \
    sudo make install

# install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    qt5-qmake \
    libqt5core5a \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5opengl5-dev \
    libqt5svg5-dev \
    libqwt-qt5-dev \
    libogre-1.12-dev \
    libboost-all-dev \
    libtar-dev \
    libsqlite3-dev \
    libbullet-dev \
    libsimbody-dev \
    libzstd-dev \
    swig \
    libzmq3-dev \
    cppzmq-dev \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*
    
# This gazebo-transport is required from source
RUN git clone https://github.com/gazebosim/gz-transport gazebo-transport && \
    cd gazebo-transport && \
    git checkout ign-transport8 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j4 && \
    sudo make install

# create user with id 1001 (jenkins docker workflow default)
RUN useradd --shell /bin/bash -u 1001 -c "" -m user && usermod -a -G dialout user

# create a user and add it to the sudo group
RUN usermod -a -G sudo user

# need to update the sudo config to not ask for a password
# for anyone in the sudo group
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Some QT-Apps/Gazebo don't not show controls without this
ENV QT_X11_NO_MITSHM=1

WORKDIR /home/gazebo-classic
COPY . .

RUN mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j4 && \
    sudo make install
    


CMD ["sleep", "infinity"]
