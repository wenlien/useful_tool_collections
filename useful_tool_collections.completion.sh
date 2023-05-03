#!/usr/bin/env zsh
# Ref: https://iridakos.com/programming/2018/03/01/bash-programmable-completion-tutorial
# https://jasonkayzk.github.io/2020/12/06/Bash%E5%91%BD%E4%BB%A4%E8%87%AA%E5%8A%A8%E8%A1%A5%E5%85%A8%E7%9A%84%E5%8E%9F%E7%90%86/

# useful_tool_collections
function _useful_tool_collections_completion() {
  default_subcommand_list='help readme vi'
  (typeset -F ${COMP_WORDS[0]} >/dev/null 2>&1) && local script=${COMP_WORDS[0]} || local script=$(which {COMP_WORDS[0]})
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[COMP_CWORD-1]}
  case ${COMP_CWORD} in
    1)
      local sub=$(($script get_subcommand_list; echo $default_subcommand_list) 2>/dev/null)
      COMPREPLY=( $(compgen -W "$sub" -- $cur) )
      ;;
    2)
      case $prev in
        vi)
          local ext=''
          ls $_useful_tool_collections_base_dir/useful_tool_collections.* >/dev/null 2>&1 && ext=$(echo $(ls $_useful_tool_collections_base_dir/useful_tool_collections* 2>/dev/null | sed -e 's/[^.]*\.//')) ||
            ext=$(echo $(ls ${script/.sh}* 2>/dev/null | sed -e 's/[^.]*\.//'))
          COMPREPLY=( $(compgen -W "${ext}" -- $cur) )
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      ;;
    *)
      ;;
  esac
}
complete -F _useful_tool_collections_completion useful_tool_collections_completion u
