<?php
// Functions for displaying news items on the front page


// Fill in missing fields in an RSS item, both new and old 
// (Forward/backward compatibility.  Someday this won't be needed?)
// 
function fill_rss_item($item){
    // Convert old-style array to new indexes
    //
    if( isset($item[0]) && !isset($item['date']) ){
        $item['date'] = $item[0];
    }
    if( isset($item[1]) && !isset($item['description']) ){
        $item['description'] = $item[1];
    }
    if( isset($item[2]) && !isset($item['title']) ){
        $item['title'] = $item[2];
    }

    // Pad new-style array with old indexes, so we can go back
    //
    if( isset($item['date']) && !isset($item[0]) ){
        $item[0] = $item['date'];
    }
    if( isset($item['description']) && !isset($item[1]) ){
        $item[1] = $item['description'];
    }
    if( isset($item['title']) && !isset($item[2]) ){
        $item[2] = $item['title'];
    }
    return $item;
}


// Display a single RSS news item
//
function rss_news_item( $item ) {
    // A news item can exist but be marked 'hidden' 
    if( array_key_exists('status', $item) && $item['status'] == "hidden" ) return;

    // fill in any fields from old-style indexing, and vice versa
    $item = fill_rss_item($item);

    if( isset($item['date']) ) {
        echo "<span class='news_date'>".$item["date"]."</span><br>\n";
    };

    if( isset($item['title']) ) {
        echo "<span class='news_title'>".$item['title']."</span><br>\n";
    }

    if( isset($item['description']) ) {
        echo "<span class='news_description'>".$item['description']."</span><br>\n";
    }

    if( isset($item['link']) ) {
        //TODO: make this tr(RSS_MORE_INFO_LINK) 
        echo "<span class='news_link'>
               <a href='".$item['link']."'>More information...</a>  
                </span><br>\n";
    }
    echo "<p>";
}


// Show the current news, up to $n items
//
function show_news($items, $n) {
    if ($n > count($items)) $n = count($items);
    for ($i=0; $i<$n; $i++) {
        rss_news_item($items[$i]);
    }
}

// Show the old news, everything after the ($n)th  item 
//
function show_old_news($items, $n) {
    for ($i=$n; $i<count($items); $i++) {
        rss_news_item($items[$i]);
    }
}

?>
