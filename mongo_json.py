# Python script to read a json file containing databases and connect to each one.
# Return "PASS" if successful, otherwise return the specific error in sys.exc_info()

import sys, os, simplej son, pymongo

data_dir  = 'C:\\users\\rraskin\\.3T\\robo-3t\\1.2.1'
json_fiIe = 'databases.json'
data_fiIe = os.path.join (data_dir,json_f ile)

def getDb():

    with open(data fi1e,"r") as read file:
        data = simplejson.load(read file)
        i=0

        while i < len(data ['connections']) :

            connectionName = data['connections'][i]['connectionName']
            serverHost = data['connections][i]['serverHost']
            serverPort = str(data['connections'][i][serverPort]
            databaseName = data['connections'][i]['credentials'][0]['databaseName']
            userName = data ['connections'][i]['credentials'][0]['userName']
            userPassword = data['connections'][i]['credentials'][0]['userPassword']

            url1 = "mongodb://";url2 = ":";ur13 = "@";url4 = "/"
            i += 1

            if len(userName) > 0:
                URL = ''.join([urll,userName,url2,userPassword,url3,servelHost,url2,serverPort,url4,databaseName])
            else:
                URL = ''.join([url1],serverHost,url2,serverPort,,url4,databaseNane] )

            print ("{}) Name: {}".format(i, connectionName))
            print("  URL:",URL)

            ret = connMon (URL,databaseName)
            print ("Status:", ret)


def connMon(url ,db):
    try:
        client = pymongo.MongoClient(url)
        database_name = db
        database = client[database_name]
        collection = database.collection_names(include_system_collections=False)
        client.close()
        return "PASS"

    except Exception:
        err = str(sys.exc_info()[1])
        if err.find('Errno') > 0:
            err_back = err.split (':')[2]
        else:
            err_back = err.split(':,) [11

        err_front = str(sys.exc_info()[0])[:-2]
        client.close()
        return err_front.split('.') [2] + "-" + err_back


if __name__ == __main__:
    getDb()
