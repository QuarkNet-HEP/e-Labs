/*
 * Prototype basically everything so that each instance
 * of the class uses the same set in memory and doesn't
 * consume huge chunks of the stack
 */

// Prototype the persistant elements of the class
jsWindowlet.prototype.newWin;
jsWindowlet.prototype.browser;

// And the persistant functions of the class
jsWindowlet.prototype.getXMLTheme     = _getXMLTheme;
jsWindowlet.prototype.add_script      = _add_script;
jsWindowlet.prototype.add_style       = _add_style;
jsWindowlet.prototype.getElementStyle = _getElementStyle;
jsWindowlet.prototype.tile            = _tile;

// functions for dragging the windowlet around the browser window
jsWindowlet.prototype.dragStart = _dragStart;
jsWindowlet.prototype.dragGo    = _dragGo;
jsWindowlet.prototype.dragStop  = _dragStop;

// conveinience functions for the buttons and such
jsWindowlet.prototype.setStack  = _setStacking;
jsWindowlet.prototype.close     = _closeWin;
jsWindowlet.prototype.expand    = _expand;
jsWindowlet.prototype.minimize  = _minimize;
jsWindowlet.prototype.maximize  = _maximize;
jsWindowlet.prototype.help      = _help;
jsWindowlet.prototype.restore   = _restoreIcon;

// Windowlet effects
jsWindowlet.prototype.fade      = _fade;
jsWindowlet.prototype.setAlpha  = _setAlpha;

// User functions to fiddle with stuff
jsWindowlet.prototype.setTitle      =  _setTitle;
jsWindowlet.prototype.setStatus     =  _setStatus;
jsWindowlet.prototype.setStyle      =  _setStyle;
jsWindowlet.prototype.bind          =  _bind;
jsWindowlet.prototype.unbind        =  _unbind;
jsWindowlet.prototype.scale         =  _scale;
jsWindowlet.prototype.wScale        =  _wScale;
jsWindowlet.prototype.hScale        =  _hScale;
jsWindowlet.prototype.fScale        =  _fScale;
jsWindowlet.prototype.changeBkg     =  _changeBkg;
jsWindowlet.prototype.shAdjust      =  _shAdjust;
jsWindowlet.prototype.setMinTop     =  _setMinTop;
jsWindowlet.prototype.setMinLeft    =  _setMinLeft;
jsWindowlet.prototype.move          =  _move;
jsWindowlet.prototype.moveTo        =  _moveTo;
jsWindowlet.prototype.getLeft       =  _getLeft;
jsWindowlet.prototype.getTop        =  _getTop;
jsWindowlet.prototype.changeContent =  _changeContent;
jsWindowlet.prototype.loadContent   =  _loadContent;
/*jsWindowlet.prototype.reThemeAll    =  _reThemeAll;*/
jsWindowlet.prototype.reTheme       =  _reTheme;
jsWindowlet.prototype.destruct      =  _destruct;

function _add_script(filename) {
    var head = document.getElementsByTagName('head')[0];
    var scripts = head.getElementsByTagName('script');
    for ( var i=0; i<scripts.length; i++ ) {
	if ( scripts[i].src && scripts[i].src.indexOf(filename) > -1 )
	    return;
    }

    var script = document.createElement('script');
    script.src = filename;
    script.type = 'text/javascript';

    head.appendChild(script);

    return;
}

function _add_style(filename) {
    var head = document.getElementsByTagName('head')[0];
    var links = head.getElementsByTagName('link');

    var text = new String();
    for ( var i=0; i<links.length; i++ ) {
	text = "comparing "+links[i].href+" to "+filename+'\n';
	if ( links[i].href.indexOf(filename) > -1 ) {
	    //alert(text);
	    return;
	}
    }

    var style = document.createElement('link');
    style.rel = "stylesheet";
    style.href = filename;
    style.type = "text/css";

    head.appendChild(style);
    
    return;
}

function createXMLHttp() {
    var xmlHttp;
    try {
	// Firefox, Opera 8.0+, Safari
	xmlHttp=new XMLHttpRequest();
    } catch (e) {
	// Internet Explorer
	try {
	    xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e) {
	    try {
		xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
	    } catch (e) {
		alert("Your browser does not support AJAX!");
		return false;
	    }
	}
    }
    return xmlHttp;
}

// Declare the global variables (used by all instances of the psuedo-class)
var stack = (stack == null) ? new Array() : stack;

var showEffects = false;      // Allow fade in/out graphics effects?
var singleWindow = false;     // Show multiple windowlets? Or just one?
var dragObj = new Object();   // Object for dragging windows around the screen
var expObj  = new Object();   // Object for expanding the windowlet
var em2px   = 16;             // Conversion from em to pixels.. determined in the instantiator
var themePath = new String(); // Path to the theme elements

// Browser detect so we can institute corrections for M$ IE
var browser = new Object();
browser.isIE = (/MSIE (\d+\.\d+);/.test(navigator.userAgent));
browser.ieVer = (browser.isIE) ? new Number(RegExp.$1) : -1;

function jsWindowlet (xmlFile, showMe, makeMe, element, myClass, title, width, height) {

    // Create the base object we'll be stuffing everything into
    this.newWin = new Object();
    this.newWin.visible = false;

    // get the theme XML file for definitions of the pieces
    this.themeXML = _getXMLTheme(xmlFile);
    
    // Get the path to the theme elements from the definition file
    var theme = this.themeXML.getElementsByTagName("theme")[0];
    this.themePath = new String();
    this.themePath = theme.getAttribute('path');
    themePath = theme.getAttribute('path');

    // The theme path dosen't have to exist... but if it doesn't
    // then everything that's used in the theme... style sheets
    // images, etc MUST have a fully qualified path, either on the
    // file system of the server or a full URL. If the themePath
    // does exist... make sure it ends in a / just in case
    if ( this.themePath ) {
	if ( this.themePath.substr(this.themePath.length-1,this.themePath.length) != "/" )
	    this.themePath += "/";
    }

    // Load the stylesheets associated with this theme
    var styles = this.themeXML.getElementsByTagName("style");
    for ( var i=0; i<styles.length; i++ )
	this.add_style(this.themePath + styles[i].childNodes[0].nodeValue);

    var scripts = this.themeXML.getElementsByTagName("script");
    for ( var i=0; i<scripts.length; i++ )
	this.add_script(scripts[i].childNodes[0].nodeValue);

    // Set up the exposed API
    this.make          = _makeWindowlet;
    this.setStyle      = _setStyle;
    this.bind          = _bind;
    this.unbid         = _unbind;
    this.scale         = _scale;
    this.wScale        = _wScale;
    this.hScale        = _hScale;
    this.fScale        = _fScale;
    this.show          = _show;
    this.hide          = _hide;
    this.unhide        = _unhide;
    this.setTitle      = _setTitle;
    this.setStatus     = _setStatus;
    this.changeBkg     = _changeBkg;
    this.shAdjust      = _shAdjust;
    this.setMinTop     = _setMinTop;
    this.setMinLeft    = _setMinLeft;
    this.changeContent = _changeContent;
    this.loadContent   = _loadContent;
    /*this.reThemeAll    = _reThemeAll;*/
    this.reTheme       = _reTheme;
    this.destruct      = _destruct;

    // Just for IE... throw up a temporary div to measure how many pixels there
    // are in 1em. This comes in way down below because MS refuses to return
    // a proper getComputedStyle and the currentStyle call will return the 
    // font definition from the stylesheet in em if it was defined as em.
    var temp = document.createElement('DIV');
    temp.style.position = "absolute";
    temp.style.width = "1em";
    temp.style.height = "1em";
    temp.id = 'tempDIV';
    temp.style.display = "block";

    document.body.appendChild(temp);
    em2px = document.getElementById('tempDIV').offsetWidth;

    // All done... now we can use the conversion factor to correct 
    // another IE inadequecy later on down the line
    document.body.removeChild(document.getElementById('tempDIV'));

    // Set the limits of where the windowlet can travel
    // Top & Left are necessary, but bottom/right aren't
    // since the broswer will put on scrollbars for content
    // that goes down & right, but won't do so for content
    // going up & left -- so it's possible to "lose" a 
    // windowlet. If you've got a persistant header or
    // nav frame on the left set these so the windowlet
    // doesn't get trapped under it and lost
    this.minTop  = 0;
    this.minLeft = 0;

    // Now that the class is basically ready... check the other variables
    // and see if we're auto-constructing/showing the new windowlet
    if ( makeMe ) {
	if ( element && myClass ) {
	    this.make(element, myClass, (title)?title:null, (width)?width:null, (height)?height:null);

	    // If -- and only if -- the class was made... are we showing it right off?
	    if ( showMe )
		this.show(this.newWin);
	}
    }

    return this;
}

