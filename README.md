# SRX_VPN_demo_CA
Simple demo CA meant to create head-end and user/spoke certificates for Juniper SRX dial-up and S2S VPNs. Tested on Debian Linux 12, any modern Linux distribution should work.

Alternative certificate subject names are DNS for VPN head-end(s) and user FQDN (email) for VPN spokes/dial-up clients.

## **Example IKE-ID use with the out of the box SRX_VPN_demo_CA certificates:**

**SRX AutoVPN head-end**
```
set groups dial-up-vpn-cert security ike gateway ikev-gw dynamic user-at-hostname "@cert.auth"
set groups dial-up-vpn-cert security ike gateway ikev-gw dynamic ike-user-type group-ike-id
set groups dial-up-vpn-cert security ike gateway ikev-gw local-identity hostname srx.domain.tld
```

**Linux strongSwan spoke** ```swanctl.conf```
```
local {
   auth = pubkey
   id = user1@cert.auth
   certs = user1-cert.pem
}
remote {
   auth = pubkey 
   id = srx.domain.tld
}
```

# Instructions:

Clone from GitHub
```
git clone https://github.com/JNPRAutomate/SRX_VPN_demo_CA
cd SRX_VPN_demo_CA
chmod 755 .needed_binaries.sh *.sh
```
or download and extract provided ```.zip``` file, then:

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

## SRX head-end certificate(s)
**Alter the** ```cert_list_server``` **file, default contents:**
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

## VPN user/spoke certificate(s)
**Alter the** ```PKCS12_password``` **file containing password for PKCS12 container export, default contents:**
```
cat PKCS12_password 
changeme!
```

**Alter the** ```cert_list_user``` **file, default contents:**
```
cat cert_list_user 
#put here user FQDN (email) of certificates, line by line, no spaces allowed
user1@cert.auth
user2@cert.auth
```
**Generate SRX user/spoke certificate(s) with validity of 2Y**:
```
./3_CA_gencerts_from_cert_list-user.sh 720
```
**To view details of generated certificate (by default terse output is printed while generating)**:
```
openssl x509 -in CA/user1_cert_auth-cert.pem -text -noout
```
```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 3 (0x3)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = DEMO_CA
        Validity
            Not Before: Feb 16 17:06:24 2025 GMT
            Not After : Feb  6 17:06:24 2027 GMT
        Subject: CN = user1
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:a5:48:47:85:9c:ed:51:2e:d4:3f:79:75:a7:87:
                    <SNIP>
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Authority Key Identifier: 
                33:32:95:65:59:8B:9C:71:10:9E:60:25:F9:2F:E6:56:24:1E:58:10
            X509v3 Subject Key Identifier: 
                97:FF:D2:C4:70:8C:56:2F:74:3D:0A:1A:89:CC:01:2D:CE:D2:24:D2
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication
            X509v3 Subject Alternative Name: 
                email:user1@cert.auth
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        48:b7:a2:9c:95:2a:99:d6:be:c0:cd:53:4d:91:35:cf:73:63:
        <SNIP>
```
**Alternatively to view the PKCS12 container**:

(sidenote - PKCS12 container crypto is weakened for compatability purposes, e.g., for purpose of import on Android 13)

```
openssl pkcs12 -in CA/user1_cert_auth.p12 -info
```
```
Enter Import Password:
MAC: sha1, Iteration 2048
MAC length: 20, salt length: 8
PKCS7 Encrypted data: pbeWithSHA1And3-KeyTripleDES-CBC, Iteration 2048
Certificate bag
Bag Attributes
    friendlyName: user1
    localKeyID: FB 4B 94 2B 48 07 BF A8 75 D5 A0 CB E5 9E 22 81 E2 D2 A2 9A 
subject=CN = user1
issuer=CN = DEMO_CA
<SNIP>
```

## Revoking user/spoke certificate(s)

**Alter the** ```revoke_list``` **file, default contents:**
```
cat revoke_list 
#put here certificate SAN(s) for revocations
#srx.domain.tld
#user1@cert.auth
```

**After uncommenting** ```user1@cert.auth``` **in the above file, CRL valid for 10 days:**

```
./4_CA_revokecerts_from_revoke_list.sh 10
```
```
Using configuration from ./openssl.cnf
Revoking Certificate 03.
Database updated
Using configuration from ./openssl.cnf
V       270206165023Z           02      unknown /CN=srx.domain.tld
R       270206170624Z   250217234612Z   03      unknown /CN=user1
V       270206170625Z           04      unknown /CN=user2
3 entries loaded from the database
generating index
making CRL
signing CRL
```

**Sidenote - typically CDPs would be configured during CA generation - review** ```*.cnf``` **files in the CA directory**

**To view the resulting CRL:**

```
openssl crl -inform PEM -in CA/cacrl.pem  -text
```
```
Certificate Revocation List (CRL):
        Version 2 (0x1)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = DEMO_CA
        Last Update: Feb 17 23:46:12 2025 GMT
        Next Update: Feb 27 23:46:12 2025 GMT
        CRL extensions:
            X509v3 Authority Key Identifier: 
                33:32:95:65:59:8B:9C:71:10:9E:60:25:F9:2F:E6:56:24:1E:58:10
Revoked Certificates:
    Serial Number: 03
        Revocation Date: Feb 17 23:46:12 2025 GMT
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        90:94:50:8c:49:fa:db:b6:b6:cb:e4:ac:8a:38:79:86:e5:1c:
        <SNIP>
-----BEGIN X509 CRL-----
MIIClTB/AgEBMA0GCSqGSIb3DQEBCwUAMBIxEDAOBgNVBAMMB0RFTU9fQ0EXDTI1
<SNIP>
-----END X509 CRL-----
```

**Alternatively to view the resulting CRL in DER format:**

```
openssl crl -inform DER -in CA/cacrl.crl  -text
```

## Extending CA certificate validity

**To re-issue CA certificate with validity time by 10 days:**

```
./5_CA_renew.sh 10
```
```
Using configuration from ./openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 6 (0x6)
        Validity
            Not Before: Feb 17 23:53:53 2025 GMT
            Not After : Feb 27 23:53:53 2025 GMT
        Subject:
            commonName                = DEMO_CA
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                33:32:95:65:59:8B:9C:71:10:9E:60:25:F9:2F:E6:56:24:1E:58:10
            X509v3 Authority Key Identifier: 
                33:32:95:65:59:8B:9C:71:10:9E:60:25:F9:2F:E6:56:24:1E:58:10
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Key Usage: critical
                Certificate Sign, CRL Sign
Certificate is to be certified until Feb 27 23:53:53 2025 GMT (10 days)
```









