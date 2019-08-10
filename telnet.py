# Read input file of host information, parse, conduct telnet test, save results
# to output file

import sys,csv,re
import datetime as dt
from telnetlib import Telnet

input = sys.argv[1]
fulltoday = dt.datetime.today().strftime("%Y-%m-%d")
output = input.split('.')[0] + "-" + fulltoday + ".csv"

def getData():

    ctr=0

    with open(input,'r') as csvfile:
    readCSV = csv.reader(csvfile, delimiter=',')
    outfile = open(output,'w' )

    for row in readCSV:

        ctr += 1

        if ctr == 1:
            outfile.write(row[0] + ',' + row[1] + ',' + row[2] + "\n"]
        else:
            ip = row[0]
            port = row[1]
            my_host = row[2]
            print (ip ,port, my_host)

            #must be valid ip address
            if re.match('\d{1,3}\.\d{1,3}\.\d{1,3}', ip) != None:
                telnet_data = TUnTELNET (ip,port)
                temprow = (ip + "," + port + "," + str(telnet_data) + "\n")
                outfile.write(temprow)

    csvfile.close()
    outfile.close()

def runTELNET (ip,port):

    session = Telnet()

    try:
        session.open(ip, port)
        session.close()
        return "PASSED"

    except Exception as e:
        session.close()
        return e

if __name__ == '__main__':
    getData()
