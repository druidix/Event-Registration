package Admin;

use Moose::Role;
use MooseX::Method::Signatures;

use Event;
use Event::Registration;
use Util;

# This role is meant to be used with a person object on a per-event basis.  A person can be made into an admin
# for one or more events.  Once she is an admin for an event, she can edit not only that event, but also the
# registrations attached to it.
# NOTE:  The person who creates an event is automatically the admin for that event.  This role is only needed
# to make non-creators into admins.

has 'admin_for_events'  => (
    is          => 'rw',
    required    => 0,
    default     => sub{ [] },
    isa         => 'ArrayRef[ Event ]',
);

# In order to remove someone's admin rights for an event, you yourself must have admin rights for that event.
# Note that the admin_for_events attribute gets modified for the Person object passed in, not for $self
# Permission checks, of course, are conducted for $self
method cancel_admin ( Event :$event!, Person :$person! ) {

    die 'You do not have admin rights to the event [' . $event->name . ']' 
        unless ( $self->can_edit_event(event => $event) );

    my $admin_canceled = 0;

    foreach my $index ( 0 .. $#{$person->admin_for_events} ) {

        my $current_event = $person->admin_for_events->[$index];

        # If we get a name match, drop that event
        if ( normalize_string($current_event->name()) eq normalize_string($event->name()) ) {

            splice( $person->admin_for_events, $index, 1 );
            $admin_canceled++;
            last;
        }
    }
    
    return $admin_canceled;
}

# In order to make someone an admin for an event, you yourself must have admin rights for that event.
# Note that the admin_for_events attribute gets modified for the Person object passed in, not for $self
# Permission checks, of course, are conducted for $self
method make_admin_for_event ( Event :$event!, Person :$person! ) {

    die 'You do not have admin rights to the event [' . $event->name . ']' 
        unless ( $self->can_edit_event(event => $event) );

    $person->admin_for_events( [$event, @{$person->admin_for_events}] );

    return 1;
}

# You can edit the event if you own it or if you have been given admin rights to it
method can_edit_event ( Event :$event! ) {

    my $is_admin_for_event = 0;
    my $is_event_owner = $event->is_owner( person => $self );

    # only go through this loop if we're not the event owner
    if ( !$is_event_owner ) {

        my $normalized_event_name = normalize_string( $event->name() );

        foreach my $admin_for_event ( @{$self->admin_for_events} ) {

            my $normalized_name = normalize_string( $admin_for_event->name );

            if ( $normalized_event_name eq $normalized_name ) {

                $is_admin_for_event++;
                last;
            }
        }
    }

    return ( $is_event_owner || $is_admin_for_event );
}

# You can edit a given registration either if it's your own or you're an admin for the event to which the
# registration is attached.
method can_edit_registration ( Event::Registration :$reg! ) {

    return ( lc($reg->attendee->email) eq lc($self->email) || $self->can_edit_event(event => $reg->event) ) ? 1 : 0;
};



1;
