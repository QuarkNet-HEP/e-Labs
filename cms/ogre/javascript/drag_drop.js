<!-- Start drag_drop script.... hidden from old browsers
var Demos       = [];
var nDemos      = 3;
var useDragDrop = true;
var selection;

// Demo variables
// iMouseDown represents the current mouse button state: up or down
/*
lMouseState represents the previous mouse button state so that we can
check for button clicks and button releases:

if(iMouseDown && !lMouseState) // button just clicked!
if(!iMouseDown && lMouseState) // button just released!
*/
var mouseOffset = null;
var iMouseDown  = false;
var lMouseState = false;
var dragObject  = null;

// Demo 0 variables
var DragDrops   = [];
var curTarget   = null;
var lastTarget  = null;
var dragHelper  = null;
var tempDiv     = null;
var rootParent  = null;
var rootSibling = null;

var mouseLeft   = 0;
var mouseTop    = 0;

var usePush     = 1; // the push method isn't supported in IE < 5.5

// firstCon (firstContainer) tracks which logic set
// is for selection and which is for rejection...
// allows fast switching between selection & rejection
// of filter groups
var firstCon = "select";

//test for MSIE x.x;
var browser = new Object();

Number.prototype.NaN0=function(){
    return isNaN(this)?0:this;
}

function CreateDragContainer(){

    /*
      Create a new "Container Instance" so that items from one "Set" can not
      be dragged into items from another "Set"
    */
    var cDrag        = DragDrops.length;
    DragDrops[cDrag] = [];

    /*
      Each item passed to this function should be a "container".  Store each
      of these items in our current container
    */
    for(var i=0; i<arguments.length; i++){
	var cObj = arguments[i];

	if ( usePush )
	    DragDrops[cDrag].push(cObj);
	else
	    DragDrops[cDrag][DragDrops[cDrag].length++] = cObj;

	cObj.setAttribute('DropObj', cDrag);


	/*
	  Every top level item in these containers should be draggable.  Do this
	  by setting the DragObj attribute on each item and then later checking
	  this attribute in the mouseMove function
	*/
	for(var j=0; j<cObj.childNodes.length; j++){

	    // Firefox puts in lots of #text nodes...skip these
	    if(cObj.childNodes[j].nodeName=='#text')    continue;

            // If there's a comment inside the DIV... (<!-- --> type) Skip it
            // otherwise the page load will hang up
            if(cObj.childNodes[j].nodeName=='#comment') continue;

	    cObj.childNodes[j].setAttribute('DragObj', cDrag);
	}
    }
} // End CreateDragContainer()

function getPosition(e){
    var left = 0;
    var top  = 0;
    while (e.offsetParent){
	left += e.offsetLeft + (e.currentStyle?(parseInt(e.currentStyle.borderLeftWidth)).NaN0():0);
	top  += e.offsetTop  + (e.currentStyle?(parseInt(e.currentStyle.borderTopWidth)).NaN0():0);
	e     = e.offsetParent;
    }

    left += e.offsetLeft + (e.currentStyle?(parseInt(e.currentStyle.borderLeftWidth)).NaN0():0);
    top  += e.offsetTop  + (e.currentStyle?(parseInt(e.currentStyle.borderTopWidth)).NaN0():0);

    return {x:left, y:top};

} // End getPosition(e)

function mouseCoords(ev){
    if(ev.pageX || ev.pageY){
	return {x:ev.pageX, y:ev.pageY};
    }
    return {
	x:ev.clientX + document.body.scrollLeft - document.body.clientLeft,
	    y:ev.clientY + document.body.scrollTop  - document.body.clientTop
	    };
} // End mouseCoords()

function writeHistory(object, message){
    if(!object || !object.parentNode || !object.parentNode.getAttribute) return;
 
    var historyDiv = new Object();
    try {
	historyDiv = object.parentNode.getAttribute('history');
    } catch(e) {return false;}

    if(historyDiv != null && message != null){
	try {
	    historyDiv = document.getElementById(historyDiv);
	    historyDiv.appendChild(document.createTextNode(object.id+': '+message));
	    historyDiv.appendChild(document.createElement('BR'));

	    historyDiv.scrollTop += 50;
	} catch(e) {return false;}
    } else
	return false;

    return true;
} // End writeHistory(object, message)

function getMouseOffset(target, ev){
    ev = ev || window.event;

    var docPos    = getPosition(target);
    var mousePos  = mouseCoords(ev);
    return {x:mousePos.x - docPos.x, y:mousePos.y - docPos.y};

} // End getMouseOffset(target, ev)


var setColor = new Object;
setColor.target = null;
setColor.color  = "#000000";

