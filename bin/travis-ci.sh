#!/bin/bash -e

export EXPECTFAIL=${EXPECTFAIL:-0}

failed=""
for t in $TOOL;
do
	set +e
	if ! docker run -e EXPECTFAIL="$EXPECTFAIL" -e TOOL="$t" --rm ctftools bash -ic 'manage-tools -s -f -v test $TOOL';
	then
		failed="$failed$t "
	fi
	set -e
done

if [ "$failed" != "" ];
then
	echo "==================================================="
	failcount=$(echo "$failed" | wc -w)
	totalcount=$(echo "$TOOL" | wc -w)
	if [ "$EXPECTFAIL" -eq "1" ];
	then
		echo "ERROR: $failcount/$totalcount tools succeeded while they were expected to fail: $failed"
	else
		echo "ERROR: $failcount/$totalcount tools failed while they should have succeeded: $failed"
	fi
	echo "==================================================="
	exit 1
fi
exit 0
