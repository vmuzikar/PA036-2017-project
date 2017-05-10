input="${PATH_VALUES}"

first=""
second=""

while IFS= read -r var
do
    db_user_create $var
    db_user_grant_table "customer" $var
    db_user_grant_table "orders" $var
    second="${first}"
    first="${var}"
done < "$input"

db_user_grant_user $first $second

