# CF Stack Scripts

## cfstackexport.sh

Export cloudformation stacks from all regions. Output to folder structure `$accountid/$region/stackname.json`.

Also times execution (this may eventually end up in a lambda function, so I needed to get an indication of how long it runs).

###

```text
huevos@PF0Z9M0A:~/code/cfstacks$ ./cfstackexport.sh
AWS Profile: acmecorp.huevos.audit

Do you want to delete and overwrite existing exports for this account (112233445566)? y

Exporting CloudFromation stacks for account 112233445566 (acmecorpprod)
 Processing region ...
  eu-north-1...
  ap-south-1...
  eu-west-3...
  eu-west-2...
  eu-west-1...
  ap-northeast-2...
  ap-northeast-1...
  sa-east-1...
  ca-central-1...
  ap-southeast-1...
  ap-southeast-2...
  eu-central-1...
  us-east-1...
  us-east-2...
  us-west-1...
  us-west-2...

Stacks Exported:
 112233445566/eu-west-1/: 14
 112233445566/us-east-1/: 1

Run time: 64 seconds.
```

Output tree:

```text
huevos@PF0Z9M0A:~/code/cfstacks/112233445566$ tree
.
├── ap-northeast-1
├── ap-northeast-2
├── ap-south-1
├── ap-southeast-1
├── ap-southeast-2
├── ca-central-1
├── eu-central-1
├── eu-north-1
├── eu-west-1
│   ├── iamtest.json
│   ├── iotrules.json
│   ├── keyrotation.json
│   ├── SC-112233445566-pp-rspku4yrrnv4o.json
│   ├── sc-portfolio-workspaces.json
│   ├── sc-product-workspace-dataanalyst.json
│   ├── sc-product-workspace-imaging.json
│   ├── sc-product-workspace-training.json
│   ├── sc-s3-bucket-set.json
│   ├── serverlessrepo-ALB-Test.json
│   ├── simplead.json
│   ├── acctFundamentals.json
│   ├── stalesgs.json
│   └── vpc.json
├── eu-west-2
├── eu-west-3
├── sa-east-1
├── us-east-1
│   └── dashbird-integration-stack.json
├── us-east-2
├── us-west-1
└── us-west-2

16 directories, 15 files

```

### to do:

 - [ ] also export parameters into a format ready-ish for redeployment
