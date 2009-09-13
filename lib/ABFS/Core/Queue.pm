package ABFS::Core::Queue;

use warnings;
use strict;
use Carp;
use List::Util 'shuffle';

=head1 NAME

ABFS::Core::Queue - Queue requests and responses

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::Core::Queue;

  my $queue = ABFS::Core::Queue->new();

=head1 DESCRIPTION

Queues up requests and responses. Process entries in queue depending on priority.

=head1 FUNCTIONS

=head2 new

  Generate object.

  $echo = new( );

=cut

sub new {
  my $type = shift;
  $type = ref $type if ref $type;
  my $this = {@_};
  bless $this, $type;
}

=head2 enqueue

  $queue->enqueue( @requests, @responses );

Add requests and/or responses to queue.

=cut

sub enqueue {
  my ( $self, @messages ) = @_;

  #$self->{newqueue} ||= [];
  #push @{ $self->{newqueue} }, @messages;
  for my $mes ( @messages ) {
    #warn "Appending $mes to ENQUEUED\n"; # XXX: debug
    $self->append($mes, 'ENQUEUED'); # Default queue is ENQUEUED
  }
}

#=head2 call
#
#  $queue->call( $request );
#
#Request is processed right away and response immediately returned.
#Only one request can be processed with call().
#
#=cut
#
#sub call {
#  my ( $self, $request ) = @_;
#
#  # Only requests can be handled
#  unless ( $request->{eventtype} eq 'request' ) {
#    carp "Call can only handle eventtype request";
#    return undef;
#  }
#  # Check module is specified
#  unless ( $request->{module} ) {
#    carp "request module not specified";
#    return undef;
#  }
#  # Check module is loaded
#  unless ( $self->{loader}{modules}{ $request->{module} } ) {
#    carp "module $request->{module} not loaded";
#    return undef;
#  }
#
#  # Process the request and return response
#  # XXX: Stats
#  return $self->{loader}{modules}{ $request->{module} }->request( $request );
#}

=head2 queuesize

  my $number = $queue->queuesize();

Lists how many requests/responses are in all queues.

=cut

sub queuesize {
  my ($self,$queuename) = @_;

  #return scalar @{ $self->{newqueue} };
  my $sum = 0;
  for my $q ( $queuename || keys %{ $self->{queue} } ) {
    $sum += scalar @{ $self->{queue}{$q} };
  }
  return $sum;
}

=head2 next

  $message = $queue->next();

Get higest priority message in queue.

=cut

sub next {
  my ($self) = @_;

  # XXX: Do responses first
  # XXX: Consider priority
  # XXX: Rearrange at regular intervals, or after every N next calls.
  # XXX: Same message should not be done more often than retry interval
  # XXX: Cancel expired messages
  #return $self->{newqueue}[0] || undef;
  #use Data::Dumper; # XXX: debug
  #warn "Queue::next, queue content:" . Dumper $self->{queue}; # XXX: debug
  return shift @{ $self->{queue}{ENQUEUED} };
}

#=head2 dequeue
#
#  $queue->dequeue( $message );
#
#Remove a message from queue.
#
#=cut
#
#sub dequeue {
#  my ( $self, $message ) = @_;
#
#  unless ($message) {
#    carp "No message to process specified";
#    return undef;
#  }
#  for my $i ( 0 .. $self->queuesize() ) {
#    if ( $self->{newqueue}[$i] ) {
#      if ( $self->{newqueue}[$i] eq $message ) {
#        splice( @{ $self->{newqueue} }, $i, 1 );
#        last;
#      }
#    }
#  }
#  return undef;
#}

=head2 reprioritize

  $queue->repriorize();

Rearrange queue according to priorities.

=cut

sub reprioritize {
  my ($self) = @_;

  # XXX: Consider age, peer relationship, resposne vs. request etc.
  # XXX: Put retry request on hold according to interval
  # For now just randomize
  @{ $self->{queue}{ENQUEUED} } = shuffle( @{ $self->{queue}{ENQUEUED} } );
}

=head2 append

  $queue->append($message,$queuename);

Add element to specific queue

=cut

sub append {
  my($self,$message,$name) = @_;

  push @{ $self->{queue}{$name} }, $message;
  #warn "Queue::append: queue content: " . Dumper $self->{queue}; # XXX: debug
}

=head2 remove

  $queue->remove($message,$queuename);

Remove message from specific queue. Returns message if removed.

=cut

sub remove {
  my($self,$message,$name) = @_;

  my $queue = $self->{queue}{$name};
  for my $i ( 0 .. $#$queue ) {
    if ( $queue->[$i] eq $message ) {
      return splice( @$queue, $i, 1 );
    }
  }
  return undef;
}

=head2 move

  $queue->move($message,$queuename);

Move message from one queue to another

=cut

sub move {
  my($self,$message,$newname) = @_;

  # Keep trying to remove from all existing queues until success
  for my $oldname ( keys %{ $self->{queue} } ) {
    last if $self->remove($message, $oldname);
  }

  # Add to new queue
  $self->append($message,$newname);
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Core::Queue

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Core::Queue
