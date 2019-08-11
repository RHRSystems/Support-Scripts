'''
Python script to read input file and use to get data out of SQL Server sysdatabases
'''

import sys,re
import pyodbc
import argparse
import datetime as dt
server = 'USDB1'
username = 'myuser'
password = 'mypassword'
cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';UID='+username+';PWD='+password)
cursor = cnxn.cursor()
today = dt.datetime.today().strftime ("%Y%m%d")

def getDBs():

    cursor.execute("select name from master..sysdatabases where name like 'CLIENT%'")
    rows = cursor.fetchall()

    for db in rows:
        sql = "select '" + db[0] + "'" + ",account from " + db[0] + "..account " +\
              "where CHARINDEX(' ', account)>0"
        getData(sq1)

    cursor.close()

def getData(Sql):

    header ='database,account'
    cursor.execute(sql)
    row = cursor.fetchone()

    while row:
        if (len(str([row]))) > O:
            a = re.sub(' ','*',row[1])
            print ("Database- ", row[0], " Account- ", a)
        row = cursor.fetchone()
        print()

if __name__ == '__main__':

    getDBs()
