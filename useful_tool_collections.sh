#!/bin/bash
# This is a useful tool collections.


# E.g. bitly_url https://www.google.com
# PS. Bitly profile (~/.bitly):
#   BITLY_GUID=<put your bitly guid in here>
#   BITLY_TOKEN=<put your bitly token in here>
function bitly_url() {
  [ ! -f ~/.bitly ] && _stderr "Cannot find key for bitly API call!" && return 1
  source ~/.bitly

  [ "${1:0:7}" != 'http://' ] && [ "${1:0:8}" != 'https://' ] && _url="https://$1" || _url="$1"
  echo "Shorten $_url w/ bitly..."
  curl \
    -H "Authorization: Bearer ${BITLY_TOKEN}" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{
  "long_url": "'$_url'",
  "domain": "bit.ly",
  "group_guid": "'${BITLY_GUID}'"
}' \
  https://api-ssl.bitly.com/v4/shorten 2>/dev/null | jq -r '.link'
}


# E.g. upload_secret_to_aws_secrets_manager [secret id] [plain text password]
function upload_secret_to_aws_secrets_manager() {
  secret_id=${1:-$secret_id} && [ -z "$secret_id" ] && _stderr "secret_id not found!" && return 1 || shift
  password=${1:-$password} && [ -z "$password" ] && _stderr "password not found!" && return 1
  e_password=$(echo $password | md5)
  aws secretsmanager put-secret-value \
    --secret-id Gilmore \
    --secret-string "{\"$e_password\":\"$password\"}"
}

# E.g. get_secret_from_aws_secrets_manager [secret id] [encrypted password]
function get_secret_from_aws_secrets_manager() {
  secret_id=${1:-$secret_id} && [ -z "$secret_id" ] && _stderr "secret_id not found!" && return 1 || shift
  e_password=${1:-$e_password} && [ -z "$e_password" ] && _stderr 'Cannot find encrypted password, exit!' && return 1
  _secret_string=$(aws secretsmanager get-secret-value \
    --secret-id Gilmore \
    --version-stage AWSCURRENT \
    --query 'SecretString')
  eval echo $_secret_string | jq -r '."'$e_password'"'
}


# E.g. encrypt_password [plain text password]  # By default, will encrypt current password ($password) and save the mapping into local password file.
function encrypt_password() {
  password=${1:-$password} && [ -z "$password" ] && _stderr "password not found!" && return 1
  e_password=$(echo $password | md5)
  grep "^$e_password=" $password_file >/dev/null 2>&1 && sed -i '' -e "s/^$e_password=.*$/$e_password=$password/" $password_file || echo "$e_password=$password" >> $password_file
  echo "Encrypt password done!"
}


# E.g. decrypt_password [encrypted password]  # By default, will encrypt current encrypted password ($e_password) which is loaded from local password file.
function decrypt_password() {
  [ ! -f "$password_file" ] && _stderr "Password file ($password_file) not found, exit!" && return 1
  e_password=${1:-$e_password}
  grep "^$e_password=" $password_file | cut -d= -f2
}


# E.g. list_password
function list_password() {
  [ ! -f "$password_file" ] && echo "Password file ($password_file) not found, exit!" && return 1
  [ $(wc -l $password_file | awk '{print($1)}') -eq 0 ] && echo "No password in vault, exit!" && return 2
  cat $password_file | while read l
  do
    echo "$(echo $l | cut -d= -f1)=$(_mask $(echo $l | cut -d= -f2))"
  done
}


# E.g. encode_uri https://www.gogole.com?q=a b c
function encode_uri() {
  python3 -c "from urllib import parse; print(parse.quote_plus('$@'));"
}


