#!/bin/sh

CFG="/home/deividas/github.com/deividaspetraitis/zmk-config"

west build -s "$CFG/zmk/app" -p -d "$CFG/build/right" -b nice_nano_v2 -- -DSHIELD="think_corne_right nice_view_adapter nice_view" -DZMK_CONFIG="$CFG/config"
west build -s "$CFG/zmk/app" -p -d "$CFG/build/left"  -b nice_nano_v2 -- -DSHIELD="think_corne_left nice_view_adapter nice_view" -DZMK_CONFIG="$CFG/config"
west build -s "$CFG/zmk/app" -p -d "$CFG/build/reset" -b nice_nano_v2 -- -DSHIELD=settings_reset -DZMK_CONFIG="$CFG/config"
