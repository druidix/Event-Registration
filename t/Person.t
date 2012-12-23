#!/usr/bin/perl

use Test::Most;
use String::Random;

use Person;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( email first_name last_name can_edit_event make_admin );

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;

my $person_meta = Person->meta();

my %supported_methods = map { $_->name => 1 } $person_meta->get_all_methods;

is_deeply( \%known_methods, \%supported_methods, "Supports all expected methods" );

my $random = String::Random->new;
my $email = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';

# Requires necessary attributes
throws_ok { Person->new() } qr/Attribute \(email\) is required/, "'email' attribute is required"; 

my $person = Person->new( email => $email );

isa_ok( $person, 'Person' );
is( $person->can_edit_event, 0, 'Cannot edit event by default' );

$person->make_admin();

is( $person->can_edit_event, 1, 'Can edit event by after being made admin' );


done_testing;
