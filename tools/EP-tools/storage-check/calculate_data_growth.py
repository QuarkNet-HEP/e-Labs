import os
import math
import datetime
import decimal

def get_size(start_path):
	total_size = 0
	folders = set()
	for dirpath, dirnames, filenames in os.walk(start_path):
		for f in filenames:
			fp = os.path.join(dirpath, f)
			try:
				stat = os.stat(fp)
			except OSError:
				continue

			if stat.st_ino in folders:
				continue
			
			folders.add(stat.st_ino)
							
			total_size += stat.st_size
			
	return total_size


def convert_size(size):
	size_name = ("B","KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
	i = int(math.floor(math.log(float(size),1024)))
	p = math.pow(1024,i)
	s = round(size/p,2)
	if (s > 0):
		return '%s %s' % (s, size_name[i])
	else:
		return '0B'
		
file_name = "/home/quarkcat/tools/storage-check/data_growth.txt"
if not os.path.exists(file_name):
	file_input = open(file_name, "wr")
	file_input.write("DATE,PRIOR_SIZE,CURRENT_SIZE,GROWTH_RATE,READABLE_SIZE\n")
	file_input.close()
	
date = ""
prior_size = 0
current_size = 0
growth_rate = 0

file_read = open(file_name, "r")
last_line = ""

for line in file_read:
	last_line = line

if len(last_line) > 0:
	fields = last_line.split(",")
	if len(fields) > 0:
		if fields[2] != 'CURRENT_SIZE':
			prior_size = int(fields[2])

file_read.close()

file_append = open(file_name, "a+")				
date = datetime.datetime.now()				
current_size = int(get_size("/disks"))

if prior_size > 0:
	decimal.getcontext().prec = 5
	growth_rate = decimal.Decimal(current_size) / decimal.Decimal(prior_size)

		
file_append.write(str(date)+','+str(prior_size)+','+str(current_size)+','+str(format(growth_rate, '.5f'))+','+str(convert_size(get_size("/disks")))+"\n")

file_append.close()
