#!/usr/bin/perl

use Test::Most;
use String::Random;

use Person;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( email first_name last_name );

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;

my $person_meta = Person->meta();

my %supported_methods = map { $_->name => 1 } $person_meta->get_all_methods;

is_deeply( \%known_methods, \%supported_methods, "Supports all expected methods" );

my $random = String::Random->new;
my $email = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';

# Requires necessary attributes
throws_ok { Person->new() } qr/Attribute \(email\) is required/, "'email' attribute is required"; 

isa_ok( Person->new( email => $email ), 'Person' );

done_testing;
