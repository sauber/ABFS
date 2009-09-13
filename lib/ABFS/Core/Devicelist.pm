package ABFS::Core::Devicelist;

use warnings;
use strict;
use Carp;
use Module::Load;
use base ('ABFS::Common::Loadable');

=head1 NAME

ABFS::Core::Devicelist - Keep a list of mounted devices

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Config:
EOF
}

=head1 SYNOPSIS

  use ABFS::Core::Devicelist;

  my $devices = ABFS::Core::Devicelist->new();

=head1 DESCRIPTION

Controls block devices, such as creating, deleting, enabling, disabling
and listing. For block operations, find a suitable devices that matches
criteria for block operations.

=head1 FUNCTIONS

=head2 devicelist

  $devices->devicelist();

List of mounted devices and basic properties of device.

  (
    {
      id => 1,
      name => 'memory',
      type => 'heap',
      size => 123458796,
      usage => 123458796,
      mount => '/',
    },
    {
      id => 2,
      name => 'memory',
      type => 'heap',
      size => 123458796,
      usage => 123458796,
      mount => '/',
    },
  )

=cut

sub devicelist {
  my ( $self ) = @_;

  return
    map{{
      id => $self->{devices}{$_}{id},
      name => $self->{devices}{$_}{name},
      type => $self->{devices}{$_}{type},
      size => $self->{devices}{$_}{device}->size(),
      usage => $self->{devices}{$_}{device}->usage(),
      mount => $self->{devices}{$_}{mountpoint},
    }}
    keys %{$self->{devices}}
  ;
}

=head2 mount

  $devices->mount(type=>'heap', name=>'memory', mount=>'/');

Mount a new block device. Returns a uniq device id.

=cut

sub mount {
  my ( $self, %options ) = @_;

  my $type = $options{type};
  # If a device is given, use it, else init a new device
  my $device = $options{device} || $self->_initdevice($type);
  # XXX: Verify that given device is a real device type
  #return $self->makeresponse( $message, message => 'Invalid device' )
  #  unless $device;
  # XXX: Propagate errors
  return undef unless $device;
  # XXX: Name should be uniq
  my $name = $options{name};
  my $mountpoint = $options{mount};
  my $id = $self->_nextid();
  $self->{devices}{$id} = {
    id=>$id,
    name=>$name,
    type=>$type,
    device=>$device,
    mountpoint=>$mountpoint,
  };
  #$self->makeresponse( $message, message => {type=>$type, mountpoint=>$mountpoint, name=>$name, id=>$id, device=>$device} );
  # XXX: What makes more sense, the ID or the device?
  return $id;
}

# Get next available ID for device
#
sub _nextid {
  my $self = shift;

  return 0 unless keys %{$self->{devices}};
  my($latest) = sort { $b <=> $a } keys %{$self->{devices}};
  return ++$latest;
}

# Create a device object
#
sub _initdevice {
  my($self,$type) = @_;

  # Load package from disk
  my $fullname = 'ABFS::Device::' . ucfirst $type;
  eval { load $fullname; };
  if ( $@ ) {
    #carp "Load $fullname failed: $@\n";
    return undef;
  }
  # XXX: Read some properties to learn about type and capabilities of device
  return new $fullname;
}

=head2 devicematch

  @devicelist = $devices->devicematch(@criteria);

List of devices matching criteria. Valid criteria:

  read
  write
  local
  remote
  temporary
  persistent
  data
  command
 

=cut

sub devicematch {
  my($self,@crit) = @_;

  return grep _devicetest($_,\@crit), values %{$self->{devices}};
}

# Test if a device match all criteria
sub _devicetest {
  my($device,$crit) = @_;

  for my $c ( @$crit ) {
    return undef if not defined $device->{config}{$c};
  }
  return 1;
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Core::Devicelist

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Core::Devicelist