function _getXMLTheme(themeXML) {

    var xmlHttp=createXMLHttp();

    // Process this as a synchronus request since we need the result to proceed
    var request = themeXML;
    xmlHttp.open("GET",request,false);
    xmlHttp.send(null);
    return xmlHttp.responseXML;
}

function fnLoadPngs(img, width, height) {

    // Do a last chance browser check... 
    // if this is IE v5.0 and the theme
    // includes PNGs ... we're screwed
    // since the AlphaImageLoader class
    // doesn't exist for 5.0... The
    // only solution is to use JPG and
    // no filter effects in the theme
    if ( browser.ieVer < 5.5 || browser.ieVer > 6 )
	return false;

    // Last ditch fallback for setting height/width of the image
    // If these are needed AND they're zero then the image must
    // absolutely have a style or it'll get displayed at 0,0
    var w = (width>0)  ? width  : 0;
    var h = (height>0) ? height : 0;

    if ( img.src.match(/\.png$/i) != null ) {
	var src = img.src;
	var div = document.createElement("DIV");

	div.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + 
	    src + "', sizingMethod='scale')";

	// set a size for the div.. otherwise IE assumes it's 0px,0px and won't show it
	// Further more.... IE refuses to recognize an image size until *after* it's 
	// loaded... so try what we have with cascading try/catch blocks until we find
	// something that works
	try {
	    if ( image.style.width ) 
		div.style.width  = img.style.width;
	    else
		throw(e);
	} catch (e) {
	    try {
		if ( img.width )
		    div.style.width = img.width + 'px';
		else
		    throw(e);
	    } catch (e) {
		if (w)
		    div.style.width = w;
	    }
	}
	try {
	    if ( img.style.height )
		div.style.height = img.style.height;
	    else
		throw(e);
	} catch (e) {
	    try {
		if ( img.height )
		    div.style.height = img.height + 'px';
		else
		    throw(e);
	    } catch (e) {
		if ( h )
		    div.style.height = h;
	    }
	}

	div.className = img.className+'IE';
		img.replaceNode(div);

    }

    img.style.visibility = "visible";
    div.id = img.id+'ieDiv';
    
    return div;
}

