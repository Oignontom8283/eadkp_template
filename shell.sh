#!/bin/bash

# Allow local connections to the X server
xhost +local:docker

docker exec -it {{snake_case}} bash
