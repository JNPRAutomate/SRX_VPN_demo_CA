#!/bin/bash
./.needed_binaries.sh || exit
cd CA
if [ $# -eq 1 ]; then
  for i in `cat ../cert_list_server | grep -v ^#`; do
    f=`echo $i | sed 's/[.@]/_/g'`	  
    if [ ! -f $f-cert.pem ]; then
      openssl req -new -newkey rsa:4096 -subj /CN=$i/ -nodes -keyout $f-key.pem -out $f-req.pem -sha256
      sed -i '/subjectAltName/d' ext_server.cnf
      echo "subjectAltName = DNS:$i" >> ext_server.cnf
      openssl ca -batch -extfile ext_server.cnf -extensions server_cert -days $1  -in $f-req.pem -out $f-cert.pem -config ./openssl.cnf
    else
      echo $i certificate already exists! Potentially revoke and rename.
    fi
  done
else
  echo -e "\n Usage: $0 [days validity]\n"
fi