function _makeWindowlet (element, myClass, title, width, height) {

    // What if the "element" isn't actually there? :O OH @#_%(#!
    // Assume the programmer knows what they're doing... and that
    // the "element" is a string denoting the ID and create the 
    // new DIV for them
    if ( !element ) {
	var contID = element;
	element    = new Object();
	element.id = contID;
	element    = document.createElement('DIV');
    }

    // Test for IE... shut off effects 
    // for old versions IE has trouble 
    // with transparent pngs
    if (browser.isIE && browser.ieVer < 5.5 )
	showEffects = false;

    // Take the given page element and turn it into a new windowlet
    // all the element content will get pushed down while a background
    // image, a drag/title bar, footer, and window buttons get added 
    // Grab the ID first so we can make use of it for reference down the line
    try {
	var id = element.id;
    } catch(e) {
	var id = 'ele'+stack.length;
    }

    // Take the XML and parse  the classes
    var windowlets = this.themeXML.getElementsByTagName("windowlet");

    for ( var i=0; i<windowlets.length; i++ ) {

	// Get the class name assigned to the windowlet
	var wClass = windowlets[i].getAttribute('class');

	// And match it to the requested class in the function call
	if ( wClass != myClass ) {

	    // We already found the right class... no sense working any more
	    if ( this.newWin.id )
		continue;

	    // if there are more definitions keep on searching for the windowlet class
	    if ( i < windowlets.length - 1 )
		continue;
	    
	    // But... if we've reached the end of the line... then use the last class 
	    // defined in the theme definition file since there's no other choice
	}

	// So now we have the basics for creating the windowlet container
	this.newWin = document.createElement('DIV');
	this.newWin.id = id+'Win';

	// Define the top/left of the windowlet... can be overridden by the stylesheet
 
	this.newWin.style.top  = parseInt(1.1*this.minTop)  + 'px';
	this.newWin.style.left = parseInt(1.1*this.minLeft) + 'px';
	this.newWin.className = wClass;

	this.id = id+'Obj';
	this.newWin.thisObj = this;
	this.myClass = myClass;

	// Since javascript really horks up the "this" keyword... 
	// Keep a pointer to the object in the windowlet object
	this.newWin.parentObj = this;

	// Keep a pointer to the title for ease of use later
	this.newWin.titleText = new String(); 
	if ( title )
	    this.newWin.titleText = title;
	else
	    this.newWin.titleText = null;

	// and the state variables of this windowlet
	this.newWin.iconized = false;
	this.newWin.maximized = false;
	this.newWin.minimized = false;
	this.newWin.visible = false;

	// Background image.... there can be only one... 
	try {
	    var bkg = windowlets[i].getElementsByTagName("background")[0];
	    var bkgSrc = bkg.getAttribute('src');
	    if ( bkgSrc )
		bkgSrc = this.themePath + bkgSrc;
	    var bkgClass = bkg.getAttribute('class');

	    // If the height/width weren't defined in the call.... 
	    // see if they're defined in the XML file... 
	    if ( !width ) {
		try {
		    width = parseInt(bkg.getAttribute('width'));
		} catch (e) {}
	    }
	    if ( !height ) {
		try {
		    height = parseInt(bkg.getAttribute('height'));
		} catch (e) {}
	    }

	    // And (maybe) a background image?
	    if ( bkgSrc != null ) {
		var bkgImg = document.createElement('IMG');
		bkgImg.src = bkgSrc;
		bkgImg.id = id+'BkgImg';
		bkgImg.alt = "";
		bkgImg.title = "";
		bkgImg.className = (bkgClass != null) ? bkgClass : null;

		// Keep a pointer to the original height/width of the background
		// incase we need to resize the windowlet later on
		this.bkgWidth  = parseInt(bkg.getAttribute('width'));
		this.bkgHeight = parseInt(bkg.getAttribute('height'));

		// If we *still* don't have a width/height...
		// try and define them from the background image
		if ( !width )
		    width = bkgImg.width;
		else  // Otherwise... set the background image to the windowlet size
		    bkgImg.width = width;

		if ( !height )
		    height = bkgImg.height;
		else
		    bkgImg.height = height;

		// And add this image to the windowlet as the background
		this.newWin.appendChild(bkgImg);
		this.newWin.bkgImg = bkgImg;

		if ( browser.isIE && browser.ieVer >= 5.5 ) {
		    if ( showEffects || browser.ieVer < 7 )
			fnLoadPngs(bkgImg, width, height);
		}

	    } //End of if ( bkgSrc != null ) {} else {}

	} catch (e) {}

	// If we've got a size... define the windowlet geometry
	// (stuck here so that if there's no size definition we can 
	// grab it from the size of the background image)
	(width  != null) ? this.newWin.style.width  = width  + 2 + 'px' : null;
	(height != null) ? this.newWin.style.height = height + 2 + 'px' : null;

	// If there's a defined style for the icon.... store the class name for minimization
	var iconClass = windowlets[i].getElementsByTagName("icon")[0];
	if ( iconClass )
	    this.newWin.iconClass = iconClass.getAttribute('class');

	// get the title bar definition....
	var ttlBar = windowlets[i].getElementsByTagName("titleBar")[0];
	if ( ttlBar ) {
	    var titleBar = document.createElement('DIV');
	    titleBar.id = id+'TitleBar';
	    titleBar.className = ttlBar.getAttribute('class');

	    // See if we've got backing graphics for the title bar
	    var ttlBkg = ttlBar.getElementsByTagName('titleBkg')[0];
	    if ( ttlBkg ) {
		ttlBackground = document.createElement('IMG');
		ttlBackground.id = id+'TtlBkg';
		ttlBackground.alt = "";
		ttlBackground.src = this.themePath + ttlBkg.getAttribute('src');
		ttlBackground.style.position = "absolute";

		if ( browser.isIE && browser.ieVer >= 5.5 ) {
		    if ( showEffects || browser.ieVer < 7 )
			fnLoadPngs(ttlBackground);
		}

		// And add the backgroud to the title bar
		titleBar.appendChild(ttlBackground);
		titleBar.ttlBkg = ttlBackground;

		// See if there's an inactive title image as well
		var ttlIkg = ttlBar.getElementsByTagName('inactive')[0];
		if ( ttlIkg ) {
		    if ( ttlIkg.getAttribute('src') ) {
			ttlInactive = document.createElement('IMG');
			ttlInactive.id = id+'TtlBkg';
			ttlInactive.alt = "";
			ttlInactive.className = ttlIkg.getAttribute('class');
			ttlInactive.src = this.themePath + ttlIkg.getAttribute('src');
			ttlInactive.style.position = "absolute";

			if ( browser.isIE && browser.ieVer >= 5.5 ) {
			    if ( showEffects || browser.ieVer < 7 )
				fnLoadPngs(ttlInactive);
			}

			// And add the backgroud to the title bar
			titleBar.appendChild(ttlInactive);
			titleBar.ttlIkg = ttlInactive;
		    }
		} // End of if ( ttlIkg )
	    } else {
		// No backing image... try and find a simple style class for inactive windows
		var ttlBkgClass = windowlets[i].getElementsByTagName('titleIn')[0];
		if ( ttlBkgClass ) {
		    titleBar.inactiveClass = ttlBkgClass.getAttribute('class');
		    titleBar.activeClass   = titleBar.className;
		}
	    } // End of if ( ttlBkg )
	    
	    // And stick the title bar onto the windowlet
	    this.newWin.appendChild(titleBar);
	    this.newWin.titleBar = titleBar;

	    // See what -- if any -- elements are to be added to the title bar
	    // Possibilities: title (text), dragBar (div), buttons (div+img)
	    var draggable = ttlBar.getElementsByTagName('dragBar')[0];
	    if ( draggable ) {
		var dragBar = document.createElement('DIV');
		dragBar.id = id+'DragBar';
		dragBar.onmousedown = this.dragStart;
		dragBar.className = draggable.getAttribute('class');

		// Add it to the title bar
		titleBar.appendChild(dragBar);

		// And keep a pointer for reference
		titleBar.dragBar = dragBar;
	    }

	    if ( title ) {
		var titleCLS = ttlBar.getElementsByTagName('title')[0];
		
		var wTitleText = document.createTextNode(title);
		if ( !browser.isIE )
		    wTitleText.id = id+'TitleText';
		if ( titleCLS )
		    wTitleText.className = titleCLS.getAttribute('class');

		// And append the title div to the draggable div if it's there
		// (so that clicking on the title invokes the drag)
		if ( dragBar ) {
		    dragBar.appendChild(wTitleText);
		    dragBar.wTitleText = wTitleText;
		} else {     // Otherwise stick it to the titleBar directly
		    titleBar.appendChild(wTitleText);
		    titleBar.wTitleText = wTitleText;
		}

	    } // End if ( title )

	    // See what/kind/how many buttons we're adding in
	    var buttons = ttlBar.getElementsByTagName('button');
	    if ( buttons.length )
		titleBar.buttons = new Array();

	    for ( var j=0; j<buttons.length; j++ ) {
		// Create the button container
		var btn = document.createElement('DIV');
		btn.id = id+buttons[j].getAttribute('class');
		btn.alt = "";
		btn.className = buttons[j].getAttribute('class');

		// the button image... if it exists
		var btnSrc = buttons[j].getAttribute('src');
		if ( btnSrc ) {
		    var btnImage = document.createElement('IMG');
		    btnImage.src = this.themePath + btnSrc;
		    btnImage.className = buttons[j].getAttribute('class');

		    // Append the image to the container...
		    btn.appendChild(btnImage);
		    btn.image = btnImage;

		    if ( browser.isIE ) {
			if ( showEffects || browser.ieVer < 7 )
			    fnLoadPngs(btnImage);
		    }
		} // End of if (btnSrc)

		// and the container to the title bar
		titleBar.appendChild(btn);

		// And keep a pointer to the button for later reference
		//titleBar[btn.className] = btn;
		if ( !browser.isIE || browser.ieVer > 5.01 )
		    titleBar.buttons.push(btn);
		else
		    titleBar.buttons[titleBar.buttons.length++] = btn;

		// And now the fun part.... bind the specified event to 
		// the callback function :O
		var event = buttons[j].getAttribute('event');
		var functn = buttons[j].getAttribute('action');
		if ( event != null && functn != null ) {
		    btn[event] = this[functn];
		}

	    } // End of if (buttons)

	} // End of if (ttlBar)

	// OK... so the top of the windowlet is all set up....
	// now it's time to deal with the bottom of it
	var ftr = windowlets[i].getElementsByTagName('footer')[0];
	if ( ftr ) {
	    var footer = document.createElement('DIV');
	    footer.id = id+'Footer';
	    footer.className = ftr.getAttribute('class');

	    // As always... stick it onto the window and keep a pointer thereto
	    this.newWin.appendChild(footer);
	    this.newWin.footer = footer;

	    // Add a status bar for text to the footer
	    var statBar = windowlets[i].getElementsByTagName('status')[0];
	    if ( statBar ) {
		var status = document.createElement('DIV');
		status.id = id+'Stat';
		status.className = statBar.getAttribute('class');

		// Add the status bar to the footer
		footer.appendChild(status);
		footer.status = status;
	    }

	    // And... finally.... build the windowlet expander for drag resizes
	    var exp = windowlets[i].getElementsByTagName('expand')[0];
	    if ( exp ) {
		var expand = document.createElement('DIV');
		expand.id = id+'Exp';
		expand.className = exp.getAttribute('class');

		// Attach the callback function if it was defined
		var event = exp.getAttribute('event');
		var functn = exp.getAttribute('action');
		if ( event != null && functn != null )
		    expand[event] = this[functn];

		// Add it to the footer
		footer.appendChild(expand);
		footer.expand = expand;

	    } // End of if(exp)
	} // End of if ( ftr )

	// Just in case... see if there are style rules for the HTML content element... just in case
	var contentStyle = windowlets[i].getElementsByTagName('content')[0].getAttribute('class');

    } // End of for ( var i=0; i<windowlets.length; i++ ) loop

    /////////////////////////////////////////////////////////////////////////////
    // Now that the primary windowlet is there... attach the original HTML element
    // to it as the windowlet content

    // Create an area for the content
    var content = document.createElement('DIV');
    content.id = id+"Content";

    //// If there was a style class in the XML.. use it...
    if ( contentStyle != null ) {
	content.className = contentStyle;
    } else {             // otherwise try and set some sensible defaults
	element.style.position = "relative";
	element.style.width = eval(width - 64)+'px';
	element.style.height = eval(height-48)+'px';
	element.style.overflow = "auto";
	element.style.left = "32px";
	element.style.top  = "16px";
	element.style.zIndex = 3;
    }

    // And put in the original HTML element as a child of the window
    if ( element ) { // But only if it exists
	content.appendChild(element);
	content.element = element;
    }
    this.newWin.appendChild(content);
    this.newWin.content = content;

    // Hide the windowlet until explicitly called in show
    this.newWin.style.display = "none";

    // and attach it to the current document
    document.body.appendChild(this.newWin);

    // Now store the new window in the stack array so we can 
    // deal with multi-window stacks.
    if ( !browser.isIE || browser.ieVer > 5.01 )
	stack.push(this.newWin);
    else
	stack[stack.length++] = this.newWin;

    // Create a generic drag object for use in the mouse drag functions
    dragObj = new Object();
    dragObj.zIndex = 10;
    dragObj.start = true;

    // Copy the minimum top/left position of the windowlet from "this" into the dragObj
    dragObj.minTop  = this.minTop;
    dragObj.minLeft = this.minLeft;

    return;
}

