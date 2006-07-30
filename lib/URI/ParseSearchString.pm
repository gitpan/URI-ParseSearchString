package URI::ParseSearchString;

use warnings;
use URI::split ( "uri_split" ) ;
use URI::Escape ( "uri_unescape" ) ;

require Exporter;
@ISA = (Exporter);
@EXPORT = ( "parse_search_string" );

use strict;

=head1 NAME

URI::ParseSearchString - parse Apache refferer logs and extract search engine query strings.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.1';

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

				$string = parse_search_string('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;

		would return 'a simple test' 

		whereas

				$string = parse_search_string('http://www.mamma.com/Mamma?utfout=1&qtype=0&query=a+more%21+complex_+search%24&Submit=%C2%A0%C2%A0Search%C2%A0%C2%A0') ;

		would return 'a more! complex_ search$' 

		Currently, the search engines supported include Yahoo, MSN, Google, Tiscali, Netscape, Blueyonder, Mamma, Hotbot, AllTheWeb,
		Lycos and Mirago. I would be glad to add support for any additional search engines you might come across so please feel free to email me.

		That is all, nothing fancy.

=cut

sub parse_search_string {
	
	my $string = shift ;
	return unless (defined $string ) ; 
	
	my $query_string ;
	my ($scheme, $auth, $path, $query, $frag) = URI::Split::uri_split($string);
	undef $scheme; undef  $path ; undef  $frag ;
	return unless (defined $auth && defined $query) ;
	
	# parse Google, MSN, Altavista, Blueyonder, and AllTheWeb search strings.
	if ($auth =~ m/^w{1,}.google\./i || $auth =~ m/.altavista./i || $auth =~ m/alltheweb.com/i || $auth =~ m/^search.msn./i 
	    || $auth =~ m/.ask.com/i || $auth =~ m/blueyonder.co.uk/i ) {
		$query =~ m/q=([^&]+)/i ;
	    $query_string = $1 ;
	    $query_string =~ s/\+/ /g ;
	    $query_string = uri_unescape($query_string);
	    return $query_string ;
	}
	
	# parse Lycos and HotBot search strings.
	elsif ($auth =~ m/search.lycos./i || $auth =~ m/.hotbot.co/i ) {
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
	
	# parse Mamma, AOL UK, Tiscali  search strings.
	elsif ($auth =~ m/mamma.com/i || $auth =~ m/search.aol.co.uk/i || $auth =~ m/tiscali.co.uk/i ) {
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

