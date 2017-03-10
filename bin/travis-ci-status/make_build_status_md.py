#!/usr/bin/env python

from make_binpacked_travis_ci_conf import *

if __name__ == "__main__":
    timingdata = parseOutput(sys.argv[1])
    distros = sorted(timingdata.keys()) # all distros seen during previous build
    tools = sorted(getToolsFromTimingdata(timingdata)) # all tools seen during previous build

    print(" | ".join([""] + distros))
    print(" | ".join(["-----"] * (1+len(distros))))
	
    for tool in tools:
	parts = []
	for distro in distros:
	    val = "unknown"
	    if tool in timingdata[distro]:
	        val = "success" if timingdata[distro][tool]["success"] else "fail"
	    parts += [val]
	print(" | ".join([tool] + ["![{0}]({0}.png)".format(x) for x in parts]))
