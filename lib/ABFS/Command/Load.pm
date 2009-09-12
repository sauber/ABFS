package ABFS::Command::Load;
use MooseX::Singleton;
#use Moose;
with 'ABFS::Role::Command', 'ABFS::Role::Loader';

=head1 NAME

ABFS::Command::Load - An echo command. Returns same message as was sent to it.

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 FUNCTIONS

=head2 commandlist

  @list = $self->commandlist();

Returns the list of commands this modules handles. In this case: qw(load unload);

=cut

sub commandlist { qw(load unload) }

=head2 load

  $self->load("ModuleName");

Process a request. Returns message as a response to sender.

=cut

sub load {
  my ($self, $module) = @_;

  warn "Runing $self ::load with $module arg\n";
  my $count = $self->loadmodule($module);
  warn "Loaded $count new modules\n";
  return "Loaded $count new modules";
}

=head2 unload

  $self->unload('OtherModuleName');

TODO: Unload a module?

=cut

sub unload {
  my($self, $modulename) = @_;

  # XXX: unregister commands
  # XXX: What else?
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-abfs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ABFS::Command::Load>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Load


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ABFS::Command::Load>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ABFS::Command::Load>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ABFS::Command::Load>

=item * Search CPAN

L<http://search.cpan.org/dist/ABFS::Command::Load>

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
1; # End of ABFS::Command::Load
