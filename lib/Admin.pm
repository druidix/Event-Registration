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
    clearer     => 'cancel_all_admin_privileges',
);

method cancel_all_admin_privileges {

    $self->admin_for_events( [] );
    return 1;
}

# In order to make someone an admin for an event, you yourself must have admin rights for that event.
# Note that the admin_for_events attribute gets modified for the Person object passed in, not for $self
method make_admin_for_event ( Event :$event!, Person :$person! ) {

    die "You don't have admin rights to the event [" . $event->name . "]" 
        unless ( $self->can_edit_event(event => $event) );

    $person->admin_for_events( [$event, @{$self->admin_for_events}] );

    return 1;
}

# You can edit the event if you own it or if you have been given admin rights to it
method can_edit_event ( Event :$event! ) {

    my $is_admin_for_event = 0;
    my $is_event_owner = lc($self->email) eq lc($event->owner->email);

    # Only go through this loop if we're not the event owner
    if ( !$is_event_owner ) {

        my $normalized_event_name = normalize_string( lc($event->name) );

        foreach my $admin_for_event ( @{$self->admin_for_events} ) {

            my $normalized_name = $self->normalize_string( lc($admin_for_event->name) );

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
