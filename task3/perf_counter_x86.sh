#!/bin/bash

set -x

runs="${runs:-10}"
unset model

while [ $# -gt 0 ]
do
	if [ "${1}" == "-n" ]; then
		shift
		runs="$1"
		shift
	else
		model="${1}"
		shift
	fi
done

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
command="${DIR}/../work/models/${model}/bin/main.x"
datasets="${DIR}/../work/datasets/"

if [ "$model" == "mnist" ] || [ "$model" == "lenet" ]
then
  command="${command} ${datasets}/mnist/mnist*.png"
else
  command="${command} ${datasets}/imagenet/val*.png"
fi

printf "\n{ \"model\": \"%s\"," "${model}"
printf "\n \"data\": ["
perf stat \
-B -r ${runs} \
-e L1-dcache-load-misses -e L1-dcache-loads \
-e L1-icache-load-misses -e duration_time -e cache-misses \
${command} 2>&1 | \
	while IFS= read -r line
	do
		[[ "$line" =~ "L1-dcache-load-misses" ]] && \
			dcachem=$(echo $line | grep "L1-dcache-load-misses" | awk '{print $1}')
		[[ "$line" =~ "L1-dcache-loads" ]] && \
			dcachel=$(echo $line | grep "L1-dcache-loads" | awk '{print $1}')
		[[ "$line" =~ "L1-icache-load-misses" ]] && \
			icachem=$(echo $line | grep "L1-icache-load-misses" | awk '{print $1}')
		[[ "$line" =~ "duration_time" ]] && \
			duration=$(echo $line | grep "duration_time" | awk '{print $1}')
		[[ "$line" =~ "cache-misses" ]] && \
			caches=$(echo $line | grep "cache-misses" | awk '{print $1}')
	done
	printf "{ \"\": %s, \"\": %s, \"\": %s, \"\": %s , \"\": %s}" \
		"${dcachem}" "${dcachel}" "${icachem}" "${duration}" "${caches}"
printf "] }\n"

# fix using vim %s;\(\d*\)\.\(\d\d\d\)\.\(\d\d\);\1\2.\3;g
