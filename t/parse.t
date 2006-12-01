#!perl 

use strict;
use warnings ;
use Test::More 'no_plan'  ;
use Test::NoWarnings      ;

use URI::ParseSearchString ;

my $raa_simpleTests = [

	['http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search',                                  'Google.com simple search'         ],
	['http://www.google.co.uk/search?hl=en&q=a+simple+test&btnG=Google+Search&meta=',                          'Google.co.uk simple search'       ],
	['http://www.google.co.jp/search?hl=ja&q=a+simple+test&btnG=Google+%E6%A4%9C%E7%B4%A2&lr=',                'Google.jp encoding simple search' ],
	['http://search.msn.co.uk/results.aspx?q=a+simple+test&geovar=56&FORM=REDIR',                              'MSN.co.uk simple search'          ],
	['http://search.msn.com/results.aspx?q=a+simple+test&geovar=56&FORM=REDIR',                                'MSN.com simple search'            ],
	['http://www.altavista.com/web/results?itag=ody&q=a+simple+test&kgs=1&kls=0',                              'Altavista.com simple search'      ],
	['http://uk.altavista.com/web/results?itag=ody&q=a+simple+test&kgs=1&kls=0',                               'Altavista.co.uk simple search'    ],
	['http://www.blueyonder.co.uk/blueyonder/searches/search.jsp?q=a+simple+test&cr=&sitesearch=&x=0&y=0',     'Blueyonder.co.uk simple search'   ],
	['http://www.alltheweb.com/search?cat=web&cs=iso88591&q=a+simple+test&rys=0&itag=crv&_sb_lang=pref',       'Alltheweb.com simple search'      ],
	['http://search.lycos.com/?query=a+simple+test&x=0&y=0',                                                   'Lycos.com simple search'          ],	
	['http://search.lycos.co.uk/cgi-bin/pursuit?query=a+simple+test&enc=utf-8&cat=slim_loc&sc=blue',           'Lycos.co.uk simple search'        ],
	['http://www.hotbot.com/index.php?query=a+simple+test&ps=&loc=searchbox&tab=web&mode=search&currProv=msn', 'HotBot.com simple search'         ],
	['http://search.yahoo.com/search?p=a+simple+test&fr=FP-tab-web-t400&toggle=1&cop=&ei=UTF-8',               'Yahoo.com simple search'          ],
	['http://uk.search.yahoo.com/search?p=a+simple+test&fr=FP-tab-web-t340&ei=UTF-8&meta=vc%3D',               'Yahoo.co.uk simple search'        ],
	['http://uk.ask.com/web?q=a+simple+test&qsrc=0&o=0&l=dir&dm=all',                                          'Ask.com simple search'            ],
	['http://www.mirago.co.uk/scripts/qhandler.aspx?qry=a+simple+test&x=0&y=0',                                'Mirago simple search'             ],
	['http://www.netscape.com/search/?s=a+simple+test',                                                        'Netscape.com simple search'       ],
	['http://search.aol.co.uk/web?invocationType=ns_uk&query=a%20simple%20test',                               'AOL UK simple search'             ],
	['http://www.tiscali.co.uk/search/results.php?section=&from=&query=a+simple+test',                         'Tiscali simple search'            ],
	['http://www.mamma.com/Mamma?utfout=1&qtype=0&query=a+simple+test&Submit=%C2%A0%C2%A0Search%C2%A0%C2%A0',  'Mamma.com simple search'          ],
	['http://blogs.icerocket.com/search?q=a+simple+test',																											 'Icerocket Blogs simple search'    ], 
	['http://blogsearch.google.com/blogsearch?hl=en&ie=UTF-8&q=a+simple+test&btnG=Search+Blogs',							 'Google Blogs simple search'					],
	['http://suche.fireball.de/cgi-bin/pursuit?query=a+simple+test&x=0&y=0&cat=fb_loc&enc=utf-8', 						 'Fireball.de simple search'          ],
	['http://suche.web.de/search/web/?allparams=&smode=&su=a+simple+test&webRb=de', 													 'Web.de simple search'								],
	['http://www.technorati.com/search/a%20simple%20test',                                                      'Technorati simple search' ],
	['http://www.feedster.com/search/a%20simple%20test',                                                        'Feedster.com simple search'],
  ['http://www.google.co.uk/search?sourceid=navclient&aq=t&ie=UTF-8&rls=DVXA,DVXA:2006-32,DVXA:en&q=a+simple+test', 'Google weird search']
	
] ;

