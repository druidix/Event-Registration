#!/usr/bin/perl

use strict;
use warnings;

use Test;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( 
    email first_name last_name can_edit_event 
    can_edit_registration make_admin registrations
    register cancel_all_registrations
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

# Make another set of dates after the first set
my ( $start_year2, $start_month2, $start_day2 ) = Add_Delta_Days( $year, $month, $day, 5 );
my ( $end_year2, $end_month2, $end_day2 ) = Add_Delta_Days( $start_year2, $start_month2, $start_day2, 2 );

my $end_date = DateTime->new(
    year    => $end_year,
    month   => $end_month,
    day     => $end_day,
);

my $start_date2 = DateTime->new(
    year    => $start_year2,
    month   => $start_month2,
    day     => $start_day2,
);

my $end_date2 = DateTime->new(
    year    => $end_year2,
    month   => $end_month2,
    day     => $end_day2,
);

my $event1 = Event->new(
    start_date  => $start_date,
    end_date    => $end_date,
    private     => 0,
    admin       => $person,
    venue       => Venue->new(name => 'foo'),
),

my $event2 = Event->new(
    start_date  => $start_date,
    end_date    => $end_date,
    private     => 0,
    admin       => $person,
    venue       => Venue->new(name => 'foo'),
),

my $guest_email = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $guest = Person->new( email => $guest_email );

foreach my $event ( ($event1, $event2) ) {

    ok( $guest->register(event => $event), 'Non-admin user can successfully register for event' );
}

is( ref($guest->registrations()), 'ARRAY', 'registrations() is a list ref' );
is( scalar(@{$guest->registrations()}), 2, 'registrations() returns expected number of items' );

foreach my $reg ( @{$guest->registrations()} ) {
    
    isa_ok( $reg, 'Event::Registration' );
}

ok( $guest->cancel_all_registrations(), 'Non-admin user can cancel all of her existing registrations' );
is_deeply( $guest->registrations(), [], 'registrations() returns empty list ref after cancellation' );


done_testing;
