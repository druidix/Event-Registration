package Event::Registration;

use namespace::autoclean;
use Moose;

# has 'reg_date'  => ( is => 'rw', required => 1, isa => 'DateTime' );
has 'attendee'  => ( is => 'rw', required => 1, isa => 'Person'   );
has 'event'     => ( is => 'rw', required => 1, isa => 'Event'    );

__PACKAGE__->meta->make_immutable;
