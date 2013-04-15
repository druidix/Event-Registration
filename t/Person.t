#!/usr/bin/perl

use strict;
use warnings;

use Test;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( 
    email first_name last_name can_edit_event 
    can_edit_registration make_admin registrations admin_for_events
    register cancel_all_registrations cancel_all_admin_privileges
    normalize_string
);

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;

my $person_meta = Person->meta();

my %supported_methods = map { $_->name => 1 } $person_meta->get_all_methods;

is_deeply( \%known_methods, \%supported_methods, "Supports all expected methods" );

my $random = String::Random->new;
my $owner_email         = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $other_owner_email   = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $guest_email         = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';

# Requires necessary attributes
throws_ok { Person->new() } qr/Attribute \(email\) is required/, "'email' attribute is required"; 

my $event_owner = Person->new( email => $owner_email );
my $other_event_owner = Person->new( email => $other_owner_email );
my $guest = Person->new( email => $guest_email );


# Create a new event, we will need this for testing of admin functions.  Need start and end dates for this.
my $event_dt        = DateTime->now;
my $event_year      = $event_dt->year;
my $event_month     = $event_dt->month;
my $event_day       = $event_dt->day;

my $event_start_date = DateTime->new(
    year    => $event_year,
    month   => $event_month,
    day     => $event_day,
);

# Set the end date a few days from today.
my ( $event_end_year, $event_end_month, $event_end_day ) = Add_Delta_Days( $event_year, $event_month, $event_day, 3 );

my $event_end_date = DateTime->new(
    year    => $event_end_year,
    month   => $event_end_month,
    day     => $event_end_day,
);

my $event0 = Event->new(
    name        => 'foo',
    start_date  => $event_start_date,
    end_date    => $event_end_date,
    private     => 0,
    owner       => $event_owner,
    venue       => Venue->new(name => 'foo'),
),

isa_ok( $event_owner, 'Person' );
is( $event_owner->can_edit_event(event => $event0), 1, 'Can edit owned event by default' );

# TODO:  Rewrite these tests after implementing admin creation
#$person->make_admin();
#
#is( $person->can_edit_event, 1, 'Can edit event by after being made admin' );
#is( $person->can_edit_registration, 1, 'Can edit registration after being made admin' );

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

my $event1 = Event->new(
    name        => 'bar',
    start_date  => $start_date,
    end_date    => $end_date,
    private     => 0,
    owner       => $other_event_owner,
    venue       => Venue->new(name => 'foo'),
);

# Make another set of dates after the first set
#my ( $start_year2, $start_month2, $start_day2 ) = Add_Delta_Days( $year, $month, $day, 5 );
#my ( $end_year2, $end_month2, $end_day2 ) = Add_Delta_Days( $start_year2, $start_month2, $start_day2, 2 );

#my $start_date2 = DateTime->new(
#    year    => $start_year2,
#    month   => $start_month2,
#    day     => $start_day2,
#);
#
#my $end_date2 = DateTime->new(
#    year    => $end_year2,
#    month   => $end_month2,
#    day     => $end_day2,
#);
#
#my $event2 = Event->new(
#    name        => 'baz',
#    start_date  => $start_date,
#    end_date    => $end_date,
#    private     => 0,
#    owner       => $other_event_owner,
#    venue       => Venue->new(name => 'foo'),
#);

foreach my $event ( $event0, $event1 ) {

    ok( $guest->register(event => $event), 'Non-admin user can successfully register for event' );
}

is( ref($guest->registrations()), 'ARRAY', 'registrations() is a list ref' );
is( scalar(@{$guest->registrations()}), 2, 'registrations() returns expected number of items' );

foreach my $reg ( @{$guest->registrations()} ) {
    
    isa_ok( $reg, 'Event::Registration' );

    if ( lc($reg->event->owner->email) eq lc($event_owner->email) ) {

        is( $event_owner->can_edit_registration(reg => $reg), 1, "Event owner can edit a guest's registration by default" );
    }
}

ok( $guest->cancel_all_registrations(), 'Non-admin user can cancel all of her existing registrations' );
is_deeply( $guest->registrations(), [], 'registrations() returns empty list ref after cancellation' );


done_testing;
