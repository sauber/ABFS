package ABFS::Request;

use warnings;
use strict;
use Carp;
use ABFS::Core::Queue;
use ABFS::Core::Constants;
#use POE;
use base ('ABFS::Common::Loadable');

=head1 NAME

ABFS::Request - Enqueues and executes events

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

# A kernel event handler to be installed to execute next request
sub _properties {
#  <<EOF;
#Event:
# - requestnext
#EOF
  <<EOF;
Depend:
 - Core::Kernel
EOF
}

=head1 SYNOPSIS

  use ABFS::Request;

  my $rq = ABFS::Request->new();

=head1 DESCRIPTION

Enqueues events (requests and responses) and execute them according to
prioritized order.

=head1 FUNCTIONS

=cut

sub _postinitialize {
  my $self = shift;

  # Get a queue for messages
  $self->{queue} = new ABFS::Core::Queue;

  # XXX: Get a scheduler to determine order of processing
  #$self->{scheduler} = ABFS::Core::Queue;

  #$self->{sessionID} = POE::Session->create(
  #  object_states => [
  #    #$self => { _start      => sub { $_[KERNEL]->yield("requestnext") } },
  #    $self => { requestnext => 'requestnext' },
  #  ],
  #  inline_states => {
  #    _start      => sub { $_[KERNEL]->yield("requestnext") },
  #  }
  #)->ID();
  $self->{sessionID} = int rand 16 ** 2;
}

# Get kernel object from modules list
# XXX: Cache it
sub _kernel {
  my $self = shift;

  return $self->{modules}->getobj('kernel');
}

=head2 requestnext

  @response = $rq->requestnext(@ARGS);

Execute a command. A number of requests or responses might be the result.

=cut

sub requestnext {
  #my ($self,$kernel) = @_[OBJECT, KERNEL];
  my ($self,$kernel) = @_;

  # XXX: TODO
  #warn "Reached requestnext\n"; # XXX: debug
  #warn " OBJECT: $_[OBJECT]\n";
  #warn " SESSION: $_[SESSION]\n";
  #warn " SENDER: $_[SENDER]\n";
  #warn " STATE: $_[STATE]\n";
  #warn " KERNEL: $_[KERNEL]\n";
  #warn " HEAP: $_[HEAP]\n";
  #warn " CALLER_FILE: $_[CALLER_FILE]\n";
  #warn " CALLER_LINE: $_[CALLER_LINE]\n";

  my $message = $self->{queue}->next();
  unless ( $message ) {
    #carp "requestnext called, but there are no messages in queue\n";
    return
  }
  #use Data::Dumper; # XXX: debug
  #warn "message: " . Dumper $message; # XXX: debug

  #use Data::Dumper; # XXX: debug
  #warn "Will now process message " . Dumper $next; # XXX: debug
  #warn "Will now process message $next->{command}\n"; # XXX: debug
  #warn "  messagetype $next->{messagetype}\n"; # XXX: debug
  #if ( $next->{messagetype} and $next->{messagetype} eq 'request' ) {
  #  #warn " It's a request\n"; # XXX: debug
  #  $self->call($next);
  #} elsif ( $next->{messagetype} and $next->{messagetype} eq 'response' ) {
  #  #warn " It's a response\n"; # XXX: debug
  #  $self->answer($next);
  #} else {
  #  carp "A message in the queue was neither request nor response. Dropping it.\n";
  #}

  # XXX: Depending out outcome of the call (success/failure), decide to
  #      dequeue or try again later.
  #$self->{queue}->dequeue($next);

  $self->statechange($message, 'PROCESSING');

  #warn "Processing done, and message dequeued\n"; # XXX: debug
  $kernel->yield("requestnext") if $self->{queue}->queuesize('PROCESSING');
}

=head2 statechange

  $rq->statechange($message,$newstate);

Change state of a message, and act accordingly.

=cut

sub statechange {
  my($self,$message,$newstate) = @_;

  # Run all pre filters
  my $method = "before_$newstate";
  #warn "Prefilter $method on $message\n"; # XXX: debug
  for my $prefilter ( $self->listfilter($method) ) {
    #warn "Running $method on $message\n"; # XXX: debug
    my $result = $prefilter->$method($message);
    if ( $result ne $message ) {
      # If result is a new state, then change to that
      $self->statechange($message,$result);
      return;
    }
  }

  # Do action
  #warn "Action $newstate on $message\n"; # XXX: debug
  $newstate =~ /NEW/          and do {}; # XXX: might not be needed
  $newstate =~ /ENQUEUED/     and $self->enqueued($message);
  $newstate =~ /REPLYWAIT/    and do {};
  $newstate =~ /PROCESSING/   and $self->processing($message);
  $newstate =~ /RESPONSEWAIT/ and do {};
  $newstate =~ /RESPONDING/   and do {};
  $newstate =~ /EXPIRED/      and do {};

  # Run all post filters
  $method = "after_$newstate";
  #warn "Postfilter $method on $message\n"; # XXX: debug
  for my $postfilter ( $self->listfilter($method) ) {
    #warn "Running $method on $message\n"; # XXX: debug
    my $result = $postfilter->$method($message);
    if ( $result ne $message ) {
      # If result is a new state, then change to that
      $self->statechange($message,$result);
      return;
    }
  }
}

