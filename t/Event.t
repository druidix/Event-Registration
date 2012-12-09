#!/usr/bin/perl

use Test::Most;
use DateTime;
use Date::Calc qw( Add_Delta_Days );
use String::Random;

use Event;
use Venue;
use Person;

# Moose autogenerates these methods on object instantiation
my @moose_methods = qw( dump BUILDALL DESTROY DEMOLISHALL can meta BUILDARGS isa does VERSION new DOES );
my @our_methods = qw( start_date end_date venue private admin );

my %known_methods = map { $_ => 1 } @moose_methods, @our_methods;

my $event_meta = Event->meta();

my %supported_methods = map { $_->name => 1 } $event_meta->get_all_methods;

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
my $admin = Person->new( email => $email );

# Requires necessary attributes
throws_ok {
    Event->new(
        start_date  => $start_date,
        end_date    => $end_date,
        private     => 0,
    )
} qr/Attribute \(admin\) is required/, "'admin' attribute is required";

# Required attribute class must be of correct class
throws_ok { 
    Event->new(
        start_date  => $start_date,
        end_date    => $end_date,
        private     => 0,
        admin       => 1,
        venue       => 1,
    )
} qr/does not pass the type constraint/, "'admin' attribute must be 'Person' class";

throws_ok {
    Event->new(
        start_date  => $start_date,
        end_date    => $end_date,
        private     => 0,
        admin       => $admin,
    )
} qr/Attribute \(venue\) is required/, "'venue' attribute is required";

# Required attribute class must be of correct class
throws_ok { 
    Event->new(
        start_date  => $start_date,
        end_date    => $end_date,
        private     => 0,
        admin       => $admin,
        venue       => 1,
    )
} qr/does not pass the type constraint/, "'venue' attribute must be 'Venue' class";

isa_ok( 
    Event->new(
        start_date  => $start_date,
        end_date    => $end_date,
        private     => 0,
        admin       => $admin,
        venue => Venue->new(name => 'foo')
    ), 'Event'
);

done_testing;
