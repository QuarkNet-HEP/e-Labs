<?php

require_once("../inc/util.inc");
require_once("../inc/news.inc");
require_once("../project/project_news.inc");

page_head("News archive");

echo "\n<blockquote>\n";

show_old_news($project_news, 0);

echo "<P ALIGN=RIGHT>
	<a href=rss_main.php>". PROJECT." News via RSS</a>
    <a href='http://validator.w3.org/feed/check.cgi?url=".URL_BASE."rss_main.php'>
        <img src='/images/valid-rss.png'
             alt='[Valid RSS]''  title='Validate this RSS feed' /></a>
";

echo "\n</blockquote>\n";
page_tail();

?>
