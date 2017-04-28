# Lambda functions for tagging and snapshot creation

***Source:*** Mike Lapidakis' post [Tagging and Snapshotting in AWS with Lambda](https://mike.lapidak.is/thoughts/tagging-and-snapshotting-with-lambda)

In both of these functions I've adjusted `ec2 = boto3.resource` to use the current region instead of hardcoding e.g. `us-west-2`.

The templates create the IAM Role and Trust, plus a trigger for each.

## ebs-lapidakis

I split Mike's [EC2-Snapshot-Lambda.py function](https://gist.github.com/mlapida/770aba3ad3be76f6b31f#file-ec2-snapshot-lambda-py) in two, because the EBS snapshot creation part takes up to 40 seconds (with nearly 0 snapshots - so who knows how long it would take it I had plenty).

I've also added a filter to only snapshot volumes with `tag:Backup` with a value of [true|True|yes|Yes]

**ebs-lapidakis-snapshot.py**
**ebs-lapidakis-snapshot-cleanup.py**

## tag-lapidakis

Pretty much like the original [EC2-Tag-Assets-Lambda.py](https://gist.github.com/mlapida/931c03cce1e9e43f147b#file-ec2-tag-assets-lambda-py).