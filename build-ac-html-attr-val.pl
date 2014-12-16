#!/usr/bin/perl -w -Ilib
# build-ac-html-attr-val.pl --- Build html-stuff for ac-html
# Created: 03 Dec 2014

use warnings;
use strict;

use Getopt::Long;
use FindBin;
use File::Spec;
use Data::H5spec;
use File::Slurp qw/read_file write_file/;
use File::Path qw/mkpath/;
use Data::Dumper;

sub usage {

    my $Line;
    my ($Script) = ( $0 =~ m#([^\\/]+)$# );

    $Line = "-" x length( $Script );

    print << "EOT";

$Script
$Line
Build html-staff/html-attributes-complete/ files for ac-html

  Usage:
    $0 [--help]
    $0 [--text filename] [--outdir directory]

    --help......Display this simple help message.
    --text......Use own attribute definition file instead
                \$SCRIPT/text/attrib.yaml
    --outdir....Set output directory default is
                \$SCRIPT/ac-html/html-stuff/html-attributes-complete

See also https://github.com/cheunghy/ac-html
EOT
}

main: {

    my $yamlFile = File::Spec->catfile($FindBin::Bin, './text/attrib.yaml');
    my $outputdir = File::Spec->catdir($FindBin::Bin, '/ac-html/html-stuff/html-attributes-complete');

    my $help = 0;

    GetOptions ( "text=s" => \$yamlFile,
                 "outdir=s" => \$outputdir,
                 "help|?"  => \$help);

    if ($help) {
        usage();
        exit(0);
    }

    my $spec = Data::H5spec->new(''.read_file($yamlFile));

    mkpath $outputdir;


    $spec->traverseAttr(
        sub {
            my ($tag, $attribute, $valueRef) = @_;
            my $filename = File::Spec->catfile($outputdir, "$tag-$attribute");

            write_file($filename,
                       join "\n"
                           , map {
                               if ($valueRef->{$_} ne '') {
                                   $_ . ' ' . do { (my $newLineEscaped = $valueRef->{$_}) =~ s/\n/\\n/g; 
                                                   $newLineEscaped }
                               } else {
                                   $_
                               }
                           } sort keys %{$valueRef}
                       );
            print "Create: $filename\n";
        });

}

__END__

=head1 AUTHOR

Olexandr Sydorchuk, E<lt>olexandr.syd [YOU KNOW] gmail.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Olexandr

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14 or,
at your option, any later version of Perl 5 you may have available.

=cut



