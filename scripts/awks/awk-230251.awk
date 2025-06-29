{
    match($0, /-oMACs=([^[:space:]'\''"]+)/, arr)
    if (arr[1] != "") print arr[1]
}
