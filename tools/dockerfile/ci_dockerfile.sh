#!/bin/bash

# Copyright (c) 2020 PaddlePaddle Authors. All Rights Reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function make_ubuntu_dockerfile(){
  dockerfile_name="Dockerfile.cuda10_cudnn7_gcc82_ubuntu16"
  sed "s/<baseimg>/10.1-cudnn7-devel-ubuntu16.04/g" ./Dockerfile.ubuntu >${dockerfile_name}
  sed -i "s#liblzma-dev#liblzma-dev openmpi-bin openmpi-doc libopenmpi-dev#g" ${dockerfile_name} 
  dockerfile_line=$(wc -l ${dockerfile_name}|awk '{print $1}')
  sed -i "${dockerfile_line}i RUN wget --no-check-certificate -q https://paddle-edl.bj.bcebos.com/hadoop-2.7.7.tar.gz \&\& \
     tar -xzf     hadoop-2.7.7.tar.gz && mv hadoop-2.7.7 /usr/local/" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN apt remove git -y \&\& apt install -y libcurl4-openssl-dev gettext zstd \&\& wget -q https://paddle-ci.gz.bcebos.com/git-2.17.1.tar.gz \&\& \
    tar -xvf git-2.17.1.tar.gz \&\& \
    cd git-2.17.1 \&\& \
    ./configure --with-openssl --with-curl --prefix=/usr/local \&\& \
    make -j8 \&\& make install " ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN pip install wheel \&\& pip3 install PyGithub wheel \&\& pip3.7 install PyGithub distro" ${dockerfile_name}
  sed -i "s#<install_gcc>#WORKDIR /usr/bin \\
    COPY tools/dockerfile/build_scripts /build_scripts \\
    RUN bash /build_scripts/install_gcc.sh gcc82 \&\& rm -rf /build_scripts \\
    RUN cp gcc  gcc.bak \&\& cp g++  g++.bak \&\& rm gcc \&\& rm g++ \\
    RUN ln -s /usr/local/gcc-8.2/bin/gcc /usr/local/bin/gcc \\
    RUN ln -s /usr/local/gcc-8.2/bin/g++ /usr/local/bin/g++ \\
    RUN ln -s /usr/local/gcc-8.2/bin/gcc /usr/bin/gcc \\
    RUN ln -s /usr/local/gcc-8.2/bin/g++ /usr/bin/g++ \\
    ENV PATH=/usr/local/gcc-8.2/bin:\$PATH #g" ${dockerfile_name}
  sed -i "s#bash /build_scripts/install_nccl2.sh#wget -q --no-proxy https://nccl2-deb.cdn.bcebos.com/nccl-repo-ubuntu1604-2.7.8-ga-cuda10.1_1-1_amd64.deb \\
    RUN dpkg -i nccl-repo-ubuntu1604-2.7.8-ga-cuda10.1_1-1_amd64.deb \\
    RUN apt remove -y libnccl* --allow-change-held-packages \&\&  apt-get install -y libsndfile1 libnccl2=2.7.8-1+cuda10.1 libnccl-dev=2.7.8-1+cuda10.1 zstd pigz ninja-build --allow-change-held-packages #g" ${dockerfile_name}
}

