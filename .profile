export _useful_tool_collections_base_dir="$(dirname $(readlink -f $0))"
function u() {
  _useful_tool_collections_script="$_useful_tool_collections_base_dir/useful_tool_collections.sh"
  case "$1" in
    cd)
      cd $_useful_tool_collections_base_dir
      ;;
    *)
      $_useful_tool_collections_script "$@"
      ;;
  esac
}
source $_useful_tool_collections_base_dir/useful_tool_collections.completion.sh