function _setMinTop(top) {   
    this.minTop = (top != null && !isNaN(top)) ? top : 0;
    dragObj.minTop = this.minTop;

    return;
}

function _setMinLeft(left) {
    this.minLeft = (left != null && !isNaN(left)) ? left : 0;
    dragObj.minLeft = this.minLeft;
    return;
}

var counter = 0;
function _tile() {

    var overlap = false;
    counter++;
    if ( counter > 15 )
	return;

    // if we aren't doing one-at-a-time... tile windowlets
    if ( !singleWindow ) {
	var thisLeft = parseInt(_getElementStyle(this.newWin,'left'));
	var thisTop  = parseInt(_getElementStyle(this.newWin,'top'));
	for ( var i=0; i<stack.length; i++ ) {
	    if ( stack[i].visible ) {
		var left = parseInt(_getElementStyle(stack[i],'left'));
		var top  = parseInt(_getElementStyle(stack[i],'top'));
		if ( top == thisTop || left == thisLeft )
		    overlap = true;
	    }
	}
    }

    if ( overlap ) {
	var width  = _getElementStyle(this.newWin,'width');
	var height = _getElementStyle(this.newWin,'height');
	this.setStyle(this.newWin, 'top', eval(thisTop+0.1*height)+'px');
	this.setStyle(this.newWin, 'left', eval(thisLeft+0.1*width)+'px');

	this.tile();

    }

    return;
}

function _show () {

    var top  = parseInt(_getElementStyle(this.newWin, 'top'));
    var left = parseInt(_getElementStyle(this.newWin, 'left'));

    if ( top < this.minTop )
	_setStyle(this.newWin, 'top', this.minTop+'px');
    if ( left < this.minLeft )
	_setStyle(this.newWin, 'left', this.minLeft+'px');

    if ( this.newWin.visible ) {
	this.setStack(this.newWin);
	return;
    }

    if ( !this.newWin.id )
	return;

    // Grab hold of the computed style to get our currect stacking index
    var mySelf = document.getElementById(this.newWin.id);
    var zIndex = _getElementStyle(mySelf, 'z-index');
    zIndex = (isNaN(zIndex)) ? 0 : zIndex;

    this.newWin.currentZ = zIndex;
    this.newWin.oldZ     = zIndex;

    // And set this to the top of the stack
    this.setStack(this.newWin);

    // Now that we're stacked... show the windowlet to the user
    if ( !showEffects )
	_setStyle(this.newWin,"display","block");
    else {
	this.setAlpha(this.newWin, 0);
	this.newWin.style.display = "block";
	this.fade(this.newWin, true);
    }

    // Try not to stack the windowlets on top of each other
    this.tile();

    // Store our current visibility state in the windowlet object
    this.newWin.visible = true;
    return;
}

function _unhide() {
    this.newWin.visible = true;
    this.newWin.style.display = "block";
    return;
}

function _hide () {
    this.newWin.visible = false;
    this.newWin.style.display = "none";
    return;
}

function testF(myObject) {
    myObject.id = myObject.id+'Changed';
    window.status = myObject.id+' ';
    return;// myObject;
}

// Relative move function
function _move(left, top) {
    this.newWin.style.left = parseInt(this.newWin.style.left) + 
	parseInt(left) + 'px';
    this.newWin.style.top  = parseInt(this.newWin.style.top)  + 
	parseInt(top)  + 'px';
    return;
}

// Absolute move function
function _moveTo(left, top) {
    this.newWin.style.left = parseInt(left) + 'px';
    this.newWin.style.top  = parseInt(top)  + 'px';
    return;
}

function _getLeft() {
    return parseInt(this.newWin.style.left);
}

function _getTop() {
    return parseInt(this.newWin.style.top);
}


function flushTheme() {

    var links = document.getElementsByTagName('link');
    var head = document.getElementsByTagName('head')[0];

    var store = new Array();
    for ( var i=0; i<links.length; i++ ) {
	if ( links[i].href && links[i].href.indexOf(themePath) > -1 ) {
	    if ( !browser.isIE || browser.ieVer > 5.01 )
		store.push(links[i]);
	    else
		store[store.length++] = links[i];
	}
    }
    for ( var i=0; i<store.length; i++ )
	head.removeChild(store[i]);

    return;
}

function reThemeAll(newTheme, windowlets) {

    flushTheme();

    for ( var i=0; i<windowlets.length; i++ ) {
	windowlets[i] = windowlets[i].reTheme(newTheme, windowlets[i].myClass);
    }

    return;
}

function _reTheme(newTheme, wClass) {

    var title   = new String();
    var content = new Object();
    var showMe  = this.newWin.visible;
    var width   = this.newWin.bkgImg.width;
    var height  = this.newWin.bkgImg.height;

    var boundWin = new Object();

    for ( var i=0; i<this.newWin.titleBar.buttons.length; i++ ) {

	if ( this.newWin.titleBar.buttons[i].binding != null ) {
	    boundWin = this.newWin.titleBar.buttons[i].binding;
	    boundWin.thisClass = this.newWin.titleBar.buttons[i].className;
	}
    }

    // Save the windowlet content
    this.newWin.content.className = null;
    content = this.newWin.content.firstChild;
    
    // And the windowlet title
    if ( this.newWin.titleBar ) {
	if ( this.newWin.titleBar.dragBar ) {
	    try {
		title = this.newWin.titleBar.dragBar.wTitleText.nodeValue;
	    } catch (e) {}
	} else {
	    try {
		title = this.newWin.titleBar.wTitleText.nodeValue;
	    } catch (e) {}
	}
    }

    // Walk the windowlet and flush all the class names
    if ( this.newWin.titleBar ) {
	if ( this.newWin.titleBar.dragBar ) {
	    if ( this.newWin.titleBar.dragBar.wTitleText ) {
		try {
		    this.newWin.titleBar.dragBar.wTitleText.className = null;
		} catch (e) {}
	    }
	    try {
		this.newWin.titleBar.dragBar.className = null;
	    } catch (e) {}

	} else if ( this.newWin.titleBar.wTitleText ) {
	    try {
		this.newWin.titleBar.wTitleText.className = null;
	    } catch (e) {}
	}
	for ( var i=0; i<this.newWin.titleBar.buttons.length; i++ ) {
	    try {
		this.newWin.titleBar.buttons[i].className = null;
	    } catch (e) {}
	}
	try {
	    this.newWin.titleBar.className = null;
	} catch (e) {}
    }
    if ( this.newWin.footer ) {
	if ( this.newWin.footer.statusBar ) {
	    try {
		this.newWin.footer.className = null;
	    } catch (e) {}
	}
	if ( this.newWin.footer.expand ) {
	    try {
		this.newWin.footer.expand.className = null;
	    } catch (e) {}
	}
	try {
	    this.newWin.footer.className = null;
	} catch (e) {}
    }
    try {
	this.newWin.className = null;
    } catch (e) {}

    // Destruct the windowlet elements
    this.hide();
    var deleted;
    try {
	deleted = document.body.removeChild(this.newWin);
    } catch (e) {}

    // And reconstruct the windowlet with the new theme
    if ( deleted ) {
	var newThis = new jsWindowlet(newTheme);
	newThis.make(content, wClass, title);
	newThis.id = newThis.id;

	document.body.appendChild(newThis.newWin);

	if ( showMe )
	    newThis.show();

	if ( boundWin.id )
	    newThis.bind(boundWin.thisClass,boundWin);

	return newThis;
    } else
	return false;
    return null;
}