function make_ubuntu_trt7_dockerfile(){
  dockerfile_name="Dockerfile.cuda102_cudnn8_gcc82_ubuntu16"
  sed "s/<baseimg>/10.2-cudnn8-devel-ubuntu16.04/g" ./Dockerfile.ubuntu >${dockerfile_name}
  sed -i "s#liblzma-dev#liblzma-dev openmpi-bin openmpi-doc libopenmpi-dev#g" ${dockerfile_name} 
  dockerfile_line=$(wc -l ${dockerfile_name}|awk '{print $1}')
  sed -i "${dockerfile_line}i RUN apt remove -y libcudnn* --allow-change-held-packages \&\& \
      apt-get install -y --allow-unauthenticated libsndfile1 libcudnn8=8.1.0.77-1+cuda10.2 libcudnn8-dev=8.1.0.77-1+cuda10.2 --allow-change-held-packages" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN wget --no-check-certificate -q  \
      https://developer.download.nvidia.com/compute/cuda/10.2/Prod/patches/2/cuda_10.2.2_linux.run \&\& \
      bash cuda_10.2.2_linux.run --silent --toolkit \&\& ldconfig" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN wget --no-check-certificate -q  \
      https://developer.download.nvidia.com/compute/cuda/10.2/Prod/patches/1/cuda_10.2.1_linux.run \&\& \
      bash cuda_10.2.1_linux.run --silent --toolkit \&\& ldconfig" ${dockerfile_name}
  sed -i 's#RUN bash /build_scripts/install_trt.sh#RUN bash /build_scripts/install_trt.sh ubuntu1604-7234#g' ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN wget --no-check-certificate -q https://paddle-edl.bj.bcebos.com/hadoop-2.7.7.tar.gz \&\& \
     tar -xzf     hadoop-2.7.7.tar.gz && mv hadoop-2.7.7 /usr/local/" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN apt remove git -y \&\& apt install -y libcurl4-openssl-dev gettext zstd ninja-build  \&\& wget -q https://paddle-ci.gz.bcebos.com/git-2.17.1.tar.gz \&\& \
    tar -xvf git-2.17.1.tar.gz \&\& \
    cd git-2.17.1 \&\& \
    ./configure --with-openssl --with-curl --prefix=/usr/local \&\& \
    make -j8 \&\& make install " ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN pip install wheel \&\& pip3 install PyGithub wheel \&\& pip3.7 install PyGithub distro \&\& pip3.8 install PyGithub distro" ${dockerfile_name}
  sed -i "s#<install_gcc>#WORKDIR /usr/bin \\
    COPY tools/dockerfile/build_scripts /build_scripts \\
    RUN bash /build_scripts/install_gcc.sh gcc82 \&\& rm -rf /build_scripts \\
    RUN cp gcc  gcc.bak \&\& cp g++  g++.bak \&\& rm gcc \&\& rm g++ \\
    RUN ln -s /usr/local/gcc-8.2/bin/gcc /usr/local/bin/gcc \\
    RUN ln -s /usr/local/gcc-8.2/bin/g++ /usr/local/bin/g++ \\
    RUN ln -s /usr/local/gcc-8.2/bin/gcc /usr/bin/gcc \\
    RUN ln -s /usr/local/gcc-8.2/bin/g++ /usr/bin/g++ \\
    ENV PATH=/usr/local/gcc-8.2/bin:\$PATH #g" ${dockerfile_name}
  sed -i "s#bash /build_scripts/install_nccl2.sh#wget -q --no-proxy https://nccl2-deb.gz.bcebos.com/nccl-local-repo-ubuntu1604-2.8.4-cuda10.2_1.0-1_amd64.deb \\
    RUN apt remove -y libnccl* --allow-change-held-packages \&\&  apt-get install -y --allow-unauthenticated libsndfile1 libnccl2=2.8.4-1+cuda10.2 libnccl-dev=2.8.4-1+cuda10.2 zstd pigz --allow-change-held-packages #g" ${dockerfile_name}
}

