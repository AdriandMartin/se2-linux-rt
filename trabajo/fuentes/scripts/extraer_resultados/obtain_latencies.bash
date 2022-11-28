#!/bin/bash
# Usage: source obtain_latencies.bash
#        obtain_latencies TESTS_DIR

function obtain_latencies {
	if [ ${#} -ne 1 ]; then
		echo "Use as: obtain_latencies measurements/syscalls/TESTS_DIR/"
		return 1
	else
        INVOCATION_PATTERN=': sys_write(fd:'
        RETURN_PATTERN=': sys_write ->'
        for FILE in $(ls ${1}); do # correct usage is assumed
            PROCESSES=$(cut -f 1 -d ' ' ${1}/${FILE} | tr -d "stress\-n\-" | sort | uniq | sed '/^$/d')
            #echo "=> PROCESOS: ${PROCESSES}"
            LATENCIES=(); COUNT=0
            #echo "=> FICHERO: ${FILE}"
            for PROCESS in ${PROCESSES}; do
                # Parsing phase
                INVOCATION_TIMESTAMP=""
                PARSING_STATUS="I" # awaiting for invocation trace, I, or return trace, R
                #echo "==> PROCESO: ${PROCESS}"
                while read LINE; do
                    #echo "---> LINEA: ${LINE}"
                    case ${PARSING_STATUS} in
                        "I")
                            if [ ! -z "$(echo ${LINE} | grep "${INVOCATION_PATTERN}")" ]; then
                                INVOCATION_TIMESTAMP=$(echo ${LINE} | cut -d ' ' -f 3 | tr -d 'us+!:')
                                PARSING_STATUS="R" # parsing status changes to awaiting for return trace
                                #echo "|--> nuevo_estado: ${PARSING_STATUS}; invocation_timestamp: ${INVOCATION_TIMESTAMP}"
                            fi # else, remain in awaiting for invocation trace status
                            ;;
                        "R")
                            if [ ! -z "$(echo ${LINE} | grep "${RETURN_PATTERN}")" ]; then
                                RETURN_TIMESTAMP=$(echo ${LINE} | cut -d ' ' -f 3 | tr -d 'us+!:')
                                LATENCIES[${COUNT}]=$((${RETURN_TIMESTAMP} - ${INVOCATION_TIMESTAMP}))
                                COUNT=$((${COUNT} + 1))
                                PARSING_STATUS="I" # parsing status changes to awaiting for invocation trace
                                #echo -n -e ${LATENCIES[$((${COUNT}-1))]}'\t'
                            fi # else, remain in awaiting for return trace status
                            ;;
                    esac
                done < <(grep "stress-n-${PROCESS}" "${1}/${FILE}") # thanks to https://stackoverflow.com/a/31878979
                #echo; echo "-----------------------------------------"
            done
            # Average calculation
            AVERAGE="0"
            for LATENCY in ${LATENCIES[@]}; do
                #echo -n -e ${LATENCY}'\t'
                AVERAGE=$((${AVERAGE} + ${LATENCY}))
            done
            #echo; echo "Average measure for file ${FILE} is: ${AVERAGE} / ${COUNT}"
            AVERAGE=$((${AVERAGE} / ${COUNT}))
            # Print the result
            echo -n -e ${AVERAGE}'\t'
            #echo; echo "------------------------------------------------------------"
        done
    fi
    echo # print an endline after while loop
	return 0
}
