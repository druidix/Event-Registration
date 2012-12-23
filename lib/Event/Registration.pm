package Event::Registration;

use namespace::autoclean;
use Moose;
use DateTime;

has 'reg_date'  => ( is => 'ro', required => 1, isa => 'DateTime', default => sub {DateTime->now} );
has 'attendee'  => ( is => 'rw', required => 1, isa => 'Person'   );
has 'event'     => ( is => 'rw', required => 1, isa => 'Event'    );


__PACKAGE__->meta->make_immutable;
