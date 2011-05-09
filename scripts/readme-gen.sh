#!/bin/sh

# generate the README.html file to put in the zip
# $1 = name-version
cat << XEOF
<html><head><title>README</title></head>
<!-- ======= This file is automatically generated ====== -->
<body>
<pre>
This zip archive contains 3 files:

XEOF
printf "%-20s %s\n" "README.html" "What you are reading now."
printf "%-20s %s\n" "$1.dmg.sig" "A detached OpenPGP signature to check the disk image."
printf "%-20s %s\n" "$1.dmg"     "A disk image containing Vienna."
cat << X2EOF

You can use your OpenPGP utility (for example: GnuPG) to check the disk image
against its cryptographic signature contained in the signature file. This
step is completely optional.

The key that was used to sign the disk image can be found by searching the key
servers for the key of dave.evans55@googlemail.com.	

GnuPG can be found at <a href="http://www.gnupg.org/">http://www.gnupg.org/</a>

</pre>
</body>
X2EOF
