#!/usr/bin/env bash

shutdown_script="/etc/rc0.d/K99_time_logger_shutdown"
startup_script="/etc/rc.local"
suspend_script="/etc/pm/sleep.d/K99_time_logger_suspend"
alias_path="${HOME}/.bash_aliases"
script_name="time_logger.sh"
script_path=`pwd`
shebang="#!/usr/bin/env bash"
script_command="$script_path/$script_name"
logger_path="$script_path/time_log"
hours_path="$script_path/working_hours"

# remove script for shutdown (in /etc/rc0.d/)
sudo rm -f $shutdown_script

# add call to file /etc/rc.local
sed -i "/.*$script_name.*/d" $startup_script # remove line

# remove script for suspend/resume (in /etc/rc.local/)
sudo rm -f $suspend_script

# remove alias
sed -i "/^alias howlong.*/d" $alias_path # replace if already existing

# remove whole folder
#cd ../
#rm -rf $script_path


echo "Everything removed"
