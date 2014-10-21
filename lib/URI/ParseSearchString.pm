package URI::ParseSearchString;

use warnings;
use URI::Split ( "uri_split" ) ;
use URI::Escape ( "uri_unescape" ) ;

require Exporter;
@ISA = (Exporter);
@EXPORT = ( "parse_search_string" );

use strict;

=head1 NAME

URI::ParseSearchString - parse Apache refferer logs and extract search engine query strings.

=head1 VERSION

Version 1.8  (more fat - less healthy ingredients!)

=cut

our $VERSION = '1.8';

=head1 SYNOPSIS

    use URI::ParseSearchString ( 'parse_search_string' );

    $string = parse_search_string('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;

=head1 FUNCTIONS

=head2 parse_search_string

This module provides a simple function to parse and extract search engine query strings. It was designed and tested having
Apache referrer logs in mind. It can be used for a wide number of purposes, including tracking down what keywords people use
on popular search engines before they land on a site. It makes use of URI::split to extract the string and URI::Escape to un-escape
the encoded characters in it.	Although a number of existing modules and scripts exist for this purpose,
the majority of them are either outdated using obsolete search strings associated with each engine.

The default function exported is "parse_search_string" which accepts an unquoted referrer string as input and returns the 
search engine query contained within. It currently works with both escaped and un-escaped queries and will translate the search
terms before returning them in the latter case. The function returns undef in all other cases and errors.

for example: 

C<$string = parse_search_string('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;>

would return I<'a simple test'>

whereas

C<$string = parse_search_string('http://www.mamma.com/Mamma?utfout=1&qtype=0&query=a+more%21+complex_+search%24&Submit=%C2%A0%C2%A0Search%C2%A0%C2%A0') ;>

would return I<'a more! complex_ search$'> 

Currently supported search engines include:

=over

=item *
B<AOL (UK)>

=item *
B<AllTheWeb>

=item *
B<ASK.com>

=item *
B<Blueyonder (UK)>

=item *
B<BBC search>

=item *
B<Feedster Blog Search>

=item * 
B<Fireball (DE)>

=item *
B<Froogle>

=item *
B<Froogle UK>

=item *
B<Google>

=item *
B<Google Blog Search>

=item *
B<HotBot>

=item * 
B<Ice Rocket Blog Search>

=item *
B<Lycos>

=item *
B<Mamma>

=item *
B<Megasearching.net>

=item *
B<Mirago (UK)>

=item *
B<MyWebSearch.com>

=item *
B<MSN>

=item *
B<Microsoft live.com>

=item *
B<Orange>

=item *
B<Netscape>

=item *
B<NTLworld>

=item *
B<Technorati Blog Search>

=item * 
B<Tesco Google search>

=item *
B<Tiscali (UK)>

=item *
B<Web.de (DE)>

=item *
B<Yahoo>

=back

=cut

sub parse_search_string {
	my $string = shift ;
	return unless (defined $string ) ; 

	my $query_string ;

	my ($scheme, $auth, $path, $query, $frag) = URI::Split::uri_split($string);
	undef $scheme; undef  $frag ;
	
	return unless defined $auth ;

	# parse technorati and feedster search strings.
	if ($auth =~ m/(technorati|feedster)\.com/i ) {
		$path =~ s/\/search\///g ;
		my $query_string = $path ;
		$query_string = uri_unescape($query_string);
		undef $path ;
		$query_string =~ s/\+/ /g ;
		return $query_string ;
	}
	
	return unless defined $query ;
	undef $path ;
	
	# parse Google
	if ( ($auth =~ m/^www.google\./i) ) {
	  	$query =~ m/\&q=([^&]+)/i || $query =~ m/q=([^&]+)/i ; ;
	  	  return unless defined $1 ;
  	    $query_string = $1 ;
  	    $query_string =~ s/\+/ /g ;
  	    $query_string = uri_unescape($query_string);
  	    return $query_string ;
  }
  	
	# parse MSN, Altavista, Blueyonder, AllTheWeb, Tesco and Ice Rocket search strings.
	if ($auth =~ m/(.altavista.|alltheweb.com|^search.msn.co|.ask.com|search.bbc.co.uk|search.live.com)/i 
	|| $auth =~ m/(blueyonder.co.uk|blogs.icerocket.com|blogsearch.google.com|froogle.google.co|tesco.net|gps.virgin.net|search.ntlworld.com|search.orange.co.uk)/i ) {
		$query =~ m/q=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}
	
	# parse Lycos, HotBot and Fireball.de search strings.
	elsif ($auth =~ m/(search.lycos.|hotbot.co|suche.fireball.de)/i ) {
		$query =~ m/query=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}
	
	# parse mywebsearch.com 
	elsif ($auth =~ m/(search.mywebsearch.com)/i ) {
		$query =~ m/searchfor=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}
	
	# parse Yahoo search strings.
	elsif ($auth =~ m/search.yahoo/i) {
		$query =~ m/p=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}
	
	# parse megasearching.net
	elsif ($auth =~ m/megasearching.net/i) {
		$query =~ m/s=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}
	
	# parse Mirago search strings.
	elsif ($auth =~ m/www.mirago.co.uk/i) {
		$query =~ m/qry=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}
		
	# parse Netscape search strings.
	elsif ($auth =~ m/www.netscape.com/i ) {
		$query =~ m/s=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}
	
	# parse Web.de search string.
	elsif ($auth =~ m/suche.web.de/i ) {
		$query =~ m/su=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}

	# parse Mamma, AOL UK, Tiscali  search strings.
	elsif ($auth =~ m/(mamma.com|search.aol.co.uk|tiscali.co.uk)/i ) {
		$query =~ m/query=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}		

	return ;
	
}

=head1 AUTHOR

Spiros Denaxas, C<< <s.denaxas at gmail.com> >>

=head1 BUGS

This is my first CPAN module so I encourage you to send all comments, especially bad, 
to my email address.

This could not have been possible without the support of my co-workers at 
http://nestoria.co.uk - the easiest way of finding UK property.

=head1 SUPPORT

For more information, you could also visit my blog: 

	http://idaru.blogspot.com

=over 4

=back

=head1 COPYRIGHT & LICENSE

Copyright 2006 Spiros Denaxas, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of URI::ParseSearchString

