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
