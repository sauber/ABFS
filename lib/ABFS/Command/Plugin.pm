package ABFS::Command::Plugin;

use warnings;
use strict;
use ABFS::Core::Message;
use ABFS::Core::Constants;
use YAML::Syck qw(Dump Load);
use Carp;
#use base ('ABFS::Common::Loadable');
use base ('ABFS::Common::Requestable');

=head1 NAME

ABFS::Command::Plugin - Loadable module that can handle
request and response events

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  my $self = shift;
#  <<EOF;
#Command:
#  load:
#  unload:
#
#Depend:
# - request
#EOF
  #Dump({Command=>[_can()], Depend=>['Command']});
  <<EOF . $self->_commandhelp();
Depend:
 - Command

EOF
}

sub _commandhelp {
  <<EOF;
Command:

EOF
} 

=head1 SYNOPSIS

  use ABFS::Command::Plugin;

  my $module = ABFS::Command::Plugin->new();

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

  #warn "request method testing if $self can do $method\n"; # XXX: debug

  if ( my $meth = $self->can($method) ) {

    #warn " Yes\n"; # XXX: debug
    # XXX: Only problem is how to deal with error status.
    
    # Generic command syntax:
    #   cmd -option parameter=value argument
    my @optn = ();
    my %parm = ();
    my @argu = ();
    if ( $message->{message} ) {
      ( my $arg = $message->{message} ) =~ s/^\S+\s*//;
      #@args = split /\s+/, $arg;
      while ( $arg ) {
        $arg =~ s/^\-(\S+)\s*// and do { push @optn, $1; next; };
        $arg =~ s/^(\S+)=\"(.*?)\"\s*// and do { $parm{$1} = $2; next; };
        $arg =~ s/^(\S+)=\'(.*?)\'\s*// and do { $parm{$1} = $2; next; };
        $arg =~ s/^(\S+)=(\S+)\s*// and do { $parm{$1} = $2; next; };
        $arg =~ s/^([^\s=]+)\s*// and do { push @argu, $1; next; };
      }
    }
    push @argu, [ @optn ] if @optn;
    push @argu, { %parm } if %parm;
    #warn "request: $self $method ( @argu )\n"; # XXX: debug
    my @res = $self->$method(@argu);
    if ( @res == 1 and not ref $res[0] ) {
      # Response is a string, so make a response message
      #warn "Response is a string: $res[0]\n";
      return $self->makeresponse($message, message=>$res[0]);
    } else {
      # Zero or more messages return unmodified
      #warn "Responses are messages: @res\n";
      return @res;
    }
    #return $meth->($self, $message);
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
  #my($self,$message) = @_;
  my $self = shift;
  my $message = shift;

  #carp "makeresponse: $message\n";
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

    perldoc ABFS::Command::Plugin

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command::Plugin
