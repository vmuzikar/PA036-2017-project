input="${PATH_VALUES}"

while IFS= read -r var
do
    db_user_create $var
done < "$input"