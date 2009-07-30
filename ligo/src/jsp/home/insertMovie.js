function InsertSampleMovie() {
	document.write('<object classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B" width="320" height="240" codebase="http://www.apple.com/qtactivex/qtplugin.cab">\n');
	document.write('<param name="src" value="gravity-waves.mov" />\n');
	document.write('<param name="autoplay" value="true" />\n');
	document.write('<param name="controller" value="false" />\n');
	document.write('<param name="loop" value="true" />\n');
	document.write('<embed src="gravity-waves.mov" width="320" height="240" autoplay="true" loop="true" controller="false" pluginspage="http://www.apple.com/quicktime/"></embed>\n');
	document.write('</object>\n');
}