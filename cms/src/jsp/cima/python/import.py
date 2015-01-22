import _mysql
import math

def loadDB():
	db=_mysql.connect(host="localhost",user="root", passwd="1stNewMCSheed",db="Masterclass")
	return db

def loadFile(db,filename):
	file=open(filename)
	for line in file:
		a=line.split("\t")
		if len(a)!=3:
			for i in range(len(a)):
				if len(a[i])==0:
					del a[i]
					break

		a.append(str(int(math.floor(float(a[0])/100.)+1)))
		#print a
		#a[0]=a[0][12:]
		#a[2]=a[2]
		#temp=a[3].split(",")
		#a[3]=str(float(temp[0])+float("0."+temp[1]))
		a[2]=a[2].replace(",",".")
		a[2]=a[2].strip("\n")
		print a
	
		db.query("INSERT INTO Events (o_no,ev_no,mass,g_no) VALUES ("+a[0]+","+a[1]+","+a[2]+","+a[3]+");")

