import os
import re

output = open("output_thresh_check13.txt", "w")
#outputFiles = open("all_files_13.txt","w")
filenames = []
filenamesNoThresh = []

def HammingDistance(line1, line2):
	#print "Zip: ", zip(line1,line2)
	distance = sum(ch1 != ch2 for ch1, ch2 in zip(line1, line2))
	return distance

for root, dirs, files in os.walk("/disks/i2u2-dev/cosmic/data"):
	for file in files:
		if not file.endswith((".log",".sh", "more", "bak", "raw", "gz", "geo", "tmp", "blessing.txt", "thresh-java", "bless", "analyze", "meta", "Store", "raw.errors")):
			filenames.append(file)

filenames.sort()
output.write("Examine the following files: they may not have a .thresh associated with them\n")
for ndx in range(len(filenames) - 1):
	if not filenames[ndx].endswith(("thresh")):
		#outputFiles.write(filenames[ndx])
		#outputFiles.write(",")
		#outputFiles.write(filenames[ndx+1])
		#outputFiles.write("\n")
		distance = HammingDistance(filenames[ndx], filenames[ndx+ 1])
		if distance > 0:
			filenamesNoThresh.append(filenames[ndx])
			
for fnt in filenamesNoThresh:
	fntthresh =  fnt.join(".thresh")
	for f in filenames:
		if f == fntthresh:
			filenamesNoThresh.remove(fnt)

output.write("Total Files Found: ")
output.write(str(len(filenamesNoThresh)))	
output.write("\n")
for fnt in filenamesNoThresh:
	output.write(fnt)
	output.write("\n")
	
output.close()
#outputFiles.close()