function mouseMove(ev){
    ev         = ev || window.event;

    /*
      We are setting target to whatever item the mouse is currently on
      Firefox uses event.target here, MSIE uses event.srcElement
    */
    var target   = ev.target || ev.srcElement;
    var mousePos = mouseCoords(ev);

    if(Demos[0] || Demos[2] ) {
	// mouseOut event - fires if the item the mouse is on has changed
	if(lastTarget && (target!==lastTarget)){

	    writeHistory(lastTarget, 'Mouse Out Fired');

	    // reset the classname for the target element
	    var origClass = null;
	    if ( lastTarget && lastTarget.getAttribute )
		origClass = lastTarget.getAttribute('origClass');
	    if(origClass) lastTarget.className = origClass;
	}

	/*
	  dragObj is the grouping our item is in (set from the createDragContainer function).
	  if the item is not in a grouping we ignore it since it can't be dragged with this
	  script.
	*/
	var dragObj = null;
	if ( target && target.getAttribute )
	    dragObj = target.getAttribute('DragObj');

	// if the mouse was moved over an element that is draggable
	if(dragObj!=null){

	    // mouseOver event - Change the item's class if necessary
	    if(target!=lastTarget){
		writeHistory(target, 'Mouse Over Fired');

		var oClass = target.getAttribute('overClass');
		if(oClass){
		    target.setAttribute('origClass', target.className);
		    target.className = oClass;
		}
	    }

	    // if the user is just starting to drag the element
	    if(iMouseDown && !lMouseState){
		writeHistory(target, 'Start Dragging');
		
		// mouseDown target
		curTarget     = target;

		// Record the mouse x and y offset for the element
		rootParent    = curTarget.parentNode;
		rootSibling   = curTarget.nextSibling;

		mouseOffset   = getMouseOffset(target, ev);

		// We remove anything that is in our dragHelper DIV so we can put a new item in it.
		for(var i=0; i<dragHelper.childNodes.length; i++) 
		    dragHelper.removeChild(dragHelper.childNodes[i]);

		// Make a copy of the current item and put it in our drag helper.
		dragHelper.appendChild(curTarget.cloneNode(true));
		dragHelper.style.display = 'block';

		// set the class on our helper DIV if necessary
		var dragClass = curTarget.getAttribute('dragClass');
		if(dragClass){
		    dragHelper.firstChild.className = dragClass;
		}

		// disable dragging from our helper DIV (it's already being dragged)
		dragHelper.firstChild.removeAttribute('DragObj');

		/*
		  Record the current position of all drag/drop targets related
		  to the element.  We do this here so that we do not have to do
		  it on the general mouse move event which fires when the mouse
		  moves even 1 pixel.  If we don't do this here the script
		  would run much slower.
		*/
		var dragConts = DragDrops[dragObj];

		/*
		  first record the width/height of our drag item.  Then hide it since
		  it is going to (potentially) be moved out of its parent.
		*/
		curTarget.setAttribute('startWidth',  parseInt(curTarget.offsetWidth));
		curTarget.setAttribute('startHeight', parseInt(curTarget.offsetHeight));
		curTarget.style.display  = 'none';

		// loop through each possible drop container
		for(var i=0; i<dragConts.length; i++){
		    with(dragConts[i]){
			var pos = getPosition(dragConts[i]);

			/*
			  save the width, height and position of each container.

			  Even though we are saving the width and height of each
			  container back to the container this is much faster because
			  we are saving the number and do not have to run through
			  any calculations again.  Also, offsetHeight and offsetWidth
			  are both fairly slow.  You would never normally notice any
			  performance hit from these two functions but our code is
			  going to be running hundreds of times each second so every
			  little bit helps!

			  Note that the biggest performance gain here, by far, comes
			  from not having to run through the getPosition function
			  hundreds of times.
			*/
			setAttribute('startWidth',  parseInt(offsetWidth));
			setAttribute('startHeight', parseInt(offsetHeight));
			setAttribute('startLeft',   pos.x);
			setAttribute('startTop',    pos.y);
		    }

		    // loop through each child element of each container
		    for(var j=0; j<dragConts[i].childNodes.length; j++){
			with(dragConts[i].childNodes[j]){
			    if((nodeName=='#text') || (dragConts[i].childNodes[j]==curTarget)) continue;

			    var pos = getPosition(dragConts[i].childNodes[j]);

			    // save the width, height and position of each element
			    setAttribute('startWidth',  parseInt(offsetWidth));
			    setAttribute('startHeight', parseInt(offsetHeight));
			    setAttribute('startLeft',   pos.x);
			    setAttribute('startTop',    pos.y);
			}
		    }
		}
	    }
	}

	// If we get in here we are dragging something
	if(curTarget) {

	    // Set the cursor to the grab icon
	    if ( curTarget.origParentNode ) {

		if ( !browser.isIE || browser.ieVersion >= 6 ) {
		    document.getElementById('body').style.cursor = "url('/~ogre/graphics/grab.gif'),pointer";
		    dragHelper.style.cursor = "url('/~ogre/graphics/grab.gif'),pointer";
		    dragHelper.firstChild.style.cursor = "url('/~ogre/graphics/grab.gif'),pointer";
		} else {
		    document.getElementById('body').style.cursor = "hand";
		    dragHelper.style.cursor = "hand";
		    dragHelper.firstChild.style.cursor = "hand";
		}
		dragHelper.firstChild.style.opacity = 0.5;
		if (dragHelper.firstChild.id != "color")
		    dragHelper.firstChild.style.backgroundColor = '#ff99cc';
	    }

	    // move our helper div to wherever the mouse is (adjusted by mouseOffset)
	    dragHelper.style.top  = mousePos.y - mouseOffset.y + 'px';
	    dragHelper.style.left = mousePos.x - mouseOffset.x + 'px';
	    dragHelper.style.zIndex = 10;

	    var x = mousePos.x - mouseOffset.x;
	    var y = mousePos.y - mouseOffset.y;

	    var dragConts  = DragDrops[curTarget.getAttribute('DragObj')];
	    var activeCont = null;

	    var xPos = mousePos.x - mouseOffset.x + (parseInt(curTarget.getAttribute('startWidth')) /2);
	    var yPos = mousePos.y - mouseOffset.y + (parseInt(curTarget.getAttribute('startHeight'))/2);

	    // check each drop container to see if our target object is "inside" the container
	    for(var i=0; i<dragConts.length; i++){
		with(dragConts[i]){
		    if((parseInt(getAttribute('startLeft'))                                           < xPos) &&
		       (parseInt(getAttribute('startTop'))                                            < yPos) &&
		       ((parseInt(getAttribute('startLeft')) + parseInt(getAttribute('startWidth')))  > xPos) &&
		       ((parseInt(getAttribute('startTop'))  + parseInt(getAttribute('startHeight'))) > yPos)){

			/*
			  our target is inside of our container so save the container into
			  the activeCont variable and then exit the loop since we no longer
			  need to check the rest of the containers
			*/
			activeCont = dragConts[i];

			// exit the for loop
			break;
		    }
		}
	    }

	    //
	    /////////////////////////////////// Restricted Variable Dropping ///////////////////////////////////////////
	    // (restrictDrop is defined in the HTML page if you want to use it) //
	    //
	    if ( restrictDrop && curTarget && activeCont ) {

		// Check the drop targets....
		if ( curTarget.parentNode == curTarget.droptarget ) { // this one handles containers 2 & 8
		    if ( activeCont != curTarget.origParentNode && activeCont != curTarget.parentNode )
			activeCont = null;

		// The color blobs shouldn't drop in the main target, only the children in it's drop target
		} else if ( curTarget.origParentNode.id == 'DragContainer3' ) {
		    
		    if ( activeCont != curTarget.droptarget && activeCont != curTarget.origParentNode )
			activeCont = null;

		    else if ( activeCont == curTarget.droptarget ) {
			var subcontainer = inchildContainer( curTarget.droptarget, xPos, yPos );
			if ( subcontainer == null ) {
			    if ( setColor && setColor.target ) {
				setColor.target.style.color = setColor.lastColor;
				setColor.target = null;
			    }
			    activeCont = null;
			} else if ( subcontainer != setColor.target ) {
			    setColor.target    = subcontainer;
			    setColor.lastColor = subcontainer.style.color;
			    setColor.color     =  curTarget.style.backgroundColor;
			    subcontainer.style.color = setColor.color;
			    activeCont = false;
			} else {
			    activeCont = null;
			}
		    }

		    // General case... only allow a child to drop if it's in it's drop target or it's original parent
		} else if ( activeCont != curTarget.droptarget && activeCont != curTarget.origParentNode )
		    activeCont = null;
	    }
	    ///////////////////////////////////////////////////////////////////////////////////////////

	    // Our target object is in one of our containers.  Check to see where our div belongs
	    if(activeCont){
		if(activeCont!=curTarget.parentNode){
		    writeHistory(curTarget, 'Moved into '+activeCont.id);
		}

		// beforeNode will hold the first node AFTER where our div belongs
		var beforeNode = null;

		// loop through each child node (skipping text nodes).
		for(var i=activeCont.childNodes.length-1; i>=0; i--){
		    with(activeCont.childNodes[i]){
			if(nodeName=='#text') continue;

			// if the current item is "After" the item being dragged
			if(curTarget != activeCont.childNodes[i]            &&
			   ((parseInt(getAttribute('startLeft')) + 
			     parseInt(getAttribute('startWidth')))  > xPos) &&
			   ((parseInt(getAttribute('startTop'))  + 
			     parseInt(getAttribute('startHeight'))) > yPos)){
			    beforeNode = activeCont.childNodes[i];
			}
		    }
		}

		// the item being dragged belongs before another item
		if(beforeNode){
		    if(beforeNode!=curTarget.nextSibling){
			writeHistory(curTarget, 'Inserted Before '+beforeNode.id);
			
			activeCont.insertBefore(curTarget, beforeNode);
		    }

		    // the item being dragged belongs at the end of the current container
		} else {
		    if((curTarget.nextSibling) || (curTarget.parentNode!=activeCont)){
			writeHistory(curTarget, 'Inserted at end of '+activeCont.id);
			
			activeCont.appendChild(curTarget);
		    }
		}

		// the timeout is here because the container doesn't "immediately" resize
		setTimeout(function(){
			var contPos = getPosition(activeCont);
			activeCont.setAttribute('startWidth',  parseInt(activeCont.offsetWidth));
			activeCont.setAttribute('startHeight', parseInt(activeCont.offsetHeight));
			activeCont.setAttribute('startLeft',   contPos.x);
			activeCont.setAttribute('startTop',    contPos.y);}, 5);

		// make our drag item visible
		if(curTarget.style.display!=''){
		    writeHistory(curTarget, 'Made Visible');
		    curTarget.style.display    = '';
		    curTarget.style.visibility = 'visible';
		}
	    } else { // not activeCont

		// our drag item is not in a container, so hide it.
		if(curTarget.style.display!='none'){
		    writeHistory(curTarget, 'Hidden');
		    curTarget.style.display  = 'none';
		    curTarget.style.visibility = 'hidden';
		}
	    }
	} else {
	    // Set the cursor to the default
	    document.getElementById('body').style.cursor = "auto";
	}

	// track the current mouse state so we can compare against it next time
	lMouseState = iMouseDown;

	// mouseMove target
	lastTarget  = target;
    }

    if(dragObject){
	dragObject.style.position = 'absolute';
	dragObject.style.top      = mousePos.y - mouseOffset.y;
	dragObject.style.left     = mousePos.x - mouseOffset.x;
    }

    // track the current mouse state so we can compare against it next time
    lMouseState = iMouseDown;
    
    // this prevents items on the page from being highlighted while dragging
    if(curTarget || dragObject) return false;

    mouseLeft = mousePos.x;
    mouseTop  = mousePos.y;

} // End mouseMove(ev)

