#!/usr/bin/env python

import binpacking, sys, pprint

MAXBINDURATION = 2000 # seconds

def parseOutput(fn):
    lines = [l.strip() for l in open(fn).readlines()]
    out = {}

    for l in lines:
	    [distro, tool, success, duration] = l.split(" ")
	    if not distro in out:
		out[distro] = {}
	    out[distro][tool] = {
		"success": success == "SUCCEEDED",
		"duration": int(duration)
	    }
    return out

def printBins(timingdata, distro, expectfail):
    inputs = dict([(t, v["duration"]) for (t, v) in timingdata[distro].items() if v["success"] != expectfail])
    bins = binpacking.to_constant_volume(inputs, MAXBINDURATION)

    for b in bins:
	tools = " ".join(sorted(b.keys()))
	duration = sum(b.values())
	if expectfail:
		print("- DISTRO='{}' EXPECTFAIL=1 TOOL='{}' # estimated {} seconds".format(distro, tools, duration))
	else:
		print("- DISTRO='{}' TOOL='{}' # estimated {} seconds".format(distro, tools, duration))

def getToolsFromTimingdata(timingdata):
    out = {}
    for d, dd in timingdata.items():
        for t, td in dd.items():
	    out[t] = 1
    return out.keys()

if __name__ == "__main__":
    timingdata = parseOutput(sys.argv[1])
    distros = sorted(timingdata.keys()) # all distros seen during previous build
    tools = sorted(getToolsFromTimingdata(timingdata)) # all tools seen during previous build

    for distro in distros:
	printBins(timingdata, distro, False)
	printBins(timingdata, distro, True)

	# no timing data, assume the build took too long for this tool on this distro
	nodata = [t for t in tools if t not in timingdata[distro]]
	for tool in nodata:
	    print("# - DISTRO='{}' TOOL='{}' # unknown duration...".format(distro, tool))