function _destruct () {
    // Try and determine if this refers to a button? Or the top level object?
    if ( this.id.indexOf('Obj') > -1 )
	var thisObj = this;
    else
	var thisObj = this.parentNode.parentNode.thisObj;

    thisObj.hide();
    var deleted = document.body.removeChild(thisObj.newWin);
    deleted = deleted && (delete thisObj);

    return deleted;
}

// User function to set the status text
function _setStatus( text ) {
    if ( this.newWin.footer && this.newWin.footer.status )
	this.newWin.footer.status.innerHTML = text;
    return;
}

// simple routine to set the style of an element
function _setStyle(element, property, value) {
    if ( element ) {
	try {
	    (element.style||element)[property] = value;
	} catch (e) {}
    }
    return;
}

// Routine to change the background image of a windowlet
function _changeBkg(newBkg, useTheme) {
    var useTheme = (useTheme != null) ? useTheme : true;
    this.newWin.bkgImg.src = (useTheme) ? this.themePath + newBkg : newBkg;
    return;
}

function _dragStart(event) {

    // If we're only showing windowlets one at a time... inhibit dragging
    if (singleWindow)
	return;

    event = (!event) ? window.event : event;

    // Get the button in a cross-browser fashion
    var button = event.button || event.which;
    
    // And only accept button 1 presses
    if ( button != 1 )
	return false;

    dragObj.elNode = this.parentNode.parentNode;

    // Don't accept the event if the windowlet is maximized
    if ( dragObj.elNode.maximized )
	return false;

    var el;
    var x = y = 0;

    /* Cute but mildy annoying effect...*/
    if ( showEffects ) {
	(browser.isIE) ? 
	    dragObj.elNode.style.filter='alpha(opacity=50)' : 
	    dragObj.elNode.style.opacity = 0.5;
    }

    // Reset the stack
    _setStacking(dragObj.elNode);

    // And ave the current stacking information
    dragObj.Z = dragObj.elNode.style.zIndex;
    
    // Get cursor position with respect to the page.
    x = event.clientX + window.scrollX || 
	window.event.clientX + document.documentElement.scrollLeft + document.body.scrollLeft;
    y = event.clientY + window.scrollY ||
	window.event.clientY + document.documentElement.scrollTop + document.body.scrollTop;

    dragObj.start = false;

    // Save starting positions of cursor and element.
    dragObj.cursorStartX = x;
    dragObj.cursorStartY = y;
    dragObj.elStartLeft  = parseInt(dragObj.elNode.style.left, 10);
    dragObj.elStartTop   = parseInt(dragObj.elNode.style.top,  10);

    // If we don't already know where this thing is... find out
    if ( isNaN(dragObj.elStartLeft) || isNaN(dragObj.elNodeStartTop) ) {
	var curleft = curtop = -1;
	var obj = dragObj.elNode;
	if (obj.offsetParent) {
	    do {
		curleft += obj.offsetLeft;
		curtop  += obj.offsetTop;
	    } while (obj = obj.offsetParent);
	}
	dragObj.elStartLeft = curleft;
	dragObj.elStartTop  = curtop;
    }

    // If we *still* don't know where it is... just set it to (0,0)
    if (isNaN(dragObj.elStartLeft)) dragObj.elStartLeft = 0;
    if (isNaN(dragObj.elStartTop))  dragObj.elStartTop  = 0;

    // Update element's z-index.
    dragObj.elNode.style.zIndex = ++dragObj.zIndex;

    // Capture mousemove and mouseup events on the page.
    if (browser.isIE) {
	document.attachEvent("onmousemove", _dragGo   );
	document.attachEvent("onmouseup",   _dragStop );
	window.event.cancelBubble = true;
	window.event.returnValue = false;
    } else {
	try {
	    document.addEventListener("mousemove", _dragGo,   true);
	    document.addEventListener("mouseup",   _dragStop, true);
	    event.preventDefault();
	} catch (e) { alert(e); }
    }

    // Set the cursor to move to indicate that we be mobile
    dragObj.cursor = dragObj.elNode.style.cursor;
    dragObj.elNode.style.cursor = "move";

    return;
}

function _dragGo(event) {
    var x = y = 0;

    // Get cursor position with respect to the page.
    x = event.clientX + window.scrollX || 
	window.event.clientX + document.documentElement.scrollLeft + document.body.scrollLeft;
    y = event.clientY + window.scrollY ||
	window.event.clientY + document.documentElement.scrollTop + document.body.scrollTop;

    if ( y<dragObj.minTop ) {
	dragObj.elNode.style.top = eval(parseInt(dragObj.elNode.style.top) + 1) + 'px';
	return;
    }
    if ( x<dragObj.minLeft ) {
	dragObj.elNode.style.left = eval(parseInt(dragObj.elNode.style.left) + 1) + 'px';
	return;
    }

    // Move drag element by the same amount the cursor has moved.
    dragObj.elNode.style.left =
	(dragObj.elStartLeft + x - dragObj.cursorStartX) + "px";
    dragObj.elNode.style.top  =
	(dragObj.elStartTop  + y - dragObj.cursorStartY) + "px";

    if (browser.isIE) {
	window.event.cancelBubble = true;
	window.event.returnValue = false;
    } else
	event.preventDefault();

    return;
}

function _dragStop(event) {

    var sessId = getCookie("sessionID");
    // Stop capturing mousemove and mouseup events.
    if (browser.isIE) {
	document.detachEvent("onmousemove", _dragGo);
	document.detachEvent("onmouseup",   _dragStop);
    } else {
	document.removeEventListener("mousemove", _dragGo, true);
	document.removeEventListener("mouseup",   _dragStop, true);
    }

    /*end of cute but mildy annoying effect */
    if ( showEffects) {
	(browser.isIE) ? 
	    dragObj.elNode.style.filter = 'alpha(opacity = 100)' :
	    dragObj.elNode.style.opacity = 1.0;
    }

    // Restore the objects original style (saved in dragStart)
    dragObj.elNode.style.zIndex = dragObj.Z;
    dragObj.zIndex = 10;
    dragObj.elNode.style.cursor = dragObj.cursor;
    // load the URI page into the content div
    var xmlHttp = [];
    var request;
    var windowNum;

    for ( i=0; i<3; i++ )
	xmlHttp[i] = createXMLHttp();

    /*
     * States: 0 == The request is not initialized
     *         1 == The request has been set up
     *         2 == The request has been sent
     *         3 == The request is in process
     *         4 == The request is complete
     */
    xmlHttp[0].onreadystatechange=function (){
	if(xmlHttp[0].readyState==4) {
	    xmlHttp[0].close;
	    return true;
	}
    }
    xmlHttp[1].onreadystatechange=function (){
	if(xmlHttp[1].readyState==4) {
	    xmlHttp[1].close;
	    return true;
	}
    }
    xmlHttp[2].onreadystatechange=function (){
	if(xmlHttp[2].readyState==4) {
	    xmlHttp[0].close;
	    return true;
	}
    }

    //Determine which window was being moved
    switch(dragObj.elNode.id){
    case "controlsWin":
	windowNum = 1;
        break;
    case "graphWin":
	windowNum = 2;
	break;
    case "histWin":
	windowNum = 3;
        break;
    default:
	//alert ("Non-registered window");
    }
    //Send coordinates to settings database
    if (windowNum > 0 && windowNum < 4){
	request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID + "&iotype=send&parameter=left" +  windowNum + "&value=" + parseInt(dragObj.elNode.style.left);
	xmlHttp[0].open("GET",request,true);
	xmlHttp[0].send(null);
	request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID + "&iotype=send&parameter=top" +  windowNum + "&value=" + parseInt(dragObj.elNode.style.top);
	xmlHttp[1].open("GET",request,true);
	xmlHttp[1].send(null);
	request = baseURL + "/asp/Burrito.asp?sessid=" + sessionID + "&iotype=send&parameter=activeWin&value='" + dragObj.elNode.id + "'";
	xmlHttp[2].open("GET",request,true);
	xmlHttp[2].send(null);
    }
    if ( !singleWindow )
	_setStacking(dragObj.elNode);

    return;
}

