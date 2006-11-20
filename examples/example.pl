#!/usr/bin/perl -w 

use strict ;
use URI::ParseSearchString ;

my $ref_str = 'http://www.google.com/search?hl=en&q=this+is+an+example&btnG=Google+Search' ;

my $keywords = parse_search_string($ref_str) ;

print "The keywords were: $keywords \n" ;