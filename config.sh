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
