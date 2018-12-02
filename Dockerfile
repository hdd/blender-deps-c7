# NOTE CAREFUL THIS BUILD CAN EAT UP 22GB of you disk !

# BUILD WITH: docker build -t efestolab/blender-deps-c7 .
# To extract the new blender:
# docker run efestolab/blender-deps-c7
# docker cp <container-name>:/root/blender-git/build_linux_full .

FROM centos/devtoolset-6-toolchain-centos7
MAINTAINER Efesto Lab LTD
USER root

# redirect library builds
ENV DEPS_INSTALL_DIR /opt/blender/lib
ENV DEPS_BUILD_DIR /opt/blender/lib_build

# update system
RUN yum update -y 
RUN yum-config-manager --add-repo http://www.nasm.us/nasm.repo
RUN yum -y install epel-release
RUN yum -y groupinstall 'Development Tools'
RUN yum -y install \
    cmake3 \
    python36 \
    tcl \
    mesa-libGLU-devel \
    libXrandr-devel \
    libXinerama-devel \
    libXcursor-devel \
    libXi-devel \
    nasm \
    yasm \
    wget \
    zlib-devel \
    python-setuptools \
    libX11-devel \
    libXt-devel

RUN alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake 10 \
--slave /usr/local/bin/ctest ctest /usr/bin/ctest \
--slave /usr/local/bin/cpack cpack /usr/bin/cpack \
--slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake \
--family cmake

RUN alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
--slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
--slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
--slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 \
--family cmake

# install and set python36 as default
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3 10 \
--family python3

RUN alternatives --install /usr/bin/python3 python3 /bin/python36 20 \
--family python3

# clone and update blender
RUN mkdir $HOME/blender-git/ && \
    git clone https://git.blender.org/blender.git $HOME/blender-git/blender && \
    cd $HOME/blender-git/blender/ && \
    git checkout blender2.8 &&\
    git submodule update --init --recursive && \
    git submodule foreach git checkout master && \
    git submodule foreach git pull --rebase origin master

# run dependencies build
RUN cd $HOME/blender-git/blender && make deps

# copy patch folder
COPY ./patches /tmp/patches

# copy blender build script
COPY ./build.sh /tmp

RUN chmod +x /tmp/build.sh
ENTRYPOINT ["/tmp/build.sh"]