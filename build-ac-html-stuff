#!/usr/bin/perl -w -Ilib
# build-ac-html-attr-val.pl --- Build html-stuff for ac-html from yaml file
# Created: 03 Dec 2014

use warnings;
use strict;

use Getopt::Long;
use FindBin;
use File::Spec;
use Data::H5spec;
use File::Slurp qw/read_file write_file/;
use File::Path qw/mkpath rmtree/;
use Data::Dumper;

use constant AC_HTML_TAG_LIST            => 'html-tag-list';
use constant AC_HTML_TAG_DOCS            => 'html-tag-short-docs';
use constant AC_HTML_ATTRIBUTES          => 'html-attributes-list';
use constant AC_HTML_ATTR_DOCS           => 'html-attributes-short-docs';
use constant AC_HTML_ATTRIBUTES_COMPLETE => 'html-attributes-complete';

sub usage {

    my $Line;
    my ($Script) = ( $0 =~ m#([^\\/]+)$# );

    $Line = "-" x length( $Script );

    print << "EOT";

$Script
$Line
Build html-staff files for ac-html

  Usage:
    $0 [--help]
    $0 [options] YAMLFILE

    --help......Display this simple help message.
    --outdir....Set output directory default is:
                ./html-stuff
    --maxdoc....Max size of documentation help, before put it to separate file.
                Default is 250
    YAMLFILE....Yaml config file. See example in "text" dir.

See also https://github.com/cheunghy/ac-html
EOT
}

main: {

    my $outputdir = './html-stuff';
    my $maxdocsize = 250;
    my $help = 0;

    GetOptions ( "outdir=s" => \$outputdir,
                 'maxdoc=i' => \$maxdocsize,
                 "help|?"  => \$help);

    my $yamlFile = $ARGV[0];
    if ($help || ($yamlFile // '') eq '') {
        usage();
        exit(0);
    }

    my $spec = Data::H5spec->new(''.read_file($yamlFile));

    my $tagfilename = File::Spec->catfile ($outputdir, AC_HTML_TAG_LIST);
    my $tagdocdir = File::Spec->catfile ($outputdir, AC_HTML_TAG_DOCS);
    my $attrdir = File::Spec->catfile ($outputdir, AC_HTML_ATTRIBUTES);
    my $attrdocdir = File::Spec->catfile ($outputdir, AC_HTML_ATTR_DOCS);
    my $valuedir = File::Spec->catfile($outputdir, AC_HTML_ATTRIBUTES_COMPLETE);

    unlink $tagfilename;
    rmtree $tagdocdir;
    rmtree $attrdir;
    rmtree $attrdocdir;
    rmtree $valuedir;

    mkpath $tagdocdir;
    mkpath $attrdir;
    mkpath $attrdocdir;
    mkpath $valuedir;

    open (my $FH, ">", $tagfilename) or die "Can't create file $tagfilename $!";
    print "Create: $tagfilename\n";

    $spec->traverseTags(
        sub {
            my ($tag, $documentation) = @_;
            if (length $documentation > $maxdocsize) {
                my $docfilename = File::Spec->catfile ($tagdocdir, $tag);
                write_file ($docfilename, $documentation);
                print "Create: $docfilename\n";
                print $FH "$tag\n";
            } else {
                $documentation =~ s/\n/\\n/g;
                print $FH "$tag $documentation\n";
            }
        });

    close $FH;

    $spec->traverseAttr(
        sub {
            my ($tag, $attribute, $valueRef, $attrDocumentation) = @_;
            my $filename = File::Spec->catfile ($valuedir, "$tag-$attribute");

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
            print Dumper \$attrDocumentation;

            if (defined $attrDocumentation) {
                my $attrFile = File::Spec->catfile ($attrdir, "$tag-$attribute");
                unless (-e $attrFile) {
                    print "Create: $attrFile\n";
                }
                open (my $FHATTR, ">>", $attrFile) or die "Can't open file $attrFile $!";
                if (length $attrDocumentation > $maxdocsize) {
                    my $attrDocFile = File::Spec->catfile ($attrdocdir, "$tag-$attribute");
                    write_file($attrDocFile, $attrDocumentation);
                    print "Create: $attrDocFile";
                    print $FHATTR $attribute . "\n";
                } else {
                    $attrDocumentation =~ s/\n/\\n/g;
                    print $FHATTR "$attribute $attrDocumentation\n";
                }
                close $FHATTR;
            }
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



