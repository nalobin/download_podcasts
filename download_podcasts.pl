#!/usr/bin/env perl

use Modern::Perl;
use ojo;
use Mojo::Util;
use Encode 'from_to';
use Getopt::Long;
use DateTime::Format::RSS;
use Number::Bytes::Human 'format_bytes';

my $date_from;
my $date_to  ;

$ENV{MOJO_MAX_MESSAGE_SIZE} = 200_000_000;

my %podcasts = (
    the_art    => 'http://taop.rpod.ru/rss.xml',
    radio_t    => 'http://feeds.rucast.net/radio-t',
    it_compot  => 'http://hack.podfm.ru/it_compot/rss/rss.xml',
    makeitsexy => 'http://makeitsexy.rpod.ru/rss.xml',
    radioma    => 'http://radioma.org/feed',
    razbor     => 'http://feeds.feedburner.com/razbor-podcast',
    pop        => 'http://b0noi.podfm.ru/PoP/rss/rss.xml',
    it_career  => 'http://it-career.podfm.ru/rss/rss.xml',
    devzen     => 'http://devzen.ru/feed/',
);

GetOptions(
    'from=s' => \$date_from,
    'to=s'   => \$date_to  ,
) or die "Error in command line arguments\n";

for ( $date_from, $date_to ) {
    next  unless defined;

    die "Date should be in YYYY-MM-DD format\n"  unless /^\d{4}-\d{2}-\d{2}$/;
}

my @only = @ARGV;

mkdir 'podcasts';

my $is_windows = $^O =~ /win/i;

my $rss_date = DateTime::Format::RSS->new;

while ( my ( $podcast, $url ) = each %podcasts ) {
    next  if @only && !grep { $podcast eq $_ } @only;

    say "Get $podcast";

    g( $url )->dom( 'item' )->each( sub {
        my $pub_date;
        if ( $pub_date = $_->find( 'pubDate' )->[0]->text ) {
            # Sat, 15 Feb 2014 14:13:00 PST
            ( $pub_date ) = split /T/, $rss_date->format_datetime( $rss_date->parse_datetime( $pub_date ) );

            return  if $date_from && $date_from gt $pub_date;  
            return  if $date_to   && $date_to   lt $pub_date;  
        }

        my $enclosure = $_->find( 'enclosure' )->[0] or return;

        my $file = $enclosure->attr( 'url'    );
        my $size = $enclosure->attr( 'length' );

        my $name = $file;
        $name =~ s{ .+ [/] ( [^/]+ ) \z}{$1}x;
        $name =~ s/ [.]mp3 (.+) \z /.mp3/ix;

        $name = Mojo::Util::url_unescape( $name );
        
        from_to( $name, 'utf8', 'cp1251' ) if $is_windows;

	mkdir "podcasts/$podcast";

        my $to = "podcasts/$podcast/${pub_date}_$name";
        if ( -f $to ) {
            say "Skipping $to";
            return;
        }

        say "Downloading $name, $pub_date", $size ? ' ' . format_bytes( $size, base => 1000 ) : '';

        g( $file )->content->asset->move_to( $to );
    } );
}
