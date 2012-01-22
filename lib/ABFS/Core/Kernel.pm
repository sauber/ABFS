package ABFS::Core::Kernel;

use warnings;
use strict;
use Carp;
#sub POE::Kernel::TRACE_EVENTS () { 1 };
#use POE;
use base ('ABFS::Common::Loadable');
#use ABFS::Core::Loader;

=head1 NAME

ABFS::Load - A Big File System Core::Kernel

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::Core::Kernel;

  my $kernel = ABFS::Core::Kernel->new();

=head1 DESCRIPTION

A kernel to manage events, and launch and remove wheels.

=head1 FUNCTIONS

=head2 new

  Generate object.

  $kernel = new( );

=cut

#sub new {
#  my $type = shift;
#  $type = ref $type if ref $type;
#  my $this = {@_};
#  bless $this, $type;
#}

=head2 console_mode

Start kernel with a console.

=cut

sub console_mode {
  my $self = shift;
}

=head2 run

  $kernel->run( );

Run a kernel. All operation from here requires events.

=cut

# Start a kernel
#
sub run {
  my $self = shift;

  #POE::Session->create(
  #  inline_states => { _default => \&default, },
  #  object_states => [ $self => [ '_start', '_stop' ], ]
  #);

  #$poe_kernel->run();
  #warn "Starting kernel\n";
  #POE::Kernel->run();
  #warn "Stopping kernel\n";

  #exit 0;
  return 1;
}

=head2 _start

First event to be called after kernel starts

=cut

# Session has started.
#
sub _start {
  #my ( $self, $kernel ) = @_[ OBJECT, KERNEL ];
  my ( $self, $kernel ) = @_;

  #warn "Kernel has started\n"; # XXX: debug
  # XXX: While we debug only run for 30 secs

  # Start the request queue
  #$self->postevent('requestnext');

  # There might be commands to run from config file or from other sources.
  # If this is so, then we need to load the config/module
  if ( $self->{configfile} or $self->{configcmd} ) {

    # XXX: Let's assume we have a loader
    # If we don't already have a loader, it's time to get one
    #$self->{loader} = new ABFS::Core::Loader
    #  unless $self->{loader};
    # Tell loader to load in config module to process our configurations
    $self->{loader}->add('config');

    #my $config = $self->{loader}->getobj('config');
    #$config->cmd( $self->{configcmd} )
    # Here we add a request to process config
    my $rq = $self->{loader}->getobj('request');
    croak "Fatal error: No requestqueue available\n" unless $rq;

    #warn "loader=$self->{loader}\n";
    #warn "rq=$rq\n";
    my $msg = ABFS::Core::Message->new(
      command    => 'configread',
      configfile => ( $self->{configfile} || undef ),
      configcmd  => $self->{configcmd} || undef,
    );
    #warn "Kernel::Call msg=$msg\n";
    $rq->call($msg);
  } else {

    # Otherwise just hang around for 2 secs in case something happens
    #warn "Delay 2 secs\n"; # XXX: debug
    #$kernel->delay( '_stop', 2 );
  }
}

=head2 _stop

Stop kernel from running

=cut

# Shutdown session.
#
sub _stop {
  #my ($self) = $_[OBJECT];
  my ($self) = @_;

  # XXX: Why are we told to stop
  #default(@_);
  # Gracefully stop all modules
  #exit;
  #return;
}

=head2 postevent

  $kernel->postevent( $eventname );

Add an event to kernel event queue.

=cut

sub postevent {
  my ( $self, $event ) = @_;

  warn "Posting event: $event\n"; # XXX: debug
  #POE::Kernel->yield($event);
}

=head2 default

Events with no handler are trapped here.

=cut

# Default event handler. Should never happen!
# XXX: But it might happen! Where should output go?
#
sub default {
  warn " ABFS Unhandled Event:\n";
  #warn " OBJECT: $_[OBJECT]\n";
  #warn " SESSION: $_[SESSION]\n";
  #warn " SENDER: $_[SENDER]\n";
  #warn " STATE: $_[STATE]\n";
  #warn " KERNEL: $_[KERNEL]\n";
  #warn " HEAP: $_[HEAP]\n";
  #warn " CALLER_FILE: $_[CALLER_FILE]\n";
  #warn " CALLER_LINE: $_[CALLER_LINE]\n";
  #warn " CALLER_STATE: $_[CALLER_STATE]\n";
  #warn " ACTIVE EVENT: " . $_[KERNEL]->get_active_event() . "\n";
}

=head2 stop

  $kernel->stop( );

Stop wheels and unload modules. Terminate process.

=head2 add

  $kernel->add( $obj, $handlers );

Install new event handlers for module after kernel is running.
XXX: This should never be necessary. Instead each object should handle
own session and states.

=cut

sub add {
  my ( $self, $obj, $events ) = @_;

  for my $e (@$events) {
    #my $code = \&{"$obj->$e"};
    my $code = sub { return $obj->$e(@_) };
    #use Data::Dump::Streamer;
    #warn Dump $code;
    warn "Register event $e for $code\n";
    #POE::Kernel->state( $e, $obj );
    use Data::Dumper; # XXX: debug
    #my $return = POE::Kernel->state();
    #warn Dumper $return;
    #my $return = POE::Kernel->state( $e, $code );
    my $return = 'OK';
    warn Dumper $return;
  }
}

=head2 del

  $kernel->del( $obj, $handlers );

Remove events handlers for module

=cut

sub del {
  my ( $self, $obj, $events ) = @_;

  for my $e (@$events) {
    #POE::Kernel->state($e);
  }
}

=head2 wheels

  $kernel->wheels( );

List active wheels in kernel


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Core::Kernel

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Core::Kernel
