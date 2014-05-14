#!/bin/python
import string
import sys
import re

if( len(sys.argv) == 1 ):
	print "Usage: postag-from-charniak.py <filename>"
	sys.exit(1)

#reobj = re.compile(r"\([A-Z][A-Z0-9\$]* [^)(][^)(]*\)")
reobj = re.compile(r"\([^ ][^ ]* [^)(][^)(]*\)")

for line in open(sys.argv[1]).readlines():
	line = string.strip(line)
	list = reobj.findall(line)

	for element in list:
		some_list = string.split(element)
		print "%s_%s"% (some_list[1][:-1], some_list[0][1:]),
	#--- this space seems to be required for further processing.. try to find out why and remove it from here ---#
	print " "

#['(S1 (S (NP (JJ Many)', '(NNS states)', '(ADVP (RB already)', '(VP (AUX have)', '(VP (VBN launched)', '(NP (JJ work-for-welfare)', '(NNS experiments)']