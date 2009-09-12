package ABFS::Role::Command;
use Moose::Role;
with 'ABFS::Role::Message';
use ABFS::Command::Register;

=head1 NAME

ABFS::Role::Command - Give modules ability to execute commands from cli, startup scripts, config etc.

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

has commandregister => (
  isa => 'ABFS::Command::Register',
  is  => 'rw',
  default => sub { new ABFS::Command::Register },
);

sub BUILD {
  my($self) = @_;

  warn "Running $self ::BUILD\n"; # XXX debug
  $self->register( $self->commandlist );
};

requires 'commandlist';

=head1 FUNCTIONS

List of functions in this module.

=head2 register

  $self->register( @commands );

Register commands executed in this module.

=cut

sub register {
  my($self, @commands) = @_;

  warn "Running $self ::register\n"; # XXX debug
  for my $cmd ( @commands ) {
    #warn "Register $cmd for $self\n"; # XXX: debug
    #my $code = sub { $self->$cmd( @_ ) };
    #warn "Coderef is $code\n"; # XXX debug
    #use Data::Dumper;
    #warn Dumper $code;
    #warn "Calling $code: " . ( &$code() || '' ) . "\n" ;
    $self->{commandregister}{register}{ $cmd } = $self;
  }
}

=head2 args

  $self->args($str);

Parse command and arguments out of commandline.

=cut

sub args {
  my ($self, $line) = @_;

  # XXX: Consider quoting
  #my @words = split /\s+/, $line;
  #shift @words; # First word is the command
  #@words;       # All other words are parameters
  split /\s+/, $line;
}

=head2 commandline

  $self->commandline( $line );

Execute a command line.
Take a command as a string. Parses it into command and arguments. Creates a request.and put into request queue. When response is recieve it will unpack and send back to sender as text output.

=cut

sub commandline {
  my ($self, $line) = @_;

  my($command, @args) = $self->args( $line );
  # For now skip the request system. Just execute the command.
  warn "Now executing $line\n"; # XXX: debug
  use Data::Dumper;
  warn Dumper $command;
  warn Dumper \@args;
  $self->callcommand( $command, @args );
  return $command;
}

=head2 callcommand

  $result = $self->callcommand(@args);

Find modules the implements command, and run it

=cut

sub callcommand {
  my($self, $cmd, @args) = @_;

  warn 'cmd: ' . Dumper $cmd;
  warn 'args: ' . Dumper \@args;
  warn 'sub: ' . Dumper $self->{commandregister}{register};
  if ( my $obj = $self->{commandregister}{register}{ $cmd } ) {
    warn "could find $cmd obj $obj\n"; # XXX: debug
    #warn &$cb( @args ); # XXX: debug
    warn "Calling $obj ::$cmd: " . ( $obj->{$cmd}( @args ) || '' ) . "\n" ;
  } else {
    warn "could not find $cmd\n"; # XXX: debug
  }
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-abfs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ABFS::Role::Command>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Role::Command


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ABFS::Role::Command>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ABFS::Role::Command>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ABFS::Role::Command>

=item * Search CPAN

L<http://search.cpan.org/dist/ABFS::Role::Command>

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
1; # End of ABFS::Role::Command
