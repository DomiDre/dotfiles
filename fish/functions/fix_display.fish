function fix_display --wraps='DISPLAY=:0 xrandr --output eDP-1 --auto' --description 'Set display to laptop'
  DISPLAY=:0 xrandr --output eDP-1 --auto $argv
        
end
