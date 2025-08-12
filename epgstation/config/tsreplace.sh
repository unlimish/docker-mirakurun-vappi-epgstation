#!/bin/bash

tsreplace -i "$INPUT" --remove-typed -o "$OUTPUT" -e qsvencc --avhw -i - --input-format mpegts --avsync vfr --tff --vpp-deinterlace normal -c hevc --icq 30 --gop-len 40 --output-format mpegts -o -
