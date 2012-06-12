package Person;

use namespace::autoclean;
use Moose;

has 'email'         => ( is => 'rw' );
has 'first_name'    => ( is => 'rw' );
has 'last_name'     => ( is => 'rw' );

__PACKAGE__->meta->make_immutable;
