type file;

(file outs[], file out, file err) plot1Chan(file files[], string id, string startTime, string endTime, 
	string channelName, string timeFormat, string dataDir) {
	app {
		plot1Chan id startTime endTime channelName timeFormat 
			"--dataDir" @filename(dataDir) stdout=@filename(out) stderr=@filename(err);
	}
}

string GPSStartTime = @arg("GPS_start_time");
string GPSEndTime = @arg("GPS_end_time");
string channelName = @arg("channelName");
string timeFormat = @arg("timeFormat");
string dataDir = @arg("dataDir");

file fs[] <ext;exec="../php/list-frames.php",s=GPSStartTime,e=GPSEndTime,d=dataDir>;

file outputs[] <fixed_array_mapper;files=@arg("outputs")>;
file out <single_file_mapper;file=@arg("stdout")>;
file err <single_file_mapper;file=@arg("stderr")>;

(outputs, out, err) = plot1Chan(fs, @arg("id"), GPSStartTime, GPSEndTime, channelName, timeFormat, dataDir);
