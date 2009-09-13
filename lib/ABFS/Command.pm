package ABFS::Command;

use warnings;
use strict;
use Carp;

use base ('ABFS::Common::Requestable');

=head1 NAME

ABFS::Command - Execute commands in modules

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Config:

Depend:
 - Request

Event:

Request:

EOF
}

=head1 SYNOPSIS

  use ABFS::Command;

  my $cmd = ABFS::Command->new();

=head1 DESCRIPTION

Process commands from Console, config, startup script, remote controller,
or other places where commands can be entered.

Typical commands will change config settings, get statistics, set up
storages and initiate connections.


=head1 FUNCTIONS

=head2 commandline

  $cmd->commandline($message);

Parses a command and arguments from $message->{message}, and executes it

=cut

sub commandline {
  my ( $self, $message ) = @_;

  return unless $message->{message};
  my ( $cmnd, $args ) = split /\s+/, $message->{message}, 2;
  return ABFS::Core::Message->new(
    request => $message,
    command => $cmnd,
    message => $args,
  );
}

=head2 runobject

  my @messages = $cmd->runobject($command);

Returns the module object that will run a specified command;

=cut

sub runobject {
  my($self,$command) = @_;

  #warn "Choose $command from $self->{command}\n"; # XXX: debug
  $self->{command}{$command};
}

=head2 register

  $cmd->register($module)

Commands for a module will be registered.

=cut

sub register {
  my($self,$obj) = @_;

  #warn "Register commands for $obj\n"; # XXX: debug
  #$self->{command}{$_} = $obj for keys %{ $obj->{config}{Command} };
  for my $c ( keys %{ $obj->{config}{Command} } ) {
    #warn "Register command $c for $obj\n"; # XXX: debug
    $self->{command}{$c} = $obj;
  }
}

=head2 unregister

  $cmd->unregister($module)

Remove commands available in module

=cut

sub unregister {
  my($self,$obj) = @_;

  delete $self->{command}{$_} for keys %{ $obj->{config}{Command} };
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command
