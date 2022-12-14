#!/bin/bash
# Usage: source extract_latency.bash
#        extract_latency TESTS_DIR

function extract_latency {
	if [ ${#} -ne 1 ]; then
		echo "Use as: extract_latencies measurements/scheduling-w/TESTS_DIR/"
		return 1
	else
		for FILE in $(ls ${1}); do # correct usage is assumed
			FILE=${1}/${FILE}
			TMP_FILE="_file"
			#echo "=> FICHERO: ${FILE}"
			if [ ! -z "$(cat ${FILE} | grep "RT task timings:")" ]; then
				#echo "|-> Removing the last lines of the file because it has RT statistics"
				# When trace is generated by a RT kernel, an extra statistics about RT tasks is added at the end of the file
				cat ${FILE} | head -n -6 > ${TMP_FILE}
			else
				cp ${FILE} ${TMP_FILE}
			fi
			echo -ne "$(cat ${TMP_FILE} | grep "Average wakeup latency:" | cut -d ' ' -f 4)"'\t'
			rm ${TMP_FILE}
		done
		echo # keep an endline after the last tab
	fi
	return 0
}
