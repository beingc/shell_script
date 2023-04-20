#!/usr/bin/env bash
# Date: 2022-05-01
# Desc: monitor host resource usage

# CONFIG START
TIME_INTERVAL=5
LOG_PATH="${HOME}/logs"
DISK_PATH="/"
# CONFIG END

CUT_TIME="00:00:00"
LOG_FILE="${LOG_PATH}/mon.log"
PID_FILE="${LOG_PATH}/.mon_pid"

log_echo()
{
    log_text=$1
    datetime=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$datetime,$log_text"
}

log_to_file()
{
    log_text=$1
    datetime=$(date +'%Y-%m-%d %H:%M:%S')
    time_str=$(echo "$datetime" | cut -c 12-20)
    if [ "${time_str}x" = "${CUT_TIME}x" ]; then
        date_str=$(echo "$datetime" | cut -c 1-10)
        mv "${LOG_FILE}" "${LOG_FILE}"_"${date_str}"
    fi
    echo "$datetime,$log_text" >> "${LOG_FILE}"
}

get_cpu_usage()
{
# CPU_TIME=user+system+nice+idle+iowait+irq+softirq
# cpu_usage=(idle2-idle1)/(cpu2-cpu1)*100

LAST_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
LAST_SYS_IDLE=$(echo "$LAST_CPU_INFO" | awk '{print $4}')
LAST_TOTAL_CPU_T=$(echo "$LAST_CPU_INFO" | awk '{print $1+$2+$3+$4+$5+$6+$7}')

sleep ${TIME_INTERVAL}

NEXT_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
NEXT_SYS_IDLE=$(echo "$NEXT_CPU_INFO" | awk '{print $4}')
NEXT_TOTAL_CPU_T=$(echo "$NEXT_CPU_INFO" | awk '{print $1+$2+$3+$4+$5+$6+$7}')

SYSTEM_IDLE=$(echo "${NEXT_SYS_IDLE}" "${LAST_SYS_IDLE}" | awk '{print $1-$2}')
TOTAL_TIME=$(echo "${NEXT_TOTAL_CPU_T}" "${LAST_TOTAL_CPU_T}" | awk '{print $1-$2}')
CPU_USAGE=$(echo "${SYSTEM_IDLE}" "${TOTAL_TIME}" | awk '{printf "%.2f%", 100-$1/$2*100}')

echo "${CPU_USAGE}"
}

get_mem_usage()
{
    used_mem=$(free -m| awk 'NR==2{print $3}')
    total_mem=$(free -m| awk 'NR==2{print $2}')
    MEM_USAGE=$(echo "$used_mem" "$total_mem" | awk '{printf "%.2f%",$1/$2*100}')
    echo "$used_mem/$total_mem($MEM_USAGE)"
}

get_disk_usage()
{
    [ "$DISK_PATH" = "" ] && DISK_PATH=$(pwd)
    disk_usage=$(df -h | awk -v path="${DISK_PATH}" '$NF==path{printf "%s/%s(%.0f%%)\n", $3,$2,$5}')
    echo "$disk_usage"
}

mon_res()
{
log_to_file "$(get_cpu_usage)","$(get_mem_usage)","$(get_disk_usage)"
}

start_mon()
{
    while true
    do
        mon_res
    done
}

stop_mon()
{
    if [ -e "${PID_FILE}" ]; then
        pid=$(cat "${PID_FILE}")
        kill -9 "$pid"
        [ $? -eq 0 ] && log_echo "script stop success"
        rm "${PID_FILE}"
    else
        log_echo "pid file not exist, maybe the script not start"
    fi
}

echo_usage()
{
    echo "Usage:"
    echo "    $0 start"
    echo "    $0 stop"
}

main()
{
    if test ! -e "${LOG_PATH}"; then
        mkdir -p "${LOG_PATH}"
    fi

    input=$@
    case "$input" in
        start)
            start_mon &
            echo $! > "${PID_FILE}"
            ;;
        stop)
            stop_mon
            ;;
        *)
            echo_usage
            exit 1
    esac
}

main $@
