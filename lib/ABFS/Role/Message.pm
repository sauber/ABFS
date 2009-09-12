package ABFS::Role::Message;
use Moose::Role;

=head1 NAME

ABFS::Role::Message - Give modules ability to send and recieve messages

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

has messagequeue => (
  is  => 'rw',
  isa => 'ABFS::Request::Queue',
);

=head1 FUNCTIONS

=head2 makerequest

  $self->makerequest($request);

Generate a request to another module.

=cut

sub makerequest {
  my ($self, %param) = @_;

  ABFS::Message::Request->new(
    content => $param{content},
    to      => $param{to},
  );
}

=head2 handlerequest

  $self->handlerequest($request);

Process a request arriving to module.

=cut

# Default is to respond that request is processed.
#
sub handlerequest {
  my ($self, $request) = @_;

  $self-makeresponse( request=> $request );
}

=head2 makeresponse

  $self->makeresponse($request);

Generate a response to another module.

=cut

sub makeresponse {
  my ($self, %param) = @_;

  ABFS::Message::Response->new( %param );
}

=head2 handleresponse

  $self->handleresponse($request);

Generate a request to another module.

=cut

# Do nothing with the responses.
# XXX: log that reponse arrived, but is not handled?
#
sub handleresponse {
  my ($self, $response) = @_;

  return ();
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-abfs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ABFS::Role::Message>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Role::Message


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ABFS::Role::Message>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ABFS::Role::Message>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ABFS::Role::Message>

=item * Search CPAN

L<http://search.cpan.org/dist/ABFS::Role::Message>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Soren Dossing.

This program is free software; you can redistribute it and/or modify it
under the terms the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

no Moose;
#__PACKAGE__->meta->make_immutable;
1; # End of ABFS::Role::Message
