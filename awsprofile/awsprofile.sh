#!/bin/bash
# Put awsprofile.sh in ~/.aws/ and add "alias awsprofile=". ~/.aws/awsprofile.sh" to .bash_profile
export DEFAULT_REGION=eu-west-1

awsWhoami(){ env | grep AWS ;}
echo_env () { echo -e "${NORMAL}\nUsing AWS profile ${RED}$AWS_DEFAULT_PROFILE${NORMAL} in region ${RED}$AWS_DEFAULT_REGION\n${NORMAL}";}
#set_shell_colours () { NORMAL="^[[0;39m"; RED="^[[1;31m"; WHITE="^[[1;37m" ;}; # set_shell_colours # uncomment if on mac
awsProfiles(){ echo -e "\n${WHITE}AWS CLI Profiles:${NORMAL}\n"
    #cat ~/.aws/config | grep "^\[" | grep ']' | grep -v '@' | awk '{print $NF}' | sed 's/]//' | sed 's/^/ /' | sed 's/\[//'
    cat ~/.aws/config | grep "^\[" | grep ']' | awk '{print $NF}' | sed 's/]//' | sed 's/^/ /' | sed 's/\[//'
    echo "${NORMAL}";
}

if [ "$1" = "" ] # HANDLE ARGUMENTS
    then
        echo -e "${RED}Please specify profile name${NORMAL}:"
        awsProfiles
        echo_env
else
    if [ "$1" = "profiles" ]
        then
            awsProfiles
        else
            if [ "$1" = "whoami" ]; then echo_env;
            else
            if [ "$2" != "" ]
                then echo Setting region to $2; export DEFAULT_REGION=$2 ; fi
                unset AWS_DEFAULT_REGION
                unset AWS_DEFAULT_PROFILE
                export AWS_DEFAULT_PROFILE=$1
                export AWS_PROFILE=$1
                export AWS_DEFAULT_REGION=$DEFAULT_REGION
                export AWS_REGION=$DEFAULT_REGION
                echo_env
            fi
    fi
fi
