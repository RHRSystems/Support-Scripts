# read a file of shell commands and execute them using os.system

import sys,os

with open ('temp.txt') as readfile:
    records = readf il-e. read]ines o
    for r in records:
        e = r.split (',')[1]
        h = r.split (',')[3]
        tempcmd = "./scr_mig.sh {} {}".format(e,h)
        print ("./scr_mig.sh {} {}").format(e,h)
        print (tempcmd)
        os.system(tempcmd)
