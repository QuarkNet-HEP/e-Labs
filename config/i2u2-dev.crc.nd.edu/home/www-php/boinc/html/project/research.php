<?php
require_once('../inc/db.inc');
require_once('../inc/util.inc');


$hide_user=true;

page_head("I2U2  Research Goals",true);

echo "
  <a name='I2U2'>
  <h3> Interactions in Understanding the Universe (I2U2)
  </h3>

  <blockquote>

   The overall goal of  <em>Interactions in Understanding the Universe</em> is
   to support and strengthen the education and outreach activities 
   of Grid-based
   scientific experiments that utilize federated resources at
   U.S. labs and universities. 

   This year a group of scientists,
   computer scientists and educators are committed to building a rich
   portfolio of coherent, online collaborative labs and to planning an
   Education Virtual Organization to support participants and
   developers long-term across projects.

   <P>

  I2U2 will develop and maintain a virtual portfolio of laboratories 
  (\"e-Labs\" and \"i-Labs\") for
  a diverse range of audiences, and will provide tools and support
  services to assist developers in creating these educational
  resources.

  These laboratories break new ground by using the Grid for
  education in the same way that science uses the Grid.

   <P>

   I2U2 is initially a collaboration between 
   the Adler Planetarium and Astronomy Museum,
   Fermilab & QuarkNet,
   the ATLAS, CMS and MARIACHI experiments,
   the Laser Interferometer Gravitational-wave Observatory (LIGO),
   the University of Chicago,
   and the University of Houston. 	


   <P>

  One potential component of the I2U2 web portal is a set of on-line 
  discussion rooms, similar to the discussion forums provided by BOINC based
  projects like SETI@Home and Einstein@Home.   
  We are using this site to test the idea that we can use
  the BOINC forum code for I2U2 without too much effort.
  Is this a useful alternative to e-mail, telecons, meetings, and the logbooks,
  or is it just a distraction?
  We don't know the right answer yet, 
  which is why it's called 'research'.

  <P>

  This is only a small part of the overall I2U2 effort for LIGO.
  We will also develop e-Labs and supporting software tools
  that will allow high school students and their teachers to make
  use of the wealth of data collected by LIGO's environmental monitors, 
  which include seismometers, tiltmeters, magnetometers, and weather stations.
  Students will be able to learn about science by actually participating in 
  investigative projects, and there is a real potential to make a contribution
  to LIGO's search for gravitational waves by adding to our understanding 
  of the sources of background noise.

  </blockquote> 

  ";



echo "
  <h3> Getting Started
  </h3>
  <blockquote>

   Participation in the I2U2 discussion site is intially by invitation
   only.
   You will need to enter an invitation code in order to create an
   account.
   Contact the Fermilab education office if you need to obtain an
   invitation code.

  </blockquote>

  ";

page_tail();
?>
