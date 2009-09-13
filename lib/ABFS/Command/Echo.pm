package ABFS::Command::Echo;
use base ('ABFS::Command::Plugin');

=head1 NAME

ABFS::Command::Echo - A Simple Echo

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Command:
  echo:
    syntax: <string>
    summary: prints string
    description: Simple request that simply returns same as sent to it

Depend:
 - Command

EOF
}

=head1 SYNOPSIS

  use ABFS::Command::Echo;

  my $echo = ABFS::Command::Echo->new();

=head1 DESCRIPTION

Create a response object with same args as request

=head1 FUNCTIONS

=head2 echo

  $string = $echo->echo( $string );

Generate a response with same args as request

=cut

sub echo {
  my ( $self, @string ) = @_;

  return join ' ', @string;
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Echo

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command::Echo
