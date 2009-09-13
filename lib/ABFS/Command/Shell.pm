package ABFS::Command::Shell;
#use ABFS::IO::Filesys;
use base ('ABFS::Command::Plugin');

=head1 NAME

ABFS::Command::Shell - Shell type commands to access files

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Command:
  cd:
    syntax: string
    summary: change current dir
    description: change working dir for new file operations
  ls:
    syntax: string
    summary: list files
    description: list files in current dir, or in specified dir

Depend:
 - Command
 - IO::Filesys

EOF
}

#sub _initialize {
#  my $self = shift;
#
#  $self->{pwd} = '/';
#  #$self->{fs} = $self->{modules}->getobj('IO::Filesys');
#}

=head1 SYNOPSIS

  use ABFS::Command::Shell;

  my $shell = ABFS::Command::Shell->new();

=head1 DESCRIPTION

Shell commands to view and manipulate filesystem

=head1 FUNCTIONS

=head2 cd

  $pwd = $shell->cd( $string );

Change or list current working dir.

=cut

sub cd {
  my ( $self, $dir ) = @_;

  $self->{pwd} = $dir if $dir;
  return $self->{pwd};
}

=head2 ls

  my @list = $shell->ls( $dir );

List file in current working dir or specified dir.

=cut

sub ls {
  my($self, $dir) = @_;

  my $fs = $self->{modules}->getobj('IO::Filesys');
  my @list = $fs->list( $dir || $self->{pwd} );
  return "@list";
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Shell

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command::Shell
