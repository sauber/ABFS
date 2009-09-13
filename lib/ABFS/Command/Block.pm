package ABFS::Command::Block;
use base ('ABFS::Command::Plugin');

=head1 NAME

ABFS::Command::Block - Read, Write and Stat data blocks

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Command:
  readblock:
    summary:
    description:
    syntax:
  statblock:
    summary:
    description:
    syntax:
  writeblock:
    summary:
    description:
    syntax:

Depend:
 - Core::Devicelist
EOF
}

sub _commandhelp {
  <<EOF;
Commands:
EOF
}

=head1 SYNOPSIS

  use ABFS::Command::Block;

  my $block = ABFS::Command::Block->new();

=head1 DESCRIPTION

Write data blocks to devices, reads datablocks and stats to check data
blocks are available.

=head1 FUNCTIONS

=head2 writeblock

  $cmd->writeblock({ blockid=>$blockid, blockdata=>$data, %options });
  $cmd->writeblock({ blockid=>$blockid, blockdata=>$dataref, %options });

Write a data block to devices suitable by criteria given.

=cut

sub writeblock {
  my($self,@args) = @_;

  return undef unless $self->{modules};
  my %optn = %{$args[0]};
  @suitable = $self->{modules}->getobj('Core::Devicelist')->devicematch();
  #use Data::Dumper;
  #return "Suitable devices: " . Dumper \@suitable;
  return "No suitable devices available" unless @suitable;
  my $chosen = $suitable[0];
  my $written = $chosen->{device}->write($args[0]{blockid}, $args[0]{blockdata});
  if ( $written ) {
    return "Data written to $chosen->{name}";
  } else {
    return "Could not write data";
  }
}

=head2 readblock

  $cmd->readblock({ blockid=>$blockid, %options });

Reads a datablock from one or more devices suitable by criteria given.

=cut

sub readblock {
  my($self,@args) = @_;

  return undef unless $self->{modules};
  my %optn = %{$args[0]};
  @suitable = $self->{modules}->getobj('Core::Devicelist')->devicematch();
  # Get list of all devices having block
  #my @have;
  for my $cand ( @suitable ) {
    my $data = $cand->{device}->read($args[0]{blockid});
    return $data if $data;
  }
  return "Block $args[0]{blockid} not available";
}

=head2 statblock

  $cmd->statblock({ blockid=>\@blocklist, %options });

Stats a list of datablock from devices suitable by criteria given.

=cut

sub statblock {
  my($self,@args) = @_;

  return undef unless $self->{modules};
  my %optn = %{$args[0]};
  @suitable = $self->{modules}->getobj('Core::Devicelist')->devicematch();
  # Get list of all devices having block
  my @have;
  for my $cand ( @suitable ) {
    push @have, $cand->{name} if $cand->{device}->stat($args[0]{blockid});
  }
  return "Block $args[0]{blockid} available on: @have";
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Block

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command::Block
