input="${PATH_VALUES}"

first=""
second=""

while IFS= read -r var
do
    if [ "${firts}" == "" ]; then
        first=$var
    elif [ "${second}" == ""]; then
        second=${var}
    fi

    db_user_create $var
    db_user_grant_table "customer" $var
    db_user_grant_table "orders" $var
done < "$input"

db_user_grant_user $first $second
