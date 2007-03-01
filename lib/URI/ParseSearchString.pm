package URI::ParseSearchString;

use warnings;
use URI::Split ( "uri_split" ) ;
use URI::Escape ( "uri_unescape" ) ;

require Exporter;
@ISA = (Exporter);
@EXPORT = ( qw (parse_search_string findEngine) );

use strict;

=head1 NAME

URI::ParseSearchString - parse Apache refferer logs and extract search engine query strings.

=head1 VERSION

Version 1.9  (more fat - less healthy ingredients!)

=cut

our $VERSION = '1.9';

=head1 SYNOPSIS

    use URI::ParseSearchString ;

    my $uparse = new URI::ParseSearchString() ;
    
    $string = $uparse->parse_search_string('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;
    $engine = $uparse->findEngine('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;

=head1 FUNCTIONS

=head2 new
  
  Creates a new instance object of the module.
  
  my $uparse = new URI::ParseSearchString() ;

=cut

sub new {
  my $class = shift ;
  my $self = { } ;
  my @engines = (<DATA>) ;
  
  $self->{engines} = \@engines ;
  
  return bless $self, $class ;
}

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

C<$string = $uparse->parse_search_string('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;>

would return I<'a simple test'>

whereas

C<$string = $uparse->parse_search_string('http://www.mamma.com/Mamma?utfout=1&qtype=0&query=a+more%21+complex_+search%24&Submit=%C2%A0%C2%A0Search%C2%A0%C2%A0') ;>

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
B<Starware>

=item *
B<Technorati Blog Search>

=item * 
B<Tesco Google search>

=item *
B<Tiscali (UK)>

=item *
B<VirginMedia>

=item *
B<Web.de (DE)>

=item *
B<Yahoo>

=back

=cut

sub parse_search_string {
  my $self = shift ;
  
	my $string = shift ;
	return unless defined $string ; 

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
	if ($auth =~ m/(.altavista.|alltheweb.com|^search.msn.co|.ask.com|search.bbc.co.uk|search.live.com|search.virginmedia.com)/i 
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
	
  # parse starware search strings
  elsif ( $auth =~ m/as.starware.com/i ) {
    $query =~ m/qry=([^&]+)/i ;
     $query_string = $1 ;
	   $query_string =~ s/\+/ /g ;
	   $query_string = uri_unescape($query_string);
	   return $query_string ;
  }
  return ;
}

=head2 findEngine

  Returns the search engine identified as extracted by the supplied
  referrer URL.
  
my $engine = $uparse->findEngine('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;
 
  This will return "google.com" as the search engine.

  Currently supports 231 Google TLD's & all the above mentioned search engines.

=cut

sub findEngine {
  my $self = shift ;
  my $ref_str = shift ;
  return unless defined $ref_str ;
  
  my $ra_engines = $self->{engines} ;
  return unless defined $ra_engines && ref $ra_engines eq 'ARRAY' ;
        
  foreach my $engine (@$ra_engines) {
    chomp ($engine) ;
    next if $engine =~ m@^#@ ;
    $engine =~ s/\s{1,}//g ;
    
    if ($ref_str =~ m/$engine/i ) {
       $engine =~ s@www.@@ ;
       return $engine ;
    }    
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

__DATA__
## -- Google TLD's
blogsearch.google.com
www.google.ad 
www.google.ae 
www.google.af 
www.google.com.af 
www.google.ag 
www.google.com.ag
www.google.off.ai 
www.google.com.ai 
www.google.am 
www.google.com.ar 
www.google.as 
www.google.at 
www.google.co.at 
www.google.com.au 
www.google.az 
www.google.com.az 
www.google.bas
www.google.com.bd 
www.google.be
www.google.bg
www.google.com.bh 
www.google.bi 
www.google.com.bi 
www.google.co.bi 
www.google.biz 
www.google.com.bn 
www.google.bo 
www.google.com.bo 
www.google.com.br 
www.google.bs 
www.google.com.bs 
www.google.co.bw 
www.google.bz 
www.google.com.bz 
www.google.ca 
www.google.cc 
www.google.cd 
www.google.cg 
www.google.ch 
www.google.ci 
www.google.co.ci 
www.google.co.ck 
www.google.cl 
www.google.cn 
www.google.com.cn 
www.google.com.co 
www.google.com
www.google.co.cr 
www.google.com.cu 
www.google.cz 
www.google.de 
www.google.dj 
www.google.dk 
www.google.dm 
www.google.com.do 
www.google.ec 
www.google.com.ec 
www.google.ee 
www.google.com.eg 
www.google.es 
www.google.com.et 
www.google.fi 
www.google.com.fj 
www.google.fm 
www.google.fr 
www.google.gd 
www.google.ge 
www.google.com.ge 
www.google.gf 
www.google.gg 
www.google.co.gg 
www.google.com.gh 
www.google.com.gi 
www.google.gl 
www.google.com.gl 
www.google.co.gl 
www.google.gm 
www.google.gp 
www.google.com.gp 
www.google.gr 
www.google.com.gr 
www.google.com.gt 
www.google.gy 
www.google.com.gy 
www.google.co.gy 
www.google.hk 
www.google.com.hk 
www.google.hn 
www.google.com.hn 
www.google.hr 
www.google.com.hr 
www.google.ht 
www.google.hu 
www.google.co.hu 
www.google.co.id 
www.google.ie 
www.google.co.il 
www.google.im 
www.google.co.im 
www.google.in 
www.google.co.in 
www.google.info 
www.google.is 
www.google.it 
www.google.co.it 
www.google.je 
www.google.co.je 
www.google.com.jm 
www.google.jo 
www.google.com.jo 
www.google.jobs 
www.google.jp 
www.google.co.jp
www.google.co.ke 
www.google.kg 
www.google.com.kg 
www.google.com.kh 
www.google.ki 
www.google.com.ki 
www.google.co.kr 
www.google.kz 
www.google.com.kz 
www.google.la 
www.google.li 
www.google.lk 
www.google.com.lk 
www.google.co.ls 
www.google.lt 
www.google.lu 
www.google.lv 
www.google.com.lv 
www.google.com.ly 
www.google.ma 
www.google.co.ma 
www.google.md 
www.google.mn 
www.google.mobi 
www.google.ms 
www.google.com.mt 
www.google.mu 
www.google.com.mu 
www.google.co.mu 
www.google.mv 
www.google.mw 
www.google.com.mw 
www.google.co.mw 
www.google.com.mx 
www.google.com.my 
www.google.com.na 
www.google.net 
www.google.nf 
www.google.com.nf 
www.google.com.ng 
www.google.com.ni 
www.google.nl 
www.google.no 
www.google.com.np 
www.google.nr 
www.google.com.nr 
www.google.nu 
www.google.co.nz 
www.google.com.om 
www.google.com.pa 
www.google.com.pe 
www.google.ph 
www.google.com.ph 
www.google.pk 
www.google.com.pk 
www.google.pl 
www.google.com.pl 
www.google.pn 
www.google.co.pn 
www.google.pr 
www.google.com.pr 
www.google.pt 
www.google.com.pt 
www.google.com.py 
www.google.com.qa 
www.google.ro 
www.google.ru 
www.google.com.ru 
www.google.rw 
www.google.com.sa 
www.google.com.sb 
www.google.sc 
www.google.com.sc 
www.google.se 
www.google.sg 
www.google.com.sg 
www.google.sh 
www.google.si 
www.google.sk 
www.google.sm 
www.google.sn 
www.google.sr 
www.google.st 
www.google.com.sv 
www.google.co.th 
www.google.com.tj 
www.google.tk 
www.google.tm 
www.google.to 
www.google.tp 
www.google.com.tr 
www.google.tt 
www.google.com.tt 
www.google.co.tt 
www.google.tv 
www.google.tw 
www.google.com.tw 
www.google.ug 
www.google.co.ug 
www.google.co.uk 
www.google.us 
www.google.com.uy 
www.google.uz 
www.google.com.uz 
www.google.co.uz 
www.google.com.ve 
www.google.co.ve 
www.google.vg 
www.google.com.vi 
www.google.co.vi 
www.google.vn 
www.google.com.vn 
www.google.vu 
www.google.ws 
www.google.com.ws 
www.google.co.za 
www.google.co.zm 
www.google.co.zw
## -- other engines
uk.altavista.com
altavista.com
search.msn.co.uk
search.msn.com
search.lycos.co.uk
search.lycos.com
uk.search.yahoo.com
search.yahoo.com
www.mirago.co.uk
uk.ask.com
www.netscape.com
search.aol.co.uk
www.tiscali.co.uk
www.mamma.com
blogs.icerocket.com
www.hotbot.com
suche.web.de
suche.fireball.de
www.alltheweb.com
www.technorati.com
www.feedster.com
www.tesco.net
gps.virgin.net
search.bbc.co.uk
search.live.com
search.mywebsearch.com
www.megasearching.net
www.blueyonder.co.uk
search.orange.co.uk
search.ntlworld.com
search.virginmedia.com
as.starware.com