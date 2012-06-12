package Event;

use namespace::autoclean;
use Moose;

has 'start_date'    => ( is => 'rw', required => 1, isa => 'DateTime' );
has 'end_date'      => ( is => 'rw', required => 1, isa => 'DateTime' );
has 'private'       => ( is => 'rw', required => 1, isa => 'Bool' );

has 'venue' => (
    is          => 'ro',
    required    => 1,
    isa         => 'Venue',
);

__PACKAGE__->meta->make_immutable;
