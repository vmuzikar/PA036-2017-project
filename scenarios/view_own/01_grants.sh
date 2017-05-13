for role in "${ROLES_ARRAY[@]}"
do
    db_user_revoke_grant_table customer $role
    db_user_grant_table customer_view $role
done