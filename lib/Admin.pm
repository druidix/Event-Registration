package Admin;

use Moose::Role;
use MooseX::Method::Signatures;

use Event;
use Event::Registration;

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

# TODO: This method needs to require an event object to be passed in.
method make_admin ( Event :$event ) {

}

# You can edit the event if you own it or if you have been given admin rights to it
method can_edit_event ( Event :$event! ) {

    my $is_admin = 0;

    # This should work, remove spaces as well
    my $normalized_event_name = $self->normalize_string( lc($event->name) );

    foreach my $admin_for_event ( @{$self->admin_for_events} ) {

        
        my $normalized_name = $self->normalize_string( lc($admin_for_event->name) );

        if ( $normalized_event_name eq $normalized_name ) {

            $is_admin++;
            last;
        }
    }

    return ( $is_admin || lc($self->email) eq lc($event->owner->email) ) ? 1 : 0;
}

method can_edit_registration ( Event::Registration :$reg! ) {

    return ( lc($reg->attendee->email) eq lc($self->email) || $self->can_edit_event(event => $reg->event) ) ? 1 : 0;
};

# This is to be used as long we don't have unique IDs for different objects.  To ensure a reasonable match,
# we take names (e.g. event names) and remove all non-alpha-numeric entities from them (note that this
# includes spaces!)
method normalize_string( Str $str! ) {

    my $normalized = ${str};
    $normalized =~ s/[^a-z A-Z 0-9]+//g;

    return $normalized;
}


1;
