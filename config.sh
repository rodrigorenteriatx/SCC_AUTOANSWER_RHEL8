#USE_MFA=false

#CHECK IF PKI IS USED (SMARTCARDS/CERTS)
if [ -f /etc/sssd/pki/sssd_auth_ca_db.pem ] && grep -Ei 'certificate_verification|pam_cert_auth|use_certauth|smartcard' /etc/sssd/sssd.conf /etc/sssd/conf.d/*.conf 2>/dev/null; then
    USE_PKI=true
    ##Rule 161 - scripts/v-230229
else
    USE_SSSD=false

#CHECK IF SSSD IS BEING ACTIVELY USED
if systemctl is-enabled sssd && systemctl is-active; then
    USE_SSSD=true
    #Rule 1041 - scripts/v-230274
else
    USE_SSSD=false

USE_CENTRIFY=true
#
USE_AUTOFS=true




check_PKI () {
    if [ "$USE_PKI" == "false" ]; then
        echo "NOT APPLICABLE: NOT USING PKI BASED AUTHENTICATION"
        return 2
    fi
    return 0
}

check_SSSD () {
    if [ "$USE_PKI" == "false" ]; then
        echo "NOT APPLICABLE: NOT USING SSSD BASED AUTHENTICATION"
        return 2
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