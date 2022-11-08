# Update submodule 

After clone this repo, run `git submodule update --recursive` to update submodules.

# Environment Setup

Adapted from [ai2thor-docker (commit id: 3d9bfd)](https://github.com/allenai/ai2thor-docker/tree/3d9bfdfbb5caa30fd0c7b35daadea0cb7f05ca94) and [alfworld](https://github.com/alfworld/alfworld).

```bash

# prepare your ssh public key which will be built into the docker container
cat ~/.ssh/yourkey.pub > docker/authorized_keys

# 1. Build docker image
python3 docker/docker_build.py

# 2. Run docker image
./docker/docker_run.sh
# VNC will be started on DISPLAY=:0 (slower, use for debugging)
# For faster headless rendering, use the Xserver at DISPLAY=:1

# 3. Then you can ssh into the container
ssh 127.0.0.1 -p 2222 -i ~/.ssh/yourkey
# and check if thor works
cd alfred-planning
DISPLAY=:1 python3 third_party/alfworld/docker/check_thor.py

###############
## (300, 300, 3)
## Everything works!!!
```
