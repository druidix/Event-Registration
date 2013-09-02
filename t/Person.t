#!/usr/bin/perl

use strict;
use warnings;

use Test;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( 
    email first_name last_name can_edit_event can_edit_registration
    make_admin_for_event registrations admin_for_events
    register cancel_registration cancel_all_registrations
    cancel_admin get_registration
);

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;

my $person_meta = Person->meta();

my %supported_methods = map { $_->name => 1 } $person_meta->get_all_methods;

is_deeply( \%known_methods, \%supported_methods, 'Supports all expected methods' );

my $random = String::Random->new;
my $owner_email         = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $other_owner_email   = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $guest_email         = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $admin_test_email    = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';

# Requires necessary attributes
throws_ok { Person->new() } qr/Attribute \(email\) is required/, "'email' attribute is required"; 

# Person objects for testing around ownership
my $event_owner = Person->new( email => $owner_email );
my $other_event_owner = Person->new( email => $other_owner_email );
my $guest = Person->new( email => $guest_email );

# Person objects for testing around admin functions
my $admin_test_person = Person->new( email => $admin_test_email );

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
    venue       => Venue->new(name => 'bar'),
);

# Make another set of dates after the first set
my ( $start_year2, $start_month2, $start_day2 ) = Add_Delta_Days( $year, $month, $day, 5 );
my ( $end_year2, $end_month2, $end_day2 ) = Add_Delta_Days( $start_year2, $start_month2, $start_day2, 2 );

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

my $event2 = Event->new(
    name        => 'baz',
    start_date  => $start_date2,
    end_date    => $end_date2,
    private     => 0,
    owner       => $other_event_owner,
    venue       => Venue->new(name => 'baz'),
);

my @events = ( $event0, $event1, $event2 );

foreach my $event ( @events ) {

    ok( $guest->register(event => $event), 'Non-admin user can successfully register for event [' . $event->name() . ']' );
}

is( ref($guest->registrations()), 'ARRAY', 'registrations() is a list ref' );
is( scalar(@{$guest->registrations()}), scalar(@events), 'registrations() returns expected number of items' );

foreach my $reg ( @{$guest->registrations()} ) {
    
    isa_ok( $reg, 'Event::Registration' );

    if ( lc($reg->event->owner->email) eq lc($event_owner->email) ) {

        is( $event_owner->can_edit_registration(reg => $reg), 1, 'Event owner can edit a guest registration by default' );
    }
}

###### BEGIN Admin tests
# $event_owner owns $event0 so an admin calls to $event1 should fail
throws_ok { $event_owner->make_admin_for_event(event => $event1, person => $admin_test_person); }
    qr/do not have admin rights/, 'Trying to call admin function without admin rights fails'; 

is( $event_owner->can_edit_event(event => $event1), 0, 'Cannot edit event not owned by self and no admin rights' );

throws_ok { $event_owner->cancel_admin(event => $event1, person => $admin_test_person); }
    qr/do not have admin rights/, 'Trying to cancel admin without admin rights fails'; 


my $non_owned_reg = $guest->get_registration( event => $event1 );
isa_ok( $non_owned_reg, 'Event::Registration' );

# $event_owner owns $event0 so she cannot edit a reg for $event1
is(
    $event_owner->can_edit_registration(reg => $non_owned_reg),
    0,
    'Cannot edit registration for event not owned by self and no admin rights'
);

# The admin test person should not be able to edit an event or reg without being made admin first
is(
    $admin_test_person->can_edit_event(event => $event1),
    0,
    'Admin test person cannot edit event not owned by self and no admin rights'
);

is(
    $admin_test_person->can_edit_registration(reg => $non_owned_reg),
    0,
    'Admin test person cannot edit registration for event not owned by self and no admin rights'
);

# The above tests should succeed after $admin_test_person is made an admin for that event, which
# has to be done by $other_event_owner who owns $event1 and $event2
my @events_to_add_admin_to = ( $event1, $event2 );

foreach my $event ( @events_to_add_admin_to ) {

    is(
        $other_event_owner->make_admin_for_event(event => $event, person => $admin_test_person),
        1,
        'Event owner can promote a non-admin person to be event admin for her event [' . $event->name . ']'
    );

    is(
        $admin_test_person->can_edit_event(event => $event),
        1,
        'Admin test person can edit event [' . $event->name . '] by after being made admin'
    );

    is( $event->is_owner(person => $guest), 0, 'Admin for event [' . $event->name . '] is not event owner' );
}

is(
    scalar(@{$admin_test_person->admin_for_events()}),
    scalar( @events_to_add_admin_to ),
    'Admin test person is admin for expected number of events'
);

is(
    $admin_test_person->can_edit_registration(reg => $non_owned_reg),
    1,
    'Admin test person can edit registration for event [' . $non_owned_reg->event->name() . '] not owned by self after being made admin'
);

is(
    $other_event_owner->cancel_admin(event => $event1, person => $admin_test_person),
    1,
    'Event owner can remove admin for admin test person for her event'
);

is(
    scalar(@{$admin_test_person->admin_for_events()}),
    scalar(@events_to_add_admin_to) - 1,
    'Admin test person is admin for expected number of events after calling cancel_admin()'
);

is(
    $admin_test_person->admin_for_events->[0]->name,
    'baz',
    'Admin test person is admin for the correct remaining event after calling cancel_admin()'
);
###### END Admin tests

my $orig_reg_count = scalar( @{$guest->registrations()} );

is(
    $guest->cancel_registration( reg => $guest->registrations()->[0] ),
    1,
    'Non-admin user can cancel one of her existing registrations'
);

is(
    scalar( @{$guest->registrations()} ),
    --$orig_reg_count,
    'Reg count after canceling individual reg is one less than original'
);

ok( $guest->cancel_all_registrations(), 'Non-admin user can cancel all of her existing registrations' );
is_deeply( $guest->registrations(), [], 'registrations() returns empty list ref after cancellation' );


done_testing;
