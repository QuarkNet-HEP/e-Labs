import os
import re
import shutil

orphans = open("output_thresh_check18.txt", "r")
for line in orphans:
	for root, dirs, files in os.walk("/disks/i2u2/cosmic/data"):
		for f in files:
			if f == line.strip('\n\r'):
				print 'Found file in: ' + str(root)
				shutil.copy2(os.path.abspath(root+ '/'+f), "/disks/i2u2/cosmic/.Trash/")
				shutil.copy2(os.path.abspath(root+ '/'+f+".bless"), "/disks/i2u2/cosmic/.Trash")
				os.remove(os.path.join(root,f))
				os.remove(os.path.join(root,f+".bless"))
orphans.close()
