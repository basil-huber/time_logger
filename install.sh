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

# create script for shutdown (in /etc/rc0.d/)
sudo echo -e "$shebang\n$script_command shutdown" > $shutdown_script
sudo chmod 755 $shutdown_script

# add call to file /etc/rc.local
if  ! grep -q ".*$script_name.*" $startup_script ; then
sudo awk -v text="$script_command startup" '!/^#/ && !p {print text; p=1} 1' "$startup_script" > tmp && sudo  mv tmp "$startup_script" # append after comments if not yet existing
else
sed -i -e "s@.*$script_name.*@$script_command startup@" $startup_script # replace if already exist
fi
sudo chmod 755 $startup_script

# create script for suspend/resume (in /etc/rc0.d/)
sudo echo -e "$shebang\n$script_command \$1" > $suspend_script
sudo chmod 755 $suspend_script

# create an alias
if ! grep -q "alias howlong=*" $alias_path ; then
sudo echo "alias howlong='$script_command info'" >> $alias_path # append at the end of file if not yet existing
else
sed -i -e "s@^alias howlong.*@alias howlong='$script_command info'@" $alias_path # replace if already existing
fi

# replace logger_path and hours_path in $script_command (time_logger.sh)
sed -i -e "s@^logger_path=.*@logger_path=$logger_path@" $script_command
sed -i -e "s@^hours_path=.*@hours_path=$hours_path@" $script_command
sudo chmod 755 $script_command

#execute startup
$script_command startup
