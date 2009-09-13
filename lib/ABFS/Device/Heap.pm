package ABFS::Device::Heap;
use base ('ABFS::Device::Plugin');
use POE;

=head1 NAME

ABFS::Device::Heap - Heap storage device

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Devops:
  read: 'true'
  write: 'true'
  local: 'true'
  temporary: 'true'
EOF
}

=head1 SYNOPSIS

  use ABFS::Device::Heap;

  my $echo = ABFS::Device::Heap->new();

=head1 DESCRIPTION

Store blocks in process heap. Data is lost when process exist. No
upper limit size is enforced and no expiration happens.

=head1 FUNCTIONS

=head2 read

  $data = $device->read( $blockid );

Reads a block. Returns the block data, or undef if block not found in storage.  

=cut

sub read {
  my($self,$blockid) = @_;

  return undef unless $blockid;
  return undef unless $self->{heap}{$blockid};
  $self->{heap}{$blockid}{access} = time;
  return $self->{heap}{$blockid}{data} || undef;
}

=head2 write

  $writecount = $device->write($blockid, $data);

Write a block. Returns number of blocks written.

=cut

sub write {
  my($self,$blockid,$blockdata) = @_;

  return 0 unless $blockid and $blockdata;
  if ( $self->{heap}{$blockid} ) {
    $self->{currentsize} -= length $blockid;
    $self->{currentsize} -= length $self->{heap}{$blockid}{data};
  }
  $self->{heap}{$blockid}{data} = $blockdata;
  $self->{heap}{$blockid}{access} = time;
  $self->{currentsize} ||= 0;
  $self->{currentsize} += length($blockid) + length($blockdata);
  return 1;
}

=head2 writenew

  $writecount = $device->writenew($blockid, $data);

Write a block if it does not exist already. Returns number of blocks written.

=cut

sub writenew {
  my($self,$blockid,$blockdata) = @_;

  return 0 unless $blockid and $blockdata;
  if ( $self->{heap}{$blockid} ) {
    $self->{heap}{$blockid}{access} = time;
    return 0;
  }
  $self->{heap}{$blockid}{data} = $blockdata;
  $self->{heap}{$blockid}{access} = time;
  $self->{currentsize} ||= 0;
  $self->{currentsize} += length($blockid) + length($blockdata);
  return 1;
}

=head2 delete

  $deletecount = $device->delete($blockid);

Deletes a block from storage. Returns number of blocks deleted.

=cut

sub delete {
  my($self,$blockid) = @_;

  return 0 unless $blockid;
  return 0 unless $self->{heap}{$blockid};
  $self->{currentsize} -= length $blockid;
  $self->{currentsize} -= length $self->{heap}{$blockid}{data};
  delete $self->{heap}{$blockid};
  return 1;
}
 
=head2 usage

  $bytes = $device->usage();

Bytes in use by storage.

=cut

sub usage {
  my $self = shift;

  return $self->{currentsize} || 0;
}

=head2 resize

  $bytes = device->resize($newsize);

Resize device to $newsize number of bytes. Only reduces size.

=cut

sub resize {
  my($self,$newsize) = @_;

  # Nothing to do if $newsize > usage
  my $usage = $self->usage();
  return $usage if $usage <= $newsize;
  # Get all blocks. Sort by access time
  my @blocks =
    sort { $a->[1] <=> $b->[1] }
    map {[ $_, $self->{heap}{$_}{access} ]}  # Add access time for each block
    @{ $self->blocklist() };
  # Delete one by one until <= than $newsize
  #while ( $self->usage > $newsize ) {
  #  my $block = shift @blocks;
  #  $self->delete($block->[0]);
  #}
  $self->_resize_session(\@blocks,$newsize);
  return $self->usage;
}

# Create a POE::Session to delete one by one to not block for too long time
#
sub _resize_session {
  my($self,$blocklist,$newsize) = @_;

  POE::Session->create(
    object_states => [
      $self => {
        _start => '_resize_session_start',
        next => '_resize_session_next',
      },
    ],
    args => [ $blocklist, $newsize ],
  );
}

sub _resize_session_start {
  my($self,$kernel,$blocklist,$newsize) = @_[ OBJECT, KERNEL, ARG0, ARG1 ];

  $kernel->yield('next',$blocklist,$newsize);
}

sub _resize_session_next {
  my($self,$kernel,$blocklist,$newsize) = @_[ OBJECT, KERNEL, ARG0, ARG1 ];

  #warn "Deleting from $blocklist\n";
  use Data::Dumper;
  #warn "ARG0: " . Dumper $_[ARG0];
  #warn "ARG1: " . Dumper $_[ARG1];
  #warn "ARG2: " . Dumper $_[ARG2];
  #warn "OBJECT: " . Dumper $_[OBJECT];
  #warn "KERNEL: " . Dumper $_[KERNEL];
  my $block = shift @$blocklist;
  if ( $block->[1] and $self->{heap}{$block->[0]}{access} ) {
    if ( $block->[1] == $self->{heap}{$block->[0]}{access} ) {
      # Access time has not changed, so can be deleted.
      $self->delete($block->[0]);
    }
  }
  if ( $self->usage > $newsize ) {
    # Still too big
    if ( @$blocklist ) {
      # Still blocks to be deleted
      $kernel->yield('next',$blocklist,$newsize);
    }
  }
}

=head2 blocklist

  $blocklistref = $device->blocklist();

List of blocks in device. Returns a reference to list.

=cut

sub blocklist {
  my $self = shift;
  return [ keys %{$self->{heap}} ];
}

=head2 stat

  @blocklist = $self->stat(@blocklist);

Test if blocks exists. Returns the id's of blocks that do exist.

=cut

sub stat {
  my $self = shift;

  return grep { defined $self->{heap}{$_} } @_;
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Device::Heap

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Device::Heap