function make_centos_dockerfile(){
  dockerfile_name="Dockerfile.cuda9_cudnn7_gcc48_py35_centos6"
  sed "s#<baseimg>#ubuntu:20.04#g" ./Dockerfile.ubuntu20 >${dockerfile_name}
  sed -i "s#<setcuda>##g" ${dockerfile_name}
  sed -i "s#WITH_GPU:-ON#WITH_GPU:-OFF#g" ${dockerfile_name}
  sed -i "s#RUN apt-key del 7fa2af80##g" ${dockerfile_name}
  sed -i 's#RUN rm /etc/apt/sources.list.d/\*##g' ${dockerfile_name}
  sed -i "s#RUN apt-key adv --fetch-keys https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub##g" ${dockerfile_name}
  dockerfile_line=$(wc -l ${dockerfile_name}|awk '{print $1}')
  sed -i 's#RUN bash /build_scripts/install_trt.sh##g' ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN wget --no-check-certificate -q https://paddle-edl.bj.bcebos.com/hadoop-2.7.7.tar.gz \&\& \
     tar -xzf     hadoop-2.7.7.tar.gz && mv hadoop-2.7.7 /usr/local/" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN apt remove git -y \&\& apt install -y libsndfile1 zstd pigz libcurl4-openssl-dev gettext zstd ninja-build" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN pip install wheel \&\& pip3 install PyGithub wheel \&\& pip3.8 install PyGithub distro \&\& pip3.9 install PyGithub wheel \&\& pip3.10 install PyGithub distro" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN apt remove git -y \&\& apt install -y libcurl4-openssl-dev gettext pigz zstd ninja-build \&\& wget -q https://paddle-ci.gz.bcebos.com/git-2.17.1.tar.gz \&\& \
    tar -xvf git-2.17.1.tar.gz \&\& \
    cd git-2.17.1 \&\& \
    ./configure --with-openssl --with-curl --prefix=/usr/local \&\& \
    make -j8 \&\& make install " ${dockerfile_name}
  sed -i 's#<install_cpu_package>#RUN apt-get install -y gcc g++ make#g' ${dockerfile_name}
}


function make_cinn_dockerfile(){
  dockerfile_name="Dockerfile.cuda11_cudnn8_gcc82_ubuntu18_cinn"
  sed "s#<baseimg>#nvidia/cuda:11.2.0-cudnn8-devel-ubuntu18.04#g" ./Dockerfile.ubuntu18 >${dockerfile_name}
  sed -i "s#<setcuda>#ENV LD_LIBRARY_PATH=/usr/local/cuda-11.2/targets/x86_64-linux/lib:\$LD_LIBRARY_PATH #g" ${dockerfile_name}
  sed -i 's#<install_cpu_package>##g' ${dockerfile_name}
  sed -i "7i ENV TZ=Asia/Beijing" ${dockerfile_name}
  sed -i "8i RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone" ${dockerfile_name}
  sed -i "27i RUN apt-get update && apt-get install -y liblzma-dev openmpi-bin openmpi-doc libopenmpi-dev libsndfile1" ${dockerfile_name}
  dockerfile_line=$(wc -l ${dockerfile_name}|awk '{print $1}')
  sed -i "${dockerfile_line}i RUN wget --no-check-certificate -q https://paddle-edl.bj.bcebos.com/hadoop-2.7.7.tar.gz \&\& \
     tar -xzf  hadoop-2.7.7.tar.gz && mv hadoop-2.7.7 /usr/local/" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN apt remove git -y \&\& apt install -y libcurl4-openssl-dev gettext pigz zstd ninja-build \&\& wget -q https://paddle-ci.gz.bcebos.com/git-2.17.1.tar.gz \&\& \
    tar -xvf git-2.17.1.tar.gz \&\& \
    cd git-2.17.1 \&\& \
    ./configure --with-openssl --with-curl --prefix=/usr/local \&\& \
    make -j8 \&\& make install " ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN pip install wheel \&\& pip3 install PyGithub wheel distro \&\& pip3.7 install PyGithub \&\& pip3.8 install distro" ${dockerfile_name}
}


