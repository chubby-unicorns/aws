# awsprofile

## Purpose
Set the AWS CLI profile you want to use, removing the need to use `--profile [profilename] --region [region]`. 
It sets the `AWS_DEFAULT_REGION` and `AWS_DEFAULT_PROFILE` variables for the current session.

It will also list the profiles you have configured in `~/.aws/config`.

## Requirements

* bash (i.e. Mac/Linux, or using git bash in Windows)
* aws cli installed and configured

## Configuration
1. copy `awsprofile.sh` into ~/.aws/
2. add `alias awsprofile=". ~/.aws/awsprofile.sh"` to your `~/.bash_profile` _(this needs to be launched using the precending ". " to export the set vars into the terminal session, hence not just launching awsprofile.sh directly)_
3. open a new terminal and run `awsprofile`

## Usage

### awsprofile

Shows current profile as well as the list of configured profiles

```
$ awsprofile
Please specify profile name:

AWS CLI Profiles:

 personal1
 personal2
 id-local
 id-acct
 awsproduction1
 awssandbox1

Using AWS profile awssandbox1 in region eu-west-1

```

### awsprofile profiles

Shows just the list of profiles

```
$ awsprofile profiles

AWS CLI Profiles:

 personal1
 personal2
 id-local
 id-acct
 awsproduction1
 awssandbox1

```

### awsprofile _[profilename]_

Sets the current profile _(it doesn't check whether it's a valid profile!)_

```
$ awsprofile awsproduction1

Using AWS profile awsproduction1 in region eu-west-1

$
```
