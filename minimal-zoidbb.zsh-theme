#
# Minimal theme (zimfw version)
#
# Original minimal theme for zsh written by subnixr:
# https://github.com/subnixr/minimal
#

function {
  # Dynamic Default Character
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # Check distro for distro-specific logos
    MNML_ZOIDBB_DEFAULT_USER_CHAR=
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    MNML_ZOIDBB_DEFAULT_USER_CHAR=
  elif [[ "$OSTYPE" == "freebsd"* ]]; then
    MNML_ZOIDBB_DEFAULT_USER_CHAR=
  elif [[ "$OSTYPE" == "win32" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    MNML_ZOIDBB_DEFAULT_USER_CHAR=
  else
    MNML_ZOIDBB_DEFAULT_USER_CHAR=
  fi

  MNML_ZOIDBB_RPROMPT_SEP="|"

  # Global settings
  MNML_ZOIDBB_OK_COLOR="${MNML_ZOIDBB_OK_COLOR:-green}"
  MNML_ZOIDBB_ERR_COLOR="${MNML_ZOIDBB_ERR_COLOR:-red}"
  # ADDED FOR ZIMFW
  MNML_ZOIDBB_DIV_COLOR="${MNML_ZOIDBB_DIV_COLOR:-magenta}"

  MNML_ZOIDBB_USER_CHAR="${MNML_ZOIDBB_USER_CHAR:-$MNML_ZOIDBB_DEFAULT_USER_CHAR}"
  MNML_ZOIDBB_INSERT_CHAR="${MNML_ZOIDBB_INSERT_CHAR:->}"
  MNML_ZOIDBB_NORMAL_CHAR="${MNML_ZOIDBB_NORMAL_CHAR:-·}"

  [ "${+MNML_ZOIDBB_PROMPT}" -eq 0 ] && MNML_ZOIDBB_PROMPT=(mnml_zoidbb_ssh mnml_zoidbb_pyenv mnml_zoidbb_status mnml_zoidbb_keymap)
  [ "${+MNML_ZOIDBB_RPROMPT}" -eq 0 ] && MNML_ZOIDBB_RPROMPT=('mnml_zoidbb_cwd 2 0' mnml_zoidbb_git mnml_zoidbb_aws)
  [ "${+MNML_ZOIDBB_INFOLN}" -eq 0 ] && MNML_ZOIDBB_INFOLN=(mnml_zoidbb_err mnml_zoidbb_jobs mnml_zoidbb_uhp mnml_zoidbb_files)

  [ "${+MNML_ZOIDBB_MAGICENTER}" -eq 0 ] && MNML_ZOIDBB_MAGICENTER=(mnml_zoidbb_me_dirs mnml_zoidbb_me_ls mnml_zoidbb_me_git)
}

# Components
mnml_zoidbb_status() {
  local output="%F{%(?.${MNML_ZOIDBB_OK_COLOR}.${MNML_ZOIDBB_ERR_COLOR})}%(!.#.${MNML_ZOIDBB_USER_CHAR})%f"

  echo -n "%(1j.%U${output}%u.${output})"
}

mnml_zoidbb_keymap() {
  local kmstat="${MNML_ZOIDBB_INSERT_CHAR}"
  [ "$KEYMAP" = 'vicmd' ] && kmstat="${MNML_ZOIDBB_NORMAL_CHAR}"
  echo -n "${kmstat}"
}

mnml_zoidbb_cwd() {
  local segments="${1:-2}"
  local seg_len="${2:-0}"

  if [ "${segments}" -le 0 ]; then
    segments=1
  fi
  if [ "${seg_len}" -gt 0 ] && [ "${seg_len}" -lt 4 ]; then
    seg_len=4
  fi
  local seg_hlen=$((seg_len / 2 - 1))

  local cwd="%${segments}~"
  cwd="${(%)cwd}"
  cwd=("${(@s:/:)cwd}")

  local pi=""
  for i in {1..${#cwd}}; do
    pi="$cwd[$i]"
    if [ "${seg_len}" -gt 0 ] && [ "${#pi}" -gt "${seg_len}" ]; then
      cwd[$i]="%F{244}${pi:0:$seg_hlen}%F{white}..%F{244}${pi: -$seg_hlen}%f"
    fi
  done

  echo -n "%F{244}${(j:/:)cwd//\//%F{white\}/%F{244\}}%f"
}

mnml_zoidbb_git() {
  [[ -n ${git_info} ]] && echo -n "$MNML_ZOIDBB_RPROMPT_SEP ${(e)git_info[color]}${(e)git_info[prompt]}%f"
}

mnml_zoidbb_aws() {
  [[ -n $AWS_PROFILE ]] && echo -n "$MNML_ZOIDBB_RPROMPT_SEP %F{248}$AWS_PROFILE%f"
}

mnml_zoidbb_uhp() {
  local cwd="%~"
  cwd="${(%)cwd}"

  echo -n "%F{244}%n%F{white}@%F{244}%m%F{white}:%F{244}${cwd//\//%F{white\}/%f%F{244\}}%f"
}

mnml_zoidbb_ssh() {
  if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
    echo -n "$(hostname -s)"
  fi
}

mnml_zoidbb_pyenv() {
  if [ -n "${VIRTUAL_ENV}" ]; then
    _venv="$(basename ${VIRTUAL_ENV})"
    echo -n "${_venv%%.*}"
  fi
}

mnml_zoidbb_err() {
  echo -n "%(0?..%F{${MNML_ZOIDBB_ERR_COLOR}}${MNML_ZOIDBB_LAST_ERR}%f)"
}

mnml_zoidbb_jobs() {
  echo -n "%(1j.%F{244}%j&%f.)"
}

mnml_zoidbb_files() {
  local a_files="$(ls -1A | sed -n '$=')"
  local v_files="$(ls -1 | sed -n '$=')"
  local h_files="$((a_files - v_files))"

  local output="[%F{244}${v_files:-0}%f"

  if [ "${h_files:-0}" -gt 0 ]; then
    output="$output (%F{244}$h_files%f)"
  fi
  output="${output}]"

  echo -n "${output}"
}

# Magic enter functions
mnml_zoidbb_me_dirs() {
  if [ "$(dirs -p | sed -n '$=')" -gt 1 ]; then
    local stack="$(dirs)"
    echo -n "%F{244}${stack//\//%F{white\}/%F{244\}}%f"
  fi
}

mnml_zoidbb_me_ls() {
  if [ "$(uname)" = "Darwin" ] && ! ls --version &> /dev/null; then
    COLUMNS=${COLUMNS} CLICOLOR_FORCE=1 ls -C -G -F
  else
    ls -C -F --color="always" -w ${COLUMNS}
  fi
}

mnml_zoidbb_me_git() {
  git -c color.status=always status -sb 2> /dev/null
}

# Wrappers & utils
# join outpus of components
mnml_zoidbb_wrap() {
  local -a arr
  arr=()
  local cmd_out=""
  local cmd
  for cmd in ${(P)1}; do
    cmd_out="$(eval "$cmd")"
    if [ -n "${cmd_out}" ]; then
      arr+="${cmd_out}"
    fi
  done

  echo -n "${(j: :)arr}"
}

# expand string as prompt would do
mnml_zoidbb_iline() {
  echo "${(%)1}"
}

# display magic enter
mnml_zoidbb_me() {
  local -a output
  output=()
  local cmd_output=""
  local cmd
  for cmd in ${MNML_ZOIDBB_MAGICENTER}; do
    cmd_out="$(eval "$cmd")"
    if [ -n "${cmd_out}" ]; then
      output+="${(%)cmd_out}"
    fi
  done
  echo -n "${(j:\n:)output}" | less -XFR
}

# capture exit status and reset prompt
mnml_zoidbb_zle-line-init() {
  MNML_ZOIDBB_LAST_ERR="$?" # I need to capture this ASAP

  zle reset-prompt
}

# redraw prompt on keymap select
mnml_zoidbb_zle-keymap-select() {
  zle reset-prompt
}

# draw infoline if no command is given
mnml_zoidbb_buffer-empty() {
  if [ -z "${BUFFER}" ] && [ "${prompt_theme}" = "minimal-zoidbb" ]; then
    mnml_zoidbb_iline "$(mnml_zoidbb_wrap MNML_ZOIDBB_INFOLN)"
    mnml_zoidbb_me
    # zle redisplay
    zle zle-line-init
  else
    zle accept-line
  fi
}

# Safely bind widgets
# see: https://github.com/zsh-users/zsh-syntax-highlighting/blob/1f1e629290773bd6f9673f364303219d6da11129/zsh-syntax-highlighting.zsh#L292-L356
prompt_minimal_zoidbb_bind() {
  zmodload zsh/zleparameter

  local -a bindings
  bindings=(zle-line-init zle-keymap-select buffer-empty)

  typeset -F SECONDS
  local zle_prefix="s${SECONDS}-r${RANDOM}"
  local cur_widget
  for cur_widget in ${bindings}; do
    case "${widgets[$cur_widget]:-""}" in
      user:mnml_zoidbb_*);;
      user:*)
        zle -N ${zle_prefix}-${cur_widget} ${widgets[$cur_widget]#*:}
        eval "mnml_zoidbb_ww_${(q)zle_prefix}-${(q)cur_widget}() { mnml_zoidbb_${(q)cur_widget}; zle ${(q)zle_prefix}-${(q)cur_widget} }"
        zle -N ${cur_widget} mnml_zoidbb_ww_${zle_prefix}-${cur_widget}
        ;;
      *)
        zle -N ${cur_widget} mnml_zoidbb_${cur_widget}
        ;;
    esac
  done
}

prompt_minimal_zoidbb_help() {
  cat <<EOH
  This prompt can be customized by setting environment variables in your
  .zshrc:

  - MNML_ZOIDBB_OK_COLOR: Color for successful things (default: 'green')
  - MNML_ZOIDBB_ERR_COLOR: Color for failures (default: 'red')
  - MNML_ZOIDBB_DIV_COLOR: Color for diverted git status (default: 'magenta')
  - MNML_ZOIDBB_USER_CHAR: Character used for unprivileged users (default: '')
  - MNML_ZOIDBB_INSERT_CHAR: Character used for vi insert mode (default: '>')
  - MNML_ZOIDBB_NORMAL_CHAR: Character used for vi normal mode (default: '·')

  --------------------------------------------------------------------------

  Three global arrays handle the definition and rendering position of the components:

  - Components on the left prompt
    MNML_ZOIDBB_PROMPT=(mnml_zoidbb_ssh mnml_zoidbb_pyenv mnml_zoidbb_status mnml_zoidbb_keymap)

  - Components on the right prompt
    MNML_ZOIDBB_RPROMPT=('mnml_zoidbb_cwd 2 0' mnml_zoidbb_git mnml_zoidbb_aws)

  - Components shown on info line
    MNML_ZOIDBB_INFOLN=(mnml_zoidbb_err mnml_zoidbb_jobs mnml_zoidbb_uhp mnml_zoidbb_files)

  --------------------------------------------------------------------------

  An additional array is used to configure magic enter's behavior:

    MNML_ZOIDBB_MAGICENTER=(mnml_zoidbb_me_dirs mnml_zoidbb_me_ls mnml_zoidbb_me_git)

  --------------------------------------------------------------------------

  Also some characters and colors can be set with direct prompt parameters
  (those will override the environment vars):

  prompt minimal-zoidbb [mnml_zoidbb_ok_color] [mnml_zoidbb_err_color] [mnml_zoidbb_div_color]
                  [mnml_zoidbb_user_char] [mnml_zoidbb_insert_char] [mnml_zoidbb_normal_char]

  --------------------------------------------------------------------------
EOH
}

prompt_minimal_zoidbb_preview() {
  if (( ${#} )); then
    prompt_preview_theme minimal-zoidbb "${@}"
  else
    prompt_preview_theme minimal-zoidbb
    print
    prompt_preview_theme minimal-zoidbb 'green' 'red' 'magenta' '#' '>' 'o'
  fi
}

prompt_minimal_zoidbb_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

prompt_minimal_zoidbb_setup() {
  # Setup
  prompt_opts=(cr percent sp subst)

  prompt_minimal_zoidbb_bind

  MNML_ZOIDBB_OK_COLOR="${${1}:-${MNML_ZOIDBB_OK_COLOR}}"
  MNML_ZOIDBB_ERR_COLOR="${${2}:-${MNML_ZOIDBB_ERR_COLOR}}"
  MNML_ZOIDBB_DIV_COLOR="${${3}:-${MNML_ZOIDBB_DIV_COLOR}}"
  MNML_ZOIDBB_USER_CHAR="${${4}:-${MNML_ZOIDBB_USER_CHAR}}"
  MNML_ZOIDBB_INSERT_CHAR="${${5}:-${MNML_ZOIDBB_INSERT_CHAR}}"
  MNML_ZOIDBB_NORMAL_CHAR="${${6}:-${MNML_ZOIDBB_NORMAL_CHAR}}"

  autoload -Uz add-zsh-hook && add-zsh-hook precmd prompt_minimal_zoidbb_precmd

  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c'
  zstyle ':zim:git-info:dirty' format '%F{${MNML_ZOIDBB_ERR_COLOR}}'
  zstyle ':zim:git-info:diverged' format '%F{${MNML_ZOIDBB_DIV_COLOR}}'
  zstyle ':zim:git-info:behind' format '%F{${MNML_ZOIDBB_DIV_COLOR}}↓ '
  zstyle ':zim:git-info:ahead' format '%F{${MNML_ZOIDBB_DIV_COLOR}}↑ '
  zstyle ':zim:git-info:keys' format \
    'prompt' '%b%c' \
    'color' '$(coalesce "%D" "%V" "%B" "%A" "%F{${MNML_ZOIDBB_OK_COLOR}}")'

  PS1='$(mnml_zoidbb_wrap MNML_ZOIDBB_PROMPT) '
  RPS1='$(mnml_zoidbb_wrap MNML_ZOIDBB_RPROMPT)'

  bindkey -M main "^M" buffer-empty
  bindkey -M vicmd "^M" buffer-empty
}
