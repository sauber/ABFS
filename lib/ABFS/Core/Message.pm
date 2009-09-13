package ABFS::Core::Message;

use warnings;
use strict;

=head1 NAME

ABFS::Core::Message - Request or Response message

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::Core::Message;

=head1 DESCRIPTION

A Request of Response message object

=head1 FUNCTIONS

=head2 new

Create object.

=cut

sub new {
  my $type = shift;
  $type = ref $type if ref $type;
  my $this = {};
  bless $this, $type;
  $this->_initialize(@_);
  return $this;
}

# Default initializor
#
sub _initialize {
  my $self = shift;
  %{$self} = ( %{$self}, @_ );

  # Messagetype must be request or response
  $self->{messagetype} = 'request'
    unless $self->{messagetype} and $self->{messagetype} eq 'response';
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Core::Message

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Core::Message
