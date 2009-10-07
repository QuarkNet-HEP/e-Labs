var isArchived = false;
function submitForm(thisForm) {

    with (thisForm) {
	archive.value = 0;
	finalize.value = 0;
    }

    thisForm.submit();
    return false;
 }

function setCuts(s) {
   var i = s.indexOf('[') + 1;
   var j = s.indexOf(']');
   var range;
   if ( j > i ) {
     range = s.substring(i,j);
   } else
    return false;

   i = range.indexOf(',');
   var min = range.substring(0,i);
   var max = range.substring(i+1,range.length);  

   document.recut.cutMin.value = min;
   document.recut.cutMax.value = max;

}

function archiveStudy(thisForm) {
    if ( isArchived )
	return false;

    with (thisForm) {
	archive.value = 1;
    }
    thisForm.submit();

    isArchived = true;
    return false;
}

function finalizeStudy(thisForm) {
    if ( isArchived )
	return false;

    with (thisForm) {
	archive.value  = 0;
	finalize.value = 1;
    }
    thisForm.submit();

    isArchived = true;
    return false;
}
