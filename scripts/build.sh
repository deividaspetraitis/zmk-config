#!/bin/sh

CFG="/home/deividas/github.com/deividaspetraitis/zmk-config/config"

west build -p -d build/right -b nice_nano_v2 -- -DSHIELD=think_corne_right -DZMK_CONFIG="$CFG"
west build -p -d build/left  -b nice_nano_v2 -- -DSHIELD=think_corne_left -DZMK_CONFIG="$CFG"
west build -p -d build/reset  -b nice_nano_v2 -- -DSHIELD=settings_reset -DZMK_CONFIG="$CFG"
