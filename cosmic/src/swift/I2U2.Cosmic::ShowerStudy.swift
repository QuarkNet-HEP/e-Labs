type File {}

type AxisParams {
	string low;
	string high;
	string label;
}

(File thresholdData) ThresholdTimes(File rawData, string detector, string cpldfreq) {
	app {
		ThresholdTimes @filename(rawData) @filename(thresholdData) detector cpldfreq;
	}
}

(File thresholdData[]) ThresholdTimesMultiple(File rawData[], string detectors[], string cpldfreqs[]) {
	foreach data, i in rawData {
		thresholdData[i] = ThresholdTimes(rawData[i], detectors[i], cpldfreqs[i]);
	}
}

(File wireDelayData) WireDelay(File thresholdData, string geoDir, File geoFile, string detector, string firmware) {
	app {
		WireDelay @filename(thresholdData) @filename(wireDelayData) @filename(geoDir) detector firmware;
	}
}

(File wireDelayData[]) WireDelayMultiple(File thresholdData[], string geoDir, File geoFiles[], string detectors[], string firmwares[]) {
	foreach td, i in thresholdData {
		wireDelayData[i] = WireDelay(thresholdData[i], geoDir, geoFiles[i], detectors[i], firmwares[i]);
	}
}

(File combined) Combine(File data[]) {
	app {
		Combine @filenames(data) @filename(combined);
	}
}

(File out) Sort(File inf, string key1, string key2) {
	app {
		Sort @filename(inf) @filename(out) key1 key2;
	}
}

(File out) EventSearch(File inf, string gate, string detectorCoincidence, string channelCoincidence,
	string eventCoincidence) {
	
	app {
		EventSearch @filename(inf) @filename(out) gate detectorCoincidence
			channelCoincidence eventCoincidence;
	}
}

(File out) EventChoice(File inf, string eventNum, string zeroZeroZeroID, string geoDir, File geoFiles[]) {
	app {
		EventChoice @filename(inf) @filename(out) eventNum zeroZeroZeroID @filename(geoDir);
	}
}


(File image, File outfile_param) Plot(string ptype, string caption, AxisParams x, AxisParams y, 
	AxisParams z, string title, File infile, File extraFun) {
	
	app {
		Plot 
			"-file" @filename(infile)
			"-extra" @filename(extraFun)
			"-param" @filename(outfile_param)
			"-svg" @filename(image)
			"-type" ptype
			"-title" title
			"-xlabel" x.label
			"-ylabel" y.label
			"-zlabel" z.label
			"-caption" caption
			"-lowx" x.low
			"-highx" x.high
			"-lowy" y.low
			"-highy" y.high
			"-lowz" z.low
			"-highz" z.high;
	}
}

(File png) SVG2PNG(File svg, string height) {
	app {
		SVG2PNG "-h" height "-w" height @filename(svg) @filename(png);
	}
}


string channelCoincidence = @arg("channelCoincidence");
string detectorCoincidence = @arg("detectorCoincidence");
string eventCoincidence = @arg("eventCoincidence");
string eventNum = @arg("eventNum");
string gate = @arg("gate");
string zeroZeroZeroID = @arg("zeroZeroZeroID");

File eventCandidates <single_file_mapper;file=@arg("eventCandidates")>;
File eventFile <single_file_mapper;file=@arg("eventFile")>;

File rawData[] <fixed_array_mapper;files=@arg("rawData")>;
//File thresholdAll[] <fixed_array_mapper;files=@arg("thresholdAll")>;
//This is done to avoid corruption of threshold files when created
//concurrently by multiple runs
File thresholdAll[] <structured_regexp_mapper;source=rawData,match=".*/(.*)",transform="\\1.thresh">;
File wireDelayData[] <fixed_array_mapper;files=@arg("wireDelayData")>;

string  detectors[] = @strsplit(@arg("detector"), "\\s");
string  cpldfreqs[] = @strsplit(@arg("cpldfreqs"), "\\s");
string  firmwares[] = @strsplit(@arg("firmwares"), "\\s");

File combineOut <single_file_mapper;file=@arg("combineOut")>;
File sortOut <single_file_mapper;file=@arg("sortOut")>;

string geoDir = @arg("geoDir");
File geoFiles[] <fixed_array_mapper;files=@arg("geoFiles")>;

AxisParams x, y, z;

x.high = @arg("plot_highX");
x.low  = @arg("plot_lowX");
x.label = @arg("plot_xlabel");

y.high = @arg("plot_highY");
y.low  = @arg("plot_lowY");
y.label = @arg("plot_ylabel");

z.high = @arg("plot_highZ");
z.low  = @arg("plot_lowZ");
z.label = @arg("plot_zlabel");


string plot_plot_type = @arg("plot_plot_type");
string plot_title = @arg("plot_title");
string sort_sortKey1 = @arg("sort_sortKey1");
string sort_sortKey2 = @arg("sort_sortKey2");


//the actual workflow
thresholdAll = ThresholdTimesMultiple(rawData, detectors, cpldfreqs);
wireDelayData = WireDelayMultiple(thresholdAll, geoDir, geoFiles, detectors, firmwares);
combineOut = Combine(wireDelayData);
sortOut = Sort(combineOut, sort_sortKey1, sort_sortKey2);
eventCandidates = EventSearch(sortOut, gate, detectorCoincidence, channelCoincidence,
	eventCoincidence);
