#!/bin/bash
# Usage: source extract_latencies.bash
#        extract_latencies TESTS_DIR

function extract_latencies {
	if [ ${#} -ne 1 ]; then
		echo "Use as: extract_latencies measurements/[irqsoff|scheduling]/TESTS_DIR/"
		return 1
	else
		cat ${1}/{[1-9],10} | grep "latency:" | cut -d ' ' -f 3 | tr '\n' '\t'
		echo # keep an endline after tr replaces all
	fi
	return 0
}
