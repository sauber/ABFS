package ABFS::Command::Help;
use base ('ABFS::Command::Plugin');

=head1 NAME

ABFS::Command::Help - Help command

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _commandhelp {
  <<EOF;
Command:
  help:
    summary: List available commands
    description: A list of all available commands in loaded modules
    syntax: [<commandname>]

EOF
}

=head1 SYNOPSIS

  use ABFS::Command::Help;

  my $cmd = ABFS::Command::Help->new();

=head1 DESCRIPTION

Show available commands and how to use them.

=head1 FUNCTIONS

=head2 help

  $cmd->help();

List available commands from other modules;

=cut

sub help {
  my ( $self, $message ) = @_;

  # XXX: Details for individual command if requested
  my $cmdlist = join ' ', sort $self->_allcommands();
  #$self->makeresponse( $message, message=>'help is not available', caller=>$message->{caller} );
  #$self->makeresponse( $message, message=>"List of commands: $cmdlist", caller=>$message->{caller} );
  return "List of commands: $cmdlist";
}

# Loop through all modules an compile list of all commands
#
sub _allcommands {
  my $self = shift;

  my @cmd = ();
  if ( $self->{modules} ) {
    for my $m ( $self->{modules}->nodeobjs() ) {
      push @cmd, keys %{ $m->{command} };
    }
  }
  return @cmd;
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Help

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command::Help
