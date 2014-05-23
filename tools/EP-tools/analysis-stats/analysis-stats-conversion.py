#!/usr/bin/python

import sys
import re

try:
	f = file(sys.argv[1])
except IndexError:
	print "usage:\n\tcatalinap.py <path/to/catalina.out>\n"

header = re.compile("(\d{8,8}-\d{4,4})-.{8,8}:")
fullid = re.compile("(\d{8,8}-\d{4,4}-.{8,8}:)")
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
fullId = ""

seenTypes = {}
commonJobId = ''
output = []

for line in f:
	m = header.match(line)
	f = fullid.match(line)
	if f:
		fullId = f.group(1)
	if m:
		curId = m.group(1)
		m = failure.match(line)
		if m:
			#print "swiftFailure " + curId
			output.append(curId)
			output.append(fullId)
			output.append("swiftFailure")
		else:		
			m = rawDataLine.match(line)
			if m:
				rawData = m.group(1)
				rawData = rawData.replace("/disks/i2u2/cosmic/data/", "")
				rawData = rawData.replace("/disks/i2u2-dev/cosmic/data/", "")
				rawData = rawData.replace("/var/tmp/quarknet-t/data/", "")
				#print "rawData " + curId + " " + rawData
				output.append(curId)
				output.append(fullId)
				output.append(rawData)
	else:
		m = sitesFile.match(line)
		if m:
			sites = m.group(1)
			#print "swiftStart " + curId
			#print "site " + curId + " " + sites
			output.append(curId)
			output.append(fullId)
			output.append(sites)
		else:
			m = jobHost.match(line)
			if m:
				t = m.group(1)
				if not t in seenTypes.keys():
					seenTypes[t] = 1
					#print "type " + curId + " " + m.group(1)[:-23]
					output.append(curId)
					output.append(fullId)
					output.append(m.group(1)[:-23])
				#print "jobHost " + curId + " " + m.group(2)
				output.append(curId)
				output.append(fullId)
				output.append(m.group(2))
			else:
				m = executionTime.match(line)
				if m:
					time = m.group(1)
					#print "swiftSuccess " + curId + " " + time
					output.append(curId)
					output.append(fullId)
					output.append("swiftSuccess")
					output.append(time)
				else:
					m = jobEnd.match(line)
					if m:
						#print "jobSuccess " + curId
						output.append(curId)
						output.append(fullId)
						output.append('jobSuccess')
					else:
						m = appException.match(line)
						if m:
							#print "jobFailure " + curId
							output.append(curId)
							output.append(fullId)
							output.append('jobFailure')
						else:
							m = vdsHeader.match(line)
							if m:
								ts = m.group(1)
								ts = ts.replace(".", "")
								ts = ts.replace(":", "")
								ts = ts.replace(" ", "-")
								curId = ts
								#print "vdsStart " + curId
							else:
								m = vdsCompletion.match(line)
								if m:
									#print "vdsCompletion " + curId
									output.append(curId)
									output.append(fullId)
									output.append('vdsCompletion')
								else:
									m = vdsFailure.match(line)
									if m:
										#print "vdsFailure " + curId
										output.append(curId)
										output.append(fullId)
										output.append('vdsFailure')

	if output:
		print output
		output = []