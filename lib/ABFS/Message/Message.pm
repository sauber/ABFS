package ABFS::Message::Message;
use Moose;

=head1 NAME

ABFS::Message::Message - A message is communication from one module to another. Messages can be queued and send to other nodes as packets.

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

has content => (
  is  => 'rw',
  isa => 'Str',
);

=head1 FUNCTIONS

=head2 size

  $bytes = $self->size();

Size of content.

=cut

sub size {
  my ($self) = @_;

  length( $self->content );
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-abfs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ABFS::Message::Message>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Message::Message


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ABFS::Message::Message>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ABFS::Message::Message>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ABFS::Message::Message>

=item * Search CPAN

L<http://search.cpan.org/dist/ABFS::Message::Message>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Soren Dossing.

This program is free software; you can redistribute it and/or modify it
under the terms the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

no Moose;
__PACKAGE__->meta->make_immutable;
1; # End of ABFS::Message::Message