function _setStacking(top) {

    for ( var i=0; i<stack.length; i++ ) {
	try {
	    if ( stack[i].visible && stack[i].id != top.id ) {
		if ( singleWindow ) {    // If we're only doing one at a time... hide everything else
		    stack[i].thisObj.hide();
		} else {
		    stack[i].style.zIndex = stack[i].oldZ;
		    stack[i].currentZ = stack[i].oldZ;

		    // Check and see if we have an inactive display definition
		    if ( stack[i].titleBar.ttlIkg ) {                // Inactive bkg on title bar
			stack[i].titleBar.ttlIkg.style.display = "block";
			stack[i].titleBar.ttlBkg.style.display = "none";
		    } else if ( stack[i].titleBar.inactiveClass ) {  // CSS class for inactivity
			if ( browser.isIE && showEffects)
			    stack[i].titleBar.style.filter = 'alpha(opacity=50)';
			stack[i].titleBar.className = stack[i].titleBar.inactiveClass;
		    }
		}
	    }
	} catch (e) {}
    }

    top.style.zIndex = 6;
    top.currentZ = 6;

    // If there's an inactive class... swap back the active class for the top of the stack
    if (top.titleBar.ttlBkg) {
	top.titleBar.ttlBkg.style.display = "block";
	if ( top.titleBar.ttlIkg )
	    top.titleBar.ttlIkg.style.display = "none";
    } else if ( top.titleBar.activeClass ) {
	if ( browser.isIE && showEffects )
	    top.titleBar.style.filter = 'alpha(opacity=100)';
	top.titleBar.className = top.titleBar.activeClass;
    }

    return;
}

function _changeContent(element) {
    if ( this.newWin.content ) {
	this.newWin.content.removeChild(this.newWin.content.element);
	element.className = this.newWin.content.className;
	this.newWin.content.appendChild(element);
	this.newWin.content.element = element;
    }
    return;
}

function _loadContent(URI) {

    var thisObj = this;

    if ( !URI )
	return false;

    // load the URI page into the content div
    var xmlHttp=createXMLHttp();
    var request;

    /*
     * States: 0 == The request is not initialized
     *         1 == The request has been set up
     *         2 == The request has been sent
     *         3 == The request is in process
     *         4 == The request is complete
     */
    xmlHttp.onreadystatechange=function() {
	if(xmlHttp.readyState==4) {
	    thisObj.newWin.content.innerHTML = xmlHttp.responseText;
	    //alert(xmlHttp.responseText);
	    return true;
	}
    }

    // Send the Ajax request to the server
    xmlHttp.open("GET",URI,true);
    xmlHttp.send(null);

    return true;
}

function _unbind(button) {

    for ( var i=0; i< this.newWin.titleBar.buttons.length; i++ ) {
	if ( this.newWin.titleBar.buttons[i].className.indexOf(button) > -1 ) {
	    this.newWin.titleBar.buttons[i].binding = null;
	    return true;
	}
    }

    return false;
}

function _setTitle(title) {

    // Find out where the title is being kept
    var titleNode = new Object();
    if ( this.newWin.titleBar.dragBar )
	titleNode = this.newWin.titleBar.dragBar;
    else if (this.newWin.titleBar)
	titleNode = this.newWin.titleBar;

    // If the title node doesn't already exist... create it now
    if ( !titleNode.wTitleText ) {
	var wTitleText = document.createTextNode(title);
	titleNode.appendChild(wTitleText);
	titleNode.wTitleText = wTitleText;
    }

    // And set the new title
    titleNode.wTitleText.nodeValue = title;
    
    return;
}

function _bind( button, windowlet ) {

    for ( var i=0; i< this.newWin.titleBar.buttons.length; i++ ) {
	if ( this.newWin.titleBar.buttons[i].className.indexOf(button) > -1 ) {
	    if ( windowlet ) {
		this.newWin.titleBar.buttons[i].binding = windowlet;
		return true;
	    }
	}
    }
    return false;
}

function _help(event) {
    if ( this.binding ) {
	this.binding.show();
	return true;
    }
    return false;
}

function _restoreIcon(win, icon) {
    if ( !win.iconized )
	return;

    document.body.removeChild(icon);
    win.iconized = false;
    win.visible = true;

    if ( !showEffects )
	win.style.display = "block";
    else
	_fade(win,true);

    _setStacking(win);
    return;
}

function _minimize() {

    // get a pointer to the windowlet
    var win = this.parentNode.parentNode;

    // figure out if we're iconizing or unmaximizing...
    if ( win.maximized ) {

	var myWidth = 0, myHeight = 0;
	if( !browser.isIE ) {
	    myWidth = window.innerWidth;
	    myHeight = window.innerHeight;
	} else if ( browser.ieVer >= 6 ) {
	    //IE 6+ in 'standards compliant mode'
	    myWidth = document.documentElement.clientWidth;
	    myHeight = document.documentElement.clientHeight;
	} else {
	    //IE 4 compatible
	    myWidth = document.body.clientWidth;
	    myHeight = document.body.clientHeight;
	}

	var wScaleFactor = eval( win.oldWidth / myWidth );
	var hScaleFactor = eval( win.oldHeight/myHeight );

	_wScale(wScaleFactor, win.id);
	_hScale(hScaleFactor, win.id);
	_fScale( (wScaleFactor>hScaleFactor)?wScaleFactor:hScaleFactor, win.id);

	// OK... simple stuff....
	win.style.left   = parseInt(win.oldLeft)   + 'px';
	win.style.top    = parseInt(win.oldTop)    + 'px';
	win.titleBar.max.style.display = "block";
	win.maximized = false;
 
	// Unhide the visible windowlets
	for ( var i=0; i<stack.length; i++ ) {
	    if (stack[i].id != win.id && stack[i].visible)
		stack[i].style.display = "block";
	    else if ( stack[i].iconized )
		stack[i].icon.style.display = "block";
	}

	return;
    }
    
    // Iconizing... create an icon and hide the window...

    // Hide the parent windowlet
    win.style.display = "none";
    win.iconized = true;
    win.visible = false;

    // and create an "icon" at the bottom
    var icon = document.createElement('DIV');
    icon.id = win.id+'_icon';
    win.icon = icon;

    // If there's an icon class.... use it...
    if ( win.iconClass )
	icon.className = win.iconClass;
    else {                // Otherwise set some simple defaults
	icon.style.position = "relative";
	icon.style.cssFloat = "left";
	icon.style.display = "block";

	// Set the text styles
	icon.style.fontSize = "0.75em";
	icon.style.color = "#f3f3f3";
	icon.style.textAlign = "center";

	icon.style.border = "1px solid";
	icon.style.width = "128px";
	icon.style.margin = "2px";
    }

    if ( browser.isIE )
	icon.style.cursor = "hand";
    else
	icon.style.cursor = "pointer";

    if ( win.titleText )
	icon.innerHTML = win.titleText;
    else
	icon.innerHTML = win.id;

    // attach the restore function to the onclick event
    icon.onclick = function(event) { _restoreIcon(win, icon); }

    document.body.appendChild(icon);

    return;
}

