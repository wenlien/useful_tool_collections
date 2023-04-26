# useful_tool_collections

It's the collections of useful tools.



### Example commands:

* Show help manual.

```
$ ./useful_tool_collections.sh help
Usage:
  ./useful_tool_collections.sh <function name> <arguements>
E.g.
  ./useful_tool_collections.sh bitly_url https://www.google.com
Function list:
  bitly_url
  encode_uri
  gen_qrcode
  help
$
```

* Generate shorten URL by calling bitly API.

```
$ ./useful_tool_collections.sh bitly_url https://www.google.com
Shorten https://www.google.com w/ bitly...
https://bit.ly/3OsWJpp
$
```

* Generate QRCode of web like.

```
$ ./useful_tool_collections.sh gen_qrcode 200x200 https://www.google.com
Generate QRCode for web link...
Resource URI: '200x200%20https://www.google.com'
Save QRCode to /tmp/qrcode.png, open it!
$
```


