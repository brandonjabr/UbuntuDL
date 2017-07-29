# This script allows you to quickly install Tensorflow, Caffe, Keras and Pytorch all with GPU support for the newest NVIDIA Pascal GPUs on a clean Ubuntu 16.04 install. It installs CUDA 8.0 and CUDNN 5.1 while taking care of many dependency issues that
# are usually encountered during installation on Ubuntu 16.04 machines. It is heavily based on Vu Manh Tu's excellent script (https://github.com/BVLC/caffe/wiki/Caffe-installing-script-for-ubuntu-16.04---support-Cuda-8), the main difference being the addition of
# Keras, Pytorch, and a special version of Caffe that includes additional layers required for compiling the state-of-the-art BVLC VQA model (found here https://github.com/akirafukui/vqa-mcb).

# INSTRUCTIONS BEFORE INSTALL -- You MUST start on a freshly install Ubuntu 16.04 machine. First, download CUDNN-5.1 for CUDA 8.0 from https://developer.nvidia.com/cudnn (requires registration). Copy the downloaded file 'cudnn-8.0-linux-x64-v5.1.tgz' to /tmp.
# With this script in your home directory, run sudo chmod +x ~/UbuntuDL-setup-MASTER.sh, and finally run the script with  ./UbuntuDL-setup-MASTER.sh. Once finished, reboot your computer, and run the following command to finish the Caffe setup:
# echo "export PYTHONPATH=/home/YOUR_USERNAME/caffe/python:$PYTHONPATH" >> ~/.bashrc (replace YOUR_USERNAME with your username).

# To check if everything went OK, run python and try running 'import tensorflow as tf', 'import caffe', 'import keras' and 'import torch' -- please report issues on the git repo, if your install is successful, feel free to share your specs so
# that everyone can get more info on compatible NVIDIA cards, thank you!

# Tested successfully on Ubuntu 16.04 LTS w/ NVIDIA GTX 1080 Ti (Pascal Architecture) 

# Add Nvidia's cuda repository
if [ ! -f "/tmp/cudnn-8.0-linux-x64-v5.1.tgz" ] ; then
  exit 1;
fi
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb

sudo apt-get update
# Note that we do upgrade and not dist-upgrade so that we don't install
# new kernels; this script will install the nvidia driver in the *currently
# running* kernel.
sudo apt-get upgrade -y
sudo apt-get install -y opencl-headers build-essential protobuf-compiler \
    libprotoc-dev libboost-all-dev libleveldb-dev hdf5-tools libhdf5-serial-dev \
    libopencv-core-dev  libopencv-highgui-dev libsnappy-dev \
    libatlas-base-dev cmake libstdc++6-4.8-dbg libgoogle-glog0v5 libgoogle-glog-dev \
    libgflags-dev liblmdb-dev git python-pip gfortran libopencv-dev
sudo apt-get clean

# Nvidia's driver depends on the drm module, but that's not included in the default
# 'virtual' ubuntu that's on the cloud (as it usually has no graphics).  It's 
# available in the linux-image-extra-virtual package (and linux-image-generic supposedly),
# but just installing those directly will install the drm module for the NEWEST available
# kernel, not the one we're currently running.  Hence, we need to specify the version
# manually.  This command will probably need to be re-run every time you upgrade the
# kernel and reboot.
#sudo apt-get install -y linux-headers-virtual linux-source linux-image-extra-virtual
sudo apt-get install -y linux-image-extra-`uname -r` linux-headers-`uname -r` linux-image-`uname -r`

sudo apt-get install -y cuda
sudo apt-get clean

# Optionally, download your own cudnn; requires registration.  
if [ -f "/tmp/cudnn-8.0-linux-x64-v5.1.tgz" ] ; then
  tar -xvf /tmp/cudnn-8.0-linux-x64-v5.1.tgz -C /tmp
  sudo cp -P /tmp/cuda/lib64 /usr/local/cuda/lib64
  sudo cp /tmp/cuda/include /usr/local/cuda/include
fi
# Need to put cuda on the linker path.  This may not be the best way, but it works.
sudo sh -c "sudo echo '/usr/local/cuda/lib64' > /etc/ld.so.conf.d/cuda_hack.conf"
sudo ldconfig /usr/local/cuda/lib64


# REBOOT SUGGESTED HERE -- I recommend running 'sudo shutdown -r now' at this point, not always neccessary but may solve errors due to NVIDIA graphic-drivers.


#Install tensorflow-gpu
sudo pip install --upgrade tensorflow-gpu

# Install Keras
sudo pip install keras

# Install Pytorch
sudo pip install http://download.pytorch.org/whl/cu80/torch-0.1.12.post2-cp27-none-linux_x86_64.whl 
sudo pip install torchvision


# Get caffe w/ additional layers -- install Caffe python requirements
git clone https://github.com/akirafukui/caffe.git
cd caffe
git fetch
git checkout feature/20160617_cb_softattention
cd python
for req in $(cat requirements.txt); do sudo pip install $req; done

# Prepare Makefile.config
cd ../
cp Makefile.config.example Makefile.config
if [ -f "../cudnn-8.0-linux-x64-v5.1.tgz" ] ; then
  sed -i '/^# USE_CUDNN := 1/s/^# //' Makefile.config
fi
sed -i '/^# WITH_PYTHON_LAYER := 1/s/^# //' Makefile.config
sed -i 's/\/usr\/local\/cuda/\/usr\/local\/cuda-8.0/g' Makefile.config
sed -i 's/\/usr\/local\/include/\/usr\/local\/include \/usr\/include\/hdf5\/serial/g' Makefile.config
sed -i '/^PYTHON_INCLUDE/a    /usr/local/lib/python2.7/dist-packages/numpy/core/include/ \\' Makefile.config

sudo ln -s /usr/lib/x86_64-linux-gnu/libhdf5_serial.so.10.1.0 /usr/lib/x86_64-linux-gnu/libhdf5.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libhdf5_serial_hl.so.10.0.2 /usr/lib/x86_64-linux-gnu/libhdf5_hl.so

# Finally, build Caffe -- (NOTE: Building Caffe is notoriously difficult on 16.04 machines w/ newer Pascal-based NVIDIA cards, if you get errors please let me know so I can keep improving this script - Thanks!)
make -j 8 all py

make -j 8 test
make runtest
