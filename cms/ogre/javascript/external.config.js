/** 
 * Example external configuration file.  
 * You can freely categorize these nodes 
 */  
var conf = {
    // default clip configuration 
    defaults: { 

        autoPlay: true, 
        autoBuffering: true, 
	baseUrl: 'graphics/',

        // functions are also supported 
        onBegin: function() { 
     
            // make controlbar visible in 1 second
            this.getControls().fadeIn(1000); 
        }
    },

    // my skins 
    skins: {         
        gray:  { 
            backgroundColor: '#666666', 
            buttonColor: '#333333', 
            opacity: 1, 
            time: true 
        }

        // setup additional skins here ...         
    }

}
