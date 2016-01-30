<?php

require_once('../inc/db.inc');
require_once('../inc/util.inc');
db_init(1);				// 1=soft, db may be down

page_head("The I2U2 Lecture Hall ",true);

echo "
<blockquote> 

This area could be structured to direct participants to on-line
lectures relevant to e-Labs and i-Labs.
It could include an interface to the database used in The Library,
as well as links to other Lecture sites, such
as the <a href='http://www.wlap.org/'
	target='Lectures'>Web Lecture Archive Project</a>
(WLAP) at the University of Michigan, 
the 
<a href='http://www-ppd.fnal.gov/EPPOffice-w/colloq/colloq.html'
	target='Lectures'>
Fermilab Colloquium archive</a>,
and the 
<a href='http://agenda.cern.ch/tools/SSLPdisplay.php?stdate=2001-07-02&nbweeks=6'
   target='Lectures'>CERN Summer Student Lecture Programme 2001</a>
(click on the \"(l)\" symbol for the full syncronized lecture).



<P>

Students could also easily record their own Web Lectures using
the WLAP software and guidelines.  
An example of what is possible is provided by 
<a href='http://www.wlap.org/browser.php?ID=20010809-umwlap002-07-palen'
   target='Lectures'>	
this UM-CERN REU report</a> and
<a href='http://www.wlap.org/browser.php?ID=umich-reu'
   target='Lectures'>other presentations like it</a>.


  </blockquote>
";







echo "<a name='LIGO'>
  <h3>LIGO Lectures 
  </h3>   
   <blockquote>  
    <UL>
    <LI> <em><a href=http://atcaltech.caltech.edu/theater/ram/barish/barish_bb.ram>
    Catching the Waves with LIGO
	</a> by
      Barry Barish (Caltech)

    <P>
    <LI>
      <em><a href='http://esmane.physics.lsa.umich.edu/wl/umich/phys/satmorn/2005/20050507-umwlap001-01-riles/real/f001.htm'>
	\"Gravitational Waves - Ripples of Space\"
	</a></em>  by
      Keith Riles (Univ. Michigan) - 7 May 2005 



    <P>
    <LI>
      <em><a href='http://esmane.physics.lsa.umich.edu/wl/umich/phys/satmorn/2005/20050514-umwlap001-01-riles/real/f001.htm'>
	\"How to Catch a Gravitational Wave\"
	</a></em>  by
      Keith Riles (Univ. Michigan) - 14 May 2005 





   </UL>
   </blockquote>
";



echo "<a name='LIGO'>
  <h3>Fermilab Lectures 
  </h3>   
  <blockquote>
  <UL>	
  <LI>	<a href='http://wlap.physics.lsa.umich.edu/cern/lectures/summer/2000/quigg1/real/f001.htm'>
	Particle Physics: The Standard Model</a>
	by Chris Quigg (CERN Summer Lectures, 2000)


  <P>
  <LI>  <a href='http://www.wlap.org/fermilab/computing/tutorials/2002/dzero-software/verzocchi/'>
	Getting Started with the D Zero Analysis Software</a>  
	by Marco Verzocchi   (University of Maryland)



  </UL>
  </blockquote>
	";


page_tail();

?>
