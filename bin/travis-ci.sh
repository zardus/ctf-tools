#!/bin/bash -e

export EXPECTFAIL=${EXPECTFAIL:-0}

function flipstatus() {
    if [ $EXPECTFAIL -eq 0 ];
    then
	    echo $1
    else
	    case $1 in
		    FAILED)
			    echo SUCCEEDED
			    ;;
		    SUCCEEDED)
			    echo FAILED
			    ;;
		    *)
			    echo $1
			    ;;
	    esac
    fi
}

starttime=$SECONDS
failed=""
for t in $TOOL;
do
	set +e
	toolstarttime=$SECONDS
	echo "[-] TOOL $t TEST STARTED: $((SECONDS - starttime)) seconds since start of script."
	if ! docker run -e EXPECTFAIL="$EXPECTFAIL" -e TOOL="$t" --rm ctftools bash -ic 'manage-tools -s -f -v test $TOOL';
	then
		failed="$failed$t "
		echo "[ACCOUNTING]=====[ $DISTRO $t $(flipstatus FAILED) $((SECONDS - toolstarttime)) ]"
	else
		echo "[ACCOUNTING]=====[ $DISTRO $t $(flipstatus SUCCEEDED) $((SECONDS - toolstarttime)) ]"
	fi
	echo "[-] TOOL $t TEST ENDED: $((SECONDS - toolstarttime)) seconds, $((SECONDS - starttime)) seconds since start of script."
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

if [ "$EXPECTFAIL" -eq "1" ];
then
	echo "DONE: $totalcount tools failed as expected."
else
	echo "DONE: $totalcount tools succeeded as expected."
fi

exit 0
