# SCC\_AUTOANSWER\_RHEL8

A Bash framework to automate responses for manual questions in DISA SCAP Compliance Checker (SCC) Autoanswer files for RHEL 8 STIG benchmarks.

## Overview

This tool automates the process of answering manual checks in the SCC Autoanswer file by using hardcoded shell logic and updating the appropriate `[ ] Finding` fields in the file. It eliminates the need to manually edit check results after each scan. This will also fill the section meant for comments with the appropriate output to further justify its result.

## Features

* Maps `QUESTION_ID`s to shell-based validation commands
* Evaluates compliance using Bash and stores results as:

  * Finding
  * Not a Finding
* Automatically edits the Autoanswer file using AWK
* Color-coded terminal output (for terminal visibility)
* Logs command results and decision outcomes separately

## Directory Structure

```
.
├── AUTO.sh                 # Main script
├── check_commands.txt            # Maps QUESTION_IDs to vulnerability_id and Bash scripts
├── RHEL_8_STIG_*.txt             # SCC Autoanswer input/output files (OUPUT=RHEL_8_STIG_2.2.12_Autoanswer.completed.txt)  
├── awk_block.awk                 # AWK logic block used to format RHEL_8_STIG_2.2.12_Autoanswer.txt
├── scripts/*                     # Location of rule check scripts and more awk logic scripts
├── detailed_summary.txt          # Output from each shell command
```

## Usage

1. Populate `check_commands.txt` with lines in the format:

   ```
   QUESTION_ID|VULNERABILITY_ID|SCRIPT_TO_RUN
   ```

2. Place your `Autoanswer.txt` file in the directory.

3. Run the script:

   ```bash
   chmod +x autoanswer.sh
   ./autoanswer.sh
   ```

## Output

* `RHEL_8_STIG_2.2.12_Autoanswer.completed.txt`: Final file with updated check results
* `results_summary.txt`: A one-line summary for each question ID
* `detailed_check_output.txt`: Full stdout and stderr from each command

## Example `check_commands.txt`

```
81|V-230225|scripts/v-230225
161|V-230229|scripts/v-230229
```

## Requirements

* Bash 4 or higher
* RHEL 8 system
* SCAP Compliance Checker (SCC) with Autoanswer support
* Autoanswer file si created after uploadding Enhanced Benchamrk from NIWC, currently version Archive/2025-Q1/U_RHEL_8_V2R2_STIG_SCAP_1-3_Benchmark-enhancedV12.zip
* Q1 2025 BEnchomark, compatible with SCC 5.10
* `Autoanswer.txt` file for the RHEL 8 STIG benchmark
* Root or sudo where needed for command checks

## Author

Rodrigo Renteria
GitHub: [https://github.com/rodrigorenteriatx](https://github.com/rodrigorenteriatx)
