package ABFS::Message::Queue;
use MooseX::Singleton;

=head1 NAME

ABFS::Message::Queue - A queue of mssagess waiting to be processed or awaiting responses

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

has queue => (
  is =>  'rw',
  isa => 'ArrayRef[ABFS::Request::Message]',
  handles => {
    'add'  => 'push',
    'next' => 'pop',
  },
);

=head1 FUNCTIONS

=head2 add

  $self->add($message);

Add messages to end of queue.

=cut

#sub add {
#  my ($self, @messages) = @_;
#
#  $self->queue->push(@messages);
#  # XXX: If the count changed from 0 to more than 0 then wake up Router process messages
#}

=head2 next

  $message = $self->next();

Get message from queue to process.

=cut

#sub next {
#  my ($self, $message) = @_;
#
#  $self->queue->pop;
#}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-abfs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ABFS::Message::Queue>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Message::Queue


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ABFS::Message::Queue>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ABFS::Message::Queue>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ABFS::Message::Queue>

=item * Search CPAN

L<http://search.cpan.org/dist/ABFS::Message::Queue>

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
1; # End of ABFS::Message::Queue
