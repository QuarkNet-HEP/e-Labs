#!/usr/bin/python

import sys
import re

try:
	f = file(sys.argv[1])
except IndexError:
	print "usage:\n\tcatalinap.py <path/to/catalina.out>\n"

header = re.compile("(\d{8,8}-\d{4,4})-.{8,8}:")
rawDataLine = re.compile(".*-rawData=(.*)")
sitesFile = re.compile("INFO.*Using sites file.*sites-(.*)\.xml")
jobHost = re.compile(".*JOB_START.*tmpdir=.*::([^/]*)/.*host=(.*)")
executionTime = re.compile("Execution time: (\d*)ms")
failure = re.compile(".*Execution failed:")
jobEnd = re.compile(".*JOB_END.*")
appException = re.compile(".*APPLICATION_EXCEPTION.*")
vdsHeader = re.compile("(\d{4,4}\.\d{2,2}\.\d{2,2} \d{2,3}:\d{2,2}).* Parsing the site catalog \(")
vdsCompletion = re.compile("Run monitor finished")
vdsFailure = re.compile("gov.fnal.elab.util.ElabShellException.*")


curId = ""

seenTypes = {}


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