input="${PATH_VALUES}"

first=""
second=""

exec_query "ALTER USER tpcc WITH SUPERUSER;"

ROLES_ARRAY=()
while IFS='' read -r var || [[ -n "$var" ]]; do
    ROLES_ARRAY+=("$var")
done < "$input"

# Roles array - do what ever you want

while IFS='' read -r var || [[ -n "$var" ]]; do
    
    if [ -z "${var// }" ]; then
        continue
    fi

    db_user_create $var
    db_user_grant_table "customer" $var
    db_user_grant_table "orders" $var
    second="${first}"
    first="${var}"
done < "$input"

db_user_grant_user $first $second



