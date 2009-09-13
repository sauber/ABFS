package ABFS::Command::Mount;
use base ('ABFS::Command::Plugin');
use Module::Load;
use Text::Table;

=head1 NAME

ABFS::Command::Mount - Mount and inspect block devices

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

sub _properties {
  <<EOF;
Command:
  devicelist:
    summary: List of mounted devices
    description: ID, Name, Size, Type and mountpoint for all mounted devices
    syntax:
  mount:
    summary: Mounts a device
    description: Mount device of specified type on requested mountpoint
    syntax: type=<type> name=<name> <mountpoint>

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

  use ABFS::Command::Mount;

  my $devcmd = ABFS::Command::Mount->new();

=head1 DESCRIPTION

Controls block devices, such as creating, deleting, enabling, disabling
and listing.

=head1 FUNCTIONS

=head2 devicelist

  $devcmd->devicelist($message);

Display list of created devices.

=cut

sub devicelist {
  my ( $self, $message ) = @_;

  return "No modules available" unless $self->{modules};
  my $devs = $self->{modules}->getobj('Core::Devicelist')->{devices};
  my $tb = Text::Table->new(
    qw(ID Name Type Size Mountpoint)
  );
  $tb->load(
    map{[
      $devs->{$_}{id},
      $devs->{$_}{name},
      $devs->{$_}{type},
      $devs->{$_}{device}->usage(),
      $devs->{$_}{mountpoint},
    ]}
    sort { $a <=> $b } keys %$devs
  );
  #$self->makeresponse( $message, message => "No devices created" ) unless $self->{devices};
  #$self->makeresponse( $message, message => sprintf $tb );
  sprintf $tb;
}

=head2 mount

  $devcmd->mount(@args);
  $devcmd->mount("/", {type=>heap, name=>memory});

Create a new block device. Returns a uniq mount id.

=cut

sub mount {
  my ( $self, @args ) = @_;

  return "No modules available" unless $self->{modules};
  my $id = $self->{modules}->getobj('Core::Devicelist')->mount(
    mount=>$args[0],
    %{ $args[1] },
  );
  my $type = $args[-1]{type};
  my $name = $args[-1]{name};
  if ( defined $id ) {
    return "$name ($id:$type) mounted on $args[0]";
  } else {
    return "Device could not be mounted";
  }
}


=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Command::Mount

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Command::Mount
