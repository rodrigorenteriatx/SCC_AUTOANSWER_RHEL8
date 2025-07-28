#!/bin/bash
#USE_MFA=false

#CHECK IF PKI IS USED (SMARTCARDS/CERTS)
if [ -f /etc/sssd/pki/sssd_auth_ca_db.pem ] && grep -Ei 'certificate_verification|pam_cert_auth|use_certauth|smartcard' /etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf 2>/dev/null; then
    USE_PKI=true
    ##Rule 161 - scripts/v-230229
else
    USE_PKI=false
fi

#CHECK IF SSSD IS BEING ACTIVELY USED
if systemctl is-enabled sssd && systemctl is-active sssd; then
    USE_SSSD=true
    #Rule 1041 - scripts/v-230274
else
    USE_SSSD=false
fi

if systemctl is-enabled centrifydc && systemctl is-active centrifydc; then
    USE_CENTRIFY=true
    #CANT USE SSSD
    USE_SSSD=false
else
    USE_CENTRIFY=false
fi
#

if systemctl is-enabled autofs && systemctl is-active autofs; then
    USE_AUTOFS=true
else
    USE_AUTOFS=false
fi




check_PKI () {
    if [ "$USE_PKI" == "false" ]; then
        echo "NOT APPLICABLE: NOT USING PKI BASED AUTHENTICATION"
        return 2
    fi
    return 0
}

check_SSSD () {
    if [ "$USE_SSSD" == "false" ]; then
        echo "NOT APPLICABLE: NOT USING SSSD BASED AUTHENTICATION"
        if [ "$USE_CENTRIFY" == "true" ]; then
            echo "USING CENTRIFY FOR AUTHENTICATION"
        return 2
        fi
    fi
    return 0
}

# Optional: Output the config (for debugging)
cat <<EOF > vars.config
USE_PKI=$USE_PKI
USE_SSSD=$USE_SSSD
USE_MFA=$USE_MFA
USE_CENTRIFY=$USE_CENTRIFY
USE_AUTOFS=$USE_AUTOFS
USE_NFS_HOME=$USE_NFS_HOME
IS_GUI_INSTALLED=$IS_GUI_INSTALLED
EOF


# In DISA STIG context:

#     PKI (Public Key Infrastructure) authentication means using smartcards (e.g., CAC/PIV) for logins.

#     MFA (Multi-Factor Authentication) is a broader category that includes:

#         Something you know (e.g., password)

#         Something you have (e.g., smartcard/token)

#         Something you are (biometrics)

# So:

#     All PKI-based logins are MFA, but not all MFA setups use PKI