function extract_key {
    # Function to extract a single key from a key-value file with
    # equal `=` as separator.
    # Result is returned in the RESULT variable
    kv_file=$1
    key=$2
    
    RESULT=`cat $kv_file | grep "^$2=" | cut -d'=' -f2`
    if test $? -ne 0; then
        RESULT=""
    fi
}

