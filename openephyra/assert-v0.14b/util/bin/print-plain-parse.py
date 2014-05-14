#!/bin/python
import string
import sys
import re

if( len(sys.argv) == 1 or len(sys.argv) != 4 ):
	print "Usage: print-parse.py <svm-scores-file> <sentence-file> <lines-file>"
	sys.exit(1)

score_file_lines = open(sys.argv[1]).readlines()

list_of_start_arrays = []
list_of_end_arrays   = []
list_of_role_arrays  = []
list_of_target_indices = []
list_of_word_lists = []
start_array = []
end_array   = []
role_array  = []

word_list   = []

i=0
for i in range(0, len(score_file_lines)):
	if(len(string.strip(score_file_lines[i])) == 0):
		list_of_start_arrays.append(start_array)
		list_of_end_arrays.append(end_array)
		list_of_role_arrays.append(role_array)
		list_of_target_indices.append(target_index)
		start_array = []
		end_array   = []
		role_array  = []
		continue

	list = string.split(score_file_lines[i])
	#print list
	#print list[2]
	#print list[3]
	#print list[13]
	start_array.append(string.atoi(list[2]))
	end_array.append(string.atoi(list[3]))
	role_array.append(list[13])
	target_index = string.atoi(list[1])

list_of_word_lists = open(sys.argv[2]).readlines()
list_of_lines      = open(sys.argv[3]).readlines()

kk=0
for kk in range(0, len(list_of_word_lists)):
	list_of_word_lists[kk] = string.split(list_of_word_lists[kk])

#word_list = string.split(open(sys.argv[2]).readlines()[0])

#print len(list_of_start_arrays)
#print len(list_of_word_lists)
#print len(list_of_lines)

jj=0
for jj in range(0, len(list_of_start_arrays)):
	#word_list_copy = [] + word_list
	word_list_copy  = list_of_word_lists[jj]
	
	word_list_copy[list_of_target_indices[jj]] = "[TARGET %s " % (word_list_copy[list_of_target_indices[jj]])
	word_list_copy[list_of_target_indices[jj]]   = "%s]" % (word_list_copy[list_of_target_indices[jj]])

	j=0
	for j in range(0, len(list_of_start_arrays[jj])):
		if( list_of_role_arrays[jj][j] == "O" ):
			continue
		word_list_copy[list_of_start_arrays[jj][j]] = "[%s %s" % (string.upper(list_of_role_arrays[jj][j]), word_list_copy[list_of_start_arrays[jj][j]])
		word_list_copy[list_of_end_arrays[jj][j]]   = "%s]" % (word_list_copy[list_of_end_arrays[jj][j]])

	print "%s: %s" % (string.strip(list_of_lines[jj]), string.strip(string.join(word_list_copy)))