#/bin/bash
# EXPORT CLOUDFORMATION STACKS AND PARAMETERS
checkforjq(){
    command -v jq  > /dev/null 2>&1
    if [[ $? != 0 ]];then
        echo -e "jq not installed. Cannot continue."
        exit 1
    fi
}; checkforjq

checkprofile(){
    if [[ $AWS_PROFILE == "" ]]; then
        echo "NO AWS PROFILE CONFIGURED"; exit 1
    else echo -e "AWS Profile: $AWS_PROFILE\n"
    fi
};checkprofile

confirmdelete(){
    read -p "Do you want to delete and overwrite existing exports for this account ($accountid)? " -n 1 -r
    echo -e "\n"
    if [[ $REPLY =~ ^[Yy]$ ]]; then rm -rf $accountid; fi
}

exportstacks(){
    echo "  $R..."
    mkdir -p $accountid/$R > /dev/null 2>&1
    for S in \
        $(aws cloudformation list-stacks \
            --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --region $R \
            | jq -r .StackSummaries[].StackName); 
        do aws cloudformation describe-stacks \
            --stack-name $S --region $R > $accountid/$R/$S.json;
            jq '.Stacks[].Parameters' $accountid/$R/$S.json > $accountid/$R/$S.params.json
        done
}

getregions(){
    aws ec2 describe-regions \
        --query 'Regions[].RegionName' \
        --out text
}

counter(){
    echo -e "\nStacks Exported:"
    for D in $(ls -d $accountid/*/); 
    do C=$(find $D/. ! -name '*.params.json' -iname \*.json | wc -l) 
        if [[ $C -gt 0 ]]; then
        echo " $D: $C"
        fi
    done
}


start0=`date +%s`
accountid=$(aws sts get-caller-identity --query "Account" --out text)
end0=`date +%s`
confirmdelete
start=`date +%s`
alias=$(aws iam list-account-aliases --query "AccountAliases[0]" --out text)
if [[ $alias != "" ]]; then alias="($alias)"; fi
echo -e "Exporting CloudFromation stacks for account $accountid $alias\n Processing region $R..."
for R in $(getregions); do exportstacks; done
counter

end=`date +%s`

runtime=$((end0-start0+end-start))
echo -e "\nRun time: $runtime seconds."
