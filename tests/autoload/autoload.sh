PATH_TCL="${BASE_DIR}/scripts/tcl"
FILE_DRIVER="${PATH_TCL}/driver.1.tcl"
FILE_DRIVER_OUT="${PATH_TCL}/driver.out.tcl"
FILE_TEMPLATE_XML="${BASE_DIR}/config/config_HammerDB_template.xml"

function crt_driver_out() 
{
        PARAMS='${TOTAL_ITERATIONS} ${HOST} ${PORT} ${DB_USER} ${DB_USER_PASS} ${DB_NAME}'     
        envsubst "$PARAMS" < "${FILE_DRIVER}" > "${FILE_DRIVER_OUT}"
}

function copy_template_xml() 
{
        cp "$FILE_TEMPLATE_XML" "${PATH_HAMMERDB}/config.xml"
}

crt_driver_out
copy_template_xml

SEQ1="2 3"
#SEQ2="12 14 16 18"
#SEQ3="20 22 24 26"
CONFIGFILE=${PATH_AUTO_CONFIG}
RUNS=1

for x in $(eval echo "{1..$RUNS}")
do
        # Running a number of passes for this autopilot sequence
        echo "running run $x of $RUNS"

        for s in "$SEQ1" #"$SEQ2" "$SEQ3"
        do
                echo "Running tests for series: $s"
                sed -i "s/<autopilot_sequence>.*<\/autopilot_sequence>/<autopilot_sequence>${s}<\/autopilot_sequence>/" $CONFIGFILE

                OLD_PATH=`pwd`
                #(cd /usr/local/hammerDB/ && ./hammerdb.tcl auto TPCC.postgres.tcl)
                cd "${PATH_HAMMERDB}"
                set -x
                ${PATH_HAMMERDB}/hammerdb.tcl auto "${FILE_DRIVER_OUT}"
                set +x
                cd "${OLD_PATH}"

                        
                #echo "Reloading data"
                #ssh postgres@postgres  '/var/lib/pgsql/reloadData.sh'
        done
done
