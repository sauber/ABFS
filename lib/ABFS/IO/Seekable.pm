package ABFS::IO::Seekable;

use warnings;
use strict;
use Carp;

our (@ISA);
@ISA = qw(IO::Seekable);

=head1 NAME

ABFS::IO::Seekable - A Big File System seek based methods for I/O objects

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

    use ABFS::IO::Seekable;

    my $io = ABFS::IO::Seekable->new();
    ...

=head1 FUNCTIONS

ABFS::IO::Seekable supports the following
functions corresponding to perl built-in functions:

    $io->getpos
    $io->setpos
    $io->seek ( POS, WHENCE )
    $io->sysseek( POS, WHENCE )
    $io->tell

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

    perldoc ABFS::IO::Seekable

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::IO::Seekable
