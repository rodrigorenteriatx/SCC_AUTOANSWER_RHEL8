#!/bin/bash

INPUT_FILE="RHEL_8_STIG_2.2.12_Autoanswer.txt"
OUTPUT_FILE="RHEL_8_STIG_2.2.12_Autoanswer.completed.txt"
cp "$INPUT_FILE" "$OUTPUT_FILE"

echo HEREEE


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


# --------------------------
# Evaluate results
# --------------------------
for QID in "${!CHECK_COMMANDS[@]}"; do
    CMD="${CHECK_COMMANDS[$QID]}"

    if [[ -z "$CMD" ]]; then
        echo "SKIPPING $QID"
        continue
    fi


    if bash "${CHECK_COMMANDS[$QID]}"; then
        RESULTS["$QID"]="Not a Finding"
    else
        RESULTS["$QID"]="Finding"
    fi
    echo "IT WAS A ${RESULTS["$QID"]}"
done



# --------------------------
# Update Autoanswer.txt
# --------------------------

update_answer() {
    local question_id="$1"
    local finding_status="$2"


    echo "Updating QUESTION_ID: $question_id → [$finding_status]"
    echo "Running AWK with input file: $OUTPUT_FILE"

    awk -v qid="$question_id" -v newval="$finding_status" -f awk_block.awk "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
}


# --------------------------
# Loop through and update
# --------------------------

for QID in "${!RESULTS[@]}"; do
    update_answer "$QID" "${RESULTS[$QID]}"

done

echo "Done. Updated file: $OUTPUT_FILE"
