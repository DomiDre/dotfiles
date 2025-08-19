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
  if test "$autovenv_enable" != "yes"; or not status is-interactive
    return
  end

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

  # No venv active (or first prompt) but we found one -> activate
  if test \( -z "$VIRTUAL_ENV" -o "$_autovenv_initialized" = "0" \) -a -n "$_source"
    source "$_source"
    if test "$autovenv_announce" = "yes"
      echo "Activated Virtual Environment ($__autovenv_new)"
    end

  # A venv is active -> maybe deactivate or switch
  else if test -n "$VIRTUAL_ENV"
    if test -n "$_source"
      # derive venv root from the found activate path: .../.venv/bin/activate.fish -> .../.venv
      set -l _found_venv (dirname (dirname "$_source"))
      if test "$_found_venv" != "$VIRTUAL_ENV"
        _autovenv_safe_deactivate
        source "$_source"
        if test "$autovenv_announce" = "yes"
          echo "Switched Virtual Environments ($__autovenv_old => $__autovenv_new)"
        end
      end
    else
      # left any project that has a venv -> deactivate
      _autovenv_safe_deactivate
      if test "$autovenv_announce" = "yes"
        echo "Deactivated Virtual Environment ($__autovenv_new)"
        set -e __autovenv_new
        set -e __autovenv_old
      end
    end
  end
end

# Run on every directory change
function autovenv --on-variable PWD -d "Automatic activation of Python virtual environments"
  applyAutoenv
end

# Track initialization state
set --global _autovenv_initialized 0

# Run once on the first prompt of a new shell
function __autovenv_on_prompt --on-event fish_prompt
  if test "$_autovenv_initialized" = "0"
    applyAutoenv
    set --global _autovenv_initialized 1
  end
end