function _maximize() {
    var win = this.parentNode.parentNode;

    win.oldWidth  = win.clientWidth;
    win.oldHeight = win.clientHeight;
    win.oldLeft   = _getElementStyle(win, 'left');
    win.oldTop    = _getElementStyle(win, 'top');

    // Save a pointer to the max button so we can restore it later
    win.titleBar.max = this;

    var myWidth = 0, myHeight = 0;
    if( !browser.isIE ) {
	myWidth = window.innerWidth;
	myHeight = window.innerHeight;
    } else if ( browser.ieVer >= 6 ) {
	//IE 6+ in 'standards compliant mode'
	myWidth = document.documentElement.clientWidth;
	myHeight = document.documentElement.clientHeight;
    } else {
	//IE 4 compatible
	myWidth = document.body.clientWidth;
	myHeight = document.body.clientHeight;
    }

    var wScaleFactor = eval( myWidth / win.oldWidth );
    var hScaleFactor = eval( myHeight/win.oldHeight );

    _wScale(wScaleFactor, win.id);
    _hScale(hScaleFactor, win.id);
    _fScale( (wScaleFactor>hScaleFactor)?wScaleFactor:hScaleFactor, win.id);


    win.style.top  = '0px';
    win.style.left = '0px';

    this.style.display = "none";
    _setStacking(win);

    // Hide all the other windows for now...
    for ( var i=0; i<stack.length; i++ ) {
	if (stack[i].id != win.id && stack[i].visible)
	    stack[i].style.display = "none";
	else if ( stack[i].iconized )
	    stack[i].icon.style.display = "none";
    }

    win.maximized = true;
    return;
}

function _expand(event) {

    // If there's only one window... inhibit drag resizing
    // (max and min still work, but there's really no need for this)
    if ( singleWindow )
	return;

    var windowlet = this.parentNode.parentNode;
    if ( windowlet.maximized )
	return false;

    // Get cursor position with respect to the page.
    var x = 0;
    var y = 0;
    try {
	x = window.event.clientX + document.documentElement.scrollLeft + document.body.scrollLeft;
    } catch (e) {
	x = event.clientX + window.scrollX;
    }
    try {
	y = window.event.clientY + document.documentElement.scrollTop + document.body.scrollTop;
    } catch (e) {
	y = event.clientY + window.scrollY;
    }

    var top  = _getElementStyle(windowlet, 'top');
    var left = _getElementStyle(windowlet, 'left');

    expObj = document.createElement('DIV');
    expObj.id = 'outline';
    expObj.style.position = "absolute";

    // Put in a transparent gif background... otherwise IE 
    // won't recognize that the div can recieve mouse events
    expObj.style.background = 'url('+baseURL+'/graphics/iebkg.gif)';

    expObj.style.top    = windowlet.style.top;
    expObj.style.left   = windowlet.style.left;
    expObj.style.width  = eval(x - left) + 'px';
    expObj.style.height = eval(y - top) + 'px';

    expObj.style.borderColor = "#ffffff";
    expObj.style.borderWidth = "1px";
    expObj.style.borderStyle = "double";
    expObj.style.zIndex = 15;
    expObj.style.display = "block";

    expObj.myTop = top;
    expObj.myLeft = left;
    expObj.parent = windowlet;
    expObj.style.cursor = "se-resize";

    document.body.appendChild(expObj);

    if ( browser.isIE ) {
	document.attachEvent("onmousemove", _expGo);
	document.attachEvent("onmouseup",   _expStop);
	window.event.cancelBubble = true;
	window.event.returnValue = false;
    } else {
	document.addEventListener("mousemove", _expGo,   true);
	document.addEventListener("mouseup",   _expStop, true);
	event.preventDefault();
    }

    return;
}

function _expGo ( event ) {

    var x = y = 0;

    // Get cursor position with respect to the page.
    x = event.clientX + window.scrollX || 
	window.event.clientX + document.documentElement.scrollLeft + document.body.scrollLeft;
    y = event.clientY + window.scrollY ||
	window.event.clientY + document.documentElement.scrollTop + document.body.scrollTop;

    // Move drag element by the same amount the cursor has moved.
    expObj.style.width  = parseInt(x - expObj.myLeft) + 'px';
    expObj.style.height = parseInt(y - expObj.myTop)  + 'px';

    if (browser.isIE) {
	window.event.cancelBubble = true;
	window.event.returnValue = false;
    } else
	event.preventDefault();

    return;
}

function _expStop( event ) {

    var win = expObj.parent;

    if (browser.isIE) {
	document.detachEvent("onmousemove", _expGo);
	document.detachEvent("onmouseup",   _expStop);
    } else {
	document.removeEventListener("mousemove", _expGo,   true);
	document.removeEventListener("mouseup",   _expStop, true);
    }

    var winWidth    = parseInt(win.style.width);
    var winHeight   = parseInt(win.style.height);
    var outlnWidth  = parseInt(expObj.style.width);
    var outlnHeight = parseInt(expObj.style.height);

    var wScaleFactor = eval( outlnWidth / winWidth );
    var hScaleFactor = eval( outlnHeight/winHeight );

    _wScale(wScaleFactor, win.id);
    _hScale(hScaleFactor, win.id);

    _fScale( (wScaleFactor>hScaleFactor)?wScaleFactor:hScaleFactor, win.id);

    document.body.removeChild(expObj);

    return;
}

function _closeWin() {
    var win = this.parentNode.parentNode;

    // Set the stacking back to the original
    win.style.zIndex = win.oldZ;

    if ( !showEffects )
	win.style.display = "none";
    else
	_fade(win, false);

    win.visible = false;

    return false;
}

function _fade(me, fadeIn, fadeStep, opacity) {

    // Set defaults for the arguments...
    var opacity   = (opacity   == null) ? 0.0 : opacity;
    var fadeStep  = (fadeStep == null) ? 0.05 : fadeStep;
    var fadeIn    = (fadeIn == null) ? true : fadeIn;

    // Fade the current windowlet in/out
    _setAlpha(me, (fadeIn) ? opacity : Math.round(100*(1.0-opacity))/100);
    me.style.display = "block";

    if ( opacity < 1.0) {
	opacity += fadeStep;
	opacity = (opacity >= 1.0) ? 1.0 : opacity;

	if ( !browser.isIE )
	    setTimeout(_fade, 10, me, fadeIn, fadeStep, opacity);
	else {
	    var callback = function() {_fade(me, fadeIn, fadeStep, opacity);};
	    setTimeout(callback, 0);
	}
    } else if ( !fadeIn ) {
	opacity = 0;
	me.style.display = "none";
    } 
    return true;
}

function _setAlpha(which, alpha) {
    if ( !which )
	return false;


    alpha = (alpha < 0) ? 0.0 : alpha;
    alpha = (alpha > 1) ? 1.0 : alpha;

    if ( browser.isIE ) {
	which.style.zoom = 1;
	var filter = 'alpha(opacity='+parseInt(100*alpha)+')';

	which.style.filter = filter;
	if (which.titleBar != null)
	    which.titleBar.style.filter = filter;
	if ( which.content )
	    which.content.style.filter  = filter;
	if ( which.footer )
	    which.footer.style.filter   = filter;
    } else
	which.style.opacity = alpha;

    return true;
}

