package Person;

use namespace::autoclean;
use Moose;

has 'email'         => ( is => 'rw', required => 1, isa => 'Str' );
has 'first_name'    => ( is => 'rw', required => 0, isa => 'Str' );
has 'last_name'     => ( is => 'rw', required => 0, isa => 'Str' );

__PACKAGE__->meta->make_immutable;
