<SCRIPT language=JavaScript>
    function dataOnLoad() {
        MM_preloadImages('graphics/home_button.jpg','graphics/resources_button.jpg','graphics/upload_button.jpg','graphics/data_buttonw.jpg','graphics/poster_button.jpg','graphics/site_button.jpg','graphics/assess_button.jpg');
        var inputs = document.getElementsByTagName('input'); 
        var prevDate = 'XX';
        var prevSchool = 'XX';
        for (var i=0;i < inputs.length;i++){
            var inputNode = inputs[i];
            if (inputNode.type == 'checkbox')  { 
                if (inputNode.name == 'f') {
                    if(inputNode.checked) {
                        var files_group = inputNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
                        var twoUp = files_group.parentNode.parentNode;
                        var dateBase = files_group.id.substring(0, files_group.id.indexOf('_'));
                        var schoolBase = twoUp.id.substring(0, twoUp.id.indexOf('_'));
                        if (schoolBase != prevSchool) {
                            document.getElementById(schoolBase + '_files').style.visibility = 'visible';
                            document.getElementById(schoolBase + '_files').style.display = '';
                            document.getElementById(schoolBase + '_open').style.visibility = 'visible';
                            document.getElementById(schoolBase + '_open').style.display = '';
                            document.getElementById(schoolBase + '_closed').style.visibility = 'hidden';
                            document.getElementById(schoolBase + '_closed').style.display = 'none';
                        }
                        if (dateBase != prevDate) {
                            document.getElementById(dateBase + '_files').style.visibility = 'visible';
                            document.getElementById(dateBase + '_files').style.display = '';
                            document.getElementById(dateBase + '_open').style.visibility = 'visible';
                            document.getElementById(dateBase + '_open').style.display = '';
                            document.getElementById(dateBase + '_closed').style.visibility = 'hidden';
                            document.getElementById(dateBase + '_closed').style.display = 'none';
                        }
                        prevDate = dateBase;
                        prevSchool = schoolBase;
                    }
                }
            }
        }
    }
    function selectAll(formObj, isInverse, start, finish) {
         var direction;
         for (var i=start;i < finish;i++){
             fldObj = formObj.elements[i];
             if (fldObj.type == 'checkbox')  { 
                 if (fldObj.name == 'selectall') {
                     direction = fldObj.checked;
                 }
                 else {
                     if(isInverse)
                         fldObj.checked = (fldObj.checked) ? false : true;
                     else fldObj.checked = direction; 
                 }
             }
         }
    }

    function openPopup(url,target,W,H){
        if (!W) W=700;
        if (!H) H=600;
        if (!target) target="_new";

        var X = (screen.width/2)-(W/2);
        var Y = (screen.height/2)-(H/2);

        var winPref = "width=" + W + ",height=" + H
        + ",innerWidth=" + W + ",innerHeight=" + H
        + ",left=" + X + ",top=" + Y
        + ",screenX=" + X + ",screenY=" + Y
        + ",dependent=no,titlebar=no,scrollbars=yes,resizable=yes";
       // alert("opening file with javascript "+ url);


        openPopup.popup = window.open( url, target, winPref );
        openPopup.popup.resizeTo(1*W,1*H);
        //openPopup.popup.focus();

        //return true;
    }

    function showTransformation(e){
        if (e.options[e.selectedIndex].value != '') {
            form1.submit();
        }
    }

    //http://www.experts-exchange.com/Web/Web_Languages/JavaScript/Q_21265898.html
    function toggle(t_show, t_hide, s_show, s_hide){
        if(document.getElementById(t_show).innerHTML==s_show){
            document.getElementById(t_show).innerHTML=s_hide;
            document.getElementById(t_hide).style.display="";
        }
        else if(document.getElementById(t_show).innerHTML==s_hide){
            document.getElementById(t_show).innerHTML=s_show;
            document.getElementById(t_hide).style.display="none";
        }
        else 
            document.getElementById(t_hide).style.display="none";
    }


    var isIE = false;
    var isOther = false;
    var isNS4 = false;
    var isNS6 = false;
    if(document.getElementById)
    {
        if(!document.all)
        {
            isNS6=true;
        }
        if(document.all)
        {
            isIE=true;
        }
    }
    else
    {
        if(document.layers)
        {
            isNS4=true;
        }
        else
        {
            isOther=true;
        }
    }

    function aLs(layerID)
    {
        var returnLayer;
        if(isIE)
        {
            returnLayer = eval("document.all." + layerID + ".style");
        }
        if(isNS6)
        {
            returnLayer = eval("document.getElementById('" + layerID + "').style");
        }
        if(isNS4)
        {
            returnLayer = eval("document." + layerID);
        }
        if(isOther)
        {
            returnLayer = "null";
            alert("-[Error]-\nDue to your browser you will probably not\nbe able to view all of the following page\nas it was designed to be viewed. We regret\nthis error sincerely.");
        }
        return returnLayer;
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
    
function describe(tr,arg,label){
 
        url="dispDescription.jsp?tr="+tr+"&arg="+arg+"&label="+label;
        var winPref = "width=250,height=250,scrollbars=no,toolbar=no,menubar=no,status=no,resizable=yes,title=yes";
    //   alert("opening file with javascript "+ url);       
       window.open(url, "Description", winPref);
        
    }
function glossary(name,H){
        var passName=name;
       if (!H) {height=250;}else{height=H;}
       while (passName.indexOf(" ")>0) {  passName=passName.replace(" ","_");}
        var url="dispReference.jsp?name="+passName+"&type=glossary";
        var winPref = "width=300,height="+height+",scrollbars=no,toolbar=no,menubar=no,status=no,resizable=yes,title=yes";
      window.open(url, "Glossary", winPref);
    }
function reference(name,H,W){
        var passName=name;
       if (!H) {height=250;}else{height=H;}
       while (passName.indexOf(" ")>0) {  passName=passName.replace(" ","_");}
        var url="dispReference.jsp?name="+passName+"&type=reference";
        var winPref = "width=300,height="+height+",scrollbars=no,toolbar=no,menubar=no,status=no,resizable=yes,title=yes";
      window.open(url, "Reference", winPref);
    }
function showRefLink(fileName,W,H)
{
      var url=fileName;
       var height=500;
       var width=500;
       if (H) {height=H;}
       if (W) {width=W;}
       winPref="width="+width+",height="+height+",scrollbars=yes,toolbar=no,menubar=no,status=yes,resizable=yes";
       window.open(url,"Linked_Reference",winPref);
}

<!--- numeric conversion scripts from http://web-nation.com/javascript/basecalc.htm-->
<!--- TJ added them Dec-2004 - we may want to improve them later-->
	function decCompute(form) {

		form.hex.value = hexfromdec(form.decimal.value);

		form.binary.value = binfromdec(form.decimal.value);

	}



	function hexCompute(form) {

		form.decimal.value = decfromhex(form.hex.value);

		form.binary.value = binfromdec(form.decimal.value);

	}

	

	function binCompute(form) {

		form.decimal.value = decfrombin(form.binary.value);

		form.hex.value = hexfromdec(form.decimal.value);

	}



	function hexfromdec(num) {

		if (num > 65535) { return ("err!") }

		

		first = Math.round(num/4096 - .5);

		temp1 = num - first * 4096;

		second = Math.round(temp1/256 -.5);

		temp2 = temp1 - second * 256;

		third = Math.round(temp2/16 - .5);

		fourth = temp2 - third * 16;

				

		return (""+getletter(first)+getletter(second)+getletter(third)+getletter(fourth));

	}

	

	function getletter(num) {

		if (num < 10) {

			return num;

		} else {

			if (num == 10) { return "A" }

			if (num == 11) { return "B" }

			if (num == 12) { return "C" }

			if (num == 13) { return "D" }

			if (num == 14) { return "E" }

			if (num == 15) { return "F" }

		}

	}

		

	function binfromdec(num) {

		var bit8=0,bit7=0,bit6=0,bit5=0,bit4=0,bit3=0,bit2=0,bit1=0;

		

		if (num > 255) { return ("err!") }

		if (num & 128) { bit8 = 1 }

		if (num & 64) { bit7 = 1 }

		if (num & 32) { bit6 = 1 }

		if (num & 16) { bit5 = 1 }

		if (num & 8) { bit4 = 1 }

		if (num & 4) { bit3 = 1 }

		if (num & 2) { bit2 = 1 }

		if (num & 1) { bit1 = 1 }

		

		return (""+bit8+bit7+bit6+bit5+bit4+bit3+bit2+bit1);

	}

	

	function decfromhex(num) {

		while (num.length < 4) {

			num = "0" + num;

		}

		

		return (eval(getnum(num.substring(3,4))) + eval(getnum(num.substring(2,3))) * 16 +

eval(getnum(num.substring(1,2))) * 256 + eval(getnum(num.substring(0,1))) * 4096);

		

	}

	

	function getnum(letter) {

		if (letter <= "9") {

			return letter;

		} else {

			if ((letter == "a") || (letter == "A")) { return 10 }

			if ((letter == "b") || (letter == "B")) { return 11 }

			if ((letter == "c") || (letter == "C")) { return 12 }

			if ((letter == "d") || (letter == "D")) { return 13 }

			if ((letter == "e") || (letter == "E")) { return 14 }

			if ((letter == "f") || (letter == "F")) { return 15 }

			return 0;

		}

	}

	

	function decfrombin(num) {

		var decimal = 0;

		

		while (num.length < 8) {

			num = "0" + num;

		}

		

		if (num.substring(7,8) == "1") { decimal++ }

		if (num.substring(6,7) == "1") { decimal += 2 }

		if (num.substring(5,6) == "1") { decimal += 4 }

		if (num.substring(4,5) == "1") { decimal += 8 }

		if (num.substring(3,4) == "1") { decimal += 16 }

		if (num.substring(2,3) == "1") { decimal += 32 }

		if (num.substring(1,2) == "1") { decimal += 64 }

		if (num.substring(0,1) == "1") { decimal += 128 }

		

		return(decimal);

	}

</SCRIPT>
