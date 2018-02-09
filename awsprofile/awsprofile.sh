#!/bin/bash
# - put awsprofile.sh in ~/.aws/ and add "alias awsprofile=". ~/.aws/awsprofile.sh" to .bash_profile

awsWhoami(){
	env | grep AWS
}
set_env () {
	echo -e "${NORMAL}\nUsing AWS profile ${RED}$AWS_DEFAULT_PROFILE${NORMAL} in region ${RED}$AWS_DEFAULT_REGION\n${NORMAL}"
}
set_shell_colours () { 
	NORMAL="[0;39m"; WARNING="[1;33m"; SECTION="[1;33m"; NOTICE="[1;33m"; OK="[1;32m"; BAD="[1;31m"; CYAN="[0;36m"; BLUE="[0;34m"; BROWN="[0;33m"; DARKGRAY="[0;30m"; GRAY="[0;37m"; GREEN="[1;32m"; MAGENTA="[1;35m"; PURPLE="[0;35m"; RED="[1;31m"; YELLOW="[1;33m"; WHITE="[1;37m" 
}; # set_shell_colours # uncomment if on mac
awsProfiles(){
	echo -e "\n${WHITE}AWS CLI Profiles:${NORMAL}\n"
	cat ~/.aws/config | grep "^\[profile " | grep ']' | awk '{print $NF}' | sed 's/]//' | sed 's/^/ /' | sed 's/\[//'
	# cat ~/.aws/config | grep ']' | awk '{print $NF}' | sed 's/]//' | sed 's/^/ /' | sed 's/\[//'
	echo "${NORMAL}"
} 

# HANDLE $1 ARGUMENTS
if [ "$1" = "" ]
	then 
		echo -e "${RED}Please specify profile name${NORMAL}:"
		awsProfiles
		set_env
else 
	if [ "$1" = "profiles" ] 
		then 
			awsProfiles			
		else 
			if [ "$1" = "whoami" ]; then set_env; 
			else
				unset AWS_DEFAULT_REGION
				unset AWS_DEFAULT_PROFILE
				export AWS_DEFAULT_PROFILE=$1
				export AWS_DEFAULT_REGION=eu-west-1
				set_env
			fi
	fi
fi