function _wScale(scaleFactor, wID) {

    // get all the windowlet elements we'll need to move around
    var win = (wID) ? document.getElementById(wID) : this.newWin;

    var image   = win.bkgImg;
    var title   = win.titleBar;
    var footer  = win.footer;
    var content = win.content;

    // Declare the variables we'll need
    var width;
    var height;
    var left;

    // Change the element geometry by scaleFactor
    if ( image ) {
	height = image.height;
	width  = image.width;

	image.width = round(width*scaleFactor);
	image.height = height;

	// Yet another trap for IE... using the image loader in the head
	// to allow PNGs to show up in old versions of IE replaces the IMG
	// element with a DIV... :-< so the resize won't work on the image
	if ( browser.isIE && (showEffects || browser.ieVer < 7) ) {
	    var ieDiv = document.getElementById(image.id+'ieDiv');

	    if ( ieDiv ) {
		width = parseInt(ieDiv.style.width);
		height = parseInt(ieDiv.style.height);

		ieDiv.style.width  = round(width*scaleFactor)  + 'px';
		ieDiv.style.height = height + 'px';
	    }
	}
    }

    // Expand the containing windowlet
    if ( win ) {
	width = _getElementStyle(win, 'width');
	win.style.width  = parseInt( round( width*scaleFactor  ) ) + 'px';
    }

    // Move the title to the left...
    if ( title ) {
	left = _getElementStyle(title, 'left');
	title.style.left = parseInt( round( left*scaleFactor ) ) + 'px';
    }

    // Move the footer up and to the left
    if ( footer ) {
	left = _getElementStyle(footer, 'left');
	footer.style.left = parseInt( round( left*scaleFactor ) ) + 'px';
    }

    // move the content element left, then rescale it
    if ( content ) {
	left = _getElementStyle(content, 'left');
	width = _getElementStyle(content, 'width');
	content.style.left     = parseInt( round( left*scaleFactor ) )   + 'px';
	content.style.width    = parseInt( round( width*scaleFactor ) )  + 'px';
    }

    return;
}

function _hScale(scaleFactor, wID) {

    // get all the windowlet elements we'll need to move around
    var win = (wID) ? document.getElementById(wID) : this.newWin;
    var image   = win.bkgImg;
    var title   = win.titleBar;
    var footer  = win.footer;
    var content = win.content;

    // Declare the variables we'll need
    var width;
    var height;
    var top;
    var bottom;

    // Change the element geometry by scaleFactor
    if ( image ) {
	height = image.height;
	width  = image.width; 
	image.height = round(height*scaleFactor);
	image.width = width;
    }

    // Yet another trap for IE... using the image loader in the head
    // to allow PNGs to show up in old versions of IE replaces the IMG
    // element with a DIV... :-< so the resize won't work on the image
    if ( browser.isIE && (showEffects || browser.ieVer < 7) ) {
	var ieDiv = document.getElementById(image.id+'ieDiv');

	if ( ieDiv ) {
	    width = parseInt(ieDiv.style.width);
	    height = parseInt(ieDiv.style.height);

	    ieDiv.style.width  = width + 'px';
	    ieDiv.style.height = round(height*scaleFactor) + 'px';
	}
    }

    // Expand the containing windowlet
    if ( win ) {
	height = _getElementStyle(win, 'height');
	win.style.height = parseInt( round( height*scaleFactor ) ) + 'px';
    }

    // Move the title down
    if ( title ) {
	top = _getElementStyle(title, 'top');
	height = _getElementStyle(title, 'height');
	title.style.top  = parseInt( round( top*scaleFactor  ) ) + 'px';
	title.style.height = parseInt( round( height*scaleFactor ) ) + 'px';
    }

    // Move the footer up
    if ( footer ) {
	bottom = _getElementStyle(footer, 'bottom');
	height = _getElementStyle(footer, 'height');
	footer.style.bottom  = parseInt( round( bottom*scaleFactor ) ) + 'px';
	footer.style.height = parseInt( round( height*scaleFactor ) ) + 'px';
    }

    // move the content element down & right, then rescale it
    if ( content ) {
	top = _getElementStyle(content, 'top');
	height = _getElementStyle(content, 'height');
	content.style.top      = parseInt( round( top*scaleFactor ) )    + 'px';
	content.style.height   = parseInt( round( height*scaleFactor ) ) + 'px';
    }
    return;
}

function _fScale(scaleFactor, wID) {

    // get all the windowlet elements we'll need for increasing fonts
    var win = (wID) ? document.getElementById(wID) : this.newWin;
    var title   = win.titleBar;
    var footer  = win.footer;
    var content = win.content;

    var size;

    // Increase the font in the titleBar
    if ( title ) {
	size = _getElementStyle(title, 'font-size');
	size = parseInt( round( size*scaleFactor ) );
	title.style.fontSize = (size>=10 && size<=20) ? size + 'px' : title.style.fontSize;
    }

    // and the footer...
    if ( footer ) {
	size = _getElementStyle(footer, 'font-size');
	size = parseInt( round( size*scaleFactor ) );
	footer.style.fontSize = (size>=10 && size<=20) ? size + 'px' : footer.style.fontSize;
    }

    // And the content
    if ( content ) {
	size = _getElementStyle(content, 'font-size');
	size = parseInt( round( size*scaleFactor ) );
	content.style.fontSize = (size>=10 && size<=20) ? size + 'px' : content.style.fontSize;
    }

   return;
}

function _scale ( scaleFactor ) {

    _wScale(scaleFactor, this.newWin.id);
    _hScale(scaleFactor, this.newWin.id);
    _fScale(scaleFactor, this.newWin.id);

    return;
}

function _shAdjust( leftShadow, topShadow, width, height ) {

    //var width  = parseInt(document.forms['mapSize'].histWidth.value);
    //var height = parseInt(document.forms['mapSize'].histHeight.value);

    var title   = this.newWin.titleBar;
    var footer  = this.newWin.footer;
    var content = this.newWin.content;

    var top = eval( leftShadow*height/this.bkgHeight);  // Move the top/left of the major elements
    var lft = eval( topShadow*width/this.bkgWidth);     // to account for the shadows of 16px/24px

    if ( title ) {
	this.setStyle(title, 'top',  top+'px' );
	this.setStyle(title, 'left', lft+'px');
    }
    if ( content ) {
	this.setStyle(content, 'top',  eval(top+20)+'px');
	this.setStyle(content, 'left', eval(lft+8)+'px');

	this.setStyle(content,  'width', width+'px');
	this.setStyle(content,  'height',height+'px');
    }
    if ( footer ) {
	this.setStyle(footer, 'left', lft+'px');
	this.setStyle(footer, 'bottom', top+'px');
    }
    return;
}

function round(number) {
    var decimal = eval(number - parseInt(number));
    number = (decimal>=0.50) ? parseInt(number) + 1 : parseInt(number);
    return number;
}

Number.prototype.NaN=function(){
    return isNaN(this)?0:this;
}

function _getElementStyle(elem, CSSStyleProperty) {

    if (window.getComputedStyle) {
	// CSS Standard... returns the current style value (in px for pixel based values)
	try {
	    var compStyle = window.getComputedStyle(elem, null);
	    return parseInt(compStyle.getPropertyValue(CSSStyleProperty));
	} catch (e) {}

    } else if ( elem.currentStyle ) {
	// IE psuedo version... returns the text rule... in px, or em, of auto, of normal or....
	if ( browser.ieVersion > 5.01 ) {
	    CSSStyleProperty = CSSStyleProperty.replace(/\-(\w)/g, function (strMatch, p1){
		    return p1.toUpperCase();
		});
	} else {      // Apparently v. 5 doesn't have RegEx... :-< 
	    while(-1 != (dashIndex = CSSStyleProperty.indexOf('-'))) {
		CSSStyleProperty = CSSStyleProperty.substring(0,dashIndex) + 
		    CSSStyleProperty.substring(dashIndex + 1, dashIndex + 2).toUpperCase() + 
		    CSSStyleProperty.substring(dashIndex + 2);
	    }
	}

	var value = elem.currentStyle[CSSStyleProperty];
	if ( CSSStyleProperty == "fontSize" && value.indexOf('em') > -1 ) {
	    // Crap... IE handed us the font size in em again... @#%(_@#%)@#$_#@
	    // so...... do a quick & dirty conversion to px from em (conversion
	    // factor is calculated from a 1em div in the class instantiator
	    var em = value.substr(0,value.indexOf('em'));
	    var pixels = parseInt( eval( em2px*em ) );
	    value = pixels;
	}
	value = parseInt(value);
	if ( isNaN(value) ) {
	    value = 0;
	}
	return value;
    }
    return 0;
}
