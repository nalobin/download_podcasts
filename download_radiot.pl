#!/usr/bin/perl

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



mkdir 'podcasts';

mkdir "podcasts/radio_t";

my $is_windows = $^O =~ /win/i;

for ( 350 .. 380  ) {
	my $file = "http://cdn.radio-t.com/rt_podcast$_.mp3";
        my $name = $file;
        $name =~ s{ .+ [/] ( [^/]+ ) \z}{$1}x;
        $name =~ s/ [.]mp3 (.+) \z /.mp3/ix;

        $name = Mojo::Util::url_unescape( $name );
        
        my $to = "podcasts/radio_t/$name";
        if ( -f $to ) {
            say "Skipping $to";
            return;
        }

        say "Downloading $name";

        g( $file )->content->asset->move_to( $to );
}
