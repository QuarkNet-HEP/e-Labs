<?php
require_once("../inc/util.inc");

page_head("BBCode tags");
echo "

<p>
BBCode tags let you format text in your profile and message-board postings.
It's similar to HTML, but simpler.
The tags start with a [ (where you would have used &lt; in HTML)
and end with ]
(where you would have used &gt; in HTML).</p>
<p>Examples:</p>
<ul>
	<li>[b]Bold[/b] to <b>Bold</b>
	<li>[i]Italic[/i] to <i>Italic</i>
	<li>[u]Underline[/u] to <u>Underline</u>
	<li>[size=20]Absolute size[/size] to 
		<span style=\"font-size: 20px\">Absolute size</span>
		(in pixels)
  	<li>[size=+1]Relative size[/size] to 
		<font size='+1'>Relative size</font> (from -7 to +7)
		(this is prefered!)
	<li>[color=red]Red text[/color] to produce
		<font color=\"red\">Red text</font>
	<li>[url=http://google.com/]Google[/url] links to
		<a href=\"http://google.com/\">Google</a>
	<li>[quote]Quoted[/quote] for quoted blocks of text
	<li>[quote=someone]Quoted[/quote] for quoted blocks of text, citing quoted author
	<li>[img]http://some.web.site/pic.jpg[/img] to display an image
	<li>[code]Code snippet here[/code] to display some code
	<li>[pre]Pre-formatted text here[/pre] to display some pre-formatted text
	<li>[[Term]] link to a term defined in the Library (our wiki)
	<li>[[w:Term]] link to a term defined in the Wikipedia
	<li>[[bz:280]] links to Bug
	      <a href='http://bugzilla.mcs.anl.gov/i2u2/show_bug.cgi?id=280'>280</a>
		in our Bugzilla.


</ul>
<p>Lists are also possible:<br/>[list]<br/>*Item 1<br/>*Item 2<br/>[/list] to:</p>
<ul>
	<li>Item 1
	<li>Item 2
</ul>
<p>
If you don't close a tag or don't specify a parameter correctly,
the raw tag itself will display instead of the formatted text.</p>
";
page_tail();
?>
