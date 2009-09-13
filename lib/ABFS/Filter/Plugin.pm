package ABFS::Filter::Plugin;

use warnings;
use strict;
use ABFS::Core::Message;
use ABFS::Core::Constants;
use Carp;
use YAML::Syck qw(Load Dump);
use base ('ABFS::Common::Loadable');

=head1 NAME

ABFS::Filter::Plugin - Base module for request filters

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  my $self = shift;
  my $prop = Load <<EOF;
Depend:
 - Request
EOF
  $prop->{Hook} = [$self->hooklist() ];
  Dump $prop;
}

=head1 SYNOPSIS

  use ABFS::Filter::Plugin;

  my $filter = ABFS::Filter::Plugin->new();

=head1 DESCRIPTION

Defaults methods for filtering messages. Each method returns the message unchanged.

=head1 FUNCTIONS

=head2 hooklist

  my @hooks = $filter->hooklist();

List of hooks for this filter. Each hookname must match one or more of the
method names below.

=cut

sub hooklist { qw() } # No hooks in base plugin

=head2 before_NEW
        
  $message = $filter->before_NEW( $message );

Filter a message before entering NEW state.

=cut

sub before_NEW { return $_[1] }

=head2 after_NEW
        
  $message = $filter->after_NEW( $message );

Filter a message after entering NEW state.

=cut

sub after_NEW { return $_[1] }

=head2 before_ENQUEUED
        
  $message = $filter->before_ENQUEUED( $message );

Filter a message before entering ENQUEUED state.

=cut

sub before_ENQUEUED { return $_[1] }

=head2 after_ENQUEUED
        
  $message = $filter->after_ENQUEUED( $message );

Filter a message after entering ENQUEUED state.

=cut

sub after_ENQUEUED { return $_[1] }

=head2 before_RETRYWAIT
        
  $message = $filter->before_RETRYWAIT( $message );

Filter a message before entering RETRYWAIT state.

=cut

sub before_RETRYWAIT { return $_[1] }

=head2 after_RETRYWAIT
        
  $message = $filter->after_RETRYWAIT( $message );

Filter a message after entering RETRYWAIT state.

=cut

sub after_RETRYWAIT { return $_[1] }

=head2 before_PROCESSING
        
  $message = $filter->before_PROCESSING( $message );

Filter a message before entering PROCESSING state.

=cut

sub before_PROCESSING { return $_[1] }

=head2 after_PROCESSING
        
  $message = $filter->after_PROCESSING( $message );

Filter a message after entering PROCESSING state.

=cut

sub after_PROCESSING { return $_[1] }

=head2 before_RESPONSEWAIT
        
  $message = $filter->before_RESPONSEWAIT( $message );

Filter a message before entering RESPONSEWAIT state.

=cut

sub before_RESPONSEWAIT { return $_[1] }

=head2 after_RESPONSEWAIT
        
  $message = $filter->after_RESPONSEWAIT( $message );

Filter a message after entering RESPONSEWAIT state.

=cut

sub after_RESPONSEWAIT { return $_[1] }

=head2 before_RESPONDING
        
  $message = $filter->before_RESPONDING( $message );

Filter a message before entering RESPONDING state.

=cut

sub before_RESPONDING { return $_[1] }

=head2 after_RESPONDING
        
  $message = $filter->after_RESPONDING( $message );

Filter a message after entering RESPONDING state.

=cut

sub after_RESPONDING { return $_[1] }

=head2 before_EXPIRED
        
  $message = $filter->before_EXPIRED( $message );

Filter a message before entering EXPIRED state.

=cut

sub before_EXPIRED { return $_[1] }

=head2 after_EXPIRED
        
  $message = $filter->after_EXPIRED( $message );

Filter a message after entering EXPIRED state.

=cut

sub after_EXPIRED { return $_[1] }

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Plugin

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Filter::Plugin