function inchildContainer(parentNode, xPos, yPos) {

    var subcontainer = parentNode.firstChild;

    while (subcontainer) {
	if ( subcontainer.id != curTarget.id ) {
	    with(subcontainer) {
		var startLeft   = parseInt(getAttribute('startLeft'));
		var startTop    = parseInt(getAttribute('startTop'));
		var startWidth  = parseInt(getAttribute('startWidth'));
		var startHeight = parseInt(getAttribute('startHeight'));

		if ( startLeft < xPos && startLeft+startWidth > xPos &&
		     startTop  < yPos && startTop+startHeight > yPos ) {
		    return subcontainer;
		}
	    }
	    subcontainer = subcontainer.nextSibling;
	}
    }

    return null;

} // End inchildContainer

function mouseUp(ev){

    if ( !useDragDrop )
	return false;

    if ( Demos[0] ) {

	if(curTarget) {
	    writeHistory(curTarget, 'Mouse Up Fired');

	    var id   = curTarget.parentNode.id;

	    // Since XOR doesn't really make sense for more than 2 items....
	    // disallow more than 2 items in the XOR containers
	    if ( id == 'DragContainer13' || id == 'DragContainer17' ) {
		if ( curTarget.parentNode.childNodes.length > 2 ) {
		    // If there are already two... pop the next one
		    // out and replace it with the current node
		    if ( curTarget == curTarget.parentNode.lastChild )
			document.getElementById('DragContainer14').appendChild(curTarget);
		    else
			document.getElementById('DragContainer14').appendChild(curTarget.nextSibling);
		}
	    }

	    // If we're moving a legend.... just swap the text... 
	    // updateLogic() will use that to figure out the order
	    // of operation we want
	    if ( curTarget.id == 'select_legend' ) {

		var reject = document.getElementById('reject_legend');
		var curTag = curTarget.innerHTML.substring(0,6).toLowerCase();

		if ( curTag == "select" ) {
		    curTarget.innerHTML = "Reject events with:";
		    reject.innerHTML    = "Select events with:";
		    firstCon = "reject";
		} else {
		    curTarget.innerHTML = "Select events with:";
		    reject.innerHTML    = "Reject events with:";
		    firstCon = "select";
		}
		dragHelper.style.display = 'none';
		document.getElementById('Demo0').appendChild(curTarget);
		//Demos[0].appendChild(curTarget);

	    } else if ( curTarget.id == 'reject_legend' ) {

		var select = document.getElementById('select_legend');
		var curTag = curTarget.innerHTML.substring(0,6).toLowerCase();

		if ( curTag == "reject" ) {
		    curTarget.innerHTML = "Select events with:";
		    select.innerHTML    = "Reject events with:";
		    firstCon = "reject";
		} else {
		    curTarget.innerHTML = "Reject events with:";
		    select.innerHTML    = "Select events with:";
		    firstCon = "select";
		}
		dragHelper.style.display = 'none';
		document.getElementById('Demo1').appendChild(curTarget);
		//Demos[1].appendChild(curTarget);

	    } else {

		dragHelper.style.display = 'none';
		if(curTarget.style.display == 'none') {
		    if(rootSibling){
			rootParent.insertBefore(curTarget, rootSibling);
		    } else {
			rootParent.appendChild(curTarget);
		    }
		}
		curTarget.style.display    = '';
		curTarget.style.visibility = 'visible';
	    }

	    // And update the trigger logic
	    updateLogic();
	}
	curTarget  = null;
    } else if ( Demos[2] ) {
	
	if ( curTarget ) {
	    var id   = rootParent.id;
	    if ( id == 'DragContainer2' ) {
		var parent = document.getElementById('DragContainer2');
		if ( parent.childNodes.length >= 8 ) {
		    // Too many plots... pop the last one out before inserting this one
		    parent.lastChild.origParentNode.appendChild(parent.lastChild);
		}
	    }
	}

	if ( curTarget ) {
	    writeHistory(curTarget, 'Mouse Up Fired');

	    dragHelper.style.display = 'none';
	    if(curTarget.style.display == 'none'){
		if(rootSibling){
		    rootParent.insertBefore(curTarget, rootSibling);
		} else {
		    rootParent.appendChild(curTarget);
		}
	    }
	    curTarget.style.display    = '';
	    curTarget.style.visibility = 'visible';

	    // For the graphics options... update the color
	    if ( setColor && setColor.target ) {
		    setColor.target.style.backgroundColor = setColor.color;
		    if ( setColor.color == 'rgb(0, 0, 0)' || 
                         setColor.color == 'rgb(0, 0, 255)' || 
                         setColor.color == 'rgb(255, 0, 0)' ) {
			setColor.target.style.color = "#ffffff";
		    } else
			setColor.target.style.color = "#000000";
		    setColor.target = null;
		    setColor.color = "";
	    } else {
		if ( curTarget.origParentNode.id == 'DragContainer1' &&  
		     curTarget.origParentNode == curTarget.parentNode )
		    curTarget.style.backgroundColor = "";
	    }

	    // If we just dropped something into DragContainer8, we'd best check if 
	    // there's already something similar there (esp a size or type element)
	    if ( curTarget.parentNode.id == 'DragContainer8' ) {
		if ( curTarget.id == "size" || curTarget.id == "type" ) {

		    // Danger! Danger! Danger Will Robinson!
		    var kiddes = curTarget.parentNode.firstChild;
		    while ( kiddes ) {
			if ( kiddes.id == curTarget.id && kiddes != curTarget ) {

			    // OK... we just doubled up on a single value option :-<
			    // Dump the old one back into it's original container
			    curTarget.parentNode.removeChild(kiddes);
			    curTarget.origParentNode.appendChild(kiddes);
			}
			kiddes = kiddes.nextSibling;
		    }
		}
	    }

	} // End if ( curTarget )

	curTarget  = null;

	// Just in case... reset the borders to their default values
	// Needed here in case someone clicked an element but never
	// actually started dragging it
	document.getElementById('DragContainer1').style.border = "none";
	document.getElementById('DragContainer3').style.border = "none";
	document.getElementById('DragContainer4').style.border = "none";
	document.getElementById('DragContainer5').style.border = "none";
	document.getElementById('DragContainer6').style.border = "none";
	document.getElementById('DragContainer7').style.border = "none";
	document.getElementById('DragContainer2').style.border = "#669999 1px solid";
	document.getElementById('DragContainer8').style.border = "#669999 1px solid";

	var child = document.getElementById('DragContainer2').firstChild;
	while ( child ) {
	    child.style.border = "#000 1px solid";
	    child = child.nextSibling;
	}

    } // End else if ( Demos[2] )

    // Reset pointers to drag in progress
    dragObject = null;
    iMouseDown = false;

    // Unset the cursor to the grab icon
    if ( clickTarget ) {
	document.getElementById('body').style.cursor = "auto";
	if ( !browser.isIE || browser.ieVersion >= 6 )
	    clickTarget.style.cursor = "url('/~ogre/graphics/draggable.gif'),pointer";
	else
	    clickTarget.style.cursor = "hand";
	clickTarget = null;
    }

} // End mouseUp(ev)

