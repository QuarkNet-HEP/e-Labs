/*
   Deluxe Menu Data File
   Created by Deluxe Tuner v3.2
   http://deluxe-menu.com
*/

// -- Deluxe Tuner Style Names
var itemStylesNames=["Top Item",];
var menuStylesNames=["Top Menu",];
// -- End of Deluxe Tuner Style Names

//--- Common
var isHorizontal=1;
var smColumns=1;
var smOrientation=0;
var dmRTL=0;
var pressedItem=-2;
var itemCursor="default";
var itemTarget="_self";
var statusString="link";
var blankImage=baseURL+"/graphics/menu/blank.gif";
var pathPrefix_img=baseURL+"/graphics/menu/";
var pathPrefix_link="";

//--- Dimensions
var menuWidth="";
var menuHeight="";
var smWidth="";
var smHeight="";

//--- Positioning
var absolutePos=0;
var posX="10px";
var posY="10px";
var topDX=0;
var topDY=1;
var DX=-5;
var DY=0;
var subMenuAlign="left";
var subMenuVAlign="top";

//--- Font
var fontStyle=["normal 14px Trebuchet MS, Tahoma","normal 14px Trebuchet MS, Tahoma"];
var fontColor=["#000000","#FFFFFF"];
var fontDecoration=["none","none"];
var fontColorDisabled="#84568F";

//--- Appearance
var menuBackColor="#CB99D2";
var menuBackImage="";
var menuBackRepeat="repeat";
var menuBorderColor="#242424";
var menuBorderWidth=1;
var menuBorderStyle="solid";

//--- Item Appearance
var itemBackColor=["#CB99D2","#851F85"];
var itemBackImage=["",""];
var beforeItemImage=["",""];
var afterItemImage=["",""];
var beforeItemImageW="";
var afterItemImageW="";
var beforeItemImageH="";
var afterItemImageH="";
var itemBorderWidth=1;
var itemBorderColor=["#CB99D2","#3D0D48"];
var itemBorderStyle=["solid","solid"];
var itemSpacing=2;
var itemPadding="1px 5px 1px 10px";
var itemAlignTop="left";
var itemAlign="left";

//--- Icons
var iconTopWidth=16;
var iconTopHeight=16;
var iconWidth=16;
var iconHeight=16;
var arrowWidth=7;
var arrowHeight=7;
var arrowImageMain=["arrv_white_up.gif",""];
var arrowWidthSub=0;
var arrowHeightSub=0;
var arrowImageSub=["arr_black.gif","arr_white.gif"];

//--- Separators
var separatorImage="";
var separatorWidth="100%";
var separatorHeight="3px";
var separatorAlignment="left";
var separatorVImage="";
var separatorVWidth="3px";
var separatorVHeight="100%";
var separatorPadding="0px";

//--- Floatable Menu
var floatable=0;
var floatIterations=6;
var floatableX=1;
var floatableY=1;
var floatableDX=15;
var floatableDY=15;

//--- Movable Menu
var movable=0;
var moveWidth=12;
var moveHeight=20;
var moveColor="#DECA9A";
var moveImage="";
var moveCursor="move";
var smMovable=0;
var closeBtnW=15;
var closeBtnH=15;
var closeBtn="";

//--- Transitional Effects & Filters
var transparency="95";
var transition=24;
var transOptions="";
var transDuration=750;
var transDuration2=200;
var shadowLen=3;
var shadowColor="#a3a3a3";
var shadowTop=1;

//--- CSS Support (CSS-based Menu)
var cssStyle=0;
var cssSubmenu="";
var cssItem=["",""];
var cssItemText=["",""];

//--- Advanced
var dmObjectsCheck=0;
var saveNavigationPath=1;
var showByClick=1;
var noWrap=1;
var smShowPause=100;
var smHidePause=1200;
var smSmartScroll=1;
var topSmartScroll=0;
var smHideOnClick=1;
var dm_writeAll=1;
var useIFRAME=0;
var dmSearch=0;

//--- AJAX-like Technology
var dmAJAX=0;
var dmAJAXCount=0;
var ajaxReload=0;

//--- Dynamic Menu
var dynamic=1;

//--- Popup Menu
var popupMode=0;

//--- Keystrokes Support
var keystrokes=0;
var dm_focus=1;
var dm_actKey=113;

//--- Sound
var onOverSnd="";
var onClickSnd="";

var itemStyles = [
    ["itemWidth=92px","itemHeight=21px","itemBorderWidth=0",
     "fontStyle=normal 11px Tahoma","fontColor=#FFFFFF,#FFFFFF",
     "itemBackImage=btn_magentablack.gif,btn_magenta.gif"],
];
var menuStyles = [
    ["menuBackColor=transparent","menuBorderWidth=0","itemSpacing=1","itemPadding=0px 5px 0px 5px"],
];

var menuItems = [
		 ["Start",              "", "", "", "", "", "0", "", "", "", "", ],

		 ["|-",                 "", "", "", "", "", "", "", "", "", "", ],

		 ["|Apply Cut",         "javascript:callMenu(1)", "", "", "", "", "", "", "", "", "", ],
		 ["|Clear Saved Cuts",  "javascript:callMenu(2)", "", "", "", "", "", "", "", "", "", ],
		 ["|Save Work",         "javascript:callMenu(3)", "", "", "", "", "", "", "", "", "", ],
		 ["|Publish",           "javascript:callMenu(4)", "", "", "", "", "", "", "", "", "", ],

		 ["|-",                "", "", "", "", "", "", "", "", "", "", ],

		 ["|Options",          "", "", "", "", "", "", "", "", "", "", ],
		 ["||Toggle Effects",  "javascript:callMenu(5)", "", "", "", "", "", "", "", "", "", ],
		 ["||Toggle Buttons",  "javascript:callMenu(6)", "", "", "", "", "", "", "", "", "", ],

		 ["|-",                 "", "", "", "", "", "", "", "", "", "", ],

		 ["|How'd I get here?", "javascript:callMenu(7)", "", "", "", "", "", "", "", "", "", ],
                 ["|Bug the OGRE",      "javascript:callMenu(8)", "", "", "", "", "", "", "", "", "", ]

		 ];

if ( useDynMenu )
    dm_init();
