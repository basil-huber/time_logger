#!/usr/bin/env bash
# script to log boot and shutdown time
hours_path=/home/basil/time_logger/working_hours
logger_path=/home/basil/time_logger/time_log

function printTime {
echo "$(($1/3600)) hours $((($1/60) % 60)) minutes" 
}

function dateEn {
LC_ALL=de_DE.utf8 date
}

# ---------------------------------
#         start of script
# ---------------------------------

dayCount=20
targetDurationDay=29520 # seconds per day

# get last entry in time_log and parse it
if [ -e "$logger_path" ]; then
IFS=';' read -ra ADDR <<< "`tail -1 $logger_path`"
lastDate=${ADDR[0]}
lastAction=${ADDR[1]}
fi

# get last entry in working_hours
if [ -e "$hours_path" ]; then
IFS=';' read -ra lastEntryArr <<< "`tail -1 $hours_path`"
lastDate2J=`date -d "${lastEntryArr[0]}" +%j`
todayJ=`date +%j`
lastDuration=${lastEntryArr[1]}
else
lastDuration=0
fi


# -----------------------------------
#           startup/resume
# -----------------------------------

if ([ "$1" == "startup" ] || [ "$1" == "resume" ]) && ([ "$lastAction" == " shutdown" ] || [ "$lastAction" == " suspend" ] || [ "$lastAction" == "" ]); then
echo "$(dateEn); $1; "  >> $logger_path

# -----------------------------------
#         shutdown/suspend 
# -----------------------------------
elif [ "$1" == "shutdown" ] || [ "$1" == "suspend" ]; then
duration=$((`date +%s` - `date -d "$lastDate" +%s`))

# print duration of current session
echo -n "$(dateEn); $1; " >> $logger_path
printTime $duration >> $logger_path

#if there is already an entry in $working_hours_path for today, add the time and erase the entry
if [ -e "$hours_path" ] && [ "$lastDate2J" == "$todayJ" ]; then # compare days in year of today and last entry
duration=$(($duration + $lastDuration)) # sum duration
sed -i '$ d' $hours_path
fi

echo -n "$(dateEn);$duration; " >> $hours_path
printTime $duration >> $hours_path

# -----------------------------------
#            info
# -----------------------------------
elif [ "$1" == "info" ]; then
durationSession=$((`date +%s` - `date -d "$lastDate" +%s`))
#if there is already an entry in $working_hours_path for today, add the time
if [ -e "$hours_path" ] && [ "$lastDate2J" == "$todayJ" ]; then # compare days in year of today and last entry
durationDay=$(($durationSession + $lastDuration)) # sum duration
todaySession=1
else
durationDay=durationSession
todaySession=0
fi
# get penultimate entry in $logger_path to calc break duration
IFS=';' read -ra penulEntry <<< "`tail -n 2 $logger_path | head -n 1`"
durationBreak=$((`date -d "$lastDate" +%s` - `date -d "${penulEntry[0]}" +%s`))

# calc daily average
if [ -e "$hours_path" ]; then
lineCount=`wc -l < "$hours_path"`
sum=0
avgDuration=0
if [ $lineCount -lt $dayCount ]; then
dayCount=$(($lineCount - $todaySession))
fi
if [ $dayCount -gt 0 ]; then
lines=`tail -n $(($dayCount + $todaySession)) $hours_path | head -n $dayCount`
while read line; do
IFS=';' read -ra entry <<< "$line"
sum=$(($sum + ${entry[1]}))
done < <(echo -e "$lines")
avgDuration=$(($sum / $dayCount))
fi
else
avgDuration=0
dayCount=0
fi

echo "------------------------------------------"
echo -n    "  duration of this session:  "
printTime $durationSession
echo -en "\n  duration for today:        "
printTime $durationDay
echo -en "\n  duration of last break:    "
printTime $durationBreak
echo -en "\n  time until quitting time:  "
printTime $(($targetDurationDay - $durationDay))
echo -en "\n  Average time in $dayCount days:    "
printTime $avgDuration
echo -e  "  (Today not included)"
echo -en "\n\n  for a complete list of hours per day consult:               $hours_path"
echo -e    "\n  for a complete list of all session starts and ends consult: $logger_path"
echo "------------------------------------------"

fi

# this is philipps comment
