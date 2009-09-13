package ABFS::IO::Dir;

use warnings;
use strict;
#use Carp;
#use base ('ABFS::Common::Loadable');


=head1 NAME

ABFS::IO::Dir - A Big File System Directory

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Depend:
 - Request
EOF
}


=head1 SYNOPSIS

    use ABFS::IO::Dir;

    my $dir = ABFS::IO::Dir->new();
    ...

=head1 DESCRIPTION

A directory lists files and subdirectories. For each entry type (file or 
dir), name, inode, last access timestamp and id of peer that introduced 
entry is stored.

Directories do not have to be created. They will be automatically 
created when entries are inserted. Empty dirs are not stored.

For each dir operation, the dir id is determined. Memory cached dirs are 
used if possible. Otherwise a new dir is created, and events to sync up 
with local and remote storage spawned.

When content arrives from local or remote, each entry is validated. For 
recent entries existing of inode is validated. For old file entries 
existence of each block is validated.

A timer is set that flushes the dir to local storage at regular 
intervals. After a periode of no access, the dir is dereferenced.

Dirs are only stored locally. A special dir protocol request dir entry 
list from all remote nodes. No limit to number of copies accepted. 
Remote requests for dir entries results in response from own node only. 
Requests are not forwarded if they can be handled locally.

Dirs are stored in a single storage unit (one block). The identifier is 
based upon full path to dir.

When a new dir is read, wait with response until local storage have been 
read in first.

Accessing a dir also means that all parent dirs are created, read and 
checked.

=head2 chdir

Not so sure here if Filesys::Virtual needs to have cwd stored.

Sets $self->cwd($path);

But the dir is created in memory is created of not already exists.

=head2 list

Returns list of names in dir.

=head2 list_details

Return information equivalent to ls -l unix command.

=head2 stat

Generate stat information for dir. It has to be unix style stat
information that is return but semantics have to be changed a little to
include information such as confidence and cost.

  dev: 0 + $self
  ino: $dir id % 32 bit
  mode: 042777
  nlink: 1
  uid: id of peer link that introduced this entry
  gid: 0
  rdev: 0
  size: size of raw dir block
  atime: last access
  mtime: last access
  ctime: last access
  blksize: default block size
  blocks: 1

=head2 size

Size of raw dir block

=head2 chmod

Doesn't change anything. Setting permission is not possible.

=head2 mkdir

A memory cached dir is created. Synchronization from local and remote 
sources starts. If not content is found or inserted, then the new dir is 
not written to disk.

=head2 delete

Remote a file from dir in memory,

=head2 rmdir

Dereference dir from memory without flushing to disk. It might have 
already been flushed, so really getting rid of a dir is rarely possible.

=head1 FUNCTIONS

=head2 new

=cut

sub new {
  my $class = shift;
  my $self  = {};
  bless( $self, $class );
  return $self;
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::IO::Dir

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::IO::Dir
