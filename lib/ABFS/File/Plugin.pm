package ABFS::File::Plugin;
use warnings;
use strict;
use base ('ABFS::Common::Loadable');

=head1 NAME

ABFS::File::Plugin - Base module for file assembly and disassembly

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

  use ABFS::File::Plugin;

  my $file = ABFS::File::Plugin->new();

=head1 DESCRIPTION

Default methods for handling files.

=head1 FUNCTIONS

=head2 nodeid
        
  $id = $file->nodeid();

The id of file, based upon content of inode.

=cut

sub nodeid {
  my $self = shift;

  return $self->cksum( $self->{content} );
}

=head2 seek

  $file->seek($offset);

Set current position pointer to $offset.

=cut

sub seek {
  my($self,$offset) = @_;

  $self->{pos} = $offset;
}

=head2 pos

  my $offset = $file->pos();

Current position for read or write.

=cut

sub pos {
  my $self = shift;

  $self->{pos} ||= 0;
  return $self->{pos};
}

=head2 size

  my $length = $file->size()

=cut

sub size { return undef }

=head2 read

  my $data = $file->($length, $offset);

=cut

sub read { return undef }

=head2 write

  $file->write($content, $offset);

=cut

sub write { return undef }

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::File::Plugin

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::File::Plugin



