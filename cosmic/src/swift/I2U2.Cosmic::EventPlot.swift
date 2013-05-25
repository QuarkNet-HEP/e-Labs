type File {}

type AxisParams {
	string low;
	string high;
	string label;
}

(File out) EventChoice(File inf, string eventNum, string zeroZeroZeroID, string geoDir, File geoFiles[]) {
	app {
		EventChoice @filename(inf) @filename(out) eventNum zeroZeroZeroID @filename(geoDir);
	}
}


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

(File png) SVG2PNG(File svg, string height) {
	app {
		SVG2PNG "-h" height "-w" height @filename(svg) @filename(png);
	}
}


string eventNum = @arg("eventNum");
string zeroZeroZeroID = @arg("zeroZeroZeroID");

File eventCandidates <single_file_mapper;file=@arg("eventCandidates")>;
File eventFile <single_file_mapper;file=@arg("eventFile")>;

string geoDir = @arg("geoDir");
File geoFiles[] <fixed_array_mapper;files=@arg("geoFiles")>;

string plot_caption = @arg("plot_caption");

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

eventFile = EventChoice(eventCandidates, eventNum, zeroZeroZeroID, geoDir, geoFiles);

File svg <"plot.svg">;
(svg, plot_outfile_param) = Plot(plot_plot_type, plot_caption, x, y, z, plot_title,
	eventFile);

File png <single_file_mapper;file=@arg("plot_outfile_image")>;

string plot_size = @arg("plot_size");
png = SVG2PNG(svg, plot_size);
File thumb <single_file_mapper;file=@arg("plot_outfile_image_thumbnail")>;
string plot_thumbnail_height = @arg("plot_thumbnail_height");
thumb = SVG2PNG(svg, plot_thumbnail_height);
