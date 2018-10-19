############################################################
# Dockerfile to build V8  container images
# Based on Ubuntu
############################################################
# Set the base image to Ubuntu
FROM ubuntu:16.04
# File Author / Maintainer
MAINTAINER Example prmis@microsoft.com
################## BEGIN INSTALLATION ######################
# Update Image

# aubonbeurre: https://stackoverflow.com/questions/24991136/docker-build-could-not-resolve-archive-ubuntu-com-apt-get-fails-to-install-a

RUN apt-get update
RUN apt-get install -y sudo
RUN apt-get install -y apt-utils
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
user docker
# Update depedency of V8
RUN sudo apt-get install -y \
				lsb-core \
				git \
				python \
				lbzip2 \
				curl 	\
				wget	\
				xz-utils \
				zip \
				emacs-nox

RUN sudo echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
WORKDIR /home/docker

#RUN curl https://dl.google.com/android/repository/android-ndk-r16b-linux-x86_64.zip -o android-ndk-r16b-linux-x86_64.zip \
#    && unzip android-ndk-r16b-linux-x86_64.zip \
#    && mkdir -p ~/Android/Sdk \
#    && ln -s ~/android-ndk-r16b ~/Android/Sdk/ndk-bundle 

# Get depot_tool
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH /home/docker/depot_tools:"$PATH"
RUN echo $PATH
# Fetch V8 code
RUN fetch v8
RUN echo "target_os= ['android']">>.gclient
RUN gclient sync
RUN sudo echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
# Update V8 depedency
RUN echo y | sudo /home/docker/v8/build/install-build-deps-android.sh
WORKDIR /home/docker/v8
ARG CACHEBUST=1
# checkout required V8 Branch
#RUN git checkout 6.8.190
RUN git checkout 6.6.346

RUN gclient sync
#ARG CACHEBUST=1

# ARM64 debug
RUN python ./tools/dev/v8gen.py arm64.debug -vv
RUN rm  out.gn/arm64.debug/args.gn
COPY ./args_arm64_dbg.gn out.gn/arm64.debug/args.gn
RUN ls -al out.gn/arm64.debug/
RUN cat out.gn/arm64.debug/args.gn
RUN sudo chmod 777 out.gn/arm64.debug/args.gn
RUN touch out.gn/arm64.debug/args.gn
RUN ninja -C out.gn/arm64.debug -t clean
RUN ninja -C out.gn/arm64.debug -j 32
# Prepare files for archiving
RUN rm -rf target/lib/android/arm64-v8a/debug
RUN mkdir -p target/lib/android/arm64-v8a/debug
RUN cp -rf out.gn/arm64.debug/libv8.cr.so ./target/lib/android/arm64-v8a/debug
RUN cp -rf out.gn/arm64.debug/libicui18n.cr.so ./target/lib/android/arm64-v8a/debug
RUN cp -rf out.gn/arm64.debug/libicuuc.cr.so ./target/lib/android/arm64-v8a/debug
RUN cp -rf out.gn/arm64.debug/libv8_libplatform.cr.so ./target/lib/android/arm64-v8a/debug
RUN cp -rf out.gn/arm64.debug/libv8_libbase.cr.so ./target/lib/android/arm64-v8a/debug

# ARM64 release
RUN python ./tools/dev/v8gen.py arm64.release -vv
RUN rm  out.gn/arm64.release/args.gn
COPY ./args_arm64_dbg.gn out.gn/arm64.release/args.gn
RUN ls -al out.gn/arm64.release/
RUN cat out.gn/arm64.release/args.gn
RUN sudo chmod 777 out.gn/arm64.release/args.gn
RUN touch out.gn/arm64.release/args.gn
RUN ninja -C out.gn/arm64.release -t clean
RUN ninja -C out.gn/arm64.release -j 32
# Prepare files for archiving
RUN rm -rf target/lib/android/arm64-v8a/release
RUN mkdir -p target/lib/android/arm64-v8a/release
RUN cp -rf out.gn/arm64.release/libv8.cr.so ./target/lib/android/arm64-v8a/release
RUN cp -rf out.gn/arm64.release/libicui18n.cr.so ./target/lib/android/arm64-v8a/release
RUN cp -rf out.gn/arm64.release/libicuuc.cr.so ./target/lib/android/arm64-v8a/release
RUN cp -rf out.gn/arm64.release/libv8_libplatform.cr.so ./target/lib/android/arm64-v8a/release
RUN cp -rf out.gn/arm64.release/libv8_libbase.cr.so ./target/lib/android/arm64-v8a/release

# x64 debug
RUN python ./tools/dev/v8gen.py x64.debug -vv
RUN rm  out.gn/x64.debug/args.gn
COPY ./args_x64_dbg.gn out.gn/x64.debug/args.gn
RUN ls -al out.gn/x64.debug/
RUN cat out.gn/x64.debug/args.gn
RUN sudo chmod 777 out.gn/x64.debug/args.gn
RUN touch out.gn/x64.debug/args.gn
RUN ninja -C out.gn/x64.debug -t clean
RUN ninja -C out.gn/x64.debug -j 32
# Prepare files for archiving
RUN rm -rf target/lib/android/x86_64/debug
RUN mkdir -p target/lib/android/x86_64/debug
RUN cp -rf out.gn/x64.debug/libv8.cr.so ./target/lib/android/x86_64/debug
RUN cp -rf out.gn/x64.debug/libicui18n.cr.so ./target/lib/android/x86_64/debug
RUN cp -rf out.gn/x64.debug/libicuuc.cr.so ./target/lib/android/x86_64/debug
RUN cp -rf out.gn/x64.debug/libv8_libplatform.cr.so ./target/lib/android/x86_64/debug
RUN cp -rf out.gn/x64.debug/libv8_libbase.cr.so ./target/lib/android/x86_64/debug

# x64 release
RUN python ./tools/dev/v8gen.py x64.release -vv
RUN rm  out.gn/x64.release/args.gn
COPY ./args_x64_dbg.gn out.gn/x64.release/args.gn
RUN ls -al out.gn/x64.release/
RUN cat out.gn/x64.release/args.gn
RUN sudo chmod 777 out.gn/x64.release/args.gn
RUN touch out.gn/x64.release/args.gn
RUN ninja -C out.gn/x64.release -t clean
RUN ninja -C out.gn/x64.release -j 32
# Prepare files for archiving
RUN rm -rf target/lib/android/x86_64/release
RUN mkdir -p target/lib/android/x86_64/release
RUN cp -rf out.gn/x64.release/libv8.cr.so ./target/lib/android/x86_64/release
RUN cp -rf out.gn/x64.release/libicui18n.cr.so ./target/lib/android/x86_64/release
RUN cp -rf out.gn/x64.release/libicuuc.cr.so ./target/lib/android/x86_64/release
RUN cp -rf out.gn/x64.release/libv8_libplatform.cr.so ./target/lib/android/x86_64/release
RUN cp -rf out.gn/x64.release/libv8_libbase.cr.so ./target/lib/android/x86_64/release

# Creating release archive
RUN mkdir -p ./target
RUN cp -rf include ./target

RUN mkdir -p ./target/resource
RUN cp -rf out.gn/arm64.debug/icudtl.dat ./target/resource

WORKDIR /home/docker/v8/target/
RUN zip -r ../v8.zip ./*
RUN ls -al /home/docker/v8/v8.zip
#End of docker Command
