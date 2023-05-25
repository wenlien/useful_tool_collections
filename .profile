export _useful_tool_collections_base_dir="$(dirname $(readlink -f $0))"
export default_show_funcs=''  # valid values: custom/system/all


function u() {
  _useful_tool_collections_script="$_useful_tool_collections_base_dir/useful_tool_collections.sh"
  case "$1" in
    cd)
      [ "$(pwd)" != "$_useful_tool_collections_base_dir" ] && cd "$_useful_tool_collections_base_dir" || cd "$awsscripts_dir/z_utils"
      ;;
    reload)
      source $_useful_tool_collections_base_dir/.profile
      source $_useful_tool_collections_base_dir/.profile.custom
      ;;
    *)
      $_useful_tool_collections_script "$@"
      ;;
  esac
}


source $_useful_tool_collections_base_dir/useful_tool_collections.completion.sh
[ -f $_useful_tool_collections_base_dir/.profile.custom ] && \
  source $_useful_tool_collections_base_dir/.profile.custom
