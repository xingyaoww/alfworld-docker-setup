#!/bin/bash

# start ssh
echo password | sudo -S service ssh start

# start vnc on :0 (for debugging)
/opt/TurboVNC/bin/vncserver :0 -geometry 1920x1080 -depth 24

# startx (headless, faster for training) on :1
cd /home/$(whoami)/alfred-planning
echo password | sudo -S python3 src/scripts/startx.py 1
