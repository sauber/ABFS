package ABFS::Core::DependencyTree;

use warnings;
use strict;
use Carp;

=head1 NAME

ABFS::Core::DependencyTree - Dependency tree of nodes

=head1 VERSION

$Revision: 9 $

=cut

our $VERSION = do { my @r = ( q$Revision: 9 $ =~ /\d+/g ); sprintf "%d." . "%02d" x $#r, @r };

=head1 SYNOPSIS

  use ABFS::Core::DependencyTree;

  my $tree = ABFS::Core::DependencyTree->new();

=head1 DESCRIPTION

Container for nodes. Upwards and downwards dependency kept.

=head1 FUNCTIONS

=head2 new

  Generate empty tree

  $tree = new( );

=cut

sub new {
  my $type = shift;
  $type = ref $type if ref $type;
  my $this = {};
  bless $this, $type;
}

=head2 addnode

  $tree->addnode( $nodename, $obj, $depend_on1, $depend_on2, ... );

Add a new nodes. Register what other nodes it depends on.

If dependants are not already registered, then node is not added.

=cut

sub addnode {
  my ( $self, $nodename, $obj, @depend_on ) = @_;

  # Verify dependencies are met
  if (@depend_on) {
    for my $d (@depend_on) {
      #return unless $self->{list}{$d};
      unless ( $self->{list}{$d} ) {
        #warn "$nodename cannot depend on $d, because $d not registered\n";
        return undef;
      }
    }
  }

  # Add new node
  $self->{list}{$nodename}{obj}  = $obj;
  $self->{list}{$nodename}{name} = $nodename;

  # Add all dependencies
  if (@depend_on) {
    for my $d (@depend_on) {
      $self->{list}{$nodename}{dep}{$d} = $self->{list}{$d};
    }
  }

  return 1;
}

=head2 removenode

  $tree->removenode( $nodename );

Remove a node, if it does not have other nodes depending on it,
and if itself does not depend on other nodes.

If node can be removed, returns object reference for last change to clean
up.

=cut

sub removenode {
  my ( $self, $nodename ) = @_;

  #warn "Deleting node $node ...\n"; # XXX: debug
  # Does node have depencies
  return if keys %{ $self->{list}{$nodename}{dep} };

  #warn "   ... no depencies ...\n"; # XXX: debug

  # Other nodes depend on me?
  for my $m ( keys %{ $self->{list} } ) {
    return if $self->{list}{$m}{dep}{$nodename};
  }

  #warn "   ... no dependants ...\n"; # XXX: debug

  # Free of depencies. Delete and return.
  #warn "Deleting node $node succesfull\n"; # XXX: debug
  my $obj = $self->{list}{$nodename}{obj};
  delete $self->{list}{$nodename};
  return $obj;
}

=head2 removerecursive

  my @modulesremoved = $tree->removerecursive( $nodename );

Remove a node and all it's dependancies.

If the node, or any of it's depancies are dependancies of other objects,
then stop,

Returns list of modules removed: 

  ( nodename=>$obj, nodename=>$obj, ... }

=cut

sub removerecursive {
  my ( $self, $nodename ) = @_;

  #warn "recursive remove $node ...\n"; # XXX: debug
  # Other nodes depend on me?
  for my $m ( keys %{ $self->{list} } ) {
    return () if $self->{list}{$m}{dep}{$nodename};
  }

  #warn "   ... no dependants ...\n"; # XXX: debug

  # Keep list of removed nodes;
  my @removed;

  # If I have depencies, remove them.
  # They are removed from my dependency list, but not necessarily from
  # other nodes list, so they may or may not disappear from tree.
  if ( $self->{list}{$nodename}{dep} ) {
    for my $d ( keys %{ $self->{list}{$nodename}{dep} } ) {
      delete $self->{list}{$nodename}{dep}{$d};

      #$self->removerecursive($d);
      push @removed, $self->removerecursive($d);
    }
  }

  #warn "   ... dependencies (@removed) removed for $node ...\n"; # XXX: debug

  # Remove myself
  #delete $self->{list}{$node};
  #return 1;
  # Remove myself. Compile list of all removed nodes.
  if ( my $obj = $self->removenode($nodename) ) {
    unshift @removed, $nodename, $obj;
  }
  return @removed;
}

=head2 numnodes

  $tree->numnodes()

Number of nodes in tree

=cut

sub numnodes {
  my $self = shift;

  return scalar keys %{ $self->{list} };
}

=head2 exists

  $tree->exists($nodename);

Verify if a node is present in tree.

=cut

sub exists {
  my ( $self, $nodename ) = @_;

  return exists $self->{list}{$nodename};
}

=head2 nodenames

  @names = $tree->nodenames();

Generate list of node names;

=cut

sub nodenames {
  my $self = shift;

  return keys %{ $self->{list} };
}

=head2 nodelist

  @nodes = $tree->nodelist();

Generate list of all nodes

=cut

sub nodelist {
  my $self = shift;

  return values %{ $self->{list} };
}

=head2 nodeobjs

  @nodes = $tree->nodeobjs();

Generate list of all node objects

=cut

sub nodeobjs {
  my $self = shift;

  return map $_->{obj}, $self->nodelist();
}

=head2 getobj

  my $obj = $tree->getobj( $nodename );

Get object of nodename

=cut

sub getobj {
  my ( $self, $nodename ) = @_;

  return $self->{list}{$nodename}{obj} || undef;
}

=head2 dependencylist

List all dependencies:

  (
    [ module1 => module2 ],
    [ module1 => module3 ],
    [ module2 => module3 ],
    ...
  )

=cut 

sub dependencylist {
  my $self = shift;

  my @list;
  for my $parent ( $self->nodenames ) {
    for my $child ( keys %{ $self->{list}{$parent}{dep} } ) {
      push @list, [ $parent => $child ];
    }
  }
  return @list;
}
  

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Nothing is working at this point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ABFS::Core::DependencyTree

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Soren Dossing, all rights reserved.

This library is not free software. Distribution and modification is
prohibited.

=cut

1;    # End of ABFS::Core::DependencyTree
