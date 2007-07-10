	function aLs(layerID)
    {
        return document.getElementById(layerID).style;
    }

    function HideShow(ID)
    {
        if((aLs(ID).visibility == "hidden"))
        {
            aLs(ID).visibility = "visible";
            aLs(ID).display = "";
        }
        else if(aLs(ID).visibility == "visible")
        {
            aLs(ID).visibility = "hidden";
            aLs(ID).display = "none";
        }
    }

    function selectAll(start, finish) {
         var direction;
         for (var i = start; i < finish; i++){
             fldObj = document.getElementById("cb" + i);
             if (fldObj.type == 'checkbox')  { 
                 if (fldObj.name == 'selectall') {
                     direction = fldObj.checked;
                 }
                 else {
                     fldObj.checked = direction; 
                 }
             }
         }
    }