function make_ce_framework_dockcerfile(){
  dockerfile_name="Dockerfile.cuda11.2_cudnn8_gcc82_trt8"
  sed "s/<baseimg>/11.2.0-cudnn8-devel-ubuntu16.04/g" ./Dockerfile.ubuntu >${dockerfile_name}
  dockerfile_line=$(wc -l ${dockerfile_name}|awk '{print $1}')
  sed -i "7i RUN chmod 777 /tmp" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN wget --no-check-certificate -q https://paddle-edl.bj.bcebos.com/hadoop-2.7.7.tar.gz \&\& \
     tar -xzf  hadoop-2.7.7.tar.gz && mv hadoop-2.7.7 /usr/local/" ${dockerfile_name} 
  sed -i "${dockerfile_line}i RUN apt remove git -y \&\& apt install -y zstd pigz libcurl4-openssl-dev gettext ninja-build \&\& wget -q https://paddle-ci.gz.bcebos.com/git-2.17.1.tar.gz \&\& \
    tar -xvf git-2.17.1.tar.gz \&\& \
    cd git-2.17.1 \&\& \
    ./configure --with-openssl --with-curl --prefix=/usr/local \&\& \
    make -j8 \&\& make install " ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN pip install wheel \&\& pip3 install PyGithub wheel \&\& pip3.7 install PyGithub distro" ${dockerfile_name}
  sed -i "s#<install_gcc>#WORKDIR /usr/bin \\
    COPY tools/dockerfile/build_scripts /build_scripts \\
    RUN bash /build_scripts/install_gcc.sh gcc82 \&\& rm -rf /build_scripts \\
    RUN cp gcc  gcc.bak \&\& cp g++  g++.bak \&\& rm gcc \&\& rm g++ \\
    RUN ln -s /usr/local/gcc-8.2/bin/gcc /usr/local/bin/gcc \\
    RUN ln -s /usr/local/gcc-8.2/bin/g++ /usr/local/bin/g++ \\
    RUN ln -s /usr/local/gcc-8.2/bin/gcc /usr/bin/gcc \\
    RUN ln -s /usr/local/gcc-8.2/bin/g++ /usr/bin/g++ \\
    ENV PATH=/usr/local/gcc-8.2/bin:\$PATH #g" ${dockerfile_name}
  sed -i 's#RUN bash /build_scripts/install_trt.sh#RUN bash /build_scripts/install_trt.sh trt8531#g' ${dockerfile_name}
  sed -i 's#28/af/2c76c8aa46ccdf7578b83d97a11a2d1858794d4be4a1610ade0d30182e8b/pip-20.0.1.tar.gz#b7/2d/ad02de84a4c9fd3b1958dc9fb72764de1aa2605a9d7e943837be6ad82337/pip-21.0.1.tar.gz#g' ${dockerfile_name}
  sed -i 's#pip-20.0.1#pip-21.0.1#g' ${dockerfile_name}
  sed -i 's#python setup.py install#python3.7 setup.py install#g' ${dockerfile_name}
}

function make_unbuntu18_cu117_dockerfile(){
  dockerfile_name="Dockerfile.cuda117_cudnn8_gcc82_ubuntu18_coverage"
  sed "s#<baseimg>#nvidia/cuda:12.0.1-cudnn8-devel-ubuntu20.04#g" ./Dockerfile.ubuntu20 >${dockerfile_name}
  sed -i "s#<setcuda>#ENV LD_LIBRARY_PATH=/usr/local/cuda-12.0/targets/x86_64-linux/lib:\$LD_LIBRARY_PATH #g" ${dockerfile_name}
  sed -i 's#<install_cpu_package>##g' ${dockerfile_name}
  sed -i "7i ENV TZ=Asia/Beijing" ${dockerfile_name}
  sed -i "8i RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone" ${dockerfile_name}
  sed -i "27i RUN apt-get update && apt-get install -y liblzma-dev openmpi-bin openmpi-doc libopenmpi-dev libsndfile1" ${dockerfile_name}
  dockerfile_line=$(wc -l ${dockerfile_name}|awk '{print $1}')
  sed -i "${dockerfile_line}i RUN wget --no-check-certificate -q https://paddle-edl.bj.bcebos.com/hadoop-2.7.7.tar.gz \&\& \
     tar -xzf  hadoop-2.7.7.tar.gz && mv hadoop-2.7.7 /usr/local/" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN apt remove git -y \&\& apt install -y libcurl4-openssl-dev gettext pigz zstd ninja-build \&\& wget -q https://paddle-ci.gz.bcebos.com/git-2.17.1.tar.gz \&\& \
    tar -xvf git-2.17.1.tar.gz \&\& \
    cd git-2.17.1 \&\& \
    ./configure --with-openssl --with-curl --prefix=/usr/local \&\& \
    make -j8 \&\& make install " ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN pip install wheel \&\& pip3 install PyGithub wheel distro \&\& pip3.7 install PyGithub \&\& pip3.8 install distro" ${dockerfile_name}
  sed -i 's# && rm /etc/apt/sources.list.d/nvidia-ml.list##g' ${dockerfile_name}
}

