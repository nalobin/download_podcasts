#!/usr/bin/perl

use Modern::Perl;
use ojo;
use Mojo::Util;

$ENV{MOJO_MAX_MESSAGE_SIZE} = 200_000_000;

my %podcasts = (
    the_art    => 'http://taop.rpod.ru/rss.xml',
    radio_t    => 'http://feeds.rucast.net/radio-t',
    it_compot  => 'http://hack.podfm.ru/it_compot/rss/rss.xml',
    makeitsexy => 'http://makeitsexy.rpod.ru/rss.xml',
);

mkdir 'podcasts';

while ( my ( $podcast, $url ) = each %podcasts ) {
    say "Get $podcast";

    mkdir "podcasts/$podcast";

    g( $url )->dom( 'enclosure' )->each( sub {
        my $file = $_->attr( 'url' );

        my $name = $file;
        $name =~ s{ .+ [/] ( [^/]+ ) \z}{$1}x;
        $name =~ s/ [.]mp3 (.+) \z /.mp3/ix;

        $name = Mojo::Util::url_unescape( $name );

        my $to = "podcasts/$podcast/$name";
        if ( -f $to ) {
            say "Skipping $to";
            return;
        }

        say "Downloading $name";

        g( $file )->content->asset->move_to( $to );
    } );
}