# E.g. gen_qrcode (200x200) https://www.google.com?q=a b c  # default image size is 200x200
function gen_qrcode() {
  gen_qrcode_url_template="https://api.qrserver.com/v1/create-qr-code/?size=__img_size__&data=__data__"
  output_file='/tmp/qrcode.png'
  img_size='200x200'
  is_quiet=false
  [ $# -eq 1 ] && ! echo "$1" | /usr/bin/egrep '^[0-9]+x[0-9]+$' >/dev/null && set $img_size "$1"
  echo "$1" | /usr/bin/egrep '^[0-9]+x[0-9]+$' >/dev/null && img_size="$1" && shift
  context="$@"
  ([ ! -z "$img_size" ] && [ ! -z "$context" ]) && is_quiet=true

  echo "Generate QRCode ($img_size, $context)..."
  ! $is_quiet && while [ -z "$_img_size" ]
  do
    read -p "Image size [$img_size]? " _img_size
    [ ! -z "$_img_size" ] && img_size=$_img_size
    [ ! -z "$img_size" ] && break
  done

  ! $is_quiet && while [ -z "$_context" ]
  do
    read -p "Context [$context]? " _context
    [ ! -z "$_context" ] && context=$_context
    [ ! -z "$context" ] && break
  done

  context=$(encode_uri $context)
  gen_qrcode_uri=$(echo $gen_qrcode_url_template | sed -e "s|__img_size__|$img_size|" | sed -e "s|__data__|$context|")
  curl -s -o $output_file $gen_qrcode_uri && echo "Save QRCode to $output_file, open it!" && open $output_file
  rm -i $output_file
}


# E.g. help
function help() {
  excluded_func_regex='(help|readme|vi)( |$)'
  _custom_file_options=$([ -f $custom_file ] && echo $custom_file)
  _sep=$(_repeat '-' 72)
  cat <<EOF
Usage:
  $0 help    # help manual
  $0 readme  # show readme info
  $0 vi      # edit $0 script
  $0 <function name> <arguements>

EOF

  ([ "$_show_funcs" == 'system' ] || [ "$_show_funcs" == 'all' ]) && _show_func_list $0
  ([ "$_show_funcs" == 'custom' ] || [ "$_show_funcs" == 'all' ]) && _show_func_list $custom_file custom
  ([ "$_show_funcs" == 'system' ] || [ "$_show_funcs" == 'all' ]) && _show_func_eg_list $0
  ([ "$_show_funcs" == 'custom' ] || [ "$_show_funcs" == 'all' ]) && _show_func_eg_list $custom_file custom
  echo 'Run command with -h/-H/--help to list custom/system/all functions!' && return 0
  return 0
}


# E.g. keep_alive (-s) https://aws.gilmoreglobal.com/en/login https://aws.gilmoreglobal.com/logout https://aws.gilmoreglobal.com/en  # -s: silence mode, password is managed by AWS secrets manager
# Note:
# you could run it in background by putting the following into your crontab.
# username=<username> e_password=<encrypted password> ./useful_tool_collection.sh keep_alive -s <login url> <logout url> <home url>
function keep_alive() {
  is_silence=false
  [ "$1" == '-s' ] && is_silence=true && shift
  [ $# -lt 3 ] && _stderr "Need to assign login/logout/homepage URIs, exit!" && return 1
  cookies_file=/tmp/cookies.txt
  output_file=/tmp/output.html
  archive_output_file=/tmp/output.html.bak
  login_url="$1"
  logout_url="$2"
  home_url="$3"

  [ -z "$username" ] && read -p 'username: ' username
  # [ ! -z "$e_password" ] && password=$(decrypt_password $e_password)  ## Deprecated, use AWS secrets manager instead.
  [ ! -z "$e_password" ] && password=$(get_secret_from_aws_secrets_manager $e_password)
  [ -z "$password" ] && read -s -p 'password: ' password

  [ -f "$output_file" ] && cat $output_file >> $archive_output_file && cat /dev/null > $output_file
  curl -i -L -X GET -c $cookies_file -o ${output_file} $home_url && [ $? -ne 0 ] && _stderr "Cannot browse homepage ($home_url)!" && return 1
  _token=$(grep _token ${output_file} | cut -d\" -f6) && [ -z "$_token" ] && _stderr "Cannot find toke in web page!" && return 1
  login_url=${login_url:-$(grep action ${output_file} | grep https | cut -d\" -f8)}
  [ -z "$login_url" ] && _stderr 'Error fetch action from page, exit!' && return 1
  curl -i -X POST -b $cookies_file -c $cookies_file -o ${output_file} -d username=$username -d password=$password -d _token=$_token $login_url
  curl -i -L -X GET -b $cookies_file -o ${output_file} $home_url
  ! $is_silence && open ${output_file}
  curl -i -L -X GET -b $cookies_file -o /dev/null $logout_url
}


# from tool to awsscript
function sync() {
  source z_utils.zshrc
  sync_useful_tool_collections
}


# from awsscript to tool
function restore() {
  source z_utils.zshrc
  restore_useful_tool_collections
}


# E.g. uuid
function uuid() {
  _uuid=$(uuidgen | tr '[A-Z]' '[a-z]')
  _uuid=$(echo $_uuid | sed -e 's/-//g')
  echo $_uuid
}


# E.g. extract email from student info
function extract_email() {
  _file="$1" && [ -f "$_file" ] && grep -EiEio '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b' $_file && return
  while read l
  do
    echo $l | grep -EiEio '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b'
  done
}


# main
custom_file=${0/.sh/.custom}
custom_profile=$(dirname $0)/.profile.custom
password_file=${0/.sh/.password}
utils_file=${0/.sh/.utils}

[ -f $utils_file ] && echo "Loading $utils_file" >&2 && source $utils_file
_gen_custom_file # generate custom file (once)
[ -f $custom_file ] && echo "Loading $custom_file" >&2 && source $custom_file

_show_funcs="$default_show_funcs"
[ "$1" == '-h' ] && _show_funcs=custom && shift
[ "$1" == '-H' ] && _show_funcs=system && shift
[ "$1" == '--help' ] && _show_funcs=all && shift
[ $# -eq 0 ] && help >&2 && exit 1
! _is_function $1 && echo "Function ($1) not found!" >&2 && exit 1

$@
