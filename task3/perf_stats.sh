#!/bin/bash

set -e

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

perf stat \
-B -r ${runs} --no-big-num \
-e L1-dcache-load-misses -e L1-dcache-loads \
-e L1-icache-load-misses -e duration_time -e cache-misses \
-o /tmp/output.${model} ${command} &>/dev/null

dcachem=$(grep "L1-dcache-load-misses" /tmp/output.${model} | awk '{print $1}' | tr -d ".")
dcachem_per=$(grep "L1-dcache-load-misses" /tmp/output.${model} | awk '{print $4}' | tr -d ".")
dcachel=$(grep "L1-dcache-loads" /tmp/output.${model} | awk '{print $1}' | tr -d ".")
icachem=$(grep "L1-icache-load-misses" /tmp/output.${model} | awk '{print $1}' | tr -d ".")
duration=$(grep "duration_time" /tmp/output.${model} | awk '{print $1}' | tr -d ".")
time_unit=$(grep "duration_time" /tmp/output.${model} | awk '{print $2}' | tr -d ".")
caches=$(grep "cache-misses" /tmp/output.${model} | awk '{print $1}' | tr -d ".")

printf "{ \"model\": \"${model}\" , \"data\": { \"L1-dcache-load-misses\": %s, \
\"percent_L1_accesses\": \"%s\", \"L1-dcache-loads\": %s, \"L1-icache-load-misses\": %s, \
\"duration_time\": %s , \"time_unit\": \"%s\" ,\"cache-misses\": %s }}" \
"${dcachem}" "${dcachem_per}" "${dcachel}" "${icachem}" "${duration}" "${time_unit}" "${caches}"

echo -e "\n"

