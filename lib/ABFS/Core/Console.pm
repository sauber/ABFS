package ABFS::Core::Console;

use strict;
use warnings;
use POE;
use POE::Wheel::ReadLine;
use Carp;
use base ('ABFS::Common::Requestable');

=head1 NAME

ABFS::Core::Console - A Big File System Console

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Config:
  prompt: "ABFS: "

Depend:
 - Command::Load

Event:
 - consoleinput
EOF
}

=head1 SYNOPSIS

  use ABFS::Core::Console;

  my $console = ABFS::Core::Console->new();

Commands that works inside ABFS console/config

  help

=head1 DESCRIPTION

Console provides a terminal line interface for submitting commands into
ABFS kernel or loaded modules.

=head1 FUNCTIONS

=cut

sub _postinitialize {
  my $self = shift;

  # Launch wheel
  $self->spawn();
}

=head2 spawn

Start a console wheel

=cut

sub spawn {
  my $self = shift;

  #POE::Session->create(
  #  inline_states=> {
  #    _start => \&setup_console,
  #    got_user_input => \&handle_user_input,
  #  }
  #);
  POE::Session->create(
    object_states=> [
      $self => { _start => 'setup_console' },
      $self => { got_user_input => 'handle_user_input' },
    ]
  );
}

=head2 handle_user_input

  $console->handle_user_input(@POEARGS);

Turn input from console into an ABFS request

=cut

sub handle_user_input {
  my ($self, $input, $exception) = @_[OBJECT, ARG0, ARG1];
  #my $console = $_[HEAP]{console};
  my $console = $self->{wheel};

  unless (defined $input) {
    $console->put("$exception caught.  B’bye!");
    $_[KERNEL]->signal($_[KERNEL], "UIDESTROY");
    $console->write_history("./test_history");
    return;
  }

  # Remove leading/trailing whitespace
  $input =~ s/^\s+//; $input =~ s/\s+$//;
  if ( length $input ) {
    $console->put("  You entered: $input");
    ( my $cmd = $input ) =~ s/^(\S+).*/$1/;
    $self->{modules}->getobj('Request')->enqueue({
      messagetype=>'request',
      message=>$input,
      command=>$cmd,
      caller=>$self,
    });
    $console->addhistory($input);
  }
  $console->get($self->{config}{Config}{prompt});
}

=head2 setup_console

  $console->setup_console();

Creates a POE wheel to deal console events

=cut

sub setup_console {
  my $self = $_[OBJECT];

  $self->{wheel} ||= POE::Wheel::ReadLine->new(
    InputEvent => 'got_user_input'
  );
  $self->{wheel}->read_history("./test_history");
  $self->{wheel}->clear();
  $self->{wheel}->put(
    "Enter some text.",
    "Ctrl+C or Ctrl+D exits."
  );
  $self->{wheel}->get($self->{config}{Config}{prompt});
}


sub _old_spawn {
  my $self = shift;

  if ( $self->{wheel} ) {
    carp("Console wheel already spawned");
    return;
  }

  # Launch a console
  $self->{wheel} = POE::Wheel::ReadLine->new(
    #InputEvent => 'consoleinput',
    InputEvent => \&consoleinput($self),
  );

  # Write out a prompt
  $self->{wheel}->get($self->{config}{Config}{prompt});
}

=head2 consoleinput

Handles input type by user on console

=cut

sub consoleinput {
  my ( $self, $input, $exception ) = @_[ OBJECT, ARG0, ARG1 ];

  warn "$self Got console input: $input / $exception\n";
  # XXX: These causes error in test case.
  #$self->{wheel}->put($input);
  #$self->{wheel}->get("ABFS: ");
  if ( defined $input ) {
    if ( length $input ) {
      $self->{wheel}->addhistory($input);
      #$self->{wheel}->put("Processing: $input");
      $self->submitmessage(
        $self->makerequest(
          message=>$input, 
          command => 'commandline',
        )
      )
    } else {
      # Empty line. Display new prompt.
      $self->{wheel}->get($self->{config}{prompt});
    }
  }
  elsif ( $exception eq 'interrupt' or $exception eq 'eot' ) {
    $self->{wheel}->put("Goodbye.");
    #delete $self->{wheel};
    exit; # XXX: do something more gracefully
    return;
  }
  else {
    $self->{wheel}->put("\tException: $exception");
    $self->{wheel}->get($self->{config}{prompt});
  }
}

=head2 response

  $console->response( $message );

A response to a command typed on console arrives from other modules. Print
it out to console.

=cut

sub response {
  my($self,$message) = @_;

  #$self->{wheel}->put("Response: $message->{message}");
  $self->{wheel}->put( split /[\r\n]+/, $message->{message} );
  $self->{wheel}->get($self->{config}{prompt});
  #warn "Response Done\n";
  1;
}

=head2 exit

  $console->exit( );

Shutdown down console

=cut

sub exit { }


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Core::Console

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Core::Console
