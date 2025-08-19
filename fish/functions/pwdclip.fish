function pwdclip --wraps='pwd | xclip -selection clipboard' --description 'alias pwdclip=pwd | xclip -selection clipboard'
  pwd | xclip -selection clipboard $argv
        
end
