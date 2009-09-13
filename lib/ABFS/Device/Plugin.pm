package ABFS::Device::Plugin;

use warnings;
use strict;
use Carp;
use ABFS::Core::Constants;
use base ('ABFS::Common::Requestable');

=head1 NAME

ABFS::Device::Plugin - Storage device template

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Devops:
  read: 'false'

EOF
}

=head1 SYNOPSIS

  use ABFS::Device::Plugin;

  my $device = ABFS::Device::Plugin->new();

=head1 DESCRIPTION

Each storage device must support basic functions

=head1 FUNCTIONS

=head2 request

  $response = $device->request( %message );

Request block device operations, such as read and write.

=cut

sub request {
  my ( $self, $message ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head2 read

  $block = $device->read( %args );

Read a block from device.

=cut

sub read {
  my ( $self, $request ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head2 write

  $device->write( %args );

Write a block to device. If existing block exist, overwrite it.

=cut

sub write {
  my ( $self, $request ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head2 writenew

  $device->write( %args );

Write a block to device if it does not already exist.

=cut

sub writenew {
  my ( $self, $request ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head2 stat

  $device->stat( %args );

Test if a list of blocks exist on device. Returns list of blockid that exist.

=cut

sub stat {
  my ( $self, $request ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head2 touch

  $device->touch( %args );

Updates recently used timestamp of block without any other read/write operations.

=cut

sub touch {
  my ( $self, $request ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head2 blocklist

  $device->blocklist( %args );

Reference to list of all blockid in device.

=cut

sub blocklist {
  my ( $self, $request ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head2 size

  $device->size( %args );

Capacity of device in number of bytes.

=cut

sub size {
  my ( $self, $request ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head2 resize

  $device->resize( %args );

Change capacity of device to number of bytes specified.

=cut

sub resize {
  my ( $self, $request ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head2 usage

  $device->usage( %args );

Number of bytes in use by device

=cut

sub usage {
  my ( $self, $request ) = @_;

  carp "Not implemented";
  return PERMFAILURE
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Device::Plugin

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Device::Plugin