var clickTarget = null;

var click2Drag = new Object();
var click2Drag = null;

function mouseClick(ev) {
    ev = ev || window.event;
    var target = ev.target || ev.srcElement;

    if ( !target )
	return false;

    if ( click2Drag && click2Drag.origParentNode && click2Drag.origParentNode.id == 'DragContainer3' ) {
	
	curTarget = click2Drag;
	var mousePos    = mouseCoords(ev);
	var mouseOffset = getMouseOffset(document.getElementById('DragContainer2').parentNode, ev);

	var xpos = mouseOffset.x;
	var ypos = mouseOffset.y;

	var subContainer = click2Drag.droptarget.firstChild;
	while ( subContainer ) {
	    var left   = parseInt(subContainer.offsetLeft);
	    var right  = parseInt(left+subContainer.offsetWidth);
	    var top    = parseInt(subContainer.offsetTop);
	    var bottom = parseInt(top+subContainer.offsetHeight);


	    if ( left < xpos && right > xpos && top < ypos && bottom > ypos ) {
		subContainer.style.backgroundColor = curTarget.style.backgroundColor;
		if ( curTarget.style.backgroundColor == 'rgb(0, 0, 0)' )
		    subContainer.style.color = '#ffffff';
		else
		    subContainer.style.color = '#000000';
		break;
	    }
	    subContainer = subContainer.nextSibling;
	}

	click2Drag = curTarget = null;

    } else if ( target.onmousedown || target.getAttribute('DropObj') ) {

	if ( !click2Drag )
	    return false;

	var mousePos = mouseCoords(ev);
	var mouseOffset   = getMouseOffset(target, ev);
	
	var xpos = mousePos.x - mouseOffset.x;
	var ypos = mousePos.y - mouseOffset.y;

	curTarget = click2Drag;
	curTarget.style.color = '#000000';

        dragHelper = document.createElement('div');
	dragHelper.appendChild(click2Drag.cloneNode(true));
	dragHelper.style.display = 'block';
        dragHelper.style.cssText = 'position:absolute;';
	dragHelper.style.zIndex = 15;
	dragHelper.style.top  = ypos + 'px';
	dragHelper.style.left = xpos + 'px';

        document.body.appendChild(dragHelper);

	curTarget.style.display = 'none';
	rootParent = target;

	useDragDrop = true;
	mouseUp(ev);
	useDragDrop = false;

	rootParent = null;
	curTarget = null;
	dragHelper = null;
	click2Drag = null;

    } else if ( target.onmousedown || target.getAttribute('DragObj') ) {
	click2Drag = target;
	return false;
    } else {
	return false;
    }

    return false;
}

