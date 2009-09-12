package ABFS::Role::Loader;
use Moose::Role;
use ABFS::Command::Load;
use Module::Load;

=head1 NAME

ABFS::Role::Loader - Let modules have role to load and unload themselves and other.

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

#has modulelist => (
#  is  => 'rw',
#  isa => 'HashRef[ABFS::Type::ModuleList]',
#);

# Make sure load command is loaded right away

has loadcommand => (
  is      => 'ro',
  isa     => 'ABFS::Command::Load',
  default => sub { new ABFS::Command::Load },
);

=head1 FUNCTIONS

=head2 loadmodule

  $modulesloaded = $self->loadmodule('OtherModule');

Load another module and all it's dependencies. Returns count of modules loaded.

=cut

sub loadmodule {
  my ($self, $modulename) = @_;

  $modulename = 'ABFS::' . $modulename;
  warn "Load $modulename with Module::Load\n"; # XXX debug
  laod $modulename;
  my $obj = $modulename->new();
}

=head2 unloadmodule

  $self->unloadmodule();
  $self->unloadmodule('OtherModule');

Unload self or other modules and dependencies. Return count of moduels unloaded.

=cut

sub unloadmodule {
  my ($self) = @_;
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-abfs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ABFS::Role::Loader>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Role::Loader


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ABFS::Role::Loader>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ABFS::Role::Loader>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ABFS::Role::Loader>

=item * Search CPAN

L<http://search.cpan.org/dist/ABFS::Role::Loader>

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
1; # End of ABFS::Role::Loader
