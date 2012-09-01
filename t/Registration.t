#!/usr/bin/perl

use Test::Most;
use DateTime;
use String::Random;

use Event;
use Venue;
use Person;
use Event::Registration;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( event attendee );

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;

my $reg_meta = Event::Registration->meta();

my %supported_methods = map { $_->name => 1 } $reg_meta->get_all_methods;

is_deeply( \%known_methods, \%supported_methods, "Supports all expected methods" );

# Requires necessary attributes
throws_ok { Event::Registration->new() } qr/Attribute \(attendee\) is required/, "'attendee' attribute is required";

my $dt      = DateTime->now;
my $year    = $dt->year;
my $month   = $dt->month;
my $day     = $dt->day;

my $next_month = ++$month;

my $start_date = DateTime->new(
    year    => $year,
    month   => $next_month,
    day     => $day,
);

my $end_date = DateTime->new(
    year    => $year,
    month   => $next_month,
    day     => $day,
);

my $random = String::Random->new;
my $email = $random->randpattern( 'cccccnnn' ) . '@palebluedot.net';
my $admin = Person->new( email => $email );

my $venue  = Venue->new( name => 'foo' );
my $event  = Event->new( start_date => $start_date, end_date => $end_date, venue => $venue, private => 0, admin => $admin );
my $person = Person->new( email => 'foo@bar.com', first_name => 'Slarty', last_name => 'Warty' );

isa_ok( Event::Registration->new(event => $event, attendee => $person ), 'Event::Registration' );

done_testing;
