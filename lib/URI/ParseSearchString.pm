package URI::ParseSearchString;

require Exporter;
@ISA = (Exporter);
@EXPORT = ( qw (parse_search_string findEngine se_host se_name se_term) );

use warnings;
use strict;

use URI::Split  ( "uri_split"    ) ;
use URI::Escape ( "uri_unescape" ) ;

=head1 NAME

URI::ParseSearchString - parse Apache refferer logs and extract search engine query strings.

=head1 VERSION

Version 2.6  (i-have-a-cold version)

=cut

our $VERSION = '2.6';

=head1 SYNOPSIS

  use URI::ParseSearchString ;

  my $uparse = new URI::ParseSearchString() ;
  
  my $query_terms = 
      $uparse->se_term('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;
  my $engine_name = 
     $uparse->se_name('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;
  my $engine_hostname = 
     $uparse->se_host('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;

=head1 FUNCTIONS

=head2 new
  
  Creates a new instance object of the module.
  
  my $uparse = new URI::ParseSearchString() ;

=cut

my $RH_LOOKUPS = {
   'abacho.com'             => 'Abacho',
   'alice.it'               => 'Alice.it',
   'altavista.com'          => { name => 'Altavista', mutex => 'uk.altavista.com' },
   'aolsearch.aol.com'      => 'AOL Search',
   'as.starware.com'        => 'Starware',
   'blogs.icerocket.com'    => 'IceRocket',
   'blogsearch.google.com'  => 'Google Blogsearch',
   'busca.orange.es'        => 'Orange ES',
   'buscador.lycos.es'      => 'Lycos ES',
   'buscador.terra.es'      => 'Terra ES',
   'buscar.ozu.es'          => 'Ozu ES',
   'categorico.it'          => 'Categorico IT',
   'cuil.com'               => 'Cuil',
   'excite.com'             => 'Excite',
   'excite.it'              => 'Excite IT',
   'www.fastweb.it'         => 'Fastweb IT',
   'godado.com'             => 'Godado',
   'godado.it'              => 'Godado (IT)',
   'gps.virgin.net'         => 'Virgin Search',
   'ilmotore.com'           => 'ilMotore',
   'ithaki.net'             => 'Ithaki',
   'kataweb.it'             => 'Kataweb IT',
   'libero.it'              => 'Libero IT',
   'lycos.it'               => 'Lycos IT',
   'search.aol.co.uk'       => 'AOL UK',
   'search.arabia.msn.com'  => 'MSN Arabia',
   'search.bbc.co.uk'       => 'BBC Search',
   'search.conduit.com'     => 'Conduit',
   'search.icq.com'         => 'ICQ dot com',
   'search.live.com'        => 'Live.com',
   'search.lycos.co.uk'     => 'Lycos UK',
   'search.lycos.com'       => 'Lycos',
   'search.msn.co.uk'       => 'MSN UK',
   'search.msn.com'         => 'MSN',
   'search.myway.com'       => 'MyWay',
   'search.mywebsearch.com' => 'My Web Search',
   'search.ntlworld.com'    => 'NTLWorld',
   'search.orange.co.uk'    => 'Orange Search',
   'search.prodigy.msn.com' => 'MSN Prodigy',
   'search.sweetim.com'     => 'Sweetim',
   'search.virginmedia.com' => 'VirginMedia',
   'search.yahoo.co.jp'     => 'Yahoo Japan',
   'search.yahoo.com'       => { name => 'Yahoo!', mutex => 'uk.search.yahoo.com' },
   'search.yahoo.jp'        => 'Yahoo! Japan',
   'simpatico.ws'           => 'Simpatico IT',
   'soso.com'               => 'Soso',
   'suche.fireball.de'      => 'Fireball DE',
   'suche.web.de'           => 'Suche DE',
   'suche.t-online.de'      => 'T-Online',
   'thespider.it'           => 'TheSpider IT',
   'uk.altavista.com'       => 'Altavista UK',
   'uk.ask.com'             => 'Ask UK',
   'uk.search.yahoo.com'    => 'Yahoo! UK',
   'www.alltheweb.com'      => 'AllTheWeb',
   'www.ask.com'            => 'Ask dot com',
   'www.blueyonder.co.uk'   => 'Blueyonder',
   'www.feedster.com'       => 'Feedster',
   'www.google.ad'          => 'Google Andorra',
   'www.google.ae'          => 'Google United Arab Emirates',
   'www.google.af'          => 'Google Afghanistan',
   'www.google.ag'          => 'Google Antiqua and Barbuda',
   'www.google.am'          => 'Google Armenia',
   'www.google.as'          => 'Google American Samoa',
   'www.google.at'          => 'Google Austria',
   'www.google.az'          => 'Google Azerbaijan',
   'www.google.ba'          => 'Google Bosnia and Herzegovina',
   'www.google.be'          => 'Google Belgium',
   'www.google.bg'          => 'Google Bulgaria',
   'www.google.bi'          => 'Google Burundi',
   'www.google.biz'         => 'Google dot biz',
   'www.google.bo'          => 'Google Bolivia',
   'www.google.bs'          => 'Google Bahamas',
   'www.google.bz'          => 'Google Belize',
   'www.google.ca'          => 'Google Canada',
   'www.google.cc'          => 'Google Cocos Islands',
   'www.google.cd'          => 'Google Dem Rep of Congo',
   'www.google.cg'          => 'Google Rep of Congo',
   'www.google.ch'          => 'Google Switzerland',
   'www.google.ci'          => 'Google Cote dIvoire',
   'www.google.cl'          => 'Google Chile',
   'www.google.cn'          => 'Google China',
   'www.google.co.at'       => 'Google Austria',
   'www.google.co.bi'       => 'Google Burundi',
   'www.google.co.bw'       => 'Google Botswana',
   'www.google.co.ci'       => 'Google Ivory Coast',
   'www.google.co.ck'       => 'Google Cook Islands',
   'www.google.co.cr'       => 'Google Costa Rica',
   'www.google.co.gg'       => 'Google Guernsey',
   'www.google.co.gl'       => 'Google Greenland',
   'www.google.co.gy'       => 'Google Guyana',
   'www.google.co.hu'       => 'Google Hungary',
   'www.google.co.id'       => 'Google Indonesia',
   'www.google.co.il'       => 'Google Israel',
   'www.google.co.im'       => 'Google Isle of Man',
   'www.google.co.in'       => 'Google India',
   'www.google.co.it'       => 'Google Italy',
   'www.google.co.je'       => 'Google Jersey',
   'www.google.co.jp'       => 'Google Japan',
   'www.google.co.ke'       => 'Google Kenya',
   'www.google.co.kr'       => 'Google South Korea',
   'www.google.co.ls'       => 'Google Lesotho',
   'www.google.co.ma'       => 'Google Morocco',
   'www.google.co.mu'       => 'Google Mauritius',
   'www.google.co.mw'       => 'Google Malawi',
   'www.google.co.nz'       => 'Google New Zeland',
   'www.google.co.pn'       => 'Google Pitcairn Islands',
   'www.google.co.th'       => 'Google Thailand',
   'www.google.co.tt'       => 'Google Trinidad and Tobago',
   'www.google.co.ug'       => 'Google Uganda',
   'www.google.co.uk'       => 'Google UK',
   'www.google.co.uz'       => 'Google Uzbekistan',
   'www.google.co.ve'       => 'Google Venezuela',
   'www.google.co.vi'       => 'Google US Virgin Islands',
   'www.google.co.za'       => 'Google	South Africa',
   'www.google.co.zm'       => 'Google Zambia',
   'www.google.co.zw'       => 'Google Zimbabwe',
   'www.google.com'         => 'Google',
   'www.google.com.af'      => 'Google Afghanistan',
   'www.google.com.ag'      => 'Google Antiqua and Barbuda',
   'www.google.com.ai'      => 'Google Anguilla',
   'www.google.com.ar'      => 'Google Argentina',
   'www.google.com.au'      => 'Google Australia',
   'www.google.com.az'      => 'Google Azerbaijan',
   'www.google.com.bd'      => 'Google Bangladesh',
   'www.google.com.bh'      => 'Google Bahrain',
   'www.google.com.bi'      => 'Google Burundi',
   'www.google.com.bn'      => 'Google Brunei Darussalam',
   'www.google.com.bo'      => 'Google Bolivia',
   'www.google.com.br'      => 'Google Brazil',
   'www.google.com.bs'      => 'Google Bahamas',
   'www.google.com.bz'      => 'Google Belize',
   'www.google.com.cn'      => 'Google China',
   'www.google.com.co'      => 'Google',
   'www.google.com.cu'      => 'Google Cuba',
   'www.google.com.do'      => 'Google Dominican Rep',
   'www.google.com.ec'      => 'Google Ecuador',
   'www.google.com.eg'      => 'Google Egypt',
   'www.google.com.et'      => 'Google Ethiopia',
   'www.google.com.fj'      => 'Google Fiji',
   'www.google.com.ge'      => 'Google Georgia',
   'www.google.com.gh'      => 'Google Ghana',
   'www.google.com.gi'      => 'Google Gibraltar',
   'www.google.com.gl'      => 'Google Greenland',
   'www.google.com.gp'      => 'Google Guadeloupe',
   'www.google.com.gr'      => 'Google Greece',
   'www.google.com.gt'      => 'Google Guatemala',
   'www.google.com.gy'      => 'Google Guyana',
   'www.google.com.hk'      => 'Google Hong Kong',
   'www.google.com.hn'      => 'Google Honduras',
   'www.google.com.hr'      => 'Google Croatia',
   'www.google.com.jm'      => 'Google Jamaica',
   'www.google.com.jo'      => 'Google Jordan',
   'www.google.com.kg'      => 'Google Kyrgyzstan',
   'www.google.com.kh'      => 'Google Cambodia',
   'www.google.com.ki'      => 'Google Kiribati',
   'www.google.com.kz'      => 'Google Kazakhstan',
   'www.google.com.lk'      => 'Google Sri Lanka',
   'www.google.com.lv'      => 'Google Latvia',
   'www.google.com.ly'      => 'Google Libya',
   'www.google.com.mt'      => 'Google Malta',
   'www.google.com.mu'      => 'Google Mauritius',
   'www.google.com.mw'      => 'Google Malawi',
   'www.google.com.mx'      => 'Google Mexico',
   'www.google.com.my'      => 'Google Malaysia',
   'www.google.com.na'      => 'Google Namibia',
   'www.google.com.nf'      => 'Google Norfolk Island',
   'www.google.com.ng'      => 'Google Nigeria',
   'www.google.com.ni'      => 'Google Nicaragua',
   'www.google.com.np'      => 'Google Nepal',
   'www.google.com.nr'      => 'Google Nauru',
   'www.google.com.om'      => 'Google Oman',
   'www.google.com.pa'      => 'Google Panama',
   'www.google.com.pe'      => 'Google Peru',
   'www.google.com.ph'      => 'Google Philipines',
   'www.google.com.pk'      => 'Google Pakistan',
   'www.google.com.pl'      => 'Google Poland',
   'www.google.com.pr'      => 'Google Puerto Rico',
   'www.google.com.pt'      => 'Google Portugal',
   'www.google.com.py'      => 'Google Paraguay',
   'www.google.com.qa'      => 'Google',
   'www.google.com.ru'      => 'Google Russia',
   'www.google.com.sa'      => 'Google Saudi Arabia',
   'www.google.com.sb'      => 'Google Solomon Islands',
   'www.google.com.sc'      => 'Google Seychelles',
   'www.google.com.sg'      => 'Google Singapore',
   'www.google.com.sv'      => 'Google El Savador',
   'www.google.com.tj'      => 'Google Tajikistan',
   'www.google.com.tr'      => 'Google Turkey',
   'www.google.com.tt'      => 'Google Trinidad and Tobago',
   'www.google.com.tw'      => 'Google Taiwan',
   'www.google.com.uy'      => 'Google Uruguay',
   'www.google.com.uz'      => 'Google Uzbekistan',
   'www.google.com.ve'      => 'Google Venezuela',
   'www.google.com.vi'      => 'Google US Virgin Islands',
   'www.google.com.vn'      => 'Google Vietnam',
   'www.google.com.ws'      => 'Google Samoa',
   'www.google.cz'          => 'Google Czech Rep',
   'www.google.de'          => 'Google Germany',
   'www.google.dj'          => 'Google Djubouti',
   'www.google.dk'          => 'Google Denmark',
   'www.google.dm'          => 'Google Dominica',
   'www.google.ec'          => 'Google Ecuador',
   'www.google.ee'          => 'Google Estonia',
   'www.google.es'          => 'Google Spain',
   'www.google.fi'          => 'Google Finland',
   'www.google.fm'          => 'Google Micronesia',
   'www.google.fr'          => 'Google France',
   'www.google.gd'          => 'Google Grenada',
   'www.google.ge'          => 'Google Georgia',
   'www.google.gf'          => 'Google French Guiana',
   'www.google.gg'          => 'Google Guernsey',
   'www.google.gl'          => 'Google Greenland',
   'www.google.gm'          => 'Google Gambia',
   'www.google.gp'          => 'Google Guadeloupe',
   'www.google.gr'          => 'Google Greece',
   'www.google.gy'          => 'Google Guyana',
   'www.google.hk'          => 'Google Hong Kong',
   'www.google.hn'          => 'Google Honduras',
   'www.google.hr'          => 'Google Croatia',
   'www.google.ht'          => 'Google Haiti',
   'www.google.hu'          => 'Google Hungary',
   'www.google.ie'          => 'Google Ireland',
   'www.google.im'          => 'Google Isle of Man',
   'www.google.in'          => 'Google India',
   'www.google.info'        => 'Google dot info',
   'www.google.is'          => 'Google Iceland',
   'www.google.it'          => 'Google Italy',
   'www.google.je'          => 'Google Jersey',
   'www.google.jo'          => 'Google Jordan',
   'www.google.jobs'        => 'Google dot jobs',
   'www.google.jp'          => 'Google Japan',
   'www.google.kg'          => 'Google Kyrgyzstan',
   'www.google.ki'          => 'Google Kiribati',
   'www.google.kz'          => 'Google Kazakhstan',
   'www.google.la'          => 'Google Laos',
   'www.google.li'          => 'Google Liechtenstein',
   'www.google.lk'          => 'Google Sri Lanka',
   'www.google.lt'          => 'Google Lithuania',
   'www.google.lu'          => 'Google Luxembourg',
   'www.google.lv'          => 'Google Latvia',
   'www.google.ma'          => 'Google Morocco',
   'www.google.md'          => 'Google Moldova',
   'www.google.mn'          => 'Google Mongolia',
   'www.google.mobi'        => 'Google dot mobi',
   'www.google.ms'          => 'Google Montserrat',
   'www.google.mu'          => 'Google Mauritius',
   'www.google.mv'          => 'Google Maldives',
   'www.google.mw'          => 'Google Malawi',
   'www.google.net'         => 'Google dot net',
   'www.google.nf'          => 'Google Norfolk Island',
   'www.google.nl'          => 'Google Netherlands',
   'www.google.no'          => 'Google Norway',
   'www.google.nr'          => 'Google Nauru',
   'www.google.nu'          => 'Google Niue',
   'www.google.off.ai'      => 'Google Anguilla',
   'www.google.ph'          => 'Google Philipines',
   'www.google.pk'          => 'Google Pakistan',
   'www.google.pl'          => 'Google Poland',
   'www.google.pn'          => 'Google Pitcairn Islands',
   'www.google.pr'          => 'Google Puerto Rico',
   'www.google.pt'          => 'Google Portugal',
   'www.google.ro'          => 'Google Romania',
   'www.google.ru'          => 'Google Russia',
   'www.google.rw'          => 'Google Rwanda',
   'www.google.sc'          => 'Google Seychelles',
   'www.google.se'          => 'Google Sweden',
   'www.google.sg'          => 'Google Singapore',
   'www.google.sh'          => 'Google Saint Helena',
   'www.google.si'          => 'Google Slovenia',
   'www.google.sk'          => 'Google Slovakia',
   'www.google.sm'          => 'Google San Marino',
   'www.google.sn'          => 'Google Senegal',
   'www.google.sr'          => 'Google Suriname',
   'www.google.st'          => 'Google Sao Tome',
   'www.google.tk'          => 'Google Tokelau',
   'www.google.tm'          => 'Google Turkmenistan',
   'www.google.to'          => 'Google Tonga',
   'www.google.tp'          => 'Google East Timor',
   'www.google.tt'          => 'Google Trinidad and Tobago',
   'www.google.tv'          => 'Google Tuvalu',
   'www.google.tw'          => 'Google Taiwan',
   'www.google.ug'          => 'Google Uganda',
   'www.google.us'          => 'Google US',
   'www.google.uz'          => 'Google Uzbekistan',
   'www.google.vg'          => 'Google British Virgin Islands',
   'www.google.vn'          => 'Google Vietnam',
   'www.google.vu'          => 'Google Vanuatu',
   'www.google.ws'          => 'Google Samoa',
   'www.hotbot.com'         => 'HotBot',
   'www.mamma.com'          => 'Mamma',
   'www.megasearching.net'  => 'Megasearching',
   'www.mirago.co.uk'       => 'Mirago UK',
   'www.netscape.com'       => 'Netscape',
   'www.technorati.com'     => 'Technorati',
   'www.tesco.net'          => 'Tesco Search',
   'www.tiscali.co.uk'      => 'Tiscali UK',
};

sub new {
  my $class        = shift ;
  my $self         = { } ;
  $self->{engines} = $RH_LOOKUPS; 
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

   $string = 
      $uparse->parse_search_string('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search');

would return I<'a simple test'>

whereas

   $string = 
      $uparse->parse_search_string('http://www.mamma.com/Mamma?utfout=1&qtype=0&query=a+more%21+complex_+search%24&Submit=%C2%A0%C2%A0Search%C2%A0%C2%A0');

would return I<'a more! complex_ search$'> 

Currently supported search engines include:

=over

=item *
B<Abacho>

=item *
B<AOL (UK)>

=item *
B<AOLSEARCH>

=item *
B<AllTheWeb>

=item *
B<ASK.com>

=item *
B<Blueyonder (UK)>

=item *
B<BBC search>

=item *
B<Categorico (IT)>

=item *
B<Conduit>

=item *
B<Cuil>

=item *
B<Fastweb IT>

=item *
B<Feedster Blog Search>

=item * 
B<Fireball (DE)>

=item *
B<Froogle>

=item *
B<Froogle (UK)>

=item *
B<Google & 231 other TLD's>

=item *
B<Google Blog Search>

=item *
B<Godado>

=item *
B<Godado (IT)>

=item *
B<HotBot>

=item * 
B<Ice Rocket Blog Search>

=item *
B<ICQ.com>

=item *
B<ilMotore.com>

=item *
B<Ithaki.net>

=item *
B<Kataweb (IT)>

=item *
B<Lycos>

=item * 
B<Lycos (ES)>

=item *
B<Lycos (IT)>

=item *
B<Libero (IT)>

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
B<MyWay>

=item *
B<Netscape>

=item *
B<NTLworld>

=item *
B<Orange>

=item *
B<Ozu ES>

=item *
B<Starware>

=item *
B<Sweetim>

=item *
B<Simpatico (IT)>

=item *
B<Soso>

=item *
B<T-Online DE>

=item *
B<Technorati Blog Search>

=item * 
B<Tesco Google search>

=item *
B<Terra (ES)>

=item *
B<Tiscali (UK)>

=item *
B<TheSpider (IT)>

=item *
B<VirginMedia>

=item *
B<Web.de (DE)>

=item *
B<Yahoo>

=item *
B<Yahoo Japan>

=back

=cut

=head2 se_term

Same as parse_search_string().

=cut

sub se_term {
  my $self = shift ;
  my $string = shift ;
  
  return unless defined $string ;
  return $self->parse_search_string($string) ;
    
}

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
	
	# parse Google , Ozu.es
	if ( ($auth =~ m/^www.google\./i) ) {
	  	$query =~ m/\&q=([^&]+)/i || $query =~ m/q=([^&]+)/i ; ;
	  	  return unless defined $1 ;
  	    $query_string = $1 ;
  }
  	
	# parse MSN, Altavista, Blueyonder, AllTheWeb, Tesco and Ice Rocket search strings.
	if ($auth =~ m/(.altavista.|sweetim.com|alltheweb.com|^search.msn.co|.ask.com|search.bbc.co.uk|search.live.com|search.virginmedia.com|search.prodigy.msn.com)/i 
	|| $auth =~ m/(suche.t-online.de|fastweb.it|cuil.com|categorico.it|search.abacho.com|www.excite.|kataweb.it|thespider.it|search.icq.com|blueyonder.co.uk|search.conduit.com|blogs.icerocket.com|blogsearch.google.com|froogle.google.co|tesco.net|gps.virgin.net|search.ntlworld.com|search.orange.co.uk|search.arabia.msn.com)/i ) {
		$query =~ m/q=([^&]+)/i ;
	    $query_string = $1 ;
	}

   # ozu.es
	if ($auth =~ m/(.ozu.es)/i ) {
		 $query =~ m/\&q=([^&]+)/i ;
	    $query_string = $1 ;
	}
		
	# parse Lycos, HotBot and Fireball.de search strings.
	elsif ($auth =~ m/(simpatico.ws|libero.it|ithaki.net|ilmotore.com|lycos.es|terra.es|search.lycos.|hotbot.co|suche.fireball.de|aolsearch.aol.com|lycos.it)/i ) {
		$query =~ m/query=([^&]+)/i ;
	    $query_string = $1 ;
	}

   # parse mywebsearch.com 
	elsif ($auth =~ m/(godado.(it|com))/i ) {
		$query =~ m/key=([^&]+)/i ;
	    $query_string = $1 ;
	}	
	
	# parse mywebsearch.com 
	elsif ($auth =~ m/(search.mywebsearch.com)/i ) {
		$query =~ m/searchfor=([^&]+)/i ;
	    $query_string = $1 ;
	}
	
	# parse Yahoo search strings.
	elsif ($auth =~ m/search.yahoo/i) {
		$query =~ m/p=([^&]+)/i ;
	    $query_string = $1 ;
	}
	
	# parse Soso.com
	
	elsif ($auth =~ m/soso.com/i) {
		$query =~ m/w=([^&]+)/i ;
	    $query_string = $1 ;
	}
	
	# parse megasearching.net
	elsif ($auth =~ m/megasearching.net/i) {
		$query =~ m/s=([^&]+)/i ;
	    $query_string = $1 ;
	}
	
	# parse Mirago search strings.
	elsif ($auth =~ m/www.mirago.co.uk/i) {
		$query =~ m/qry=([^&]+)/i ;
	    $query_string = $1 ;
	}
		
	# parse Alice.it
   elsif ($auth =~ m/alice.it/i) {
		$query =~ m/qs=([^&]+)/i ;
	    $query_string = $1 ;
	}		
		
	# parse Netscape search strings.
	elsif ($auth =~ m/www.netscape.com/i ) {
		$query =~ m/s=([^&]+)/i ;
	    $query_string = $1 ;
	}
	
	# parse Web.de search string.
	elsif ($auth =~ m/suche.web.de/i ) {
		$query =~ m/su=([^&]+)/i ;
	    $query_string = $1 ;
	}

	# parse Orange.es search string.
	elsif ($auth =~ m/orange.es/i ) {
		$query =~ m/buscar=([^&]+)/i ;
	    $query_string = $1 ;
	}

   # parse Orange.es search string.
	elsif ($auth =~ m/.myway.com/i ) {
		$query =~ m/searchfor=([^&]+)/i ;
	    $query_string = $1 ;
	}
		
	# parse Mamma, AOL UK, Tiscali  search strings.
	elsif ($auth =~ m/(mamma.com|search.aol.co.uk|tiscali.co.uk)/i ) {
		$query =~ m/query=([^&]+)/i ;
	    $query_string = $1 ;
	}		
	
  # parse starware search strings
  elsif ( $auth =~ m/as.starware.com/i ) {
    $query =~ m/qry=([^&]+)/i ;
     $query_string = $1 ;
  }
  
  if ( defined($query_string) ) {
     $query_string =~ s/\+/ /g ;
     $query_string = uri_unescape($query_string);
     return $query_string
   }
   
  return undef;
  
}

=head2 findEngine

 Returns the search engine hostname and name extracted by the supplied referrer URL.
  
  my $engine = 
     $uparse->findEngine('http://www.google.com/search?hl=en&q=a+simple+test&btnG=Google+Search') ;
 
This will return "google.com" as the search engine hostname and 'Google' as the name.
Currently supports 231 Google TLD's & all the above mentioned search engines.

=cut

sub findEngine {
  my $self    = shift ;
  my $ref_str = shift ;

  return unless defined $ref_str;
  
  foreach my $e ( keys %{$self->{engines}} ) {
    
     my $name = $self->{engines}->{$e};
     
     if ( ref($self->{engines}->{$e}) eq 'HASH' ) {
        $name = $self->{engines}->{$e}->{name};
     }
         
     if ( $ref_str =~ m@\b$e\b@i ) {
        
        if ( ref($self->{engines}->{$e}) eq 'HASH' 
             && $self->{engines}->{$e}->{mutex}
         )  {
            next if ( $ref_str =~ m!$self->{engines}->{$e}->{mutex}!i );
         }
 
        $e =~ s!www.!!;
        return ($e, $name);
     }     
 }
  
  return ;
}

=head2 se_host 

Wrapper around findEngine. Returns the search engine hostname.

=cut

sub se_host {
  my $self = shift ;
  my $string = shift ;
  return unless defined $string ;
  my ($host,$name) = $self->findEngine($string) ;
  return $host ;
}

=head2 se_name

Wrapper around findEngine. Returns the search engine canonical name.

=cut

sub se_name {
  my $self = shift ;
  my $string = shift ;
  return unless defined $string ;
  my ($host,$name) = $self->findEngine($string) ;
  return $name ;
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

Copyright 2008 Spiros Denaxas, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of URI::ParseSearchString