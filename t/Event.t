#!/usr/bin/perl

use Test::Most;
use DateTime;

use Event;
use Venue;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( start_date end_date venue private );

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;

my $event_meta = Event->meta();

my %supported_methods = map { $_->name => 1 } $event_meta->get_all_methods;

is_deeply( \%known_methods, \%supported_methods, "Supports all expected methods" );

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

# Requires necessary attributes
throws_ok {
    Event->new(
        start_date  => $start_date,
        end_date    => $end_date,
        private     => 0,
    )
} qr/Attribute \(venue\) is required/, "'venue' attribute is required";

# Required attribute class must be of correct class
throws_ok { 
    Event->new(
        start_date  => $start_date,
        end_date    => $end_date,
        private     => 0,
        venue       => 1,
    )
} qr/does not pass the type constraint/, "'venue' attribute must be 'Venue' class";

isa_ok( 
    Event->new(
        start_date  => $start_date,
        end_date    => $end_date,
        private     => 0,
        venue => Venue->new(name => 'foo')
    ), 'Event'
);

done_testing;
