function fix_display --wraps='DISPLAY=:0 xrandr --output eDP-1 --auto' --description 'Set display to laptop'
  xrandr --output HDMI-0 --mode 7680x2160
end
