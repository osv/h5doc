#!/usr/bin/perl -I..lib -Ilib

use Test::More qw( no_plan );
use strict;
use Data::Dumper;

BEGIN { use_ok( "H5spec" ); }
my $h = H5spec->new(<<YAMLTAG);
tags:
  div:
  nav: |
    Documentation here
  span:
YAMLTAG

subtest 'traverseTags' => sub {
    my $expect = {div => "",
               nav => "Documentation here\n",
               span => ""};

    my $count = 0;
    $h->traverseTags(
        sub {
            my ($tag, $documentation) = @_;
            is($documentation, $expect->{$tag}, "Check tag <$tag>");
            $count++;
        }
    );
    is ($count, 3, "Tags count");
}










