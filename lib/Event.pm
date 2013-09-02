package Event;

use namespace::autoclean;
use Moose;
use MooseX::Method::Signatures;

use Person;

# Attributes that are themselves objects
has 'owner'         => ( is => 'rw', required => 1, isa => 'Person'   );
has 'venue'         => ( is => 'ro', required => 1, isa => 'Venue'    );

# Attributes of standard types
has 'name'          => ( is => 'rw', required => 1, isa => 'Str'      );
has 'start_date'    => ( is => 'rw', required => 1, isa => 'DateTime' );
has 'end_date'      => ( is => 'rw', required => 1, isa => 'DateTime' );
has 'private'       => ( is => 'rw', required => 1, isa => 'Bool'     );


method is_owner ( Person :$person! ) {

    return ( lc($person->email) eq lc($self->owner->email()) ) ? 1 : 0;
}
__PACKAGE__->meta->make_immutable;
