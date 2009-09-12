package ABFS::Module::Loader;
use MooseX::Singleton;

=head1 NAME

ABFS::Module::Loader - A list of ABFS modules loaded

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

has list => (
  is  => 'rw',
  isa => 'HashRef',
);

=head1 FUNCTIONS

=head2 add

  $modules = $self->add('ModuleName');

Load another module and all it's dependencies. Returns count of modules loaded.

=cut

sub add {
  my ($self) = @_;
}

=head2 del

  $self->del('ModuleName');

Unload self or other modules and dependencies. Return count of moduels unloaded.

=cut

sub del {
  my ($self) = @_;
}

=head2 get

  $self->get('ModuleName');

Get an instance of class ModuleName.

=cut

sub get {
  my ($self, $modulename) = @_;
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-abfs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ABFS::Module::Loader>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Module::Loader


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ABFS::Module::Loader>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ABFS::Module::Loader>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ABFS::Module::Loader>

=item * Search CPAN

L<http://search.cpan.org/dist/ABFS::Module::Loader>

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
1; # End of ABFS::Module::Loader
