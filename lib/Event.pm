package Event;

use namespace::autoclean;
use Moose;

# Attributes that are themselves objects
has 'owner'         => ( is => 'rw', required => 1, isa => 'Person'   );
has 'venue'         => ( is => 'ro', required => 1, isa => 'Venue'    );

# Attributes of standard types
has 'name'          => ( is => 'rw', required => 1, isa => 'Str'      );
has 'start_date'    => ( is => 'rw', required => 1, isa => 'DateTime' );
has 'end_date'      => ( is => 'rw', required => 1, isa => 'DateTime' );
has 'private'       => ( is => 'rw', required => 1, isa => 'Bool'     );


__PACKAGE__->meta->make_immutable;
