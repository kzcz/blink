# Requirements
Zig version >= 0.13.0  
Linux >= 5.x
# How to run
Note: this program is only compilable on linux.

Execute: `zig build` to generate an executable, it will be located at `./zig-out/bin/blink`

syntax: `blink <DEVICE>`, where device is a directory inside `/sys/class/leds/`

press `y` to turn the led on, press `n` to turn the led off, press `q` to quit