function mouseDown(ev){

    if ( !useDragDrop ) {
	mouseClick(ev);
	return false;
    }

    ev         = ev || window.event;
    var target = ev.target || ev.srcElement;

    // See if we can figure out which we're dealing with....
    // the triggers page? or the variables page?
    var obj   = target;
    if (obj.parentNode) {
	do {
	    try {
		if ( obj.id.indexOf("moveData") != -1 ) {  // This belongs to the triggers page
		    Demos[0] = Demos[1] = true;
		    Demos[2] = restrictDrop = false;
		    break;
		} else if (obj.id.indexOf("moveVars") != -1 ) { // this is on the variables page
		    Demos[0] = Demos[1] = false;
		    Demos[2] = restrictDrop = true;
		    break;
		}
	    } catch (e) {}
	} while (obj = obj.parentNode);
    }

    iMouseDown = true;
    if(lastTarget){
	    writeHistory(lastTarget, 'Mouse Down Fired');
    }
    
    if ( target.origParentNode ) {
	// Grab the element
	if ( !browser.isIE || browser.ieVersion >= 6 )
	    target.style.cursor = "url('/~ogre/graphics/grab.gif'),pointer";
	else
	    target.style.cursor = "hand";

	clickTarget = target;
    }

    // If this is a draggable element... highlight the
    // allowed targets of the drag
    if ( Demos[2] && target.origParentNode ) {

	// Highlight the allowed targets of the drop
	if ( target.origParentNode.id == target.parentNode.id ) {
	    // Special case... the color blobs don't go into the main
	    // drag container... they go into the children of the drag
	    // container (DragContainer2). So we need to highlight the 
	    // children, not the container
	    if ( target.id == "color" ) {
		// find the main children here...
		var child = target.droptarget.firstChild;
		while ( child ) {

		    child.style.border = "#ff0000 1px solid";
		    child = child.nextSibling;
		}
		target.origParentNode.style.border = "none";
	    } else {
		target.droptarget.style.border = "#ff0000 1px solid";
		target.origParentNode.style.border = "none";
	    }
	} else {
	    target.origParentNode.style.border = "#ff0000 1px solid";
	    target.droptarget.style.border = "#669999 1px solid";
	}
    }

    if(target.onmousedown || target.getAttribute('DragObj')){
	return false;
    }

} // End mouseDown(ev)

