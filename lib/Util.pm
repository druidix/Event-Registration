package Util;

use Exporter;

use base qw(Exporter);

@EXPORT = qw(normalize_string);

# This is to be used as long we don't have unique IDs for different objects.  To ensure a reasonable match,
# we take names (e.g. event names) and remove all non-alpha-numeric entities from them (note that this
# includes spaces!)
sub normalize_string {

    my $str = shift;
    die "Must supply string to normalize!" unless( $str );

    my $normalized = $str;
    $normalized =~ s/[^a-z A-Z 0-9]+//g;

    return $normalized;
}


1;
