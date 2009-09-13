package ABFS::Filter::Messagetype;
use base ('ABFS::Filter::Plugin');

=head1 NAME

ABFS::Filter::Messagetype - Drop messages that are not of
type request or response.

=head1 VERSION

$Revision$

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

#sub _properties {
#  <<EOF;
#Depend:
# - Request
#EOF
#}

=head1 SYNOPSIS

  use ABFS::Filter::Messagetype;

  my $filter = ABFS::Filter::Messagetype->new();

=head1 DESCRIPTION

Before enqueueing, verify that messagetype property is either
request or response. Drop any messages that are not.

Same filtering happens before processing.

=head1 FUNCTIONS

=head2 hooklist

  my @hooks = $filter->hooklist();

Names of hooks for this filter.

=cut

sub hooklist {
  return qw(before_ENQUEUED);
}

=head2 before_ENQUEUED
        
  $message = $filter->before_ENQUEUED( $message );

Filter a message before entering ENQUEUED state.

=cut

sub before_ENQUEUED {
  my($self,$message) = @_;

  return 'EXPIRED' unless $message->{messagetype};
  return 'EXPIRED' unless $message->{messagetype} eq 'request'
                       or $message->{messagetype} eq 'response';
  return $message;
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Messagetype

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Filter::Messagetype



