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

(File combined) Combine(File data[]) {
	app {
		Combine @filename(data) @filename(combined);
	}
}

(File out[]) SingleChannel(File inf, string channel) {
	app {
		SingleChannel @filename(inf) @filename(out) channel;
	}
}

(File out) Frequency (File inf, string binType, string binValue, string col) {
	app {
		Frequency @filename(inf) @filename(out) col binType binValue;
	}
}

(File out[]) FrequencyMultiple (File inf[], string binType, string binValue, string col) {
	foreach data, i in inf {
		out[i] = Frequency(inf[i], binType, binValue, col);
	}
}

(File image, File outfile_param) Plot(string ptype, string caption, AxisParams x, AxisParams y, 
	AxisParams z, string title, File infile[]) {
	
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

(File png) SVG2PNG(File svg, string height) {
	app {
		SVG2PNG "-h" height "-w" height @filename(svg) @filename(png);
	}
}


File rawData[] <fixed_array_mapper;files=@arg("rawData")>;
//File thresholdAll[] <fixed_array_mapper;files=@arg("thresholdAll")>;
//This is done to avoid corruption of threshold files when created
//concurrently by multiple runs
File thresholdAll[] <structured_regexp_mapper;source=rawData,match=".*/(.*)",transform="\\1.thresh">;
File combineOut;

string detectors[] = @strsplit(@arg("detector"), "\\s");
string cpldfreqs[] = @strsplit(@arg("cpldfreqs"), "\\s");

string freq_binType = @arg("freq_binType");
string freq_binValue = @arg("freq_binValue");
string freq_col = @arg("freq_col");

File singleChannelOut[] <fixed_array_mapper;files=@arg("singlechannelOut")>;
File freqOut[] <fixed_array_mapper;files=@arg("freqOut")>;

string plot_caption = @arg("plot_caption");
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


//the actual workflow
thresholdAll = ThresholdTimesMultiple(rawData, detectors, cpldfreqs);
combineOut = Combine(thresholdAll);
singleChannelOut = SingleChannel(combineOut, singlechannel_channel);
freqOut = FrequencyMultiple(singleChannelOut, freq_binType, freq_binValue, freq_col);

File svg;
(svg, plot_outfile_param) = Plot(plot_plot_type, plot_caption, x, y, z, plot_title,
	freqOut);

File png <single_file_mapper;file=@arg("plot_outfile_image")>;

string plot_size = @arg("plot_size");
png = SVG2PNG(svg, plot_size);
File thumb <single_file_mapper;file=@arg("plot_outfile_image_thumbnail")>;
string plot_thumbnail_height = @arg("plot_thumbnail_height");
thumb = SVG2PNG(svg, plot_thumbnail_height);
