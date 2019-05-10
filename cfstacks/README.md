# CF Stack Scripts

## cfstackexport.sh

Results in 3 output files, in a folder structure starting with `accountid`, then `region`:

1. Export cloudformation stacks from all regions. Output to folder structure `$accountid/$region/stackname.describe.json`.
2. Parameters are extracted into json parameter file. `$accountid/$region/stackname.params.json`.
3. The stack template is exported to `$accountid/$region/stackname.[json|yaml]`

*It also times execution (this may eventually end up in a lambda function, so I needed to get an indication of how long it runs).*

### Prerequisites

1. iam user &/ role that has read access to cloudformation
2. aws cli
3. jq

### Example output

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
 112233445566/eu-west-1/: 2
 112233445566/us-east-1/: 1

Run time: 23 seconds.
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
│   ├── iamtest.describe.json
│   ├── iamtest.yaml
│   ├── iamtest.params.json
│   └── vpc.describe.json
│   └── vpc.json
│   └── vpc.params.json
├── eu-west-2
├── eu-west-3
├── sa-east-1
├── us-east-1
│   └── dashbird-integration-stack.describe.json
│   └── dashbird-integration-stack.json
│   └── dashbird-integration-stack.params.json
├── us-east-2
├── us-west-1
└── us-west-2

16 directories, 9 files
```
## Oddities

### Service Catalog-deployed stack templates
***Service Catalog-deployed stack templates*** have values explicitly stated as `!!bool` or `!!int` *(the original template used for SC did not)*:

```yaml
    'AllowedValues':
    - !!bool 'true'
```

and 

```yaml
    'AllowedValues':
    - !!int '32'
```

### Stacks with no parameters

***Stacks with no parameters*** - the exported `*.params.json` file will have the value `null` on the first line.
