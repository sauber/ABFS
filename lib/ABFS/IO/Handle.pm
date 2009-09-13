package ABFS::IO::Handle;

use warnings;
use strict;
use Carp;

our (@ISA);
@ISA = qw(IO::Handle);

=head1 NAME

ABFS::IO::Handle - A Big File System File Handle

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

    use ABFS::IO::Handle;

    my $io = ABFS::IO::Handle->new();
    ...

=head1 FUNCTIONS

ABFS::IO::Handle supports the following
functions corresponding to perl built-in functions:

    $io->close
    $io->eof
    $io->fileno
    $io->format_write( [FORMAT_NAME] )
    $io->getc
    $io->read ( BUF, LEN, [OFFSET] )
    $io->print ( ARGS )
    $io->printf ( FMT, [ARGS] )
    $io->say ( ARGS )
    $io->stat
    $io->sysread ( BUF, LEN, [OFFSET] )
    $io->syswrite ( BUF, [LEN, [OFFSET]] )
    $io->truncate ( LEN )

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

    perldoc ABFS::IO::Handle

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::IO::Handle
