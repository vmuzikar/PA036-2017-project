input="${PATH_VALUES}"

first=""
second=""

while IFS= read -r var
do
    if [ "${firts}" == "" ]; then
        first=$var
    fi

    if [ "${second}" == "" ]; then
        second=${var}
        db_user_grant_user $first $second
    fi

    db_user_create $var
    db_grant_user_table "customer" $var
    db_grant_user_table "orders" $var
    
done < "$input"