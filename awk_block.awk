BEGIN {
    found = 0
    within_checklist = 0
}

$0 ~ ("^QUESTION_ID.*question:" qid "$") {
    found = 1
    within_checklist = 0
    #print "DEBUG: Matched QUESTION_ID " qid > "/dev/stderr"
    print
    next
}

#match(string, regex, array)

#$0 -> the entire current line
#Purpose: Finds a match and stores capture groups in array.

#split(string, array, delimiter)

#Splits a string by a delimiter into an array.

found == 1 {
    if (match($0, /^[[:space:]]*\[[Xx ]\][[:space:]]*(Finding|Not a Finding|Not Applicable|Not Reviewed)/, arr)) {
        within_checklist = 1
        val = arr[1]
        if (val == newval) {
            print "     [X] " val
        } else {
            print "     [ ] " val
        }
        next
    }

    if ($0 ~ /^[[:space:]]*Enter any comments *:/) {
        print
        split(comment, lines, "\n")
        for (i in lines) {
            print "       " lines[i]
        }
        next
    }


    if (within_checklist == 1) {
        found = 0
        within_checklist = 0
    }

    print
    next
}

{ print }
