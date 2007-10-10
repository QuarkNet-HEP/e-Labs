type file;

(file f) echo(string msg) {
	app {
		echo "**" msg "**" stdout=@f;
	}
}

string text = @arg("text");

file out <single_file_mapper;file=@arg("output")>;

out = echo(text);