function makeDraggable(item){
    if(!item) return;
    item.onmousedown = function(ev){
	dragObject  = this;
	mouseOffset = getMouseOffset(this, ev);
	return false;
    }
} // End makeDraggable(item)

function makeClickable(item){
    if(!item) return;
    item.onmousedown = function(ev){
	try {
	    document.getElementById('ClickImage').value = this.name;
	} catch(e) {}
    }
} // End makeClickable(item)

function addDropTarget(item, target){
    item.droptarget = target;
} // End addDropTarget(item, target)

function mouseDblClick(ev) {
    ev         = ev || window.event;
    var target = ev.target || ev.srcElement;

    // See if this is a draggable element
    if ( !target.parentNode || !target.origParentNode )
	return;

    // If we've caught a double click on something that isn't 
    // in it's original place... send it home
    if ( target.parentNode.id != target.origParentNode.id ) {
	target.parentNode.removeChild(target);
	target.origParentNode.appendChild(target);

	// For the plot options... reset the color to it's bland home value
	if (target.origParentNode.id == 'DragContainer1' )
	    target.style.backgroundColor = "";
    }

    // If this is for the trigger list... update it
    if ( Demos[0] )
	updateLogic();

    return false;
} // End mouseDblClick(ev)

document.onmousemove = mouseMove;
document.onmousedown = mouseDown;
document.onmouseup   = mouseUp;
document.ondblclick  = mouseDblClick;

//window.onload = function(){
function dragLoad() {

    // Test for IE so we can correct it's screw-ups
    var rslt = navigator.appVersion.match(/MSIE (\d+\.\d+)/, '');
    if ( rslt != null ) {
	browser.isIE = true;
	browser.ieVersion = Number(rslt[1]);

	if ( browser.isIE && browser.ieVersion < 5.5)
	    usePush = 0;
    }

    for(var i=0; i<nDemos; i++){
	Demos[i] = document.getElementById('Demo'+i);
    }

    if (Demos[0]) {    //Demos[0] & Demos[1] are from the triggers/data page
	CreateDragContainer(document.getElementById('DragContainer11'),
			    document.getElementById('DragContainer12'), 
			    document.getElementById('DragContainer13'),
			    document.getElementById('DragContainer14'),
			    document.getElementById('DragContainer15'),
			    document.getElementById('DragContainer16'),
			    document.getElementById('DragContainer17')
			    );
	
	CreateDragContainer(document.getElementById('Demo0'),
			    document.getElementById('Demo1'));


	document.getElementById('DragContainer14').setAttribute('DropObj',1);
	makeClickable(document.getElementById('DragContainer14'));


	// Define the original container of the draggable elements
	var node = document.getElementById('DragContainer14');
	var child = node.firstChild;
	while ( child ) {
	    child.origParentNode = node;
	    child = child.nextSibling;
	}

	// Create our helper object that will show the item while dragging
	dragHelper = document.createElement('div');
	dragHelper.style.cssText = 'position:absolute;';
	document.body.appendChild(dragHelper);
 
	// Add the select/reject containers as drop targets of each other
	var select = document.getElementById('select_legend');
	var reject = document.getElementById('reject_legend');
	addDropTarget(select, reject);
	addDropTarget(reject, select);

   } // End of Demos[0]

    if(Demos[2]) {    //Demos[2] is from the variables page
	//var hasCookie = getCookie('selection');
	var request = "/~ogre/asp/getCookie.asp?sessionID=" + sessionID;
	var xmlHttp = new XMLHttpRequest();
	xmlHttp.open("GET",request,false);
	xmlHttp.send(null);
	var hasCookie = (xmlHttp.responseText != null && xmlHttp.responseText != "null" );

	if ( hasCookie )
	    selection = xmlHttp.responseText;

	if ( hasCookie ) {
	    CreateDragContainer(document.getElementById('DragContainer1'),
				document.getElementById('DragContainer2'),
				document.getElementById('DragContainer3'),
				document.getElementById('DragContainer4'),
				document.getElementById('DragContainer5'),
				document.getElementById('DragContainer6'),
				document.getElementById('DragContainer7'),
				document.getElementById('DragContainer8'));
	} else {
	    CreateDragContainer(document.getElementById('DragContainer1'),
				document.getElementById('DragContainer2'),
				document.getElementById('DragContainer3'),
				document.getElementById('DragContainer4'),
				document.getElementById('DragContainer5'),
				document.getElementById('DragContainer6'),
				document.getElementById('DragContainer8'));
	}
	
	// Define the parent node of the children in the containers
	// Used extensively above to restict what can be dropped where
	// when this script is used by the variable selection page
	var containerList = new Array( 'DragContainer1',
				       'DragContainer3',
				       'DragContainer4',
				       'DragContainer5',
				       'DragContainer6'
				       );

	if ( hasCookie )
	    containerList[containerList.length++] = 'DragContainer7';

	for ( var i=0; i<containerList.length; i++ ) {
	    var node = document.getElementById(containerList[i]);
	    var child = node.firstChild;
	    while ( child ) {
		child.origParentNode = node;

		switch (node.id) {
		case 'DragContainer1': case 'DragContainer3':
		    addDropTarget(child, document.getElementById('DragContainer2'));
		    break;
		case 'DragContainer4': case 'DragContainer5':case 'DragContainer6': case 'DragContainer7':
		    addDropTarget(child, document.getElementById('DragContainer8'));
		    break;
		}

		child = child.nextSibling;
	    }
	}

	if ( !hasCookie )
	    document.getElementById('DragContainer7').style.display = 'none';

	// Create a drag helper which will container the object being dragged
	dragHelper = document.createElement('div');
	dragHelper.style.cssText = 'position:absolute;';
	document.body.appendChild(dragHelper);

	// Set some basic defaults for the variables page..
	var ele = new Array();
	ele = document.getElementsByName("type");
	for ( var i=0; i<ele.length; i++ ) {
	    if ( ele[i] && ele[i].getAttribute("value") == "png" ) {
		document.getElementById("DragContainer8").appendChild(ele[i]);
	    }
	}

	// set up the default plot size based on the users browser size
	ele = document.getElementsByName("size");

	// Available sizes....
	var widths  = [640,800,1024,1280,1600];
	var heights = [480,600, 768,1024,1200];
	
	// area = current browser width/height
	var area = {w:0, h:0};
	area = getSize();

	// These will be the width x height of the default plot size
	var width  = 0;
	var height = 0;

	// See which size will fit completely into the browser window
	for ( var i=0; i<widths.length; i++ ) {
	    if ( widths[i] > area.w ) {
		if ( i > 0 ) {

		    if ( heights[i-1] > area.h ) {
			if ( i > 2 ) {
			    width = widths[i-2];
			    height = heights[i-2];
			} else {
			    width  = widths[0];
			    height = heights[0];
			}
			break;
		    } else {
			width  = widths[i-1];
			height = heights[i-1];
			break;
		    }
		} else {
		    width = widths[0];
		    height = heights[0];
		}
	    }
	}
	if ( width == 0 || height == 0 ) {
	    width  = widths[0];
	    height = heights[0];
	}
	var size = width+"x"+height;

	for ( var i=0; i<ele.length; i++ ) {
	    if ( ele[i] && ele[i].getAttribute("value") == size ) {
		document.getElementById("DragContainer8").appendChild(ele[i]);
	    }
	}
    } // End of if ( Demos[2] )

} // End window.onload = function();

