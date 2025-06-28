#!/bin/bash

INPUT_FILE="RHEL_8_STIG_2.2.12_Autoanswer.txt"
OUTPUT_FILE="RHEL_8_STIG_2.2.12_Autoanswer.completed.txt"

cp "$INPUT_FILE" "$OUTPUT_FILE"

# --- Function Definitions ---
check_question_7321() {
    if grep -qi nullok /etc/pam.d/system-auth; then
        echo "Finding"
    else
        echo "Not a Finding"
    fi
}

# Add more check_question_xxxx functions here

# --- Update Function ---
update_answer() {
    local question_id="$1"
    local finding_status="$2"

    awk -v qid="$question_id" -v newval="$finding_status" '
        BEGIN { found=0 }
        {
            if ($0 ~ "QUESTION_ID[[:space:]]+:[[:space:]]+" qid) {
                found=1
            }
            if (found && $0 ~ /^\[[Xx]\] Not Reviewed/) {
                gsub(/\[X\] Not Reviewed/, "[ ] Not Reviewed")
                gsub(/\[ \] Finding/, "[ ] Finding")
                gsub(/\[ \] Not a Finding/, "[ ] Not a Finding")
                gsub(/\[ \] Not Applicable/, "[ ] Not Applicable")

                if (newval == "Finding") print "[X] Finding"
                else if (newval == "Not a Finding") print "[X] Not a Finding"
                else print "[X] Not Applicable"

                found=0; next
            }
            print
        }
    ' "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
}

# --- Logic to Run ---
# Question: ocil:navy.navwar.niwcatlantic.scc.rhel8os:question:7321
QID_7321="ocil:navy.navwar.niwcatlantic.scc.rhel8os:question:7321"
RESULT_7321=$(check_question_7321)
update_answer "$QID_7321" "$RESULT_7321"

# Add more QID/RESULT/update_answer lines here

echo "✅ Autoanswer file updated: $OUTPUT_FILE"
