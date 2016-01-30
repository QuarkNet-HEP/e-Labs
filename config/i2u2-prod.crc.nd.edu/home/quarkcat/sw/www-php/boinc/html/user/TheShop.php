<?php

require_once('../inc/db.inc');
require_once('../inc/util.inc');
db_init(1);				// 1=soft, db may be down

page_head("The I2U2 Shop",true);

echo "
<blockquote> 

As anybody knows, The Shop is where they keep the tools.
So this part of the I2U2 site will be where we keep links to the
tools used by participants in e-Labs and i-Labs.

<P>

But since there aren't  any tools yet, this page is blank.

   ";



echo "
	 </blockquote>
	";

page_tail();

?>
