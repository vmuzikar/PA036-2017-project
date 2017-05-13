function crt_driver_out() {
        PATH_TCL="${BASE_DIR}/scripts/tcl"
        FILE_DRIVER="${PATH_TCL}/driver.1.tcl"
        FILE_DRIVER_OUT="${PATH_TCL}/driver.out.tcl"
        TOTAL_ITER=${TOTAL_ITERATIONS}
        USER=${DB_USER}
        PASS=${DB_USER_PASS}
        DB=${DB_NAME}

        envsubst < "${FILE_DRIVER}" > "${FILE_DRIVER_OUT}"
}

crt_driver_out

SEQ1="4 6 8 10"
SEQ2="12 14 16 18"
SEQ3="20 22 24 26"
CONFIGFILE=${PATH_AUTO_CONFIG}
SCRIPT_FILE=${FILE_DRIVER} # No idea what is this!
RUNS=6

for x in $(eval echo "{1..$RUNS}")
do
        # Running a number of passes for this autopilot sequence
        echo "running run $x of $RUNS"

        for s in "$SEQ1" "$SEQ2" "$SEQ3"
        do
                echo "Running tests for series: $s"
                sed -i "s/<autopilot_sequence>.*<\/autopilot_sequence>/<autopilot_sequence>${s}<\/autopilot_sequence>/" $CONFIGFILE

                #(cd /usr/local/hammerDB/ && ./hammerdb.tcl auto TPCC.postgres.tcl)
                set -x
                ${PATH_HAMMERDB}/hammerdb.tcl auto "${FILE_DRIVER_OUT}"
                set +x
                        
                #echo "Reloading data"
                #ssh postgres@postgres  '/var/lib/pgsql/reloadData.sh'
        done
done