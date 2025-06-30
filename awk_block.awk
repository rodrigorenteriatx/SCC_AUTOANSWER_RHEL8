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

    if (within_checklist == 1) {
        found = 0
        within_checklist = 0
    }

    print
    next
}

{ print }
