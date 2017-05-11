function log_any()
{
    level="$1"
    msg="$2"
    >&2 echo "$(date) [${level}]: ${msg}"
}

function log_info()
{
    log_any "INFO" "$1"
}

function log_debug()
{
    log_any "DEBUG" "$1"

}

function log_error()
{
    log_any "ERROR" "$1"
}