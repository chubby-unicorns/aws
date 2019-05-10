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
            --stack-name $S --region $R > $accountid/$R/$S.describe.json;
            jq '.Stacks[].Parameters' $accountid/$R/$S.describe.json > $accountid/$R/$S.params.json
            aws cloudformation get-template --stack-name $S  --region $R --query TemplateBody | jq -r . > $accountid/$R/$S.template  # jq -r doesn't do much to json templates, but unpacks yaml properly. *.template could be yaml or json. 
            if [[ $(head -c 1 $accountid/$R/$S.template) == "{" ]]; then
                mv $accountid/$R/$S.template $accountid/$R/$S.json
            else
                mv $accountid/$R/$S.template $accountid/$R/$S.yaml
            fi
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

zipall(){
    command -v zip  > /dev/null 2>&1
    if [[ $? != 0 ]];then
        echo -e "zip not installed. Cannot create archive."
        exit 1
    fi
    echo -e "\nCreating archive $accountid-$NOW.zip"
    zip --quiet -r $accountid-$NOW.zip $accountid/
}

zipold(){
    command -v zip  > /dev/null 2>&1
    if [[ $? != 0 ]];then
        echo -e "zip not installed. Cannot create archive."
        exit 1
    fi
    echo -e "Creating archive of existing output: $accountid-pre$NOW.zip"
    zip --quiet -r $accountid-pre$NOW.zip $accountid/
}

NOW=$(date -d "today" +"%Y%m%d-%H%M")
start0=`date +%s`
accountid=$(aws sts get-caller-identity --query "Account" --out text)
end0=`date +%s`

if [[ -d $accountid ]];then
    zipold
    confirmdelete
fi
start=`date +%s`
alias=$(aws iam list-account-aliases --query "AccountAliases[0]" --out text)
if [[ $alias != "" ]]; then alias="($alias)"; fi
echo -e "Exporting CloudFromation stacks for account $accountid $alias\n Processing region $R..."
for R in $(getregions); do exportstacks; done
counter
zipall
end=`date +%s`

runtime=$((end0-start0+end-start))
echo -e "\nRun time: $runtime seconds."
