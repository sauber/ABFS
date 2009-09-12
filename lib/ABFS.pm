package ABFS;
use MooseX::Singleton;

with 'ABFS::Role::Loader', 'ABFS::Role::Command';

=head1 NAME

ABFS - A Big File System

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

    use ABFS;

    my $abfs = ABFS->start();
    ...

=head1 FUNCTIONS

=head2 commandlist

  $abfs->commandlist();
  
Returns empty list, since this module does not have any commands. It just wants to run some.

=cut

sub commandlist { () }

=head2 start

  $abfs = ABFS->start(
    config => $config,
    commands => [ <startup_commands> ],
  );

Create a new ABFS object and start daemon and cli.

=cut

sub start {
  my ($self) = shift;
}

=head2 run_commands

Load core modules, and execute a list of commands.

  $abfs->run_commands("command1", "command2", ...);

=cut

sub run_commands {
  my($self,@commands) = @_;

  return unless @commands;
  my @results;
  for my $cmd ( @commands ) {
    push @results, $self->commandline( $cmd );
  }
  return @results;
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-abfs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ABFS>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ABFS>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ABFS>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ABFS>

=item * Search CPAN

L<http://search.cpan.org/dist/ABFS/>

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
1; # End of ABFS
