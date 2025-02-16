#!/bin/bash
./.needed_binaries.sh || exit
cd CA
if [ $# -eq 1 ]; then
  for i in `cat ../cert_list_user | grep -v ^#`; do
    f=`echo $i | sed 's/[.@]/_/g'`	  
    c=`echo $i | sed 's/@.*//'`
    if [ ! -f $i-cert.pem -a ! -f $f-cert.pem ]; then
      openssl req -new -newkey rsa:4096 -subj /CN=$c/ -nodes -keyout $f-key.pem -out $f-req.pem -sha256
      sed -i '/subjectAltName/d' ext_user.cnf
      echo "subjectAltName = email:$i" >> ext_user.cnf
      openssl ca -batch -extfile ext_user.cnf -extensions user_cert -days $1 -in $f-req.pem -out $f-cert.pem -config ./openssl.cnf 
      openssl pkcs12 -export -inkey $f-key.pem -in $f-cert.pem -name $c -CAfile cacert.pem -out $f.p12 -chain\
	      -passout file:../PKCS12_password -legacy -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES 
    else
      echo $i certificate already exists! Potentially revoke and rename.
    fi
  done
else
  echo -e "\n Usage: $0 [days validity]\n"
fi