function getSize() {
    var myWidth = 0, myHeight = 0;
    if( typeof( window.innerWidth ) == 'number' ) {
	//Non-IE
	myWidth = window.innerWidth;
	myHeight = window.innerHeight;
    } else if( document.documentElement && 
	       ( document.documentElement.clientWidth || 
		 document.documentElement.clientHeight ) ) {
	//IE 6+ in 'standards compliant mode'
	myWidth = document.documentElement.clientWidth;
	myHeight = document.documentElement.clientHeight;
    } else if( document.body && 
	       ( document.body.clientWidth || document.body.clientHeight ) ) {
	//IE 4 compatible
	myWidth = document.body.clientWidth;
	myHeight = document.body.clientHeight;
    }

    var area = {w:0, h:0};
    area.w = myWidth;
    area.h = myHeight;

    return area;

    //window.alert( 'Width = ' + myWidth + ' Height = ' + myHeight );
}

// Define the variable logicString here since
// we'll need to share it in the next two functions
var logicString;

function updateLogic() {

    if ( !Demos[0] )
	return;

    var i = 0, l = 0;

    var selrej = new Array( new String(), new String() );
    var dbString = ""; //"SELECT run,nevents,energy,beam,eta,phi from rundb where";

    // Flush and reset any previous results
    logicString = new String();

    // Get the contents of the logic containers
    // First... feret out the current ordering....
    var container = new Array();
    //var firstCon  = document.getElementById('select_legend').innerHTML.substring(0,6).toLowerCase();

    if ( firstCon == "select" ) {
	container[0] = document.getElementById("Demo0");    // Select container
	container[1] = document.getElementById("Demo1");    // Reject container
    } else {
	container[0] = document.getElementById("Demo1");    // Reject container
	container[1] = document.getElementById("Demo0");    // Select container
    }

    for ( l = 0; l < container.length; l++ ) {
	var counter = 0;
	var strings = new Array( new String(), new String(), new String() );

	for (i=0; i<container[l].childNodes.length; i++) {
	    if ( container[l].childNodes[i].id ) {
		var id = container[l].childNodes[i].id;
		if ( id.substring( id.length-3, id.length ) == "col" ) {
		    var j = 0;
		    for ( j=0; j<container[l].childNodes[i].childNodes.length; j++ ) {
			if ( container[l].childNodes[i].childNodes[j].id ) {
			    id = container[l].childNodes[i].childNodes[j].id;

			    if ( id.substring(0,13) == "DragContainer" ) {

				var blackbox = document.getElementById(id);
				var k = 0;
				id = parseInt(id.substring(id.length-1,id.length));

				if ( blackbox && blackbox.childNodes.length ) {
				    for (k=0; k<blackbox.childNodes.length-1; k++) {
				    
					if ( id == 1 || id == 5)
					    strings[counter] += blackbox.childNodes[k].id + " OR ";
					else if ( id == 2 || id == 6 )
					    strings[counter] += blackbox.childNodes[k].id + " AND ";
					else if ( id == 3 || id == 7 )
					    strings[counter] += blackbox.childNodes[k].id + " XOR ";
				    }
				    strings[counter] += blackbox.childNodes[k].id;
				    counter++;
				}
			    }

			    if ( strings[0].length )
				selrej[l] = '(' + strings[0] + ')';
			    if ( strings[1].length ) {
				if ( strings[0].length )
				    selrej[l] += ' OR (' + strings[1] + ')';
				else
				    selrej[l] = '(' + strings[1] + ')';
			    }
			    if ( strings[2].length ) {
				if ( strings[0].length || strings[1].length )
				    selrej[l] += ' OR (' + strings[2] + ')';
				else
				    selrej[l] = '(' + strings[2] + ')';
			    }
			}
		    }
		}
	    }
	}
    } // End of for (l=0; l<container.length; l++)

    if ( selrej[0].length || selrej[1].length ) {

	var first = selrej[0].indexOf('(');
	var next  = selrej[0].indexOf('(',first+1);
	if ( next > -1 ) {                          // We have multiple terms in select
	    if ( selrej[1].length ) {               // And we'll need to group them
		selrej[0] = '(' + selrej[0] + ')';

		first = selrej[1].indexOf('(');
		next  = selrej[1].indexOf('(',first+1);
		if ( next > -1 ) {                  // And we've got multiple terms in reject
		    selrej[1] = '(' + selrej[1] + ')';
		}
	    }
	} else if ( selrej[1].length ) {
	    first = selrej[1].indexOf('(');
	    next  = selrej[1].indexOf('(',first+1);
	    if ( next > -1 ) {                  // And we've got multiple terms in reject
		selrej[1] = '(' + selrej[1] + ')';
	    }
	}

	// Put together the actual string 
	logicString = dbString;
	if ( selrej[0].length && selrej[1].length )
	    logicString += selrej[0] + " AND NOT " +selrej[1];
	else if ( selrej[0].length )
	    logicString += selrej[0];
	else if ( selrej[1].length )
	    logicString += " NOT " + selrej[1];

	// If we had an actual result.... put it into the box
	if ( logicString.length ) {

	    // Get a pointer to the logic display box
	    var logic = document.getElementById('logic1');

	    // Clean it out....
	    for ( i=logic.childNodes.length-1; i>=0; i-- ) {
		if (logic.childNodes[i].nodeName == "#text" || logic.childNodes[i].nodeName == "BR")
		    logic.removeChild(logic.childNodes[i]);
	    }

	    // And put in the new result we just assembled
	    logic.appendChild(document.createTextNode(logicString));

	}
    } else {         // If there were no results... wipe the box clean
	var logic = document.getElementById('logic1');
	for ( i=logic.childNodes.length-1; i>=0; i-- ) {
	    if (logic.childNodes[i].nodeName == "#text" || logic.childNodes[i].nodeName == "BR")
		logic.removeChild(logic.childNodes[i]);
	}
	logicString ="";
    }

    // Call the DB page to fill in the data form
    asyncDB();

    return;
}

