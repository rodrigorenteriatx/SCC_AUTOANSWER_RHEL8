#!/bin/bash
#RESULTS DIRECTORY
#"RESULTS"

#CONTAINS VARS FOR ACCURATE ANSWERING (PKI, CENTRIFY, ETC)

INPUT_FILE="RHEL_8_STIG_2.2.12_Autoanswer.txt"
OUTPUT_FILE="RESULTS/RHEL_8_STIG_2.2.12_Autoanswer.COMPLETED.txt"
cp "$INPUT_FILE" "$OUTPUT_FILE"


# Enable associative arrays
#create the list of ordered question_ids
declare -A CHECK_COMMANDS
declare -A RESULTS
declare -A VNUMBERS
declare -A COMMENTS
ORDERED_KEYS=()

# --------------------------
# Populate COMMAND dictionary
# --------------------------

while IFS='|' read -r qid vnum script; do
    # Skip blank lines or comments
    [[ -z "$qid" || "$qid" =~ ^# ]] && continue

    ORDERED_KEYS+=("$qid")
    VNUMBERS["$qid"]="$vnum"
    CHECK_COMMANDS["$qid"]="$script"
done < check_commands.txt



# Color variables
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'



# --------------------------
# Evaluate results
# --------------------------

OUTPUT_LOG="RESULTS/detailed_summary.txt"
> "$OUTPUT_LOG"

source config.sh

for qid in "${ORDERED_KEYS[@]}"; do
    script="${CHECK_COMMANDS[$qid]}"
    vnum="${VNUMBERS["$qid"]}"

    if [[ -z "$script" ]]; then
        echo "SKIPPING $qid ($vnum)"
        continue
    fi


    if script_output=$(source "${script}" 2>&1); then
        RESULTS["$qid"]="Not a Finding"
    else
        RESULTS["$qid"]="Finding"
    fi

    #OUTPUT FROM EACH COMMAND WILL ALSO BE STORED HERE, MEANT FOR THE AUTOANSWER.TXT
    #THE FOLLOWING OUTPUT AFTER, WILL NOT BE INCLUDED BUT WILL BE USED TO FORMAT THE detailed_summary.txt which will CLEANLY mirror the AUTOANSWER.txt
    COMMENTS["$qid"]="$script_output"

    #1. output rule/vnum first, 2. output from script to COMMENTS AND THE OUTPU_LOG3. ------- at then end
    echo "[$qid] $vnum - $script" | tee -a "$OUTPUT_LOG"
    echo "$script_output" | tee -a "$OUTPUT_LOG"
    echo | tee -a "$OUTPUT_LOG"
    echo "RESULT: ${RESULTS["$qid"]}" | tee -a "$OUTPUT_LOG"
    echo "------------------------------------------" | tee -a "$OUTPUT_LOG"
    echo "##########################################" | tee -a "$OUTPUT_LOG"
    echo "------------------------------------------" | tee -a "$OUTPUT_LOG"
done



# --------------------------
# Update Autoanswer.txt
# --------------------------

update_answer() {
    local question_id="$1"
    local finding_status="$2"
    local comment="$3"

    awk -v qid="$question_id" -v newval="$finding_status" -v comment="$comment" -f awk_block.awk "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"


    case "$finding_status" in
        "Finding")
            STATUS_COLOR="$RED"
            ;;
        "Not a Finding")
            STATUS_COLOR="$GREEN"
            ;;
        "Not Applicable"|"Not Reviewed")
            STATUS_COLOR="$YELLOW"
            ;;
        *)
            STATUS_COLOR="$RESET"
            ;;
    esac


    echo -e "Updating QUESTION_ID:${STATUS_COLOR} $question_id → [$finding_status] ${RESET}"
    #echo -e "Running AWK with input file: $OUTPUT_FILE"
}


# --------------------------
# Loop through and update
# --------------------------

for qid in "${!RESULTS[@]}"; do

    update_answer "$qid" "${RESULTS[$qid]}" "${COMMENTS["$qid"]}"

done
#Need to change ownerships and permissions of RESULTS dir and files inside
#May need to set group to ISSO (644), Mostly meant for admin to use to remediate or for SCAP SCAN

echo "Done. Updated AUTOANSWER file: $OUTPUT_FILE"
