package Person;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Event::Registration;

with 'Admin';

has 'email'         => ( is => 'rw', required => 1, isa => 'Str' );
has 'first_name'    => ( is => 'rw', required => 0, isa => 'Str' );
has 'last_name'     => ( is => 'rw', required => 0, isa => 'Str' );

has 'registrations'  => (
    is          => 'rw',
    required    => 0,
    default     => sub{ [] },
    isa         => 'ArrayRef[ Event::Registration ]',
    clearer     => 'cancel_all_registrations',
);


method register ( Event :$event ) {

    my $reg = Event::Registration->new( event => $event, attendee => $self );

    $self->registrations( [@{$self->registrations()}, $reg] );

    return $self;
}

method cancel_all_registrations {

    $self->registrations( [] );
    return 1;
}

__PACKAGE__->meta->make_immutable;
