package ABFS;

use warnings;
use strict;
#use ABFS::Core::Kernel;
use ABFS::Core::Loader;
#use ABFS::Console;
#use ABFS::Request::Queue;

#use base ('Filesys::Virtual');

=head1 NAME

ABFS - A Big File System

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

    use ABFS;

    my $abfs = ABFS->new();
    ...

=head1 FUNCTIONS

=head2 new

=cut

sub new {
  my $type = shift;
  $type = ref $type if ref $type;
  my $this = {};
  bless $this, $type;
}

=head2 console_mode

Run abfsd in foreground console mode.

=cut

sub console_mode {
  my $self = shift;

  # XXX: We need a kernel, a loader, a console, a request broker.
  # XXX: Console depends on command module
  #my $abfs_loader = new ABFS::Core::Loader;
  #my $abfs_kernel =
  #  ABFS::Core::Kernel->new( loader => $abfs_loader );
  #my $abfs_request = new ABFS::Request::Queue;

  # Tell loader to load Console
  #my $abfs_console = new ABFS::Console;
  my $abfs_kernel = $self->bootstrap();
  #$abfs_kernel->{loader}->add('Command::Console');
  # Let Request module load in Console after kernel is started
  $abfs_kernel->{loader}{modules}->getobj('Request')->cmd('load Command::Console');

  $abfs_kernel->run();
}

=head2 run_commands

Load core modules, and execute a list of commands.

  $abfs->run_commands("command1", "command2", ...);

=cut

sub run_commands {
  my($self,@commands) = @_;

  my $loader = new ABFS::Core::Loader;
  #$loader->add('Command');
  $loader->add('Command::Load'); # XXX: We need a better way to load load-cmd
  #$loader->{modules}->getobj('Command')->commandline({ message=>$command });
  #warn "Now enqueueing command message\n"; # XXX: debug
  for my $commandline ( @commands ) {
    $commandline =~ s/^\s*//; $commandline =~ s/\s*$//; # Head/trail wht space
    ( my $cmd = $commandline ) =~ s/^(\S+).*/$1/;
    $loader->{modules}->getobj('Request')->enqueue({
      messagetype=>'request',
      message=>$commandline,
      command=>$cmd,
      caller=>$self,
    });
  }
  #warn "*** run_command status check\n";
  $loader->{modules}->getobj('Core::Kernel')->run();
  warn "Now unloading modules\n";
  $loader->del('Command::Load');
  warn "Unloading modules done\n";
}

=head2 response

Print out responses to requests raised from this module

  $abfs->response($message);

=cut

sub response {
  my($self,$message) = @_;

  print ">>> " . $message->{message} . "\n";
}

# Load in required modules for starting
# The boot strap process is to load the loader, and give the loader more
# modules to load, such as load command and config command.
# The request module will require a kernel.
# If a kernel is loaded, then start it after loading is finished.
# At this point there should some event for kernel to execute, to get
# started.
#
sub bootstrap {
  my $self = shift;

  # Modules we need:
  #   Loader
  #   Kernel
  #   -> Request
  #      -> Command
  #         -> Load
  #            -> Config
  #my $abfs_kernel = ABFS::Core::Kernel->new(
  #  loader => new ABFS::Core::Loader,
  #);
  #$abfs_kernel->{loader}->add('Command::Load');
  ##$abfs_kernel->{loader}->add('Command::Config');
  #return $abfs_kernel;

  my $loader = new ABFS::Core::Loader;
  #$loader->add('Command::Load'); # XXX: Should this be hardcoded?
  return $loader;
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS
