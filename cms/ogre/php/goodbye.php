<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <?php
    //include the config file...
    include "config.php";
    ?>
    <title>Error 404? Or is it something more? When does a perceptual schematic become consciousness? When does a difference engine become the search for truth? When does a personality simulation become the bitter mote... of a soul?</title>
    <Script Language="JavaScript" Type="Text/Javascript" SRC="/~ogre/javascript/restore-include.js"></Script>
    
    <Script>
      <?php
      
      echo "var triedPage = '".$_SERVER['REQUEST_URI']."'";
      ?>;

      var url = triedPage.split('/');
      triedPage = url[3];

      function Find(event){
	var request = "/~ogre/asp/check_archive.asp?sessionID="+triedPage;
	var xmlHttp=new XMLHttpRequest();
	xmlHttp.open("GET",request,false);
	xmlHttp.send(null);
	var isArchived = parseInt(xmlHttp.responseText);

	if ( isArchived ) {
	  document.getElementById('restoreForm').sessionID.value = triedPage;
          restoreArchive(event,triedPage);
	} else {
	  // get the user name associated with this session ID
	  var request = "/~ogre/asp/Burrito.asp?sessid="+triedPage+"&iotype=getUser";
	  var xmlHttp=new XMLHttpRequest();
	  xmlHttp.open("GET",request,false);
	  xmlHttp.send(null);
	  var userName = xmlHttp.responseText;
	  setCookie('sessionID',triedPage);
	  document.location.href = "/~ogre/ogre.php?user="+userName;
	}

	return;
      }
    </Script>
  </head>
  <body onLoad='javascript:Find();'>
    <h1>Well, congratulations! You have come accross the temporary 404 page! What does that mean? It means you had an "Error 404" while this test 404 page was put in place to trap errors resulting from an attempted access of an archived study.</h1>
    <p>Either you have simply had an error and need to return to whatever you were doing and try again, or you are one of the wonderful programmers working to improve this site. As I said, this is a temporary page and should, once the proper code is in place, be transparent to the everyday user, unless the aforementioned archived study isn't present, in which case the user will just have to put up with it's ugly sight!</p>
    <p>000 000 000 000 000 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>000 000 000 000 404 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>000 000 000 404 000 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>000 000 000 404 000 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>000 000 404 000 000 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>000 404 000 000 000 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>404 000 000 000 000 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>404 404 404 404 404 404 404 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>000 000 000 000 000 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>000 000 000 000 000 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>000 000 000 000 000 404 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000<br>000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000 / 000 000 000 000 000 000 000 000</p>
    <div class="background" name="Bert" id="background">
      <img src="/~ogre/graphics/ogre.png" id="funnyOgre">
    </div>
    <!-- Form for grabbing previous investigations -->
    <form method="POST" id='restoreForm' name="restore"
	action="/~ogre/cgi-bin/restore.pl.cgi"
        onsubmit='return submitForm(document.forms["restore"]);'
	style="float:right;">
	<input type='hidden' name="sessionID"/>
    </form>
    <input Type=Button id='Find' value="Try to dig up my study!"
	onClick="javascript:Find(event);"><br>

  </body>
</html>
