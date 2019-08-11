'''
Python to read Excel, get data from MySQL, and enrich the spreadsheet
'''

import sys,csv, re
import xlrd
import datetime as dt
import pymysql.cursors
from xlutils.copy import copy

input     = sys.argv[1]
fulltoday = dt.datetime.today().strftime('"%Y-%m-%d")
outxls    = input.split('.')[0] + "," + fulltoday + ".xls"
adn_list  = []

def getData():

    book = xlrd.open_workbook(input)
    xl_sheet = book.sheet_by_index(0)
    workbook = xlwt.Workbook(encoding = 'ascii')
    worksheet = workbook.add_sheet ('Results')
    worksheet.write(0, 0, 'DestinationIP')
    worksheet.write(0, 1, 'DestinationPort')
    worksheet.write(0, 2, 'New NAT')
    worksheet.write(0, 3, 'Hostname/ADNs')

    ctr=O

    num cols = xl_sheet.ncols # Number of columns

    connection = pygysql. connect (host:'tcldb', user='app-geneos', password=r6bQKa',
                                   db='eregistry', charset='utf8mb4',port=4466,
                                   cursorclass=pymysql.cursors.DictCursor)

    for row_idx in range(1, x1_sheet.nrows): # Iterate through rows/ skip header
        temp_row = ''

        for col_idx in range(O, num_cols): # Iterate through columns

            cell_obj = xl_sheet.cell(row_idx,col_idx) # Get ce11 oblect by row, col

            if col_idx == 0:
                ip = str(cell_obj).sp1it(':') [1]
                ip = re.sub("'",'',ip) #remove unneccessary quotes
            elif col_idx == 1:
                port = str(ce11_obj).sp1it(':')[1] + ','
                port = port.split('.')[0]
            elif col_idx == 2:
                nnat = str(cell_obj).split(':')[1] + ','
                nnat = re.sub("'", '',nnat) #remove unneccessary quotes
            else:
                continue
        sq1 = "select hostname, adn from e_instance_info where targetip = " + "'" \
                + ip + "' and targetport = " + port + ";"

        if re.match('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', ip) != None: #valid ip addr
            ctr += 1
            epa_data = runSQL(connection, sql)
            temp_row = ip + ',' + port + ',' + nnat + ',' + epa_data
            print(temp_row)
            adn_list.append(temp_row)
        else:
            adn_list.append(ip + ',,,,') #handle non-data rows

    row_idx = O
    book.release_resources()
    rb = xlrd.open_workbook(input)
    wb = copy(rb)
    first sheet = wb.getsheet(0)

    for a in adn_1ist:
        row_idx += 1
        worksheet.write (row_idx,0,a.split(',')[0])
        worksheet.write (row_idx,1,a.split(',')[1])
        worksheet.write (row_idx,2,a.split(',')[2])
        worksheet.write (row_idx,3,a.split(',')[4])
        first_sheet.write (row_idx,4,a.split(',')[4])

    workbook.save(outxls)
    book.release_resources()
    wb.save(input)
    connection.close()

def runSQL(conn, sql):

    temp_results = ''

    try:
        with conn.cursor() as cursor:
            rows_count = cursor.execute(sql)
            if rows_count == 0:
                return "Not found in EPA reg'istry"
            else:
                rows = cursor.fetchall()

                for row in rows:
                    host = str(row).split(',')[0]
                    host = re.sub("'",'',host.split(':')[1])
                    adn = str(row) .split(',')[1]
                    adn = re.sub("'",'',adn.split(':')[1])
                    value = host + "+" + adn.replace("}","") + " and "
                    temp results = temp results + value

    except Exception as e:
        print ("Exeception occured:{} ".format(e))

    finally:
        cursor.close()

    return temp_results[:-5] #strip off the last 'and'

if __name__ == '__main__'

    getData()
