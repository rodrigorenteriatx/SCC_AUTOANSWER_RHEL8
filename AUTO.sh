#!/bin/bash

INPUT_FILE="RHEL_8_STIG_2.2.12_Autoanswer.txt"
OUTPUT_FILE="RHEL_8_STIG_2.2.12_Autoanswer.completed.txt"
cp "$INPUT_FILE" "$OUTPUT_FILE"


# Enable associative arrays
declare -A CHECK_COMMANDS
declare -A RESULTS

# --------------------------
# Populate COMMAND dictionary
# --------------------------

while IFS='=' read -r key val; do
    # Skip blank lines or comments
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    CHECK_COMMANDS["$key"]="$val"
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

OUTPUT_LOG="detailed_summary.txt"
> "$OUTPUT_LOG"

for QID in "${!CHECK_COMMANDS[@]}"; do
    CMD="${CHECK_COMMANDS[$QID]}"

    if [[ -z "$CMD" ]]; then
        echo "SKIPPING $QID"
        continue
    fi


    if OUTPUT=$(bash "${CMD}" 2>&1); then
        RESULTS["$QID"]="Not a Finding"
    else
        RESULTS["$QID"]="Finding"
    fi

echo "$OUTPUT" >> "$OUTPUT_LOG"
echo "---------------------------" >> "$OUTPUT_LOG"
done



# --------------------------
# Update Autoanswer.txt
# --------------------------

update_answer() {
    local question_id="$1"
    local finding_status="$2"

    awk -v qid="$question_id" -v newval="$finding_status" -f awk_block.awk "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"


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
    echo -e "Running AWK with input file: $OUTPUT_FILE"
}


# --------------------------
# Loop through and update
# --------------------------

for QID in "${!RESULTS[@]}"; do
    update_answer "$QID" "${RESULTS[$QID]}"

done
echo "Done. Updated file: $OUTPUT_FILE"
