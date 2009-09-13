package ABFS::Common::Requestable;

use warnings;
use strict;
use ABFS::Core::Message;
use ABFS::Core::Constants;
use Carp;
use base ('ABFS::Common::Loadable');

=head1 NAME

ABFS::Common::Requestable - Loadable module that can handle
request and response events

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::Common::Requestable;

  my $module = ABFS::Common::Requestable->new();

=head1 DESCRIPTION

Defaults methods for generating and handling requests and responses

=head1 FUNCTIONS

=head2 request
	
  $provider->request( $message );

Process a request to object.

=cut

sub request {
  my ( $self, $message ) = @_;

  my $method = $message->{command};

  #warn "request method Testing if $self can do $method\n";

  if ( $self->can($method) ) {

    #warn " Yes\n"; # XXX: debug
    return $self->$method($message);
  } else {

    #warn " No\n"; # XXX: debug
    return PERMFAILURE;
  }
}

=head2 response

  $provider->response( $message );

Process a response to object.

=cut

#sub response { return PERMFAILURE; }

sub response {
  my($self,$message) = @_;

  # This is a generic responder. If the requester is further down the chain
  # forward to it, otherwise mark as failed.

  if ( $message->{caller} ) {
    #warn "Forwarding response to $message->{request}\n"; # XXX: debug
    $message->{caller}->response($message);
  } else {
    #warn "We got a response, but don't know how to handle"; # XXX: debug
    return PERMFAILURE;
  }
}

=head2 makerequest

  $message = $provider->makerequest( %args );

Generate a new request.

=cut

sub makerequest {
  my $self = shift;
  #warn "Makerequest for caller $self\n"; # XXX: debug
  return ABFS::Core::Message->new(
    caller => $self,
    @_,
    messagetype => 'request',
  );
}

=head2 makeresponse

  $provider->makeresponse( $request, %args );

Generate new response to request;

=cut

sub makeresponse {
  my($self,$message) = @_;
  return ABFS::Core::Message->new(
    caller => $message->{caller},
    request => $message,
    @_,
    messagetype => 'response',
  );
}

=head2 submitmessage

  $provider->submitmessage( @requests );

Puts one or more requests/responses into request queue. Wheels handlers
are called directly by POE kernel, so no chance for Request to
intercept and pick up returned messages. Instead wheel handlers have to
add to Request queue directly themselves.

=cut

sub submitmessage {
  my $self = shift;

  #use Data::Dumper;
  #warn Dumper $self->{modules}->getobj('request');
  croak "Message to be submitted to Requestqueue, but object not available"
    unless my $rq = $self->{modules}->getobj('request');

  #my $rq = $self->{modules}{request}{obj};
  for my $m ( @_ ) {
    $rq->enqueue($m);
  }
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Common::Requestable

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Common::Requestable
