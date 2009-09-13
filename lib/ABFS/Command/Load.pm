package ABFS::Command::Load;
use base ('ABFS::Command::Plugin');
use YAML::Syck qw(Dump Load);

=head1 NAME

ABFS::Command::Load - Load and unload modules

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
  load:
    summary: Load a module
    description: Load a module from disk and add to list of in-memory modules
    syntax: <modulename>

  unload:
    summary: Unload a module
    description: Remove a module if there are no dependants.
    syntax: <modulename>
  
  lsmod:
    summary: List loaded modules
    description: A list of names of all loaded modules
    syntax:

  lsdep:
    summary: Module dependency list
    description: Shows all child->parent dependencies between loaded modules
    syntax:

EOF
}

=head1 SYNOPSIS

  use ABFS::Command::Load;

  my $loader = ABFS::Command::Load->new();

=head1 DESCRIPTION

Make the load and unload command available as requests to other abfs
modules.

=head1 FUNCTIONS

=head2 load

  $laoder->load($message);

=cut

sub load {
  my ( $self, $modulename ) = @_;

  #my $modulename = $message->{message};

  #warn "Command::Load::load unimplemented\n";
  #return ABFS::Core::Message->new(
  #  request => $message,
  #  command => 'load',
  #  message => $args,
  #);
  my $response = "Module $modulename not loaded.";

  #my $loader = $self->{modules}->getobj('loader');
  my $loader = $self->{loader};

  #warn "modules=$self->{modules}\n";
  #use Data::Dumper;
  #warn 'dump modules: ' . Dumper $self->{modules};
  #warn "loader=$loader\n";
  if ( $loader ) {
    if ( my @newmodules = $loader->add($modulename) ) {
      $response = 'New modules loaded: ' . join ' ', @newmodules;
    }
  }
  #$self->makeresponse( $message, message => $response );
  return $response;
}

=head2 unload

  $loader->unload($message);

=cut

sub unload {
  my ( $self, $modulename ) = @_;

  #my $modulename = $message->{message};
  #warn "Command::Load::unload unimplemented\n";
  #$self->makeresponse( $message, message => 'Command::Load::unload unimplemented' );
  return 'Command::Load::unload unimplemented';
}

=head2 lsmod

  $cmd->lsmod();

List modules loaded

=cut

sub lsmod {
  my($self, $message) = @_;

  #use Data::Dumper;
  #warn 'lsmod $self var: ' . Dumper $self;
  # XXX: todo
  # Make a respons
  #warn "lsmod called\n";
  my $modlist = "";
  if ( $self->{modules} ) {
    $modlist  = join " ", $self->{modules}->nodenames();
  }
  #$self->makeresponse( $message, message => "List of modules: $modlist" );
  return "List of modules: $modlist";
}

=head2 lsdep

  my $string = $cmd->lsdep();

List dependencies between modules. Example:

  child1->parent1
  child2->parent2
  child2->parent2
  ...

=cut

sub lsdep {
  my($self, $message) = @_;

  my $res = "List of dependencies:\n";
  if ( $self->{modules} ) {
    for my $d ( $self->{modules}->dependencylist() ) {
      $res .= "$d->[0] -> $d->[1]\n";
    }
  }
  #$self->makeresponse( $message, message => $res );
  return $res;
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Load

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command::Load
