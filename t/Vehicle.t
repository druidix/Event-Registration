#!/usr/bin/perl

use Test::Most;
use String::Random;

use Vehicle;
use Person;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( year make model color owner );

my $year = 1989;
my $make = 'BMW';
my $model = '325i';

my $random = String::Random->new;
my $email = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $owner = Person->new( email => $email );

# Requires necessary attributes
throws_ok {
    Vehicle->new( make => $make, model => $model, owner => $owner )
} qr/Attribute \(year\) is required/, "'year' attribute is required";

throws_ok {
    Vehicle->new( year => $year, model => $model, owner => $owner )
} qr/Attribute \(make\) is required/, "'make' attribute is required";

throws_ok {
    Vehicle->new( year => $year, make => $make, owner => $owner )
} qr/Attribute \(model\) is required/, "'model' attribute is required";

throws_ok {
    Vehicle->new( make => $make, model => $model, )
} qr/Attribute \(owner\) is required/, "'owner' attribute is required";

# Required attribute class must be of correct class
throws_ok { 
    Vehicle->new( year => $year, make => $make, model => $model, owner => 1 )
} qr/does not pass the type constraint/, "'owner' attribute must be 'Person' class";

isa_ok( Vehicle->new(year => $year, make => $make, model => $model, owner => $owner), 'Vehicle' );

my $vehicle_meta = Vehicle->meta();

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;
my %supported_methods = map { $_->name => 1 } $vehicle_meta->get_all_methods;

is_deeply( \%known_methods, \%supported_methods, "Supports all expected methods" );



done_testing;
