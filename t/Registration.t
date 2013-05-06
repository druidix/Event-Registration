#!/usr/bin/perl

use Test::Most;
use DateTime;
use Date::Calc qw( Add_Delta_Days );
use String::Random;

use Event;
use Venue;
use Person;
use Event::Registration;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( event attendee reg_date );

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;

my $reg_meta = Event::Registration->meta();

my %supported_methods = map { $_->name => 1 } $reg_meta->get_all_methods;

is_deeply( \%known_methods, \%supported_methods, "Supports all expected methods" );

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

my $random = String::Random->new;
my $email = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $person = Person->new( email => $email );

my $venue  = Venue->new( name => 'foo' );

my $event  = Event->new( 
    name        => 'bar',
    owner       => $person,
    start_date  => $start_date,
    end_date    => $end_date,
    venue       => $venue,
    private     => 0,
);

my $guest = Person->new( email => 'foo@bar.com', first_name => 'Slarty', last_name => 'Warty' );

# Requires necessary attributes
throws_ok { Event::Registration->new() } qr/Attribute \(attendee\) is required/, "'attendee' attribute is required";

throws_ok {
    Event::Registration->new(attendee => $guest)
} qr/Attribute \(event\) is required/, "'event' attribute is required";

my $reg = Event::Registration->new( event => $event, attendee => $guest );

isa_ok( $reg, 'Event::Registration' );
isa_ok( $reg->reg_date, 'DateTime' );

done_testing;
