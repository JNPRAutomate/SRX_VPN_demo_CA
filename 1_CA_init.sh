#!/bin/bash
./.needed_binaries.sh || exit
if [ $# -eq 2 ]; then
  if cd CA; then
    rm *.pem newcerts/* *.old *.p12 &>/dev/null
    echo "02" > serial
    echo -n > index.txt
    openssl req -new -x509 -newkey rsa:4096 -sha256 -subj /CN=$1/ -nodes -keyout cakey.pem -out cacert.pem -days $2 -config openssl.cnf -set_serial 01
    openssl x509 -in cacert.pem -outform DER -out cacert.crt
    cd ..
  fi
else
  echo -e "\n Usage:   $0 [CA COMMON NAME] [days validity] \n Example: $0 dial-up_demo_CA 3650 - Creates CA with CN=dial-up_demo_demo_CA valid for 10 years\n\n WARNING: command will WIPE ALL PREVIOUS DATA!\n"
fi
