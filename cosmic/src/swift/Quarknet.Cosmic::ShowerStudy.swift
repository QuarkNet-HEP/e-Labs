type File {}

type AxisParams {
	string low;
	string high;
	string label;
}

(File thresholdData[]) ThresholdTimes(File rawData[], string detector) {
	app {
		ThresholdTimes @filename(rawData) @filename(thresholdData) detector;
	}
}

(File wireDelayData[]) WireDelay(File thresholdData[], File geoDir, File geoFiles[]) {
	app {
		WireDelay @filename(thresholdData) @filename(wireDelayData) @filename(geoDir);
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

(File out) EventChoice(File inf, string eventNum, string zeroZeroZeroID, File geoDir, File geoFiles[]) {
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
			"-lowz " z.low
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
File thresholdAll[] <fixed_array_mapper;files=@arg("thresholdAll")>;
File wireDelayData[] <fixed_array_mapper;files=@arg("wireDelayData")>;
string detector = @arg("detector");
File combineOut <single_file_mapper;file=@arg("combineOut")>;
File sortOut <single_file_mapper;file=@arg("sortOut")>;

File geoDir <single_file_mapper;file=@arg("geoDir")>;
File geoFiles[] <fixed_array_mapper;files=@arg("geoFiles")>;

string plot_caption = @arg("plot_caption");
File extraFun_out <single_file_mapper;file=@arg("extraFun_out")>;

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


File plot_outfile_param <single_file_mapper;file=@arg("plot_outfile_param")>;

string plot_plot_type = @arg("plot_plot_type");
string plot_title = @arg("plot_title");
string sort_sortKey1 = @arg("sort_sortKey1");
string sort_sortKey2 = @arg("sort_sortKey2");


//the actual workflow
thresholdAll = ThresholdTimes(rawData, detector);
wireDelayData = WireDelay(thresholdAll, geoDir, geoFiles);
combineOut = Combine(wireDelayData);
sortOut = Sort(combineOut, sort_sortKey1, sort_sortKey2);
eventCandidates = EventSearch(sortOut, gate, detectorCoincidence, channelCoincidence,
	eventCoincidence);
eventFile = EventChoice(eventCandidates, eventNum, zeroZeroZeroID, geoDir, geoFiles);

File svg;
(svg, plot_outfile_param) = Plot(plot_plot_type, plot_caption, x, y, z, plot_title,
	eventFile, extraFun_out);

File png <single_file_mapper;file=@arg("plot_outfile_image")>;

string plot_size = @arg("plot_size");
png = SVG2PNG(svg, plot_size);
File thumb <single_file_mapper;file=@arg("plot_outfile_image_thumbnail")>;
string plot_thumbnail_height = @arg("plot_thumbnail_height");
thumb = SVG2PNG(svg, plot_thumbnail_height);

