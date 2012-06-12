package Venue;

use namespace::autoclean;
use Moose;

has 'name'      => ( is => 'rw', required => 1 );
has 'address'   => ( is => 'rw' );
has 'url'       => ( is => 'rw' );

__PACKAGE__->meta->make_immutable;
