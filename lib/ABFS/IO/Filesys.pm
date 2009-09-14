package ABFS::IO::Filesys;

use warnings;
use strict;
use Carp;
#use ABFS::IO::Inode;
#use ABFS::Core::Constants;
use base ('ABFS::Common::Loadable');


=head1 NAME

ABFS::IO::Filesys - Implementation of Filesys::Virtual
compatible methods.

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Depend:
 - IO::Dir

EOF
}


=head1 SYNOPSIS

    use ABFS::IO::File;

    my $file = ABFS::IO::File->new();
    ...

=head1 DESCRIPTION

This module is compatible with Filesys::Virtual. But unlike Filesys::Virtual
not all methods are syncronous and requires postbacks for posting results
when ready.

=head1 FUNCTIONS

=head2 new

=cut

#sub new {
#  my $class = shift;
#  my $self  = {};
#  bless( $self, $class );
#  return $self;
#}

=head2 open

An open call specifies if mode is read, write or append. For read, a 
filename of inode number can be specified. For write or append, filename 
has to be specified, since the inode number will change as data is 
written, and final number is not determined until file is changed.

Read and append translated the file name to inode number and reads it in.

Seek pointer is set to 0. Blocksize is either read from inode when open 
for read or append, or set to default size.

Inode of dir is required for adding entries when closing files that have 
been written to.

XXX: This method is not needed; use open_read or open_write instead.

=cut

sub open {
  @_ >= 2 && @_ <= 4 or croak 'usage: $fh->open(FILENAME [,MODE [,PERMS]])';
  my ( $fh, $file ) = @_;
}

=head2 open_read

A filename of inode number can be specified. Filenme is translated to inode
number and inode is read.
Seek pointer is set to 0. Blocksize is read from inode when opened.

=cut

sub open_read {
  my ( $self, $fin, $create ) = @_;

  $self->{seek} = 0;

  #my $inode = new...
  # XXX: postback when inode is read
}

=head2 Read

According to to seek pointer and requested read buffer size, blocks are 
requested. A postback is required to hand the data back to when ready. 
Additional blocks can be requested for read-ahead performance. A 
postback is given to block request. Blocks can be read from any source 
and only one copy is required.

=head2 Write

Size of buffer and seek pointer determines if write is within a block 
that has previously been written to. If so, same block is chosen for the 
write. Otherwise a new anonymouse block is allocated and write goes to 
that one. A list is maintained for which blocks are allocated for each
range of data. Each block has default size.

A timer is created for the block, and if no further writes are done, the 
block's id is calculated and used in list instead of reference to 
anonymous block. The block is written to storage and derefenced. Storage 
location is according to policy, default is 1 copy, and local storage is 
preferred. Existing blocks does not need overwrite - just touching.

If writes happen to same block after timeout, it will have to be read 
again, before buffer can be written to it and new timer set.

A write buffer might stretch over several blocks, in which case the 
buffer is broken up and handled individualle for each block.

Another timer is set for the file for each write. If no writes happen, 
all blocks, inode and file object is dereferenced. Without a close the 
file is considered incomplete and since the inode is not generated, the 
file basically does not exist.

=head2 Append

Append is similar to write, except that the inode is read in and block 
id's are used. Seek pointer is set to size of file. Writes can happen at 
end of file, of if seek is set, at any point inside existing file.

=head2 Close

For a read mode file, the file is just dereferenced.

When write or append file is closed, all blocks are flushed, and block 
id's are combined in inode. Inode and filename is added to directory 
entry that was specified when opening file.

If same filename already exist, it is overwritten. There can only be one 
entry for each filename in each dir.

Sparse files. Seek is possible beyond end of file and can introduce gaps 
in list of blocks. When flushing a file with block gaps, null byte 
blocks are inserted to make blocklist complete. Only one null byte block 
need to be generated and saved to disc.

=head2 Stat

Generate stat information for file. It has to be unix style stat 
information that is return but semantics have to be changed a little to 
include information such as confidence and cost.

  dev: 0 + $self
  ino: $inode % 32 bit
  mode: 0100666
  nlink: Confidence level from 0-100 about availability of file
  uid: id of peer link that introduced this entry
  gid: relative cost 0-65535 to get file
  rdev: 0
  size: file size
  atime: last access
  mtime: last access
  ctime: last access
  blksize: block size
  blocks: number of block entries in inode

=head2 test

Respond to file test operations: 

  # -r File is readable by effective uid/gid.
  # -w File is writable by effective uid/gid.
  ...
  # -M Age of file in days when script started.

=head2 list

  my @list = $fs->list($dir);

List files in a dir.

=cut

sub list {
  my($self,$dir) = @_;

  # XXX: See if dir already is cached
  # XXX: Loadable modules are singletons in Loader module
  # unless ( $self->{dircache}{$dir} ) {
  #   $self->{dircache}{$dir} = new ABFS::IO::Dir($dir);
  # }
  # my $dir = $self->{dircache}{$dir};

  # XXX: Dirs take time to load, so use postback
  # XXX: For now all dirs have bar and foo
  return qw(bar foo);
}



=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::IO::File

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::IO::File
