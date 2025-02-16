#!/bin/bash
./.needed_binaries.sh || exit
cd CA
if [ $# -eq 1 ]; then
  for i in `cat ../revoke_list | grep -v ^#`; do
    if [ -f $i-cert.pem ]; then
      openssl ca -config ./openssl.cnf -revoke $i-cert.pem
    fi
    f=`echo $i | sed 's/[.@]/_/g'`
    if [ -f $f-cert.pem ]; then
      openssl ca -config ./openssl.cnf -revoke $f-cert.pem
    fi

  done
  openssl ca -verbose -config ./openssl.cnf -gencrl -crldays $1 -out cacrl.pem
else
  echo -e "\n Usage: $0 [days validity]\n"
fi
cd ..
