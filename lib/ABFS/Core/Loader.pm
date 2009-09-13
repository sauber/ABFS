package ABFS::Core::Loader;

use warnings;
use strict;
use Carp;
use Module::Load;
use ABFS::Core::DependencyTree;

=head1 NAME

ABFS::Core::Loader - A Big File System Module Loader

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::Core::Loader;

  my $loader = ABFS::Core::Loader->new();

=head1 DESCRIPTION

This module will load other modules into ABFS kernel, or unload. An ABFS
kernel can be the full ABFS system, or only subset, such as router,
storage, filesystem, chatter etc.

When a module is loaded, all required modules are also loaded.

=head1 FUNCTIONS

=head2 new

  Generate object.

  $loader = new( );

=cut

sub new {
  my $type = shift;
  $type = ref $type if ref $type;
  my $this = {
    modules => new ABFS::Core::DependencyTree,
    @_,
  };
  bless $this, $type;
}

=head2 add

  $loader->add( $modulename, $parentmodule );

Load in new driver. Register $parentdriver as dependant driver.
Install kernel handlers, register console commands, initialize
default settings for module.

Recursively load in all required modules, and return a list of all
new modules that has been loaded.

=cut

# XXX: This subroutine is called 'add' instead of 'load' because 'load' is
#      exported from Module::Load. For some reason
#      '$self->SUPER::load $fullname' does not work.
# XXX: It's too long - need to refactor
#
sub add {
  my ( $self, $module, $parent ) = @_;

  # Strategy:
  # Load module
  # Load dependencies
  # Register in modulelist
  # Return list of modules loaded, (so that config, kernelhandlers,
  #   requesthandlers etc. can be handled by owner of this module)

  return unless $module;
  #$module = lc $module;

  # Don't load module if already loaded
  if ( $self->{modules}->exists($module) ) {
    if ($parent) {

      # Register dependencies
      my $pobj = $self->{modules}{$parent}{obj};
      #warn "Register $parent as parent to $module\n";
      $self->{modules}->addnode( $parent, $pobj, $module );
    }
    return ();    # No new modules loaded
  }

  # Load package from disk
  #my $fullname = 'ABFS::' . ucfirst $module;
  my $fullname = 'ABFS::' . $module;
  eval { load $fullname; };
  if ( $@ ) {
    croak "Load $module failed: $@\n";
  }
  #return if $@;    # Loading failed
  #warn "Load of $module was successful\n";

  # Identify and load dependencies
  my @depends = $fullname->dependencies();
  my @loaded;

  #warn "module $module depends on @depends\n"; # XXX: debug
  for my $depend (@depends) {

    #warn "$module depends on $depend\n"; # XXX: debug
    my @newmodules = $self->add( $depend, $module );

    #use Data::Dumper;
    #warn Dumper("newmodules", \@newmodules); # XXX: debug
    if ( @newmodules and $#newmodules >= 0 and $newmodules[0] !~ /./ ) {

      # If dependency fail, then this module will fail. Clean up.
      $self->{modules}->removerecursive($module);
      return;
    } else {

      #warn "$depend loaded, adding it to \@loaded"; # XXX: debug
      push @loaded, @newmodules;
    }
  }

  # Make object of newly loaded class
  # XXX: Test for failure and roll back?
  my($obj) = $self->initobj($module);
  #warn "Loaded $module\n";

  # Register parent and child dependencies
  $self->{modules}->addnode( $module, $obj, @depends );

  # We need to return a list of new modules that has been loaded
  return $module, @loaded;
}

=head2 del

  $loader->del( $module );

Unload driver. Will not unload if there are dependants.
If required modules have no other dependants, they will be unloaded as well.

=cut

# XXX: This sub is called 'del' instead of 'unload' for the same reason
#      as sub 'add'.
sub del {
  my ( $self, $module ) = @_;

  # XXX: Actually cannot unload the perl code...
  #unload 'ABFS::Provider::' . ucfirst $module;

  # Remove recursively from dependency tree. Get list of actually removed
  # modules. But so far nothing else to do, so just pass on the list to
  # caller.
  # For each module need to call uninitobj.
  #use Data::Dumper; # XXX: debug
  #warn Dumper $self->{modules}->dependencylist(); # XXX: debug
  my %modulelist = $self->{modules}->removerecursive($module);
  while ( my($modulename,$obj) = each %modulelist ) {
    #warn "Doing uninitobj of $modulename\n";
    $self->uninitobj($modulename, $obj);
  }
  #warn Dumper $self->{modules}->dependencylist(); # XXX: debug
}

