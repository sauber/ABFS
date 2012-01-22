package ABFS::Core::Block;

use Moose;
use MooseX::Method::Signatures;
use Digest::SHA qw(sha256_hex);

# Block content
#
has content => ( is => 'ro', isa => 'Str' );

# Checksum of content
#
method checksum { sha256_hex $self->content }

# Name of block is same as checksum
#
method name { $self->checksum }

__PACKAGE__->meta->make_immutable;
 
1;

package ABFS::Core::Block_delme;

use warnings;
use strict;
use Carp;
use Digest::SHA qw(sha256_hex);
use Crypt::CBC;
use Crypt::Rijndael;

=head1 NAME

ABFS::Core::Block - Storage blocks

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::Core::Block;

  my $block = ABFS::Core::Block->new();

=head1 DESCRIPTION

A block is the smallest data unit in ABFS. It contains either a file fragment,
a directory index, an inode, or possibly any other information.

Blocks can be named or anonymous. named is required when storing
or transfering. Blocks can generate their own key, or have key assigned.

Blocks will do lazy encryption for permanent
storage or transfer when required.

Blocks can have restrictions on storage and transfer, such as not allowing
transfer or storage.

When storing, blocks can be told to just update timestamp of existing files
instead of full save.

=head1 FUNCTIONS

=head2 new

Generate block object.

  $block = new( );

=cut

sub new {
  my $type = shift;
  $type = ref $type if ref $type;
  my $this = {@_};
  bless $this, $type;
}

=head2 set

  $block->set( %properties );

Set one or more properties of block. Possible values are:

   key => Index of block
   dataref => ref to block data
   cryptref => ref to encrypted block data
   local=> don't try remote
   asis => don't encrypt
   update => save local should do overwrite or keep
   cache => <local|traffic>
   count => number of required saves

=cut

sub set {
  my ( $self, %prop ) = @_;

  while ( my ( $k, $v ) = each %prop ) {
    $self->{$k} = $v;
  }
}

=head2 get

  $block->get( @properties );

Retrieve one ore more properties of block. Return hash with key/value pairs.

=cut

sub get {
  my ( $self, @prop ) = @_;

  my %r;
  for my $k (@prop) {
    $r{$k} = $self->{$k};
  }
  return %r;
}

=head2 genkey

  $key = $block->genkey( );

Calculate key of block. Key is checksum of data referred to by dataref.

=cut

sub genkey {
  my ($self) = @_;

  # XXX: Find a way to not make new sha object for every block to be stored.
  #$self->{sha256} ||= Digest::SHA->new(256);
  #my $hash = $self->{sha256}->hexdigest( ${ $self->{dataref} } );
  my $hash = sha256_hex( ${ $self->{dataref} } );
  $hash =~ s/ //g;
  $self->{key} = $hash;
  return $hash;
}

=head2 encrypt

  $cryptref = $block->encrypt( );
  $cryptref = $block->encrypt( $key );

Encrypt block data. Still keeps unencrypted around. Returns ref to encrypted
data.

=cut

# XXX: todo
# XXX: Any need to encrypt if already encrypted?
# XXX: Perhaps delete encrypted on writes to dataref
# XXX: Cannot encrypt if key is missing
# XXX; Somethings wrong - it just doesn't work
#
sub encrypt {
  my ($self) = @_;

  return $self->{cryptref} if $self->{cryptref};

#unless( $self->{key} ) {
#  carp("Cannot encrypt data without key");
#  return undef;
#}
#$self->{cipher} ||= new Crypt::CBC( -key=>$self->{key}, -cipher=>'Rijndael');
#$self->{cipher} ||= new Crypt::CBC( -key=>'soren', -cipher=>'Rijndael');
#my $data = $self->{cipher}->encrypt( ${$self->{dataref}} || '' );
#my $cipher = Crypt::CBC->new( 'my secret key', 'Rijndael' );
#my $cipher = Crypt::CBC->new( -key=>'my secret key', -cipher=>'Rijndael' );
#my $cipher = Crypt::Rijndael->new( "a" x 32, Crypt::Rijndael::MODE_CBC );
#my $data = $cipher->encrypt( ${$self->{dataref}} || '' );
#my $data = $cipher->encrypt( 'This data is hush hush' );
#$self->{cryptref} = \$data;
  $self->{cryptref} = $self->{dataref};
  return $self->{cryptref};
}

=head2 decrypt

  $dataref = $block->decrypt( $key );

Encrypt block data.

=cut

# XXX: TODO
# XXX: * Make encryption work first
#
sub decrypt {
  my ( $self, $key ) = @_;

  return $self->{dataref} if $self->{dataref};

  #unless( $key ) {
  #  carp("Cannot decrypt data without key");
  #  return undef;
  #}
  #$self->{key} = $key;
  #$self->{cipher} ||= new Crypt::CBC($self->{key}, 'Rijndael');
  #my $data = $self->{cipher}->decrypt( ${$self->{cryptref}} || '' );
  #$self->{dataref} = \$data;
  $self->{dataref} = $self->{cryptref};
  return $self->{dataref};
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Core::Block

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Core::Block
