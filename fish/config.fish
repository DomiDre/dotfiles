if status is-interactive
    # Commands to run in interactive sessions can go here
         
    # if not set -q ZELLIJ
    #     if test "$ZELLIJ_AUTO_ATTACH" = "true"
    #         zellij attach -c
    #     else
    #         zellij
    #     end
    #
    #     if test "$ZELLIJ_AUTO_EXIT" = "true"
    #         kill $fish_pid
    #     end
    # end
end

zoxide init fish | source

# remap capslock to ctrl
setxkbmap -option 'caps:ctrl_modifier'
