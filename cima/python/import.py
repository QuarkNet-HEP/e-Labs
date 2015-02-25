import _mysql

def loadDB():
	db=_mysql.connect(host="localhost",user="root", passwd="1stNewMCSheed",db="Masterclass")
	return db

def loadFile(db,filename):
	file=open(filename)
	for line in file:
		a=line.split("\t")
		#print a
		a[0]=a[0][12:]
		a[2]=a[2]
		temp=a[3].split(",")
		a[3]=str(float(temp[0])+float("0."+temp[1]))
		print a
		db.query("INSERT INTO Events (g_no,e_no,o_no,mass) VALUES ("+a[0]+","+a[1]+","+a[2]+","+a[3]+");")

