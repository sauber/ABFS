package ABFS::File::Inline;
use base ('ABFS::File::Plugin');

=head1 NAME

ABFS::File::Inline - Store file content inside inode

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

  use ABFS::File::Inline;

  my $file = ABFS::File::Inline->new();

=head1 DESCRIPTION

Store file content inside inode descriptor. Should only be used for small
files or for testing.

=head1 FUNCTIONS

=head2 write
        
  $file->write($content, $offset);

Write content into file. If $offset is given, write from position. Otherwise
write from current position.

=cut

sub write {
  my($self,$content,$offset) = @_;

  $offset ||= $self->pos;
  substr($self->{content}, $offset) = $content;
  $self->seek($offset  + length $content);
}

=head2 read

  $content = $file->read($length,$offset);

Reads content from file. Reads from current position, otherwise starting
from $offset. Read $length number of bytes, or until end of file.

=cut

sub read {
  my($self,$length,$offset) = @_;

  $offset ||= $self->pos;
  $length ||= $self->size() - $offset;
  $self->seek($offset+$length);
  return substr($self->{content}, $offset, $length);
}


=head2 makeinode

  my $inode = $file->makeinode();

Generate an inode for file.

=cut

sub makeinode {
  my $self = shift;

  return <<EOF;
type: inline

$content
EOF
}

=head2 size

  my $length = $file->size();

Size of file content.

=cut

sub size {
  my $self = shift;

  return length $self->{content};
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::File::Inline

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::File::Inline



