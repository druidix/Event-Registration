package Vehicle;

use namespace::autoclean;
use Moose;

has 'year'  => ( is => 'rw' );
has 'make'  => ( is => 'rw' );
has 'model' => ( is => 'rw' );

__PACKAGE__->meta->make_immutable;
