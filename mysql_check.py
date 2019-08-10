# Take an input file argument, the read each entry and see if it exists in MySQL database.  Print out
# details for the ones it found

import sys,re
import pymysql.cursors
import argparse

def getArgs():

    ap = argparse.ArgumentParser()
    ap.add_argument ( "-f", "--filename", required=True, help="Filename")
    args = vars (ap.parse_args())
    f = args ["filename"]

    connection = pymysql.connect(host='rtdbrr', user='eapp_genr', password='pass',db = 'eegisy', charset = 'utf8mb4',
                                 port='4466', cursorclass=pymysql.cursors.Dictcursor)

    adns = getData(connection, f)
    print("No entry in EPA registry for for adns:)

    for a in adns:
        print (a)

    connection.close()


def getData (conn, filename) :

    with open(filename,'r') as inputfile:
        adns = []
        records = inputfile.readlines()

        for f in records:

            r = r.strip()
            sql = "select adn,hostname,deppath from epa_instance where adn = " + '"' + r + '"'

            try:
                with conn.cursor() as cursor:

                    rows_count = cursor.execute(sql)

                    if rows_count == 0:
                        adns.append(r)
                    else:
                        row = cursor.fetchone()

            except Exception as e:
                print ("Exeception occured: {}".format(e))

            finally:
                cursor.close()

    return adns


if __name__ == '__main__':

    getArgs()
