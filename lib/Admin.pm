package Admin;

use Moose::Role;

has 'can_edit_event'  => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has 'can_edit_registration'  => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

sub make_admin {

    my( $self ) = @_;

    $self->can_edit_event( 1 );
    $self->can_edit_registration( 1 );
}


1;
