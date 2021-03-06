#!/usr/bin/perl -I..lib -Ilib

use Test::More qw( no_plan );
use strict;
use Scalar::Util qw/blessed/;
use Data::Dumper;

BEGIN { use_ok( "Data::H5spec" ); }

my $h = Data::H5spec->new(<<YAMLDATE);
type:
  charset: &CHARSETS
    utf-7: 
    utf-8: Unicode (UTF-8)
attributes:
  - accept-charset:
      t: form
      v: *CHARSETS
  - charset:
      t: [meta, script]
      v: *CHARSETS
  - type:
      t: button
      v:
        button: Does nothing
        reset: Resets the form
        submit: Submits the form
#                dumplicate test for ol type
  - type:
      t: ol
      v: [A, i, I ]
#                dumplicate
  - type:
      v:
        1:
        a:
        A: Uppercase latin alphabet 
      t: ol
  - spellcheck:
      t:
        textarea: This is some text here
      v: on
YAMLDATE

is (ref $h->{yaml}, 'HASH', 'Got yaml hash');

is (@{$h->getAtrributes}, 6, 'Get attributes');

subtest 'traverseAttr values' => sub {
    my $expect = { 'button-type' => {button => "Does nothing",
                                     reset => "Resets the form",
                                     submit => "Submits the form"},
                   'ol-type' => {1 => '', a => '', A => 'Uppercase latin alphabet', i => '', I => ''},
                   'form-accept-charset' => {
                       "utf-7" => '',
                       "utf-8" => "Unicode (UTF-8)"},
                   'meta-charset' => {
                       "utf-7" => '',
                       "utf-8" => "Unicode (UTF-8)",},
                   'script-charset' => {
                       "utf-7" => '',
                       "utf-8" => "Unicode (UTF-8)" },
                   'textarea-spellcheck'  => {"on" => '' }
               };

    my $count = 0;

    $h->traverseAttr(
        sub {
            my ($tag, $attribute, $values) = @_;
            $count++;
            is_deeply($values, $expect->{"$tag-$attribute"}, "\"$tag\" \"$attribute\"")
        });
    is ($count, 6, "Attribute value count");
};


my $h2 = Data::H5spec->new(<<YAMLATTR);
attributes:
  - class:
      t: div
      v:
        clearfix:
        container:
      d: CSS style properties.
  - dir:
      t: global
      d: Text direction.

# this will be ignored, no "d:"
  - src:
      t: foo

  - src:
      t: a
      d:
  - src:
      t: script
      d: URI of external script.
YAMLATTR

subtest 'traverseAttr documentation' => sub {
    my $expect = {
        "div-class" => "CSS style properties.",
        "global-dir" => "Text direction.",
        "a-src" => "",
        "script-src" => "URI of external script.",
    };

    my $count = 0;

    $h2->traverseAttr(
        sub {
            my ($tag, $attribute, $values, $documentation) = @_;
            next unless defined $documentation;

            is($documentation, $expect->{"$tag-$attribute"}, "\"$tag\" \"$attribute\"");

            $count++;
            # is_deeply($values, $expect->{"$tag-$attribute"}, "\"$tag\" \"$attribute\"")
        });
    is($count, 4, "Attributes count");

}
