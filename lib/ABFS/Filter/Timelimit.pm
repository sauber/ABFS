package ABFS::Filter::Timelimit;
use base ('ABFS::Filter::Plugin');

=head1 NAME

ABFS::Filter::Timelimit - Drop tool old requests and requests from the future

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

#sub _properties {
#  <<EOF;
#Depend:
# - Request
#EOF
#}

=head1 SYNOPSIS

  use ABFS::Filter::Timelimit;

  my $filter = ABFS::Filter::Timelimit->new();

=head1 DESCRIPTION

Before enqueueing, timestamp is checked. If the request is from the future, clock differences taken into consideration, the messahe is dropped. Same, if it's too old. If there is no timestamp, then one is added.

Same filtering happens before processing.

=head1 FUNCTIONS

=head2 hooklist

  my @hooks = $filter->hooklist();

Names of hooks for this filter.

=cut

sub hooklist {
  return qw(before_ENQUEUED before_PROCESSING);
}

=head2 before_ENQUEUED
        
  $message = $filter->before_ENQUEUED( $message );

Filter a message before entering ENQUEUED state.

=cut

sub before_ENQUEUED { return $_[1] }

=head2 before_PROCESSING
        
  $message = $filter->before_PROCESSING( $message );

Filter a message before entering PROCESSING state.

=cut

sub before_PROCESSING { return $_[1] }


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Timelimit

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Filter::Timelimit



