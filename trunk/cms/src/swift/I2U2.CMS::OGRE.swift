type File;

(File out) OGRE() {
	app {
		OGRE "-X" @arg("xmlfile") "-d" @arg("dataset") "-n" @arg("run_number") 
			"-r" @strcat(@arg("all_runs"), ",", @arg("muon_runs"), ",", @arg("pion_runs"), ",", @arg("electron_runs"), ",", @arg("calibration_runs"))
			"-l" @arg("leaf") "-s" @arg("cut") "-c" @arg("color") 
			"-f" @arg("formula") 
			@arg("logx", "") @arg("logy", "") @arg("logz", "") 
			"-w" @arg("gWidth") "-h" @arg("gHeight")
			@arg("allonone", "")
			"-o" @filename(out)
			"-v";
	}
}

(File out) scale(File input, string size) {
	app {
		convert "-size" @strcat(size, "x") @filename(input) @filename(out);
	}
}

File output <single_file_mapper;file=@arg("output")>;
File thumb  <single_file_mapper;file=@arg("thumbnail")>;

output = OGRE();

thumb = scale(output, @arg("thumbHeight", "120"));
