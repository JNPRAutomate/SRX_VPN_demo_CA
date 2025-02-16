# SRX_VPN_demo_CA
Simple demo CA meant to create head-end and user/spoke certificates for Juniper SRX dial-up and S2S VPNs. Tested on Debian Linux 12, any modern Linux distribution should work.

Alternative certificate subject names are DNS for VPN head-end(s) and user FQDN (email) for VPN spokes/dial-up clients.

# Instructions:

1.  put desired SRX certificate DNS subject alternative name to ```cert_list_server file```, line by line for more certificates

2.  put desired user certificate Email subject alternative name to ```cert_list_user``` file, line by line for more certificates

3. ```./1_CA_init.sh [CA CN] [days validity]```  for help just run ```./1_CA_init.sh```

4. ```./2_CA_gencerts_from_cert_list-server.sh [days validity]```

5.   adjust PKCS12 container export password in ```PKCS12_password``` file

6. ```./3_CA_gencerts_from_cert_list-user.sh  [days validity]```

7. ```./4_CA_revokecerts_from_revoke_list.sh [days validity]``` even if there is nothing in revoke_list to get CRL with no revocations

8.  adjust whatever you like (keysize, MD, AIA, CDP, attributes, ...) in ```CA/*.cnf``` and re-iterate ... Default settings are RSA-4096b and SHA-256

9.  extract relevant self-explanatory crypto-material from the ```CA``` folder 

10. potentially renew CA certificate ```./5_CA_renew.sh [days validity]```

# Example: 

## CA certificate
**CA key/certificate generation with validity of 10 years:**

```./1_CA_init.sh DEMO_CA 3650```

**To view resulting CA certificate:**

```openssl x509 -in CA/cacert.pem -text -noout```
```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = DEMO_CA
        Validity
            Not Before: Feb 16 16:38:00 2025 GMT
            Not After : Feb 14 16:38:00 2035 GMT
        Subject: CN = DEMO_CA
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:bd:df:57:b8:af:8a:17:00:b3:e3:4f:61:eb:4c:
                    <SNIP>
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                33:32:95:65:59:8B:9C:71:10:9E:60:25:F9:2F:E6:56:24:1E:58:10
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Key Usage: critical
                Certificate Sign, CRL Sign
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        01:a7:75:00:94:f2:5b:ac:d6:b8:a5:21:5e:29:4d:e3:45:40:
        <SNIP>
```

## SRX head-end certificate
**Alter ```cert_list_server``` file, default contents:**
```
cat cert_list_server 
#put here DNS FQDN of certificates, line by line, no spaces allowed
srx.domain.tld
```
**Generate SRX head-end certificate(s) with validity of 2Y**:
```
./2_CA_gencerts_from_cert_list-server.sh 720
```
**To view details of generated certificate (by default terse output is printed while generating)**:
```
openssl x509 -in CA/srx_domain_tld-cert.pem -text -noout
```
```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 2 (0x2)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = DEMO_CA
        Validity
            Not Before: Feb 16 16:50:23 2025 GMT
            Not After : Feb  6 16:50:23 2027 GMT
        Subject: CN = srx.domain.tld
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:b4:e9:15:3e:f3:a5:7f:c1:34:97:e2:fe:66:b3:
                    <SNIP>
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Authority Key Identifier: 
                33:32:95:65:59:8B:9C:71:10:9E:60:25:F9:2F:E6:56:24:1E:58:10
            X509v3 Subject Key Identifier: 
                A0:17:39:01:D1:F8:44:B8:86:C1:6F:BE:57:77:5B:0C:C9:3E:EF:20
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Subject Alternative Name: 
                DNS:srx.domain.tld
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        61:17:fa:fd:cf:68:d2:9d:89:a1:c4:e9:aa:0c:88:e5:af:a3:
        <SNIP>
```




