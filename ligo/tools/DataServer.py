#!/usr/bin/python

PORT = 8100

import time
#import io
import os
import os.path
from urlparse import *
import cgi
import cgitb
cgitb.enable()

from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler

class HandlerException(Exception):
	def __init__(self, code, msg):
		self.code = code
		self.msg = msg

class DataHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		self.send_response(200)
		self.send_header("Content-type", "text/html")
		self.end_headers()
		self.wfile.write("<html><head></head><body>")
		self.wfile.write("<form method=\"POST\">")
		self.wfile.write("File: <input type=\"text\" name=\"file\" /><br />")
		self.wfile.write("Record size: <input type=\"text\" name=\"recsz\" /><br />")
		self.wfile.write("Records: <textarea name=\"records\"></textarea><br />")
		self.wfile.write("<input type=\"submit\" name=\"Submit\" />")
		self.wfile.write("</form></body></html>")
		
	def do_POST(self):
		try:
			type, params = cgi.parse_header(self.headers.getheader("content-type"))
			len, _ = cgi.parse_header(self.headers.getheader("content-length"))
			if type == "application/x-www-form-urlencoded":
				data = self.rfile.read(int(len))
				query = cgi.parse_qs(data)
			else:
				raise HandlerException(406, "Unrecognized encoding: " + type)
			self.checkMissing(query, "file")
			self.checkMissing(query, "recsz")
			self.checkMissing(query, "records")
			f = query.get("file")[0]
			f = self.checkFile(f)
			recsz = int(query.get("recsz")[0])
			if recsz < 4 or recsz > 256:
				raise HandlerException(406, "Recsz (" + str(recsz) + ") not in accepted range (4 - 256)")
			records = query.get("records")[0].split()
			records = self.parseRecords(records)
			self.sendData(f, recsz, records)

		except HandlerException, e:
			self.error(e.code, e.msg)
		except Exception, e:
			self.error(500, str(e))
			print e
			
	def sendData(self, f, recsz, records):
		ts = time.clock()
		rf = open(f, "r")
		try:
			self.send_response(200)
			self.send_header("Content-type", "application/octet-stream")
			self.send_header("Content-Transfer-Encoding", "binary")
			self.end_headers()
			flen = os.path.getsize(f)
			
			for r in records:
				if r < 0 or recsz * (r + 1) > flen:
					for i in range(0, recsz):
						self.wfile.write("\000")
				else:
					rf.seek(recsz * r)
					self.wfile.write(rf.read(recsz))
		finally:
			rf.close()
			print str(len(records)) + " records in %4.3f s" % (time.clock() - ts)
			
	def parseRecords(self, records):
		ret = []
		for r in records:
			v = int(r)
			if len(ret) != 0:
				if v < ret[-1]:
					raise HandlerException("Records not monotonic: " + str(records))
			ret.append(v)
		return ret
			
	def checkFile(self, f):
		absf = os.path.abspath(f)
		if os.getcwd() != os.path.dirname(absf):
			raise HandlerException(406, "Invalid file: " + f)
		if not os.path.isfile(absf):
			raise HandlerException(406, "File not found: " + f)
		return absf
		
			
	def checkMissing(self, query, param):
		value = query.get(param)
		if value == None:
			raise HandlerException(406, "Missing parameter: " + param)
		if len(value) == 0:
			raise HandlerException(406, "Empty parameter value for " + param)
	
	def error(self, code, msg):
		self.send_response(code)
		self.send_header("Content-type", "text/html")
		self.end_headers()
		self.wfile.write("<html><head></head><body>")
		self.wfile.write("<h1>Request not accepted</h1>" + msg)
		self.wfile.write("</form></body></html>")

try:
	server = HTTPServer(("", PORT), DataHandler)
	print "Server started on port " + str(PORT)
	server.serve_forever()
except KeyboardInterrupt:
	print "Shutting down..."
	exit(1)