function asyncDB() {

    // If there's no triger list... just clear the form
    // no sense wasting bandwidth to the server for a null result
    if ( !logicString || !logicString.length ) {
	var data = document.getElementById('data1');
	for ( i=data.childNodes.length-1; i>=0; i-- ) {
	    if (data.childNodes[i].nodeName == "#text" || data.childNodes[i].nodeName == "BR")
		data.removeChild(data.childNodes[i]);
	}

	// And while we're at it... clear the run list too
	updateSelect(new Array());
	return;
    }

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
    /*
     * States: 0 == The request is not initialized
     *         1 == The request has been set up
     *         2 == The request has been sent
     *         3 == The request is in process
     *         4 == The request is complete
     */
    xmlHttp.onreadystatechange=function() {
	if(xmlHttp.readyState==4) {
	    var data = document.getElementById('data1');

	    var i;
	    for ( i=data.childNodes.length-1; i>=0; i-- ) {
		if (data.childNodes[i].nodeName == "#text" || data.childNodes[i].nodeName == "BR")
		    data.removeChild(data.childNodes[i]);
	    }

	    var runs = new Array();

	    // Process the response since textNodes don't like \n :-<
	    var rString = xmlHttp.responseText;
	    var response = rString.split('\n');
	    for (i=0; i<response.length-1; i++) {
		data.appendChild(document.createTextNode(response[i]));
		data.appendChild(document.createElement('BR'));
		data.scrollTop += 50;

		// we'll need to treat this as the current run numbers 
		// for the form submission later
		var run = response[i].split(':');

		if ( usePush )
		    runs.push(run[0].substring(4,run[0].length));
		else
		    runs[runs.length++] = run[0].substring(4,run[0].length);
	    }

	    // Update the hidden select list
	    updateSelect(runs);

	}
    }

    // Build the CGI request to the ASP page which will process the DB request
    var dset = new String();
    try { 
	dset = document.getElementById('dataset').value.toLowerCase();
    } catch (e) {
	dset = "mc09";
    }

    var request = new String();
    if ( dset.indexOf('tb04') > -1 )
	request = '/~ogre/asp/DBRequest.asp?varlist=run,nevents,energy,beam,eta,phi';
    else if (dset.indexOf('mc09') > -1 )
	request = '/~ogre/asp/DBRequest.asp?varlist=run,nevents,description';

    request += '&dataset='+dset;
    request += '&selection=' + logicString;
    
    // Send the Ajax request to the server
    xmlHttp.open("GET",request,true);
    xmlHttp.send(null);

} // End of ayncDB function

function updateSelect( runs ) {
    return;

    var i;

    // Step #1 .... clear out all the previous runs
    var select = document.getElementById('select1');
    if ( !select )
	return;

    for ( i=select.length-1; i>=0; i-- )
	select.remove(i);

    // Add in the current runs to the list
    // these are what will be submitted when
    // the form is POSTed (minus 2 to remove the 
    // status & number of events lines)
    for ( i=0; i<runs.length-2; i++ ) {
	var newopt = document.createElement('option');
	newopt.text = 'Run #' + runs[i];
	newopt.value = runs[i];
	newopt.selected = true;
	try {
	    select.add(newopt, null);
	} catch(e) {
	    select.add(newopt);
	}
    }

    return;
} // End of updateSelect


// End of script -->
