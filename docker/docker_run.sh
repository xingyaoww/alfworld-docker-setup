docker run  \
    --rm \
    --user $(whoami) \
    --name alfworld  \
    --gpus all \
    --privileged \
    -v `pwd`:/home/$(whoami)/alfred-planning  \
    -p 2222:22 \
    -d $(whoami)-alfworld \
    bash /home/$(whoami)/alfred-planning/docker/docker_entry.sh
