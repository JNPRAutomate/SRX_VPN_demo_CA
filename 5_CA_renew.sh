#!/bin/bash
./.needed_binaries.sh || exit
if [ $# -eq 1 ]; then
  if cd CA; then
    cp cacert.pem cacert.pem.old
    CN=`openssl x509 -subject -in cacert.pem -noout | cut -f 3 -d =| cut -c 2-`
    openssl req -new -key cakey.pem -sha256 -subj /CN=$CN/ -nodes -out careq.pem -config openssl.cnf
    openssl ca -batch -extfile ext_ca.cnf -extensions ca_cert -days $1 -in careq.pem -out cacert.pem -config ./openssl.cnf
    cd ..
  fi
else
  echo -e "\n Usage:   $0 [days validity] \n Example: $0 3650 - Extend CA certificate validity by another 10 years\n"
fi
