type File {}

type AxisParams {
	string low;
	string high;
	string label;
}

//I like File[] better
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

//undocumented magic in @filename - it will make an absolute path relative
//in other words it answers the question: if the parameter was a file,
//what would have its path been on the remote site?
(File wireDelayData) WireDelay(File thresholdData, string geoDir, File geoFile) {
	app {
		WireDelay @filename(thresholdData) @filename(wireDelayData) @filename(geoDir);
	}
}

(File wireDelayData[]) WireDelayMultiple(File thresholdData[], string geoDir, File geoFiles[]) {
	foreach td, i in thresholdData {
		wireDelayData[i] = WireDelay(thresholdData[i], geoDir, geoFiles[i]);
	}
}

(File combined) Combine(File data[]) {
	app {
		Combine @filenames(data) @filename(combined);
	}
}

//"in" doesn't quite work as an identifier
(File out) SingleChannel(File inf, string channel) {
	app {
		SingleChannel @filename(inf) @filename(out) channel;
	}
}

(File out) Sort(File inf, string key1, string key2) {
	app {
		Sort @filename(inf) @filename(out) key1 key2;
	}
}

(File out) Flux(File inf, string binWidth, string geoDir, File geoFiles[]) {
	app {
		Flux @filename(inf) @filename(out) binWidth @filename(geoDir);
	}
}

(File png) SVG2PNG(File svg, string height) {
	app {
		SVG2PNG "-h" height "-w" height @filename(svg) @filename(png);
	}
}

//nor does "type"
(File image, File outfile_param) Plot(string ptype, string caption, AxisParams x, AxisParams y, 
	AxisParams z, string title, File infile) {
	
	app {
		Plot 
			"-file" @filename(infile)
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

File rawData[] <fixed_array_mapper;files=@arg("rawData")>;
//File thresholdAll[] <fixed_array_mapper;files=@arg("thresholdAll")>;
//This is done to avoid corruption of threshold files when created
//concurrently by multiple runs
//"This" means mapping threshold files to local (to the run directory)
//instead of mapping to the ones in the data directory
File thresholdAll[] <structured_regexp_mapper;source=rawData,match=".*/(.*)",transform="\\1.thresh">;
File wireDelayData[] <fixed_array_mapper;files=@arg("wireDelayData")>;
string detectors[] = @strsplit(@arg("detector"), "\\s");
string cpldfreqs[] = @strsplit(@arg("cpldfreqs"), "\\s");
File combineOut;
File fluxOut;
File singleChannelOut <single_file_mapper;file=@arg("singlechannelOut")>;
File sortOut;

string binWidth = @arg("flux_binWidth");
string geoDir = @arg("geoDir");
File geoFiles[] <fixed_array_mapper;files=@arg("geoFiles")>;

string plot_caption = @arg("plot_caption");

//not used
//File extraFun_out <single_file_mapper;file=@arg("extraFun_out")>;

AxisParams x, y, z;

x.high = @arg("plot_highX");
x.low  = @arg("plot_lowX");
x.label = @arg("plot_xlabel");

y.high = @arg("plot_highY");
y.low  = @arg("plot_lowY");
y.label = @arg("plot_ylabel");

z.high = "";
z.low  = "";
z.label = "";


File plot_outfile_param <single_file_mapper;file=@arg("plot_outfile_param")>;

string plot_plot_type = @arg("plot_plot_type");


string plot_title = @arg("plot_title");


string singlechannel_channel = @arg("singlechannel_channel");

string sort_sortKey1 = @arg("sort_sortKey1");
string sort_sortKey2 = @arg("sort_sortKey2");


//the actual workflow
thresholdAll = ThresholdTimesMultiple(rawData, detectors, cpldfreqs);
wireDelayData = WireDelayMultiple(thresholdAll, geoDir, geoFiles);
combineOut = Combine(wireDelayData);
singleChannelOut = SingleChannel(combineOut, singlechannel_channel);
//TODO the following must work:
//sortOut = Sort(singleChannelOut[0], sort_sortKey1, sort_sortKey2);
sortOut = Sort(singleChannelOut, sort_sortKey1, sort_sortKey2);
fluxOut = Flux(sortOut, binWidth, geoDir, geoFiles);
File svg <"plot.svg">;

(svg, plot_outfile_param) = Plot(plot_plot_type, plot_caption, x, y, z, plot_title,
	fluxOut);

File png <single_file_mapper;file=@arg("plot_outfile_image")>;

string plot_size = @arg("plot_size");
png = SVG2PNG(svg, plot_size);
File thumb <single_file_mapper;file=@arg("plot_outfile_image_thumbnail")>;
string plot_thumbnail_height = @arg("plot_thumbnail_height");
thumb = SVG2PNG(svg, plot_thumbnail_height);

