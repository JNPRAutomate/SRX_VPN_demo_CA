Simple demo CA meant to create head-end and user certificates for Juniper SRX dial-up and S2S VPNs

Alternate certificate subject names are DNS for VPN head-end(s) and user FQDN (email) for VPN spokes/dial-up clients

1/ put desired SRX certificate DNS subject alternative name to cert_list_server file, line by line for more certificates

2/ put desired user certificate Email subject alternative name to cert_list_user file, line by line for more certificates

3/ ./1_CA_init.sh [CA CN] [days validity], for help just run ./1_CA_init.sh

4/ ./2_CA_gencerts_from_cert_list-server.sh [days validity]

5/ adjust PKCS12 container export password in PKCS12_password file

6/ ./3_CA_gencerts_from_cert_list-user.sh  [days validity]

7/ ./4_CA_revokecerts_from_revoke_list.sh [days validity] even if there is nothing in revoke_list to get CRL with no revocations

8/ adjust whatever you like (keysize, MD, AIA, CDP, attributes, ...) in CA/*.cnf and re-iterate ... Default settings are RSA-4096b and SHA-256

9/ extract relevant self-explantory crypt-material files from the CA folder 

10/ potentially renew CA certificate ./5_CA_renew.sh [days validity]
