#!/usr/bin/perl

use Test::Most;

use Venue;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( name address url );

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;

my $venue_meta = Venue->meta();

my %supported_methods = map { $_->name => 1 } $venue_meta->get_all_methods;

is_deeply( \%known_methods, \%supported_methods, "Supports all expected methods" );

throws_ok { Venue->new() } qr/Attribute \(name\) is required/, "'name' is required for construction";

isa_ok( Venue->new(name => 'foo'), 'Venue' );

done_testing;
