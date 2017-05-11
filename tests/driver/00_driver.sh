
FILE_DRIVER="${BASE_DIR}/scripts/tcl/driver.tcl"
TOTAL_ITER=${TOTAL_ITERATIONS}
USER=${DB_USER}
PASS=${DB_USER_PASS}
DB=${DB_NAME}
# 1-st arg total_iterations
# 2nd arg HOST
# 3rd PORT
# 4th USER
# 5th PASS
# 6th DB
EXEC_CREATE="${PATH_HDB_TCLSH} ${FILE_DRIVER} ${TOTAL_ITER} ${HOST} ${PORT} ${USER} ${PASS} ${DB}"

time eval "${EXEC_CREATE}"