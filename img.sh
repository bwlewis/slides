#!/bin/bash
# Experimental script that replaces images with base64-encoded data URIs
# Usage:
# ./img.sh input.html output.html
#
# ASSUMES EVERY <img ... /> is on its own line!

tmp=/dev/shm/x.html
cp $1 $tmp
for x in $(cat $1 | grep '<img' | sed -e 's/ /@@@/g');do
  y=$(echo $x | sed -e 's/@@@/ /g')
  echo $y
  f=$(echo $y | sed -e 's/.*src="//;s/".*//')
  a=$(echo $y | perl -pe "s/src=\".*?\"//;s/<img//;s/\/>//;s/>//") # other img attributes
  t=$(echo $f | sed -e 's/.*\./data:image\//')
  b=$(cat $f | base64 -w 0)
  z=$(echo $y | sed -e 's%/%\\/%g') # escape slashes for searching
  cat $tmp | sed -n "/${z}/q;p" > ${tmp}-
  echo "<img ${a} src=\"...\"/>"
  echo "<img ${a} src=\"$t;base64,${b}\"/>" >> ${tmp}-
  cat $tmp | sed "0,/${z}/d" >> ${tmp}-
  mv ${tmp}- $tmp
done
mv $tmp $2
