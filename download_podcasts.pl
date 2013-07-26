#!/usr/bin/perl

use Modern::Perl;
use ojo;

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
        my $file = $_->attrs( 'url' );

        my $name = $file;
        $name =~ s{ .+ [/] ( [^/]+ ) \z}{$1}x;

        say "Downloading $file";

        g( $file )->content->asset->move_to( "podcasts/$podcast/$name" );
    } );
}