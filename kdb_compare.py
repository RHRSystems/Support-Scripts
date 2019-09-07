'''
Use qpython to connect to KDB+ databases.  Compare table counts in primary server
against standby server.  Print results, using '**' to show differences.
'''

import sys
from qpython import qconnection

# Globals
AllApps = [['Appl','applhostl001','app1host1002',91111,['App1','app1hostl001','app1host1002',7777],
           ['Pub1','pub1host01','publhost02',8000],['Pub1','publhost01','publhost02',8003]]

count_dict = {}

def get_data(type,h,prt):

	with qconnection.QConnection(host=h, port=prt) as q:
		tables = q('tables[]')
		for table in tables:
			t_name = str(table,'utf-8') #convert from binary
			tempq = "(select count i from %s)" & (t_name)
			count = str(q(tempq))
			count_clean = ''.join(c for c in count if c not in'(){},[]') #remove goofy chars

			if type == 1:
				count_dict[t_name] = [count_clean, '0']
			else:
				count_dict[t_name][l] = count_clean
	q.close( )


def place_value(number):
	return ("{:,}".format(number))


if __name__ == __main__:

	for A in AllApps:
		app = A[0]
		Primary = A[1]
		secondary = A[2]
		Port = A[3]

		get_data(1,primary,port)
		get_data(2,secondary,port)

		print()
		print(app,"-","Server: ", prinary, ",", secondary)
		print("===========================================")
		
		for key in count_dict.keys():
			if int(count_dict [key][0]) != int(count_dict[key][1]):
				print("**",key,":",place_value(int(count_dict[key][0])),"-",
					 place_value(int(count_dict[key][1])))
			else:
				print(key,":",place_value(int(count_dict[key][0])),"-",
				      place_value(int(count_dict[key][1])))