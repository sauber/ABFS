package ABFS::Command::Echo;
#use MooseX::Singleton;
use Moose;
with 'ABFS::Role::Command';

=head1 NAME

ABFS::Command::Echo - An echo command. Returns same message as was sent to it.

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

has list => (
  is  => 'rw',
  isa => 'HashRef',
);

=head1 FUNCTIONS

=head2 commandlist

  @list = $self->commandlist();

Returns the list of commands this modules handles. In this case: 'echo';

=cut

sub commandlist { 'echo' }

=head2 handlerequest

  $self->handlerequest($request);

Process a request. Returns message as a response to sender.

=cut

sub handlerequest {
  my ($self, $request) = @_;

  return makeresponse(
    content => $request->content,
    to => $request->sender,
  );
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-abfs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ABFS::Command::Echo>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Echo


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ABFS::Command::Echo>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ABFS::Command::Echo>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ABFS::Command::Echo>

=item * Search CPAN

L<http://search.cpan.org/dist/ABFS::Command::Echo>

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
1; # End of ABFS::Command::Echo
