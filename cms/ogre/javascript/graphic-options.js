function passValUp(formEL) {
    parent.document.getElementsByName(formEL.name)[0].value = formEL.value;
    return;
}

function passValUpByID(formEL) {
    var ele = parent.document.getElementById(formEL.id);
    ele.checked = formEL.checked;
    return;
}

function setGeometry(selectBox) {

    var whichGeom = selectBox.selectedIndex;
    var height;
    var width;

    if ( whichGeom == 0 ) {
	width  = 640;
	height = 480;
    } else if ( whichGeom == 1 ) {
	width  = 800;
	height = 600;
    } else if ( whichGeom == 2 ) {
	width  = 1024;
	height = 768;
    } else if ( whichGeom == 3 ) {
	width  = 1280;
	height = 1024;
    } else if ( whichGeom == 4 ) {
	width  = 1600;
	height = 1200;
    }

    return;
}
