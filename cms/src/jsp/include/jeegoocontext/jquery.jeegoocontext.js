// Copyright (c) 2010 Erik van den Berg (http://www.planitworks.nl)
// Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) 
// and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
//
// Thanks to Denis Evteev for some excellent improvements.
//
// Version: 1.2.1
// Requires jQuery 1.3.2+
(function($){
    var _global;
    var _menus;

    // Detect overflow.
    var _overflow = function(x, y){
        return {
            width : (x && parseInt(x)) ? (x - $(window).width() - $(window).scrollLeft()) : 0,
            height : (y && parseInt(y)) ? (y - $(window).height() - $(window).scrollTop()) : 0
        };
    };
    
    // Clear all active context.
    var _clearActive = function(){
        for(cm in _menus)
        {
            $(_menus[cm].allContext).removeClass(_global.activeClass);
        } 
    };
    
    // Reset menu.
    var _resetMenu = function(){
        // Hide active menu and it's submenus.
        if(_global.activeId)$('#' + _global.activeId).add('#' + _global.activeId + ' ul').hide();  
        // Clear active menu.
        _global.activeId = null;
                
		// Unbind click and mouseover functions bound to the document
		$(document).unbind('.jeegoocontext');              
    };
	
	$.fn.jeegoocontext = function(id, options){
        
        if(!_global) _global = {};
        if(!_menus) _menus = {};
        
        // Always override _global.menuClass if value is provided by options.
        if(options && options.menuClass)_global.menuClass = options.menuClass;
        // Only set _global.menuClass if not set.
        if(!_global.menuClass)_global.menuClass = 'jeegoocontext';
        // Always override _global.activeClass if value is provided by options.
        if(options && options.activeClass)_global.activeClass = options.activeClass;
        // Only set _global.activeClass if not set.
        if(!_global.activeClass)_global.activeClass = 'active';
		
		_menus[id] = $.extend({
            hoverClass: 'hover',
            submenuClass: 'submenu',
            operaEvent: 'dblclick',
            fadeIn: 200,
            delay: 300,
            widthOverflowOffset: 0,
            heightOverflowOffset: 0,
            submenuLeftOffset: 0,
            submenuTopOffset: 0,
            autoAddSubmenuArrows: true
        }, options || {});
             
        // All context bound to this menu.
        _menus[id].allContext = this.selector;
        
        // Auto add submenu arrows(spans) if set by options.
        if(_menus[id].autoAddSubmenuArrows)$('#' + id).find('li:has(ul)').not(':has(.' + _menus[id].submenuClass + ')').prepend('<span class="' + _menus[id].submenuClass + '"></span>');
        
        $('#' + id).find('li').unbind('.jeegoocontext').bind('mouseover.jeegoocontext', function(e){  

            var $this = $(this);
    
            // Clear hide and show timeouts.
            window.clearTimeout(_menus[id].show);
            window.clearTimeout(_menus[id].hide);
            
            // Clear all hover state.
            $('#' + id).find('*').removeClass(_menus[id].hoverClass);
            
            // Set hover state on self, direct children, ancestors and ancestor direct children.
            var $parents = $this.parents('li');
            $this.add($this.find('> *')).add($parents).add($parents.find('> *')).addClass(_menus[id].hoverClass);
            
            // Invoke onHover callback if set, 'this' refers to the hovered list-item.
            // Discontinue default behavior if callback returns false.  
            var continueDefault = true;                 
            if(_menus[id].onHover)
            {
                if(_menus[id].onHover.apply(this, [e, _menus[id].context]) == false)continueDefault = false;
            }      
            
            // Continue after timeout(timeout is reset on every mouseover).
            if(!_menus[id].proceed)
            {
                _menus[id].show = window.setTimeout(function(){
                    _menus[id].proceed = true;
                    $this.mouseover(); 
                }, _menus[id].delay);
                               
                e.stopPropagation();
                return false;
            }            
            _menus[id].proceed = false;

            // Hide all sibling submenu's and deeper level submenu's.
            $this.parent().find('ul').not($this.find('> ul')).hide();
            
            if(!continueDefault)
            {
                e.preventDefault();
                return false;
            }
            
            // Default behavior.
            // =================================================== //       
                
            // Position and fade-in submenu's.
            var $submenu = $this.find('> ul');
            if($submenu.length != 0)
            {
                var offSet = $this.offset();
                	 
                var overflow = _overflow(
                    (offSet.left + $this.parent().width() + _menus[id].submenuLeftOffset + $submenu.width() + _menus[id].widthOverflowOffset), 
                    (offSet.top + _menus[id].submenuTopOffset + $submenu.height() + _menus[id].heightOverflowOffset)
                );
				var parentWidth = $submenu.parent().parent().width();
				var y = offSet.top - $this.parent().offset().top;
                $submenu.css(
                    {
                        'left': (overflow.width > 0) ? (-parentWidth - _menus[id].submenuLeftOffset + 'px') : (parentWidth + _menus[id].submenuLeftOffset + 'px'),
                        'top': (overflow.height > 0) ? (y - overflow.height + _menus[id].submenuTopOffset) + 'px' : y + _menus[id].submenuTopOffset + 'px'
                    }
                );     
                     	            
                $submenu.fadeIn(_menus[id].fadeIn);   
            }
            e.stopPropagation(); 
        }).bind('click.jeegoocontext', function(e){
        
            // Invoke onSelect callback if set, 'this' refers to the selected listitem.
            // Discontinue default behavior if callback returns false.
            if(_menus[id].onSelect)
            {            
                if(_menus[id].onSelect.apply(this, [e, _menus[id].context]) == false)
                {
                    e.stopPropagation();
                    return false;
                }
            }
            
            // Default behavior.
            //====================================================//
            
            // Reset menu
            _resetMenu();
                
            // Clear active state from this context.
            $(_menus[id].context).removeClass(_global.activeClass);
            
            e.stopPropagation();
        });
        
        // Event type is a namespaced event so it can be easily unbound later.
        var eventType = _menus[id].event;
        if(!eventType)
        {
            eventType = $.browser.opera ? _menus[id].operaEvent + '.jeegoocontext' : 'contextmenu.jeegoocontext';
        }
        else
        {
            eventType += '.jeegoocontext';
        }
        
        return $(this)[_menus[id].livequery ? 'livequery' : 'bind'](eventType, function(e){
            
			// Save context(i.e. the current area to which the menu belongs).
            _menus[id].context = this;
            var $menu = $('#' + id);

            // Check for overflow and correct menu-position accordingly.         
            var overflow = _overflow((e.pageX + $menu.width() + _menus[id].widthOverflowOffset), (e.pageY + $menu.height() + _menus[id].heightOverflowOffset));         
            if(overflow.width > 0) e.pageX -= overflow.width;
            if(overflow.height > 0) e.pageY -= overflow.height;
                
            // Invoke onShow callback if set, 'this' refers to the menu.
            // Discontinue default behavior if callback returns false.         
            if(_menus[id].onShow)
            {
                if(_menus[id].onShow.apply($menu, [e, _menus[id].context]) == false)
                {
                    e.stopPropagation();
                    return false;
                }
            }

            // Default behavior.
            // =================================================== //

            // Reset last active menu.
            _resetMenu();

            // Set this id as active menu id.
            _global.activeId = id;

            // Clear all active context on page.
            _clearActive();   
                   
            // Make this context active.
            $(_menus[id].context).addClass(_global.activeClass); 
                                   
            // Clear all hover state.
            $menu.find('li, li > *').removeClass(_menus[id].hoverClass);
                       
            // Fade-in menu at clicked-position.		
            $menu.css({
                'left': e.pageX + 'px',
                'top':  e.pageY + 'px'
            }).fadeIn(_menus[id].fadeIn);
			
			// Bind mouseover and click events to the document
			$(document).bind('mouseover.jeegoocontext', function(e){ 
				// Remove hovers from last-opened submenu and hide any open relatedTarget submenu's after timeout.
				if($(e.relatedTarget).parents('#' + id).length > 0)
				{
					// Clear show submenu timeout.
					window.clearTimeout(_menus[id].show);
								   
					var $li = $(e.relatedTarget).parent().find('li');               
					$li.add($li.find('> *')).removeClass(_menus[id].hoverClass);
	
					// Set hide submenu timeout.
					_menus[id].hide = window.setTimeout(function(){
						$li.find('ul').hide();
					}, _menus[id].delay);                             
				}
			}).bind('click.jeegoocontext', function(e){
				// Invoke onHide callback if set, 'this' refers to the menu.    
				// Discontinue default behavior if callback returns false.       
				if(_global.activeId && _menus[_global.activeId].onHide)
				{
					if(_menus[_global.activeId].onHide.apply($('#' + _global.activeId), [e, _menus[_global.activeId].context]) == false)
					{
						return false;
					}
				}
	
				// Default behavior.
				// =================================================== // 
	
				// Clear active context.
				_clearActive();  
				// Hide active menu.
				_resetMenu();
			});

            e.stopPropagation();
            return false;
        });      
    }; 
	
	// Unbind context from context menu.
    $.fn.nojeegoocontext = function(id)
	{
		$(this).unbind('.jeegoocontext');
		
		if(id && _menus[id] instanceof Object) _menus[id] = {};
    };
       	   
})(jQuery);