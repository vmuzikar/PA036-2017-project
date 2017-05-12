PATH_TCL="${BASE_DIR}/scripts/tcl"
FILE_DRIVER="${PATH_TCL}/driver.1.tcl"
FILE_DRIVER_OUT="${PATH_TCL}/driver.out.tcl"
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

#EXEC_CREATE="${PATH_HDB_TCLSH} ${FILE_DRIVER} ${TOTAL_ITER} ${HOST} ${PORT} ${USER} ${PASS} ${DB}"

#time eval "${EXEC_CREATE}"

envsubst < "${FILE_DRIVER}" > "${FILE_DRIVER_OUT}"