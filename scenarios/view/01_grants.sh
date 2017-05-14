for role in "${ROLES_ARRAY[@]}"
do
    db_user_grant_table $TABLE_CUSTOMERS $role
    db_user_grant_table $TABLE_ORDERS $role
done