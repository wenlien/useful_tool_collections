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

* Keep alive.

  You could pass username/password during process or assign username/password into environment before execute the script.

```
$ username=<user> password<plain text> ./useful_tool_collections.sh -s <login url> <logout url> <homepage url>
```

or

    You could encrypt your password into password file first and the password will be saved into useful_tool_collection.password (the same directoy of the script), then you could pass the encrypted password into environment before execute the script.  (You could use this tip to avoid your password being show in crontab)

```
$ ./useful_tool_collections encrypt_password
$ cat ./useful_tool_collections.password
$ username=<user> e_password<encrypted text> ./useful_tool_collections.sh -s <login url> <logout url> <homepage url>
```
