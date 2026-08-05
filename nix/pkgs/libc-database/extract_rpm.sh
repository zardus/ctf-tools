#!/bin/bash
# Extract RPM with fallback to rpm2archive for large files (>4GB)
rpm_file="$1"
err_file=$(mktemp)
if rpm2cpio "$rpm_file" 2>"$err_file" | cpio -id --quiet 2>>"$err_file"; then
  rm -f "$err_file"
  exit 0
fi
if grep -q "4GB" "$err_file"; then
  rm -f "$err_file"
  # rpm2archive 4.18+ (Ubuntu Noble) writes to stdout by default
  rpm2archive "$rpm_file" | tar xzf -
  exit $?
fi
cat "$err_file" >&2
rm -f "$err_file"
exit 1
