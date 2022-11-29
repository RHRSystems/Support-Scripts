#
# Use this script to search for any value in a file.
#
import sys, os, re

ctr = 0; bad = 0; fctr = 0; fctr2 = 0
dict_fields = {}

regex = '<define this>'
infile = 'somefile.csv'
os.chrdir('somedir')

# READ FILE AND CHECK FOR BAD VALUES
# ----------------------------------

with open(infile,'r') as read_obj:
	for row in read_obj:
		ctr += 1
		fields = row.split(',')
		if ctr == 1: #build dictionary of column headers
			for f in fields:
				fctr += 1
				dict_fields[fctr] = f
		else:
			if (re.search(regex,row))   # found bad row
				for f in fields:
					fctr2 += 1
					if (re.search(regex,f)) # found exact field
						bad_col = list(dict_fields.values())[fctr2]
						print("Found - {} in row {}: column '{}'".format(regex,ctr,bad_col))
						bad += 1
				fctr2 = 0

	print("\nTotal lines read -> {}, Bad records -> {}".format(ctr,bad))
