
NAME_OUT="simple"
OUT="${PATH_OUT}/${NAME_OUT}.log"

echo "# RESULTS FOR SIMPLE!" > "$OUT"

# Executes all sql scripts that are in simple dir
echo -e "\nBEGIN: `time`\n\n" >> "${OUT}"
load_sql_pretty_scripts "${PATH_SQL_TESTS}/simple" $NAME_OUT
echo -e "\nEND: `time`\n\n" >> "${OUT}"

echo -e "\t Simple results"
cat "${OUT}"