my $raa_complexTests = [

	['http://www.google.com/search?hl=en&lr=&q=a+more%21+complex_+search%24&btnG=Search',                      'Google.com complex search'                  ],
	['http://www.google.co.uk/search?hl=en&q=a+more%21+complex_+search%24&btnG=Google+Search&meta=',           'Google.co.uk complex search'                ],
	['http://www.google.co.jp/search?hl=ja&q=a+more%21+complex_+search%24&btnG=Google+%E6%A4%9C%E7%B4%A2&lr=', 'Google.co.jp complex search'                ],
	['http://search.msn.com/results.aspx?q=a+more%21+complex_+search%24&FORM=QBHP',                            'MSN.co.uk complex search'                   ],
	['http://search.msn.co.uk/results.aspx?q=a+more%21+complex_+search%24&FORM=MSNH&srch_type=0&cp=65001',     'Altavista.com complex search'               ],
	['http://www.altavista.com/web/results?itag=ody&q=a+more%21+complex_+search%24&kgs=1&kls=0',               'Altavista.com complex search'               ],
	['http://uk.altavista.com/web/results?itag=ody&q=a+more%21+complex_+search%24&kgs=1&kls=0',                'Altavista.co.uk complex search'             ],
  ['http://www.blueyonder.co.uk/blueyonder/searches/search.jsp?q=a+more%21+complex_+search%24&cr=&sitesearch=&x=0&y=0', 'Blueyonder.co.uk complex search' ],
	['http://www.alltheweb.com/search?cat=web&cs=iso88591&q=a+more%21+complex_+search%24&rys=0&itag=crv&_sb_lang=pref', 'Alltheweb.com complex search'      ],
	['http://search.lycos.com/?query=a+more%21+complex_+search%24&x=0&y=0',                                              'Lycos.com complex search'         ],
	['http://search.lycos.co.uk/cgi-bin/pursuit?query=a+more%21+complex_+search%24&enc=utf-8&cat=slim_loc&sc=blue', 'Lucos.co.uk complex search'            ],
	['http://www.hotbot.com/index.php?query=a+more%21+complex_+search%24&ps=&loc=searchbox&tab=web&mode=search&currProv=msn', 'Hotbot.com complex search'   ],
	['http://search.yahoo.com/search?p=a+more%21+complex_+search%24&fr=FP-tab-web-t400&toggle=1&cop=&ei=UTF-8', 'Yahoo.com complex search'   ],
	['http://uk.search.yahoo.com/search?p=a+more%21+complex_+search%24&fr=FP-tab-web-t340&ei=UTF-8&meta=vc%3D', 'Yahoo.co.uk complex search' ],
	['http://uk.ask.com/web?q=a+more%21+complex_+search%24&qsrc=0&o=0&l=dir&dm=all', 'Ask.com complex search'],
	['http://www.mirago.co.uk/scripts/qhandler.aspx?qry=a+more%21+complex_+search%24&x=0&y=0', 'Mirago complex search' ],
	['http://www.netscape.com/search/?s=a+more%21+complex_+search%24', 'Netscape.com complex search' ],
	['http://search.aol.co.uk/web?query=a+more%21+complex_+search%24&x=0&y=0&isinit=true&restrict=wholeweb', 'AOL UK complex search' ],
	['http://www.tiscali.co.uk/search/results.php?section=&from=&query=a+more%21+complex_+search%24', 'Tiscali.co.uk complex search' ],
	['http://www.mamma.com/Mamma?utfout=1&qtype=0&query=a+more%21+complex_+search%24&Submit=%C2%A0%C2%A0Search%C2%A0%C2%A0', 'Mamma.com complex search'],
] ;




diag "\nTesting simple queries\n\n" ;
foreach (@$raa_simpleTests) {
  is ( parse_search_string($_->[0]), 'a simple test', $_->[1] ) ;
} ;
 

diag "\nTesting complex queries\n\n" ;
foreach (@$raa_complexTests) {
  is ( parse_search_string($_->[0]), 'a more! complex_ search$', $_->[1] ) ;

}

diag "\nTesting for akward situations\n\n" ;
is ( parse_search_string('http://googlemapsmania.blogspot.com/'), undef, 'Google-esque sites do not go through') ;
is ( parse_search_string('-------------------------'), undef, 'Works with bad input') ;
is ( parse_search_string(''), undef, 'Works with no input') ;
