FROM nvidia/cuda:11.8.0-devel-ubuntu18.04

# === USER ===
ARG USER_NAME
ARG USER_PASSWORD
ARG USER_ID
ARG USER_GID

RUN apt-get update
RUN apt install sudo
RUN useradd -ms /bin/bash $USER_NAME --no-log-init
RUN usermod -aG sudo $USER_NAME
RUN yes $USER_PASSWORD | passwd $USER_NAME

# set uid and gid to match those outside the container
RUN usermod -u $USER_ID $USER_NAME
RUN groupmod -g $USER_GID $USER_NAME
WORKDIR /home/$USER_NAME

# === DEPENDENCIES ===
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install python3-pip python3-tk libxrender1 libsm6 xserver-xorg-core xorg vim pciutils wget git kmod curl cmake screen tmux htop

# - NVIDIA DRIVER
COPY docker/install_nvidia.sh /tmp/install_nvidia.sh
RUN /tmp/install_nvidia.sh

# - PIP (ALFWorld dependencies)
RUN pip3 install --upgrade pip
RUN ln -s /usr/bin/python3 /usr/bin/python
COPY third_party/alfworld/requirements.txt /tmp/alfworld-requirements.txt
RUN pip3 install -r /tmp/alfworld-requirements.txt

# - GLX-Gears (for debugging)
RUN apt-get update && apt-get install -y \
   mesa-utils && \
   rm -rf /var/lib/apt/lists/*

# - Dependency for SSH
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /home/$USER_NAME/.ssh
COPY docker/authorized_keys /home/$USER_NAME/.ssh/authorized_keys
RUN chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh
# Disable password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# === Setup VirtualGL+TurboVNC ===
# - Install VirtualGL
RUN wget https://sourceforge.net/projects/virtualgl/files/3.0.2/virtualgl_3.0.2_amd64.deb/download -O /tmp/virtualgl_3.0.2_amd64.deb
RUN dpkg -i /tmp/virtualgl_3.0.2_amd64.deb
RUN printf "1\nn\nn\nn\nx\n" | /opt/VirtualGL/bin/vglserver_config

# - Install xfce4
RUN apt-get install -y xfce4

# - Install TurboVNC
RUN wget https://sourceforge.net/projects/turbovnc/files/3.0.1/turbovnc_3.0.1_amd64.deb/download -O /tmp/turbovnc_3.0.1_amd64.deb
RUN dpkg -i /tmp/turbovnc_3.0.1_amd64.deb

# - Set $USER_NAME as password for TurboVNC
# printf "$USER_NAME\n$USER_NAME\nn\n" | /opt/TurboVNC/bin/vncpasswd
RUN su $USER_NAME -c "printf \"$USER_NAME\n$USER_NAME\nn\n\" | /opt/TurboVNC/bin/vncpasswd"
# later run /opt/TurboVNC/bin/vncserver in the entry script to start the server

# === Environment Variables ===
ENV ALFWORLD_DATA /home/$USER_NAME/alfred-planning/data/raw/alfworld
ENV PYTHONPATH /home/$USER_NAME/alfred-planning:/home/$USER_NAME/alfred-planning/third_party/alfworld:$PYTHONPATH
