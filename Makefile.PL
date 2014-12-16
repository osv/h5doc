#use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => "H5spec",
    VERSION_FROM => "lib/Data/H5spec.pm",
    AUTHOR => 'Olexandr Sydorchuk',
    EXE_FILES => [ 'build-ac-html-attr-val.pl' ],

    PREREQ_PM => {
        'Carp'              => '0',
        'File::Basename'    => '0',
        'File::Path'        => '0',
        'File::Spec'        => '0',
        'File::Slurp'       => '0',
        'Getopt::Long'      => '0',
        'Data::Dumper'      => '0',
        'Test::More'        => '0.98', # For subtest()
        'Text::ParseWords'  => '3.1',
        'Scalar::Util'      => '0',
        'YAML'              => '0',
        },
);
