## AutoVenv Settings
if status is-interactive
  test -z "$autovenv_announce"
  and set -g autovenv_announce "yes"
  test -z "$autovenv_enable"
  and set -g autovenv_enable "yes"
  test -z "$autovenv_dir"
  and set -g autovenv_dir ".venv"
end

function _autovenv_safe_deactivate
  if functions -q deactivate
    deactivate
  else
    set -e VIRTUAL_ENV
    set -e VIRTUAL_ENV_PROMPT
    if functions -q _old_fish_prompt; functions -e _old_fish_prompt; end
    if set -q _OLD_FISH_PROMPT_OVERRIDE; set -e _OLD_FISH_PROMPT_OVERRIDE; end
  end
end

function applyAutoenv
  test ! "$autovenv_enable" = "yes"
  or not status is-interactive
  and return

  set _tree (pwd)
  set -e _source
  while test $_tree != "/"
    set -l _activate (string join '/' "$_tree" "$autovenv_dir" "bin/activate.fish")
    set -l _activate (string replace -a "//" "/" "$_activate")
    if test -e "$_activate"
      set _source "$_activate"
      if test "$autovenv_announce" = "yes"
        set -g __autovenv_old $__autovenv_new
        set -g __autovenv_new (basename $_tree)
      end
      break
    end
    set _tree (dirname $_tree)
  end

  if test \( -z "$VIRTUAL_ENV" -o "$_autovenv_initialized" = "0" \) -a -e "$_source"
    source "$_source"
    if test "$autovenv_announce" = "yes"
      echo "Activated Virtual Environment ($__autovenv_new)"
    end

  else if test -n "$VIRTUAL_ENV"
    set -l ve (string escape --style=regex -- "$VIRTUAL_ENV")
    set -l pattern (string join '' '^' $ve '(/|\$)')
    if string match -rq -- $pattern (pwd)
      set -l _in_venv_tree yes
    else
      set -e _in_venv_tree
    end

    # Left the venv tree entirely → deactivate
    if test -z "$_in_venv_tree" -a ! -e "$_source"
      _autovenv_safe_deactivate
      if test "$autovenv_announce" = "yes"
        echo "Deactivated Virtual Enviroment ($__autovenv_new)"
        set -e __autovenv_new
        set -e __autovenv_old
      end

    # Moved from one venv to another → switch
    else if test -z "$_in_venv_tree" -a -e "$_source"
      _autovenv_safe_deactivate
      source "$_source"
      if test "$autovenv_announce" = "yes"
        echo "Switched Virtual Environments ($__autovenv_old => $__autovenv_new)"
      end
    end
  end
end