=head2 enqueued

  $rq->enqueued($message);

Message is being enqueued.

=cut

sub enqueued {
  my($self,$message) = @_;

  $self->{queue}->append($message);
}

=head2 processing

  $rq->processing($message);

Message is being processes

=cut

sub processing {
  my($self,$message) = @_;

  $self->{queue}->move($message,'PROCESSING');
  # XXX: Should probably let a filter chech for correct messagetype
  if ( $message->{messagetype} and $message->{messagetype} eq 'request' ) {
    #warn " It's a request\n"; # XXX: debug
    $self->call($message);
  } elsif ( $message->{messagetype} and $message->{messagetype} eq 'response' ) {
    #warn " It's a response\n"; # XXX: debug
    $self->answer($message);
  } else {
    carp "A message in the queue was neither request nor response. Dropping it.\n";
  }

  # XXX: Depending on outcome of call() and answer(), decide to
  #      wait, retry or expire. For now just expire all.
  $self->{queue}->move($message,'EXPIRED');
}

=head2 call

  $rq->call( $message );

Request is processed right away and response immediately returned.
No enqueueing or dequeueing happens.
Only one request can be processed with call().
XXX: What about stats?

=cut

sub call {
  my ( $self, $message ) = @_;

  # XXX: debug
  #use Data::Dumper;
  #warn "Request::call: \n";
  #while ( my($k,$v) = each %$message ) {
  #  warn "  $k=>$v\n";
  #}

  # Only requests can be handled
  unless ( $message->{messagetype} eq 'request' ) {
    #carp "Call can only handle messagetype request";
    return PERMFAILURE;
  }

  # Check module is available
  # XXX: Generate error response if cannot handle
  #my $command = $message->{command} || $self->parseargs($message);
  #$self->selectmodule($message); # Kept in $message->{moduleobj} for later use
  #warn "Request command: $message->{command}\n";
  return unless $self->{modules};
  $message->{moduleobj} =
    $self->{modules}->getobj('Command')->runobject($message->{command});
  unless ( $message->{moduleobj} ) {
    # XXX: Generate a response message
    warn "No loaded modules implements $message->{command}\n";
    return PERMFAILURE;
  }
  # XXX: Cache Command obj for performance?
  # XXX: Check if this is command request or data request
  #warn "Calling Command::runcommand $message->{command}\n"; # XXX: debug
  #$self->{modules}->getobj('Command')->runcommand($message->{command},$message);
  #warn "Calling done\n";
  #$message->{moduleobj} =
  #  $self->{modules}->getobj('Command')->runobject($message->{command});

  # Process the message and return response
  # XXX: Stats
  # XXX: Enqueue responses or return immediately?

  # Process request and push responses to event queue
  #use Data::Dumper;
  #warn "Executing a Request: $message->{command}\n"; # XXX: debug
  #warn "Obj: " . Dumper $message->{moduleobj};
  #warn "Msg: " . Dumper $message;
  #warn "call request start\n";
  $self->enqueue( $message->{moduleobj}->request($message) );
  #warn "call request done\n";
}

=head2 parseargs

  $rq->parseargs($message);

A command request might have arguments and parameters. Parse the command
string and split into command, arguments and parameters. Generic syntax

  cmd -parm1 -parm2 arg2 arg3 arg4 ...

=cut

sub _old_parseargs {
  my($self,$message) = @_;

  # XXX: To be determined how to have a generic syntax and parser
  # XXX: Parsing probably belongs in Command module
  # XXX: Don't modify original message value
  my $cmdstring = $message->{command};
  (my $cmd = $cmdstring ) =~ s/^(\S+).*/$1/;
  $cmdstring =~ s/^(\S+)\s*//;
  $message->{command} = $cmd;
  $message->{args} = [ split /\s+/, $cmdstring ];
  $message->{message} = $cmdstring;
}

sub parseargs {
  my($self,$message) = @_;

  use Data::Dumper;
  warn "$self::parseargs: " . Dumper $message;
  ( my $cmd = $message->{message} ) =~ s/^(\S+).*/$1/;
  return $cmd;
}

=head2 answer

  $rq->answer( $message );

Route a response back to requester. There might be several requesters
for same data.

=cut

sub answer {
  my ( $self, $message ) = @_;

  # Find original requester...
  my $r = $message;
  my $c = $r->{caller};
  while ( $r = $r->{request} ) {
    $c = $r->{caller} if defined $r->{caller};
  }
  if ( $c ) {
    #warn "Caller is $c\n"; # XXX: debug
    $c->response($message);
  } else {
    carp "No caller defined for answer\n";
    #use Data::Dumper;
    #warn " Message lost: " . Dumper $message->{message};
    # If there are no callers, then print to stdout.
    # XXX: For now at least. It really has to be dropped.
    #print $message->{message} . "\n";
  }
}

