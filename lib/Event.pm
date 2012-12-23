package Event;

use namespace::autoclean;
use Moose;

# Attributes that are themselves objects
has 'admin'         => ( is => 'rw', required => 1, isa => 'Person'   );
has 'venue'         => ( is => 'ro', required => 1, isa => 'Venue'    );

# Attributes of standard types
has 'start_date'    => ( is => 'rw', required => 1, isa => 'DateTime' );
has 'end_date'      => ( is => 'rw', required => 1, isa => 'DateTime' );
has 'private'       => ( is => 'rw', required => 1, isa => 'Bool'     );


sub BUILD {

    my( $self ) = @_;

    die "FATAL: Person designated as admin does not have admin rights"
        unless( $self->admin->can_edit_event );
}

__PACKAGE__->meta->make_immutable;
