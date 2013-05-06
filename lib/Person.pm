package Person;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Event::Registration;
use Util;

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

method get_registration ( Event :$event ) {

    my $normalized_query_name = normalize_string( $event->name );
    my $reg_to_return = undef;

    foreach my $reg ( @{$self->registrations} ) {

        if ( normalize_string($reg->event->name) eq $normalized_query_name ) {

            $reg_to_return = $reg if ( normalize_string($reg->event->name) eq $normalized_query_name );
            last;
        }
    }
    
    return $reg_to_return;
}

__PACKAGE__->meta->make_immutable;
