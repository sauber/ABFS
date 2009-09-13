package ABFS::Core::Constants;

use warnings;
use strict;
our @ISA    = qw(Exporter);
our @EXPORT = qw(SUCCESS TEMPFAILURE PERMFAILURE ASYNC);

=head1 NAME

ABFS::Core::Constants - A Big File System Constants

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::Core::Constants;

=head1 DESCRIPTION

Defines constants, such as return values

=head1 CONSTANTS

=head2 SUCCESS

A request is successfully completed.

=cut

use constant SUCCESS => 2;

=head2 TEMPFAILURE

A request temporarily failed. It wont be retried, but requester is encouraged
to submit request again.

=cut

use constant TEMPFAILURE => 3;

=head2 PERMFAILURE

A request permanently failed. Requester should not submit request again.

=cut

use constant PERMFAILURE => 4;

=head2 ASYNC

A request will be attempted to be completed asyncronously. Results will be
posted later, or request will timeout.

=cut

use constant ASYNC => 5;

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Core::Constants

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Core::Constants
