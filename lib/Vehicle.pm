package Vehicle;

use namespace::autoclean;
use Moose;

has 'year'  => ( is => 'rw', required => 1, isa => 'Int' );
has 'make'  => ( is => 'rw', required => 1, isa => 'Str' );
has 'model' => ( is => 'rw', required => 1, isa => 'Str' );
has 'color' => ( is => 'rw', required => 0, isa => 'Str' );

# Attributes that are themselves objects
has 'owner' => ( is => 'rw', required => 1, isa => 'Person' );

__PACKAGE__->meta->make_immutable;
