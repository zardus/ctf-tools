#!/usr/bin/env python

from make_binpacked_travis_ci_conf import *

if __name__ == "__main__":
    timingdata = parseOutput(sys.argv[1])
    # all distros seen during previous build
    distros = sorted(timingdata.keys())
    # all tools seen during previous build
    tools = sorted(getToolsFromTimingdata(timingdata))

    fulltable = []
    summarytable = []

    fulltable.append("| " + " | ".join([""] + distros) + " |")
    fulltable.append("| " + " | ".join(["-----"] * (len(distros) + 1)) + " |")

    summary = {}
    for tool in tools:
        parts = []
        for distro in distros:
            val = "unknown"
            if tool in timingdata[distro]:
                val = ("success"
                       if timingdata[distro][tool]["success"] else "fail")
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
        fulltable.append("| " + " | ".join(
            [tool] + ["![{0}]({0}.png)".format(x) for x in parts]) + " |")

    summarytable.append("| " + " | ".join([""] + distros) + " |")
    summarytable.append("| " + " | ".join(["-----"] * (len(distros) + 1)) + " |")

    for x in ["success", "fail", "unknown"]:
        summarytable.append("| " + " | ".join(["![{0}]({0}.png)".format(
            x)] + [str(summary[d][x]) for d in distros]) + " |")

    for x in ["total"]:
        summarytable.append("| " + " | ".join(
            [x] + [str(summary[d][x]) for d in distros]) + " |")

    print("\n".join(summarytable))
    print("")
    print("\n".join(fulltable))
