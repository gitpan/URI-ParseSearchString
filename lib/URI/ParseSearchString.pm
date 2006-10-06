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

Version 0.6  (more fat - less healthy ingredients!)

=cut

our $VERSION = '0.6';

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
B<Blueyonder (UK)>

=item * 
B<Fireball (DE)>

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
B<Mirago (UK)>

=item *
B<MSN>

=item *
B<Netscape>

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
	undef $scheme; undef  $path ; undef  $frag ;
	return unless (defined $auth && defined $query) ;
	
	# parse Google, MSN, Altavista, Blueyonder, AllTheWeb and Ice Rocket search strings.
	if ($auth =~ m/(^w{1,}.google\.|.altavista.|alltheweb.com|^search.msn.co|.ask.com)/i 
	|| $auth =~ m/(blueyonder.co.uk|blogs.icerocket.com|blogsearch.google.com)/i ) {
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
	
	# parse Yahoo search strings.
	elsif ($auth =~ m/search.yahoo/i) {
		$query =~ m/p=([^&]+)/i ;
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

