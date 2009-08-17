#!/usr/bin/python

import sys
import re
import os.path
import glob

def error(msg):
	print msg
	sys.exit(1)

try:
	path = sys.argv[1]
	if not os.path.exists(path):
		error("Path does not exist: " + path)
	if not os.path.isdir(path):
		error("Path is not a directory: " + path)
except IndexError:
	error("Missing argument\nUsage:\n\tcatalinap.py <path/to/tomcat/logs>\n")
	

header = re.compile("(\d{8,8}-\d{4,4})-.{8,8}:")
rawDataLine = re.compile(".*-rawData=(.*)")
sitesFile = re.compile("INFO.*Using sites file.*sites-(.*)\.xml")
jobHost = re.compile(".*JOB_START.*tmpdir=.*::([^/]*)/.*host=(.*)")
executionTime = re.compile("Execution time: (\d*)ms")
failure = re.compile(".*Execution failed:")
jobEnd = re.compile(".*JOB_END.*")
swiftSuccess = re.compile(".*SWIFT_SUCCESS.*time=(\d*),.*")
appException = re.compile(".*APPLICATION_EXCEPTION.*")
vdsHeader = re.compile("(\d{4,4}\.\d{2,2}\.\d{2,2} \d{2,3}:\d{2,2}).* Parsing the site catalog \(")
vdsCompletion = re.compile("Run monitor finished")
vdsFailure = re.compile("gov.fnal.elab.util.ElabShellException.*")


seenTypes = {}

files = glob.glob(path + "/catalina*.out")

if len(files) == 0:
	error("No catalina.out files found in " + path);
	
 

def processFile(f):
	print("#Processing file " + str(f))
	curId = ""

	for line in f:
		m = header.match(line)
		if m:
			curId = m.group(1)

			m = failure.match(line)
			if m:
				print "swiftFailure " + curId
			else:		
				m = rawDataLine.match(line)
				if m:
					rawData = m.group(1)
					rawData = rawData.replace("/disks/i2u2/cosmic/data/", "")
					rawData = rawData.replace("/disks/i2u2-dev/cosmic/data/", "")
					rawData = rawData.replace("/var/tmp/quarknet-t/data/", "")
					print "rawData " + curId + " " + rawData
		else:
			m = sitesFile.match(line)
			if m:
				sites = m.group(1)
				print "swiftStart " + curId
				print "site " + curId + " " + sites
			else:
				m = jobHost.match(line)
				if m:
					t = m.group(1)
					if not t in seenTypes.keys():
						seenTypes[t] = 1
						print "type " + curId + " " + m.group(1)[:-23]
					print "jobHost " + curId + " " + m.group(2)
				else:
					m = executionTime.match(line)
					if not m:
						m = swiftSuccess.match(line)
					if m:
						time = m.group(1)
						print "swiftSuccess " + curId + " " + time
					else:
						m = jobEnd.match(line)
						if m:
							print "jobSuccess " + curId
						else:
							m = appException.match(line)
							if m:
								print "jobFailure " + curId
							else:
								m = vdsHeader.match(line)
								if m:
									ts = m.group(1)
									ts = ts.replace(".", "")
									ts = ts.replace(":", "")
									ts = ts.replace(" ", "-")
									curId = ts
									print "vdsStart " + curId
								else:
									m = vdsCompletion.match(line)
									if m:
										print "vdsCompletion " + curId
									else:
										m = vdsFailure.match(line)
										if m:
											print "vdsFailure " + curId
											
for f in files:
	processFile(file(f))
