#!/usr/bin/perl

use strict;
use warnings;

use Test;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( 
    email first_name last_name can_edit_event 
    can_edit_registration make_admin registration
    has_registration register cancel_registration
);

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
is( $person->can_edit_registration, 0, 'Cannot edit registration by default' );

$person->make_admin();

is( $person->can_edit_event, 1, 'Can edit event by after being made admin' );
is( $person->can_edit_registration, 1, 'Can edit registration after being made admin' );

my $dt      = DateTime->now;
my $year    = $dt->year;
my $month   = $dt->month;
my $day     = $dt->day;

my $start_date = DateTime->new(
    year    => $year,
    month   => $month,
    day     => $day,
);

# Set the end date a few days from today.
my ( $end_year, $end_month, $end_day ) = Add_Delta_Days( $year, $month, $day, 3 );

my $end_date = DateTime->new(
    year    => $end_year,
    month   => $end_month,
    day     => $end_day,
);

my $event = Event->new(
    start_date  => $start_date,
    end_date    => $end_date,
    private     => 0,
    admin       => $person,
    venue       => Venue->new(name => 'foo'),
),

my $guest_email = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $guest = Person->new( email => $guest_email );

is( $guest->has_registration(), '', 'has_registration predicate returns false before registration' );
ok( $guest->register(event => $event), 'Non-admin user can successfully register for an event' );
is( $guest->has_registration(), 1, 'has_registration predicate returns true after successful registration' );

ok( $guest->cancel_registration($event), 'Non-admin user can cancel existing registration for an event' );
is( $guest->has_registration(), '', 'has_registration predicate returns false after cancellation' );
is( $guest->registration(), undef, 'registration() returns undef after cancellation' );


done_testing;
