package ABFS::Command::Queue;
use base ('ABFS::Command::Plugin');
use YAML::Syck qw(Dump Load);

=head1 NAME

ABFS::Command::Queue - Inspect request queue

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

# Loader modules is not a loadable module, so it's commands are not
# initialises. And the methods inside Loader are called add/del anyway
# due to Module::Load overwriting name space.
#sub _properties {
#  <<EOF;
#Command:
#  load:
#  unload:
#
#Depend:
# - request
#EOF
#}

# List of commands that this module can handle
#
#sub _can {
#  qw(load unload);
#}

sub _properties {
  my $self = shift;
  my $config = Load $self->SUPER::_properties();
#  $config->{Command} = [ qw(load unload lsmod) ];
  Dump($config) . _commandhelp();
}

sub _commandhelp {
  <<EOF;
Command:
  lsq:
    summary: List messages in queue
    description: List state and details of messages in request queue
    syntax:

EOF
}

=head1 SYNOPSIS

  use ABFS::Command::Queue;

  my $cmd = ABFS::Command::Queue->new();

=head1 DESCRIPTION

Inspect details of messages in request queue.

=head1 FUNCTIONS

=head2 lsq

  $cmd->lsq();

=cut

sub lsq {
  my ( $self, $message ) = @_;

  return "No modules available" unless $self->{modules};
  my $queue = $self->{modules}->getobj('Request')->{queue};
  my $queuesize = $queue->queuesize();
  my $list = '';
  for my $state ( keys %{$queue->{queue}} ) {
    for my $mes ( @{ $queue->{queue}{$state} } ) {
      $list .= "$state $mes->{messagetype}: $mes->{message}\n";
    }
  }
  $self->makeresponse( $message, message => "Queuesize: $queuesize\n$list" );
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Queue

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command::Queue
