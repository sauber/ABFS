package ABFS::IO::Inode;

use warnings;
use strict;
use Carp;
use ABFS::Core::Block;
use ABFS::Core::Constants;
use YAML::Syck qw(Dump Load);

=head1 NAME

ABFS::IO::Inode - A Big File System File Inode

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::IO::Inode;

  my $inode = ABFS::IO::Inode->new();
  ...

=head1 DESCRIPTION

Inodes are read or written in entirety. When a file is opened for read 
or append, the inode is read to get filesize, blocksize and a list of 
all data blocks.

When a file is written or appended, the inode is not generated and 
written until the file is closed, When an inode is generated, it is also 
inserted into a directory.

Inodes are cached for future directory listing, but dereferenced after a 
periode of not accessed.

Inodes determine which block fragments are required for reading and writing.
New anonymous blocks will be created for writing as needed. The size of the
file is updated for each write.

For now just one plain layout of blocks exist: concatenation. But other
methods like mirroring and raid5/6 could be created.

=head1 FUNCTIONS

=head2 new

=cut

sub new {
  my $class = shift;
  my $self  = {};
  bless( $self, $class );
  return $self;
}

=head2 open_read

Request Inode from local storage or remote. Only one copy is needed.

=cut

sub open_read {
  my ( $self, $key, $postback ) = @_;

  $self->{key} = $key;

  # XXX: A kernel is required.
  #$self->{kernel}->request(
  #  type=>block, id=>$key, postback=>$self->inode_load
  #);
  # XXX: Several postbacks might exist for same inode
  #      ... but kernel might be able to keep track of it anyway...
  #$self->{postback} = $postback;
  # XXX: Let kernel know that this is async request
  #return 0;
  return {
    status  => ASYNC,
    enqueue => [
      {
        module    => 'block',
        eventtype => 'request',
        key       => $key,
        postback  => $self->inode_load,
      }
    ]
  };
}

=head2 inode_load

A postback method to be called when a requested inode is loaded.

=cut

sub inode_load {
  my ( $self, $block ) = @_;

  $self->{raw} = $block->{raw};
  $self->decode;

  # Let requester know that open file call suceeded.
  #$self->{kernel}->respond($self->{postback});
  return { status => SUCCESS };
}

=head2 close_read

Dereference inode

=head2 open_write

Create a blank inode for writing a new file.

=cut

sub open_write {
  my ( $self, $filename ) = @_;

  # Will need filename when inserting in dir list later
  $self->{filename}  = $filename;
  $self->{blocklist} = [];

  #$self->{blocksize} = 2048;  # XXX: Need to use defaults/config;
  $self->{blocksize} = 4;    # XXX: Need to use defaults/config;
  $self->{filesize}  = 0;

  # XXX: Respond to kernel that request is completed.
  return { status => SUCCESS };
}

=head2 close_write

Flush inode to storage, generate key, insert in dir, and derefence object

=head2 flush

From blocklist and blocksize, generate an inode, write it to disk and 
update dir with filename and inode id. The idenfier for an inode is the 
checksum of it's content, so when content of an inode changes, the id of 
the inode itself changes. By using checksum as identifier, the content 
can be validated and discarded if not matching.

If blocklist is missing blocks, then create empty blocks and add to list as
needed.

=head2 size

Read inode from storage. Return file size attribute.

=cut

sub size {
  my ($self) = @_;

  #return (1, $self->{filesize});
  return { status => SUCCESS, result => $self->{filesize} };
}

=head2 write

Write data into blocks. Generate blocks as needed. $pos is optional. Default
is to append at end of file. This method uses a simple concatenation layout
of blocks.

=cut

sub write {
  my ( $self, $data, $pos ) = @_;

  $pos ||= $self->{filesize};

  # Determine block boundaries
  while ( length $data ) {

    # Determine if remaining data fits in one block
    my $maxsize = $self->{blocksize} - ( $pos % $self->{blocksize} );

    #warn "maxsize=$maxsize\n";
    # Otherwise chop off as much as can fit
    my ( $writedata, $boundary );
    if ( $maxsize < length $data ) {
      $writedata = substr( $data, 0, $maxsize, '' );
      $boundary = 1;
    } else {
      $writedata = $data;
      $data      = '';
    }

    # Create block if doesn't exist already
    # XXX: Since we can write anywhere in file, there is a possibility that
    #      same pos will be written to multiple times. If the block was
    #      already flushed, then it has be read in again (wait for read to
    #      finish before writing), and data cloned into new anonymous block
    #      since same key cannot be used after data changes.
    my $blocknum = int $pos / $self->{blocksize};
    $self->{blocklist}[$blocknum]{block} ||=
      new ABFS::Core::Block;

    # Write to block
    my $blockpos = $self->{blocksize} - $maxsize;

    #warn "blocknum=$blocknum blockpos=$blockpos writedata=$writedata\n";
    # XXX: Is this write() function written yet?
    #$self->{blocklist}[$blocknum]{block}->write(\$writedata, $blockpos);
    # XXX: If we reach block boundary, flush block to storage
    if ($boundary) {

      # XXX: Is this flush() function written yet?
      #my $key = $self->{blocklist}[$blocknum]{block}->flush();
      #$self->{blocklist}[$blocknum]{key} = $key;
      delete $self->{blocklist}[$blocknum]{block};
    }

    # Update size and pos
    $pos              += $maxsize;
    $self->{filesize} += $maxsize;
  }

}

=head2 read

From blocklist of inode, determine which blocks are required. When all
required blocks are loaded, extract the data and return with postback.

=head2 fields

List fields to include in inode block

=cut

sub fields {
  return qw(filesize blocksize blocklist);
}

=head2 encode

Serialize inode data into one block.

=cut

sub encode {
  my ($self) = @_;

  my %kv =  map { $_, $self->{$_} } fields();
  $self->{raw} = Dump \%kv;
}

=head2 decode

Parse block of raw data into inode data structure.

=cut

sub decode {
  my ($self) = @_;

  my $data = Load $self->{raw};
  $self->{$_} = $data->{$_} for fields();
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::IO::Inode

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::IO::Inode
