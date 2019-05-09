# CF Stack Scripts

## cfstackexport.sh

Export cloudformation stacks from all regions. Output to folder structure `$accountid/$region/stackname.json`.

Also times execution (this may eventually end up in a lambda function, so I needed to get an indication of how long it runs).

### to do:

 - [ ] also export parameters into a format ready-ish for redeployment
