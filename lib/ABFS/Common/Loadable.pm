package ABFS::Common::Loadable;

use warnings;
use strict;
use YAML::Syck qw(Load);
use Data::Dumper;    # XXX: debug
use ABFS::Core::Constants;

=head1 NAME

ABFS::Common::Loadable - Base class for loadable modules for ABFS

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::Common::Loadable;

  my $module = ABFS::Common::Loadable->new();

=head1 DESCRIPTION

Bare module for ABFS loadable modules. Each loadable module must have
a properties sub that defines default values for config options, 
commands that Command module can execute, POE kernel handlers, dependency
requirements for other modules and possibly category of requests that it
can handle.

=head1 FUNCTIONS

=head2 new

  Generate object.

  $module = new( );

=cut

sub new {
  my $type = shift;
  $type = ref $type if ref $type;
  my $this = {};
  bless $this, $type;
  $this->_initialize(@_);
  return $this;
}

# Default initializor
#
sub _initialize {
  my $self = shift;
  %{$self} = ( %{$self}, @_ );
  #my $prop = Load $self->_properties();
  $self->{config} = Load $self->_properties();
  #$self->{config}  = $prop->{Config};
  #$self->{events}  = $prop->{Event};
  #$self->{command} = { map { $_ => 1 } @{ $prop->{Command} } };
  #$self->{command} = $prop->{Command};

  #warn "Config: " . Dumper $self->{config}; # XXX: debug
  #warn "Command: " . Dumper $self->{command}; # XXX: debug
  $self->_postinitialize();
}

# Local Post Initialize
#
sub _postinitialize { }

=head2 _properties

  $loadable->_properties( );

YAML formatted string of Module properties

=cut

sub _properties {
  <<EOF;
Command:

Config:

Depend:

Event:

Request:
  cmnd: noop
EOF
}

=head2 dependencies

List other modules that this module depend on.

=cut

sub dependencies {
  my $self = shift;
  my $prop = Load $self->_properties();

  return $prop->{Depend} ? @{ $prop->{Depend} } : ();
}

=head2 getconfig

  $value = $loadable->getconfig($key);

Get a configuration variable.

=cut

sub getconfig {
  my ( $self, $key ) = @_;

  $self->{config}{$key} || undef;
}

=head2 setconfig

  $loadable->setconfig($key, $value);

Set a configuration variable.

=cut

sub setconfig {
  my ( $self, $key, $value ) = @_;

  $self->{config}{$key} = $value;
  return $value;
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Common::Loadable

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Common::Loadable
