-- Edit this SQL script so that it contains only those entries you wish to 
-- have in your project's interwiki table.   You can borrow from interwiki.sql,
-- wictionary-interwiki.sql and wikipedia-interwiki.sql, but be sure to edit the 
-- final 'iw_local' value (0 means it's not local to your project).
-- Then run this script 'by hand' to implement the changes.

DELETE FROM /*$wgDBprefix*/interwiki;

REPLACE INTO /*$wgDBprefix*/interwiki (iw_prefix,iw_url,iw_local) VALUES
('glossary', 'http://www13.i2u2.org/glossary/index.php/$1', 1),
('lib',      'http://www13.i2u2.org/glossary/index.php/$1', 1),

('i2u2_p', 'http://www13.i2u2.org/$1', 1),
('i2u2_g', 'http://www13.i2u2.org/glossary/index.php/$1', 1),
('ligo_g', 'http://www13.i2u2.org/glossary/index.php/$1', 1),

('wikipedia','http://en.wikipedia.org/wiki/$1',0),
('w',        'http://en.wikipedia.org/wiki/$1',0),
('mediawiki', 'http://www.mediawiki.org/wiki/$1', 0),
('mw',        'http://www.mediawiki.org/wiki/$1', 0),
('meta','http://meta.wikimedia.org/wiki/$1',0),
('m',   'http://meta.wikimedia.org/wiki/$1',0),
('wiktionary','http://en.wiktionary.org/wiki/$1',0),
('wikibooks','http://en.wikibooks.org/wiki/$1',0),
('wikimedia','http://wikimediafoundation.org/wiki/$1',0),
('wikiquote','http://en.wikiquote.org/wiki/$1',0),
('wikisource','http://sources.wikipedia.org/wiki/$1',0),
('wikispecies','http://species.wikipedia.org/wiki/$1',0),
('wikia','http://www.wikia.com/wiki/index.php/$1',0)

-- be sure to end the list with a semi-colon, not a comma 

;


