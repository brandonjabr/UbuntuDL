# UbuntuDL

#### Prerequisites

This script is meant to be run on a freshly installed copy of Ubuntu 16.04 LTS w/ a CUDA compatible NVIDIA GPU (running Python 2.7).The ONLY prerequisite is to download CUDNN V5.1 for CUDA 8.0 from https://developer.nvidia.com/cudnn (requires registration).

Once downloaded, just cd to the downloaded file and run 'sudo mv cudnn-8.0-linux-x64-v5.1.tgz /tmp' to move it where the script expects, and you're good to go!

#### Installation 

Simply download or copy the bash script and run 'chmod +x UbuntuDL-setup-MASTER.sh' first, then './UbuntuDL-setup-MASTER.sh' to run.

#### Credits


This is a modified version of Vu Manh Tu's install script for Caffe to optimize compatibility with latest NVIDIA GPUs
and add installation of Tensorflow, Keras, Theano, Pytorch, and Torch7.

(His version can be found at https://github.com/BVLC/caffe/wiki/Caffe-installing-script-for-ubuntu-16.04---support-Cuda-8) 

