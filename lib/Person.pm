package Person;

use namespace::autoclean;

use EventMoose;

with 'Admin';

has 'email'         => ( is => 'rw', required => 1, isa => 'Str' );
has 'first_name'    => ( is => 'rw', required => 0, isa => 'Str' );
has 'last_name'     => ( is => 'rw', required => 0, isa => 'Str' );

has 'registration'  => (
    is          => 'rw',
    required    => 0,
    isa         => 'Event::Registration',
    clearer     => 'cancel_registration',
    predicate   => 'has_registration',
);


#sub register {
#
#    
#}

__PACKAGE__->meta->make_immutable;
