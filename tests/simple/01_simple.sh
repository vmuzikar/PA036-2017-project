
NAME_OUT="${SCENARIO_NAME}-simple"
OUT="${PATH_OUT}/${NAME_OUT}.log"

echo "# RESULTS FOR SIMPLE!" > "$OUT"

# Executes all sql scripts that are in simple dir
echo -e "BEGIN: ` get_perf_time ` \n" >> "${OUT}"
load_sql_pretty_scripts "${PATH_SQL_TESTS}/simple" $NAME_OUT
echo -e "END: ` get_perf_time ` \n" >> "${OUT}"

echo -e "\t Simple results" >> ${OUT}
cat "${OUT}"
