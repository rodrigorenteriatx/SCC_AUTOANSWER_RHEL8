USE_MFA=false
#
USE_PKI=false
#Rule 161 - scripts/v-230229

USE_CENTRIFY=true
#
USE_AUTOFS=true

USE_SSSD=false

check_PKI () {
    if [ "$USE_PKI" == "false" ]; then
        echo -e "NOT APPLICABLE\nNOT USING PKI BASED AUTHENTICATION"
        finding=2
        return $finding
    fi
    return 0
}

check_SSSD () {
    if [ "$USE_PKI" == "false" ]; then
        echo -e "NOT APPLICABLE\nNOT USING SSSD BASED AUTHENTICATION"
        finding=2
        return $finding
    fi
    return 0
}
