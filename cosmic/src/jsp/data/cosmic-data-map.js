function initialize() {
   var map;
   var bounds = new google.maps.LatLngBounds();
   var mapOptions = {
		       zoom: 1,
           minZoom: 1,
           rotateControl: true,
           mapTypeControl: true,
           style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
           mapTypeIds: [
                 google.maps.MapTypeId.ROADMAP,
                 google.maps.MapTypeId.TERRAIN
                 ]
       };
   map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
   map.setTilt(45);          
   var oms = new OverlappingMarkerSpiderfier(map);
   
   var daq = [];
   var latitude = [];
   var longitude = [];
   var school = [];
   var city = [];
   var state = [];
   var stacked = [];
   var teacher = [];
   var latest = [];
   var uploads = [];
   var detectorUploads = [];
   
   var detectorDetails = document.getElementsByName("detectorDetails");
   if (detectorDetails.length > 0) {
     for (var i=0; i < detectorDetails.length; i++) {
       daqArr = detectorDetails[i].value.split(',');
       if (daqArr[1] != "null" && daqArr[2] != "null") {
         daq.push(daqArr[0]);
         latitude.push(daqArr[1]);
         longitude.push(daqArr[2]);
         school.push(daqArr[3]);
         city.push(daqArr[4]);
         state.push(daqArr[5]);
         stacked.push(daqArr[6]);
         teacher.push(daqArr[7]);
         latest.push(daqArr[8]);
         uploads.push(daqArr[9])
         detectorUploads.push(new detectorInfo(daqArr[0],daqArr[9]));
       }
     }
   }
   // Loop through our array of markers & place each one on the map  
   for( i = 0; i < daq.length; i++ ) {
       var position = new google.maps.LatLng(latitude[i], longitude[i]);
       bounds.extend(position);
       if (parseInt(daq[i].trim()) >= 6000) {
               var daqForm = createDataLink('DAQ#:','detectorid',daq[i].trim());
               var schoolForm = createDataLink('School:','school',school[i].trim());
               var cityForm = createDataLink('City:','city',city[i].trim());
               var stateForm = createDataLink('State:','state',state[i].trim());
               var stackedForm = createDataLinkOther('Stacked:','stacked',stacked[i].trim());
               var teacherInfo = createDataLink('Teacher:','teacher',teacher[i].trim());
               var latestInfo = 'Last Upload: ' + latest[i].trim() + '<br />';
               var examineYear = latest[i].trim().split('-');
               var markerIcon = "https://maps.google.com/mapfiles/ms/icons/blue-dot.png";
               var thisYear = new Date().getFullYear();
               if (parseInt(examineYear[0]) == thisYear) {
                   markerIcon = "https://maps.google.com/mapfiles/ms/icons/red-dot.png";
               }
               var uploadsInfo = 'Total Files: ' + uploads[i].trim() + '<br />';
               var marker = new google.maps.Marker({
                   position: position,
                   icon: markerIcon,
                   map: map,
                   title: daq[i].trim(),
                   clickable: true
               });
               
               
               //Code added by SB, 9Mar2016, to make (0,0) points invisible 
               if (latitude[i]==0 && longitude[i]==0) {
               		marker.setVisible(false);
               }
               //End code for (0,0) point 
               
               
               var header = "<br />Latest data uploaded by:<br />";
               var content =  '<div id="daqContent" style="text-align: left;">'+
                              daqForm + latestInfo + uploadsInfo + header + teacherInfo + schoolForm + cityForm + stateForm + stackedForm +
                              '</div>';
               var infowindow = new google.maps.InfoWindow({maxWidth:250});
               oms.addMarker(marker);
               google.maps.event.addListener(marker, 'click', (function(marker,content,infowindow){
                     return function() {
                       infowindow.setContent(content);
                       infowindow.open(map,marker);
                     }
                   })(marker,content,infowindow));
           }
       }
       map.fitBounds(bounds);
}

function createDataLink(keyname, key, value) {
   var submitToPage = document.getElementById("submitToPage");
   var study = document.getElementById("study");
   var lastMonth = document.getElementById("lastMonth");
   var dataLink = '<form action="'+submitToPage.value+'" name="searchForm" method="post">'+
     '<input type="hidden" name="key" value="'+key+'" />'+
     '<input type="hidden" name="value" value="'+value+'" />'+
     '<input type="hidden" name="date1" value="'+lastMonth.value+'" />'+
	 '<input type="hidden" name="study" value="'+study.value+'" />'+
     '<input type="hidden" name="submitFromMap" value=true />'+keyname+' ';
   if (submitToPage.value.indexOf("controller.jsp") != -1) {
	    dataLink += '<input type="hidden" name="action" value="Search Data">';
   }
   dataLink += '<a href="#" onclick="$(this).closest(&quot;form&quot;).submit()">'+value+'</a>'+
     '</form>';
   return dataLink;
}

function createDataLinkOther(keyname, key, value) {
	 var submitToPage = document.getElementById("submitToPage");
	 var study = document.getElementById("study");
	 var lastMonth = document.getElementById("lastMonth");
	 var newValue = "";
	 if (value == true && key == "stacked") {
	   newValue = "yes";
	 } else {
	   newValue = "no";
	 }
	 var dataLink = '<form action="'+submitToPage.value+'" name="searchForm" method="post">'+
	   '<input type="hidden" name="'+key+'" value="'+newValue+'" />'+
	   '<input type="hidden" name="date1" value="'+lastMonth.value+'" />'+
	   '<input type="hidden" name="study" value="'+study.value+'" />'+
	   '<input type="hidden" name="submitFromMap" value=true />'+keyname+' ';
	 if (submitToPage.value.indexOf("controller.jsp") != -1) {
	     dataLink += '<input type="hidden" name="action" value="Search Data">';
	 }
	 dataLink +='<a href="#" onclick="$(this).closest(&quot;form&quot;).submit()">'+value+'</a>'+
	   '</form>';
	 return dataLink;
}

function detectorInfo(detectorid, uploadcount) {
   this.detectorid = detectorid;
   this.uploadcount = uploadcount;
}           

google.maps.event.addDomListener(window, 'load', initialize);  
