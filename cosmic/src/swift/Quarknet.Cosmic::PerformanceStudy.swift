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

(File combined) Combine(File data[]) {
	app {
		Combine @filename(data) @filename(combined);
	}
}

(File out[]) SingleChannel(File inf, int channel) {
	app {
		SingleChannel @filename(inf) @filename(out) channel;
	}
}

(File out[]) Frequency (File inf[], string binType, string binValue, string col) {
	app {
		Frequency @filename(inf) @filename(out) col binType binValue;
	}
}

(File image, File outfile_param) Plot(string ptype, string caption, AxisParams x, AxisParams y, 
	AxisParams z, string title, File infile[]) {
	
	app {
		Plot 
			"-file" @filenames(infile)
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

File rawData[] <fixed_array_mapper;files=@arg("rawData")>;
File thresholdAll[] <fixed_array_mapper;files=@arg("thresholdAll")>;
File combineOut <fixed_mapper;file=@arg("combineOut")>;

string detector = @arg("detector");

string freq_binType = @arg("freq_binType");
string freq_binValue = @arg("freq_binValue");
string freq_col = @arg("freq_col");

File singlechannelOut[] <fixed_array_mapper;files=@arg("singlechannelOut")>;
File freqOut[] <fixed_array_mapper;files=@arg("freqOut")>;

string plot_caption = @arg("plot_caption");
//File extraFun_out <fixed_mapper;file=@arg("extraFun_out")>;

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


File plot_outfile_param <fixed_mapper;file=@arg("plot_outfile_param")>;

string plot_plot_type = @arg("plot_plot_type");

File plot_outfile_image <fixed_mapper;file=@arg("plot_outfile_image")>;

string plot_title = @arg("plot_title");


int singlechannel_channel = @arg("singlechannel_channel");


//the actual workflow
thresholdAll = ThresholdTimes(rawData, detector);
combineOut = Combine(thresholdAll);
singleChannelOut = SingleChannel(combineOut, singlechannel_channel);
freqOut = Frequency(singleChannelOut, freq_binType, freq_binValue, freq_col);

(plot_outfile_image, plot_outfile_param) = Plot(plot_plot_type, plot_caption, x, y, z, plot_title,
	freqOut);
