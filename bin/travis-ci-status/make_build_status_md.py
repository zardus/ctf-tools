#!/usr/bin/env python

from make_binpacked_travis_ci_conf import *

if __name__ == "__main__":
    timingdata = parseOutput(sys.argv[1])
    distros = sorted(timingdata.keys()) # all distros seen during previous build
    tools = sorted(getToolsFromTimingdata(timingdata)) # all tools seen during previous build

    fulltable = []
    summarytable = []

    fulltable += [" | ".join([""] + distros)]
    fulltable += [" | ".join(["-----"] * (1+len(distros)))]
	
    summary = {}
    for tool in tools:
	parts = []
	for distro in distros:
	    val = "unknown"
	    if tool in timingdata[distro]:
	        val = "success" if timingdata[distro][tool]["success"] else "fail"
	    parts += [val]
	    if distro not in summary:
	        summary[distro] = {
		    "unknown": 0,
		    "success": 0,
		    "fail": 0,
		    "total": 0,
		}
	    summary[distro][val] += 1
	    summary[distro]["total"] += 1
	fulltable += [" | ".join([tool] + ["![{0}]({0}.png)".format(x) for x in parts])]

    summarytable += [" | ".join([""] + distros)]
    summarytable += [" | ".join(["-----"] * (1+len(distros)))]
    for x in ["success", "fail", "unknown"]:
	summarytable += [" | ".join(["![{0}]({0}.png)".format(x)] + ["{}".format(summary[d][x]) for d in distros])]
    for x in ["total"]:
	summarytable += [" | ".join([x] + ["{}".format(summary[d][x]) for d in distros])]

    print("\n".join(summarytable))
    print("")
    print("\n".join(fulltable))
