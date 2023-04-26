#!/bin/bash
# This is a useful tool collections.


# E.g.
#   bitly_url https://www.google.com
# PS. Bitly profile (~/.bitly):
#   BITLY_GUID=<put your bitly guid in here>
#   BITLY_TOKEN=<put your bitly token in here>
function bitly_url () {
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


# E.g.
#   encode_uri https://www.gogole.com?q=a b c
function encode_uri () {
  echo $@ | sed -e 's/ /%20/g'
}


# E.g.
#   gen_qrcode 200x200 https://www.google.com
#   gen_qrcode https://www.google.com  # default image size is 200x200
function gen_qrcode () {
  gen_qrcode_url_template="https://api.qrserver.com/v1/create-qr-code/?size=__img_size__&data=__resource_uri__"
  output_file='/tmp/qrcode.png'
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


function help () {
  cat <<EOF
Usage:
  $0 <function name> <arguements>
E.g.
  $0 bitly_url https://www.google.com
Function list:
$(grep '^function [^_]' $0 | cut -d ' ' -f2 | sed -e 's/^/  /' | sort)
EOF
}

# main
$@
