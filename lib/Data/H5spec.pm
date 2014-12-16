package Data::H5spec;

use strict; 
use warnings;

use Carp;
use YAML qw/Load/;
use Data::Dumper;

our $VERSION = '1.01'; # Don't forget to set version and release date in POD!

=head1 NAME

H5spec - yaml spec file reader

=head1 SYNOPSIS

    $spec->traverseAttr(
        sub {
            my ($tag, $attribute, $valueRef) = @_;
            print "Tag \"$tag\" with attribute \"$attribute\" have next values:".
                join "\n"
                    , map {
                        $_ . ':' . $valueRef->{$_}
                    } sort keys %{$valueRef};
            print "\n\n";
                }
    );

=cut

sub new {
    my $class = shift;
    return bless ({
        yaml => Load(shift ())
    }, $class);
}

sub getAtrributes {
    my $self = shift;

    die "In your YAML file you must have ARRAY \"attributes\"" unless ref $self->{yaml}->{attributes} eq 'ARRAY';
    return $self->{yaml}->{attributes};
}

sub _resKey {
    my ($tag, $attr) = @_;
    return "$tag--$attr";
}

sub _tagAttrFromKey {
    my $key = shift;
    my ($tag, $attribute) = $key =~ m|(.*?)--(.*)|;
}

# add to hash ref newest document
sub addToRes {
    my ($res, $tag, $attribute, $v, $documentation) = @_;
    my $resKey = _resKey($tag, $attribute);

    my $rdoc = \$res->{$resKey}->{documentation};
    if (defined $$rdoc && defined $documentation) {
        warn <<WARNTTEXT
Redefined documentation for \"$tag\" \$attribute
was: $$rdoc
now: $documentation
WARNTTEXT
            ;
    }
    if (defined $documentation) {
        $$rdoc = $documentation;
    }

    foreach my $valuename (keys (%{$v})) {

        my $rval = \$res->{$resKey}->{values}{$valuename};
        if (($$rval // '') eq '') {
            $$rval = $v->{$valuename} // '';
            next;
        }
        if (($v->{$valuename} // '') ne '') {
            warn <<WARNTTEXT 
Duplication found for \"$tag\" \"$attribute\" \"$valuename\":
  was: $$rval
  now: $v->{$valuename}
WARNTTEXT
                ;
            $$rval = $v->{$valuename} // '';
        }
    }
}

=head1 B<traverseAttr>

  traverseAttr( $cb );

Where

  $cb => sub {
  my ($tag, $attribute, $valuehash, $attributeDocumentation) = @_; }

=cut

sub traverseAttr {
    my $self = shift;
    my $cb = shift;

    my %res;

    foreach my $it (@{$self->getAtrributes}) {
        my $attribute= (keys (%{$it}))[0];
        my $currentAttr = $it->{$attribute};

        die "There no \"t\" key in attribute \"$attribute\". You forgot define it?"
            if !exists($currentAttr->{"t"});

        my @tagnames;
        if (ref $currentAttr->{"t"} eq 'HASH') {
            @tagnames = keys(%{$currentAttr->{"t"}});
        } elsif (ref $currentAttr->{"t"} eq 'ARRAY') {
            @tagnames = @{$currentAttr->{"t"}};
        } else {
            push @tagnames, $currentAttr->{"t"};
        }

        foreach my $tagname (@tagnames) {
            my $text;
            my $v = $currentAttr->{"v"};
            my $documentation = undef;
            $documentation = $currentAttr->{"d"} // ''
                if (exists $currentAttr->{"d"});

            if (ref $v eq 'HASH') {
                addToRes(\%res, $tagname, $attribute,
                         $v,
                         $documentation);
            } elsif (ref $v eq 'ARRAY') {
                addToRes(\%res, $tagname, $attribute,
                         {map { $_ => ''} @{$v}},
                         $documentation);
            } elsif (ref $v eq '') {
                addToRes(\%res, $tagname, $attribute,
                         defined $v ? {$v => ''} : undef,
                         $documentation),
                     }
        }
    }

    foreach my $k (keys %res) {
        my ($tag, $attribute) = _tagAttrFromKey($k) ;
        if (defined $attribute) {
            $cb->($tag, $attribute, $res{$k}{values}, $res{$k}{documentation});
        }
    }
}

sub traverseTags {
    my $self = shift;
    my $cb = shift;

    return unless exists $self->{yaml}{tags};

    die "In your yaml config file, \"tags\" must be hash" if (ref $self->{yaml}{tags} ne 'HASH');

    while (my ($tag, $documentation) = each $self->{yaml}{tags}){
        $cb->($tag, $documentation //= '');
    }
}
1;
