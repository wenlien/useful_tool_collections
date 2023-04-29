#!/bin/bash
# This is a useful tool collections.


# E.g. bitly_url https://www.google.com
# PS. Bitly profile (~/.bitly):
#   BITLY_GUID=<put your bitly guid in here>
#   BITLY_TOKEN=<put your bitly token in here>
function bitly_url() {
  [ ! -f ~/.bitly ] && echo "Cannot find key for bitly API call!" && exit 1
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


# E.g. decrypt_password <encrypted password>
function decrypt_password() {
  grep "^$1=" $password_file | cut -d= -f2
}


# E.g. encode_uri https://www.gogole.com?q=a b c
function encode_uri() {
  echo $@ | sed -e 's/ /%20/g'
}


# E.g. encrypt_password  # will encrypt your current password and save the mapping into password file.
function encrypt_password() {
  password=${1:-$password} && [ -z "$password" ] && echo "password not found!" && return 1
  e_password=$(echo $password | md5)
  grep "^$e_password=" $password_file >/dev/null 2>&1 && sed -i '' -e "s/^$e_password=.*$/$e_password=$password/" $password_file || echo "$e_password=$password" >> $password_file
  echo "Encrypt password done!"
}


# E.g. gen_qrcode 200x200 https://www.google.com
# E.g. gen_qrcode https://www.google.com  # default image size is 200x200
function gen_qrcode() {
  gen_qrcode_url_template="https://api.qrserver.com/v1/create-qr-code/?size=__img_size__&data=__resource_uri__"
  output_file='/tmp/qrcode.png'
  img_size='200x200'
  is_quiet=false
  [ $# -eq 1 ] && set $img_size "$1"
  [ $# -gt 1 ] && img_size="$1" && shift && resource_uri="$@" && is_quiet=true

  echo 'Generate QRCode for web link...'
  ! $is_quiet && while [ -z "$_img_size" ]
  do
    read -p "Image size [$img_size]? " _img_size
    [ ! -z "$_img_size" ] && img_size=$_img_size
    [ ! -z "$img_size" ] && break
  done

  ! $is_quiet && while [ -z "$_resource_uri" ]
  do
    read -p "resource URI [$resource_uri]? " _resource_uri
    [ ! -z "$_resource_uri" ] && resource_uri=$_resource_uri
    [ ! -z "$resource_uri" ] && break
  done

  resource_uri=$(encode_uri $resource_uri)
  gen_qrcode_uri=$(echo $gen_qrcode_url_template | sed -e "s|__img_size__|$img_size|" | sed -e "s|__resource_uri__|$resource_uri|")
  echo "Resource URI: '$resource_uri'"
  curl -s -o $output_file $gen_qrcode_uri && echo "Save QRCode to $output_file, open it!" && open $output_file
}


# E.g. help
function help() {
  excluded_func_regex='(help|readme|vi)( |$)'
  cat <<EOF
Usage:
  $0 help    # help manual
  $0 readme  # show readme info
  $0 vi      # edit $0 script
  $0 <function name> <arguements>
Function list:
$(grep '^function [^_]' $0 $custom_file $plugins_file | cut -d ' ' -f2 | cut -d '(' -f1 | egrep -v "$excluded_func_regex" | sed -e 's/^/  /' | sort)
E.g.
$(cat $0 $custom_file $plugins_file | grep '^# E.g. [^_]' | sed -e "s|^#[ ]*E.g.[ ]*|  $0 |" | egrep -v "  $0 $excluded_func_regex" | sort)
EOF
}


# E.g. list_password
function list_password() {
  cat $password_file
}


# Hidden function, check if it is a function.
# E.g. _is_function
function _is_function() {
  [ ! -z "$1" ] && typeset -F $1 >/dev/null 2>&1 || return 1
}


# E.g. keep_alive -s https://aws.gilmoreglobal.com/login/en https://aws.gilmoreglobal.com/logout https://aws.gilmoreglobal.com/en  # -s: silence mode
# Note:
# you could run it in background by putting "username=<username> e_password=<encrypted password> ./useful_tool_collection.sh keep_alive -s <url 1> <url 2> <url>" into your crontab.
function keep_alive() {
  is_silence=false
  [ "$1" == '-s' ] && is_silence=true && shift
  [ $# -lt 3 ] && echo "Need to assign login/logout/homepage URIs, exit!" && return 1
  token_file=/tmp/token.txt
  output_file=/tmp/output.html
  login_url="$1"
  logout_url="$2"
  home_url="$3"

  [ -z "$username" ] && read -p 'username: ' username
  [ ! -z "$e_password" ] && password=$(decrypt_password $e_password)
  [ -z "$password" ] && read -s -p 'password: ' password

  curl -i -L -X GET -c $token_file -o ${output_file} $home_url && \
    _token=$(grep _token ${output_file} | cut -d\" -f6) && \
    login_url=$(grep action ${output_file} | grep https | cut -d\" -f8) && \
    [ -z "$login_url" ] && echo 'Error fetch action from page, exit!' && exit 1
  curl -i -X POST -b $token_file -c $token_file -o ${output_file} -d username=$username -d password=$password -d _token=$_token $login_url
  curl -i -L -X GET -b $token_file -o ${output_file} $home_url
  ! $is_silence && open ${output_file}
  curl -i -L -X GET -b $token_file -o /dev/null $logout_url
}


# E.g. readme
function readme() {
  open $(dirname $0)/README.md
}


# E.g. vi [custom/password/plugins/sh]
function vi() {
  vim ${0/.sh}.${1:-sh}
}


# main
password_file=${0/.sh/.password}
custom_file=${0/.sh/.custom}
plugins_file=${0/.sh/.plugins}
[ -f $custom_file ] && echo "Loading $custom_file" && source $custom_file
[ -f $plugins_file ] && echo "Loading $plugins_file" && source $plugins_file
[ $# -eq 0 ] && help && exit 1
! _is_function $1 && echo "Function ($1) not found!" && exit 1
$@
