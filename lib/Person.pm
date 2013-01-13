package Person;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Event::Registration;

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


method register ( Event :$event ) {

    my $reg = Event::Registration->new( event => $event, attendee => $self );
    $self->registration( $reg );

    return $self;
}

__PACKAGE__->meta->make_immutable;