=head2 initobj

  my $obj = $loader->initobj( $module );

Initilization of object.

=cut

sub initobj {
  my ( $self, $module ) = @_;

  my $fullname = 'ABFS::' . ucfirst $module;

  # Install kernel handlers
  # Setup config
  # Setup commands
  #warn "loader kernel: $self->{kernel}\n"; # XXX: debug
  my %globals;
  $globals{modules} = $self->{modules} if $self->{modules};
  my $obj = $fullname->new(%globals);
  #use Data::Dumper;
  #warn "Check that Config is set for $obj: " . Dumper $obj;

  # Reference to loader
  $obj->{loader} = $self;

  # XXX: Install kernel handlers
  #if ( $self->{kernel} ) {
  #  $obj->{kernel} = $self->{kernel};
  #  if ( $obj->{events} ) {
  #    warn "$module has events. Need to load kernel\n";
  #    $self->add('Core::Kernel', $module);
  #    #$self->{kernel}->add( $obj, $obj->{events} );
  #    $self->{modules}->getobj('Core::Kernel')->add( $obj, $obj->{events} );
  #  }
  #}
  #$self->registerevents($module,$obj);
  #return $obj, $self->registerevents($module,$obj);;

  # Register commands, filters, storage devices, file assemblers
  # XXX: filter should use Filter in _properties instead of hooklist
  $self->getobj("Request")->registerfilter($obj)
    if $obj->can('hooklist') and $self->getobj("Request");
  $self->getobj("Command")->register($obj)
    if $obj->{config}{Command} and $self->getobj("Command");

  return $obj;
}

=head2 uninitobj

  $loader->uninitobj($obj);

Uninitialization of object. Undoes what initobj() does.

=cut

sub uninitobj {
  my ( $self, $module, $obj ) = @_;

  #$self->{kernel}->del( $self, $obj->{events} );
  #$self->unregisterevents($module,$obj);

  # Unregister commands, filters, storage devices, file assemblers
  $self->getobj("Request")->unregisterfilter($obj)
    if $obj->can('hooklist') and $self->getobj("Request");
  $self->getobj("Command")->unregister($obj)
    if $obj->{Config}{Command} and $self->getobj("Command");

  # XXX: call clean up in $obj
  # XXX: At this point last reference, and object disappears magically.
}

#=head2 registerevents
#
#  $loader->registerevents("Modulename",$moduleobj);
#
#Check if there are kernel handlers for new object to register
#
#=cut
#
#sub registerevents {
#  my($self,$module,$obj) = @_;
#
#  if ( $obj->{events} ) {
#    warn "$module has events. Need to load kernel\n";
#    $self->add('Core::Kernel', $module);
#    $self->{modules}->getobj('Core::Kernel')->add( $obj, $obj->{events} );
#    return 'Core::Kernel';
#  }
#  #use Data::Dumper; # XXX: debug
#  #warn Dumper $self->{modules}->dependencylist(); # XXX: debug
#  return ();
#}
#
#=head2 unregisterevents
#
#  $loader->registerevents("Modulename",$moduleobj);
#
#Remove kernel events for module
#
#=cut
#
#sub unregisterevents {
#  my($self,$module,$obj) = @_;
#
#  if ( $obj->{events} ) {
#    warn "$module had events. removing events an unload kernel\n";
#    $self->{modules}->getobj('Core::Kernel')->del( $obj, $obj->{events} );
#    $self->del('Core::Kernel', $module);
#  } 
#}

=head2 getobj

  my $obj = $loader->loaded( $module );

Get object for module

=cut

sub getobj {
  my ( $self, $module ) = @_;

  return $self->{modules}->getobj($module) || undef;
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Core::Loader

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Core::Loader
