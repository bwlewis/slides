#!/bin/sh
# Experimental script that replaces images with base64-encoded data URIs
# Reads from an input file.
# Writes to the output file, which must be different from the input file.
#
# NOTE: Requires that src= immediately follow the img tag, for example:
# <img src="cazart.png" width=100/>   OK
# <img width=100 src="cazart.png"/>   NOT OK
# Usage:
# ./img.sh input.html output.html
if test $# -lt 2; then
  echo "Usage: ./img.sh input_file output_file"
  exit 2
fi
if test "${1}" = "${2}"; then
  echo "Error: input and output files must differ."
  exit 2
fi
cp "${1}" "${2}"
imfiles=`cat "${2}" | grep "<img src=" | sed -e 's/<img src=["'\'']//' | sed -e 's/["'\''].*//' | sort | uniq`
for x in ${imfiles}; do
  mimetype=$(file -bN --mime-type "${x}")
  content=$(base64 < "${x}" | tr -d '\n')
  sed -i -f - "${2}" << EOF
s@<img *src=[\"']${x}[\"']@<img src=\"data:${mimetype};base64,${content}\"@g
EOF
done
