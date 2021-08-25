#!/bin/bash
# Wrapper for lma_analysis to automate long timeframe data processing into source .dat.gz files
# Created 24 August 2021 by Sam Gardner <stgardner4@tamu.edu>

if type -P lma_analysis &> /dev/null
then
    lma_analysis_path=`(type -P lma_analysis)`
else
    if [ -x /home/lma_admin/lma_analysis ]
    then
        lma_analysis_path=/home/lma_admin/lma_analysis
    else
        echo "lma_analysis binary not found, please place it in PATH or /home/lma_admin/lma_analysis"
    fi
fi
echo "Found lma_analysis at $lma_analysis_path"

countOfArgs=$#
for arg in "$@"
do
    if [ $arg == "--help" ]
    then
        echo "Usage: lma_analysis-wrapper.sh --input --starttime <start time> --endtime <end time> <lma_analysis arguments>"
        echo "<start time> and <end time> formatted as YYYYMMDDHHMM using 24-hour UTC format"
        echo "202108241230 is equal to 12:30 UTC on August 24, 2021"
        echo "Any arguments provided after the start time, and end time will be passed directly to lma_analysis. Do not include -d, -t, -s, or an input file here, they will be automatically handled for you."
        echo "IMPORTANT: start time and end time are required and MUST be the first arguments provided. lma_analysis arguments MUST be provided afterwards."
        exit
    fi
done
origArgs=("$@")
for (( i=0; i<$#; i++ ))
do
    thisArg=${origArgs[$i]}
    if [ "$thisArg" == "--starttime" ]
    then
        targetIdx=$(($i + 1))
        starttime=${origArgs[$targetIdx]}
    elif [ "$thisArg" == "--endtime" ]
    then
        targetIdx=$(($i + 1))
        endtime=${origArgs[$targetIdx]}
    elif [ "$thisArg" == "--input" ]
    then
        targetIdx=$(($i + 1))
        inputPath=${origArgs[$targetIdx]}
    fi
done
if [ -z "$starttime" ]
then
    echo "Start time not found, please specify."
    exit
fi
if [ -z "$endtime" ]
then
    echo "End time not found, please specify."
    exit
fi
if [ -z "$inputPath" ]
then
    echo "Input not found, please specify."
    exit
fi
output=(`python3 <<END
from datetime import datetime as dt
from datetime import timedelta

startdt = dt.strptime("$starttime", "%Y%m%d%H%M")
workingdt = startdt
enddt = dt.strptime("$endtime", "%Y%m%d%H%M")
print(startdt.strftime("%Y%m%d%H%M"))
while workingdt < enddt:
    workingdt = workingdt + timedelta(minutes=10)
    if workingdt < enddt:
        print(workingdt.strftime("%Y%m%d%H%M"))
END`)
echo "Copying input files..."
shopt -s globstar
mkdir lma_analysis_input.tmp/
cp $inputPath/**/*.dat lma_analysis_input.tmp/
shift 6
echo $@
for time in "${output[@]}"
do
    $lma_analysis_path -d ${time:0:8} -t ${time:8:12} -s 600 $@ lma_analysis_input.tmp/L*{time:2:6}_${time:8:12}00.dat
done
echo "Cleaning up..."
rm -rf lma_analysis_input.tmp
exit 0