function make_ubuntu18_cu112_dockerfile(){
  dockerfile_name="Dockerfile.cuda11.2_cudnn8.1_trt8.4_gcc8.2_ubuntu18"
  sed "s#<baseimg>#nvidia/cuda:11.2.0-cudnn8-devel-ubuntu18.04#g" ./Dockerfile.ubuntu18 >${dockerfile_name}
  sed -i "s#<setcuda>#ENV LD_LIBRARY_PATH=/usr/local/cuda-11.2/targets/x86_64-linux/lib:\$LD_LIBRARY_PATH #g" ${dockerfile_name}
  sed -i "s#liblzma-dev#liblzma-dev openmpi-bin openmpi-doc libopenmpi-dev#g" ${dockerfile_name} 
  dockerfile_line=$(wc -l ${dockerfile_name}|awk '{print $1}')
  sed -i 's#RUN bash /build_scripts/install_trt.sh#RUN bash /build_scripts/install_trt.sh trt8431#g' ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN wget --no-check-certificate -q https://paddle-edl.bj.bcebos.com/hadoop-2.7.7.tar.gz \&\& \
     tar -xzf     hadoop-2.7.7.tar.gz && mv hadoop-2.7.7 /usr/local/" ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN apt remove git -y \&\& apt install -y libsndfile1 zstd pigz libcurl4-openssl-dev gettext zstd ninja-build \&\& wget -q https://paddle-ci.gz.bcebos.com/git-2.17.1.tar.gz \&\& \
    tar -xvf git-2.17.1.tar.gz \&\& \
    cd git-2.17.1 \&\& \
    ./configure --with-openssl --with-curl --prefix=/usr/local \&\& \
    make -j8 \&\& make install " ${dockerfile_name}
  sed -i "${dockerfile_line}i RUN pip install wheel \&\& pip3 install PyGithub wheel \&\& pip3.7 install PyGithub distro \&\& pip3.8 install PyGithub distro" ${dockerfile_name}
  sed -i 's#<install_cpu_package>##g' ${dockerfile_name}
  sed -i "s#<install_gcc>#WORKDIR /usr/bin \\
    COPY tools/dockerfile/build_scripts /build_scripts \\
    RUN bash /build_scripts/install_gcc.sh gcc82 \&\& rm -rf /build_scripts \\
    RUN cp gcc  gcc.bak \&\& cp g++  g++.bak \&\& rm gcc \&\& rm g++ \\
    RUN ln -s /usr/local/gcc-8.2/bin/gcc /usr/local/bin/gcc \\
    RUN ln -s /usr/local/gcc-8.2/bin/g++ /usr/local/bin/g++ \\
    RUN ln -s /usr/local/gcc-8.2/bin/gcc /usr/bin/gcc \\
    RUN ln -s /usr/local/gcc-8.2/bin/g++ /usr/bin/g++ \\
    ENV PATH=/usr/local/gcc-8.2/bin:\$PATH #g" ${dockerfile_name}
}

function main() {
  make_ubuntu_dockerfile
  make_ubuntu_trt7_dockerfile
  make_centos_dockerfile
  make_cinn_dockerfile
  make_ce_framework_dockcerfile
  make_unbuntu18_cu117_dockerfile
  make_ubuntu18_cu112_dockerfile
}

main "$@"