=head2 process

  $rq->process( $message );

Process a message. Mark the message as being in-progress.
Hand over to module than can handle depending on criteria.
Track success and failure.
Send reponses back to requesters.
Retry and expire.

=cut

sub process {
  my ( $self, $message ) = @_;

  # XXX: Lots to do.
  # For now just remove from queue
  unless ($message) {
    carp "No message to process specified";
    return undef;
  }
  for my $i ( 0 .. $self->queuesize() ) {
    if ( $self->{newqueue}[$i] eq $message ) {
      splice( @{ $self->{newqueue} }, $i, 1 );
      last;
    }
  }
  return undef;
}

=head2 selectmodule

  my $module = $rq->selectmodule($message);

Select which module to send message to for processing.

=cut

sub selectmodule {
  my ( $self, $message ) = @_;

  # If the modulename is already chosen, use that
  if ( $message->{module} ) {
    $message->{moduleobj} = $self->{modules}->getobj( $message->{module} );
    return $message->{module};
  }

  # Do we have any modules available?
  return PERMFAILURE unless $self->{modules}; 

  # Do we have modules that has command implemented
  # XXX: There might be multiple
  # XXX: Exclude modules that are to be ignored for this message, forexample
  #      same module as where the message came from. Example is a block cache
  #      that wants to store in permanent storage.
  #      [ $message->{ignoremodule} ]

  # XXX: For now use first found
  my $command = $message->{command};
  for my $m ( $self->{modules}->nodelist() ) {

    #warn "Testing if $m->{name} can do $message->{command}\n"; # XXX: debug
    if ( $m->{obj}{command}{$command} ) {
    #if ( @{ $m->{obj}{command} } ) {
    #  for my $availcommand ( @{ $m->{obj}{command} } ) {
    #    if ( $availcommand eq $command ) {

          #warn " Yes it can\n"; # XXX: debug
          $message->{module}    = $m->{name};
          $message->{moduleobj} = $m->{obj};
          return $m->{name};
    #    }
    #  }
    }
  }

  # No module found!
  return PERMFAILURE;
}

=head2 enqueue

  $rq->enqueue( @messages );

Enqueues zero, one or more messages. If the queue is non-empty, then
call kernel with requestprocess event.

=cut

sub enqueue {
  my ( $self, @messages ) = @_;

  for my $m (@messages) {
    #use Data::Dumper;
    #warn "Enqueueing " . Dumper $m; # XXX: debug
    $self->{queue}->enqueue($m);
  }
  if ( $self->{queue}->queuesize() > 0 ) {

    #use Data::Dumper; # XXX: debug
    #warn Dumper $self->{kernel};
    # XXX: Only call requestnext, if queue was 0 before enqueueing?
    #$self->{kernel}->postevent('requestnext');
    my $qsize = $self->{queue}->queuesize();
    #warn "$self, yield, queuesize $qsize\n"; # XXX: debug
    #POE::Kernel->post($self->{sessionID}, 'requestnext');
  }
}

=head2 cmd

  $rq->cmd($string);

Enqueue a command request

=cut

# Submit a cmd request
# XXX; TODO
#
sub cmd {
  my($self,$command) = @_;

  warn "Command received: $command\n";
  # XXX: translate command as a request
  # XXX: Find out how to route respons back
  $self->{queue}->enqueue($command);
  #my $kernel = $self->_kernel();
  #warn $kernel;
  #$self->_kernel()->postevent('requestnext');
}

=head2 registerfilter

  $rq->registerfilter($obj);

Register filter hooks from a filter object.

=cut

sub registerfilter {
  my($self,$obj) = @_;

  # Add object to list for each filtername
  for my $filter ( $obj->hooklist() ) {
    #warn "Adding $obj as hook to $filter\n"; # XXX: debug
    push @{ $self->{filter}{$filter} }, $obj;
  }
}

=head2 unregisterfilter

  $rq->unregisterfilter($obj);

Remove an object from filter list

=cut

sub unregisterfilter {
  my($self,$obj) = @_;

  for my $filter ( $obj->hooklist() ) {
    for my $i ( 0 .. $#{ $self->{filter}{$filter} } ) {
      # Remove object from list if found.
      if ( $obj eq $self->{filter}{$filter}[$i] ) {
        splice @{ $self->{filter}{$filter} }, $i, 1;
        last;
      }
    }
  }
}

=head2 listfilter

  $rq->listfilter($filter);

List all filters of a certain type.

=cut

sub listfilter {
  my($self,$filter) = @_;

  #warn "List $filter filter\n"; # XXX: debug
  #warn "List $filter filters: @{ $self->{filter}{$filter} }\n"; # XXX: debug
  return @{ $self->{filter}{$filter} } if $self->{filter}{$filter};
  return ();
}



=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Request

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Request
