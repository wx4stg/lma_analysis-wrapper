# lma_analysis-wrapper

Automates `lma_analysis` execution for events longer than 10 minutes

Usage:
`lma_analysis-wrapper.sh --starttime <start time> --endtime <end time> --input <input directory> <ARGS FOR LMA_ANALYSIS GO HERE>`

start time and end time are formatted as "YYYYMMDDHHMM" using 24-hour UTC time

Arguments after input directory and start/end time will be passed directly to `lma_analysis`

**Important:** do not include -d, -t, -s. They will be filled for you.

**Important:** start/end time and input directory can be listed in any order, but they MUST come before any additional arguments to be passed to lma_analysis

## Example:

`lma_analysis-wrapper.sh --starttime 202104080000 --endtime 202104092359 --input ~/lightningin -l /home/lma_admin/lma/loc/hlma.loc --decimate 80 -o ~/lightningout/`

- start time is 8 April 2021 at 0z
- end time is 9 April 2021 at 2359z
- .dat files located in ~/lightningin (the input directory will be recursively searched for .dat files, so `.dat`s in ~/lightningin/a/, ~/lightningin/b/, ~/lightningin/0/, etc. will also be included in the analysis)
- the -l, --decimate, and -o args are passed to lma_analysis