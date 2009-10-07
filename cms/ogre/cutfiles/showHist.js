<!-- Hide from old browsers

function toggleNext(el) {
    var next=el.nextSibling;
    while(next.nodeType != 1) next=next.nextSibling;
    next.style.display=((next.style.display=="none") ? "block" : "none");
    next.zIndex = 18;
    next.position='absolute';
}

function toggleNextById(el) {
    var ccn="clicker";
    var clicker=document.getElementById(el);
    clicker.className+=" "+ccn;
    clicker.onclick=function() {toggleNext(this)}
    toggleNext(clicker);
}

function toggleNextByTagName(tname) {
    var ccn="clicker";
    var clickers=document.getElementsByTagName(tname);
    for (i=0; i<clickers.length; i++) {
	clickers[i].className+=" "+ccn;
	clickers[i].onclick=function() {toggleNext(this)}
	toggleNext(clickers[i]);
    }
}

// End of script -->
