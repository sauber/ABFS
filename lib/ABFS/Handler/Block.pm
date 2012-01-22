# Retrieves and Stores blocks

package ABFS::Handler::Block;

use ABFS::Storage;
use ABFS::Storage::Heap;
use ABFS::Data::Message;
use ABFS::Data::Block;
use MooseX::Method::Signatures;
use Moose;

method service { 'block' }

has storages => ( is=>'ro', isa=>'ArrayRef[ABFS::Storage]', default=>sub{[]} );

# Retrives a block from some storage
#
method get ( ABFS::Data::Message $msg ) {
  my $key = $msg->header->{blockid};
  my $shelf = $self->storages;

  for my $store ( @$shelf ) {
    if ( my $block = $store->get($key) ) {
      my $resp = new ABFS::Data::Message exchange=>'response', header=>{blockid=>$key}, content=>$block->content;
      return $resp;
    }
  }

  return undef; # Block not found
}

# Stores a block in some storage
#
method post ( ABFS::Data::Message $msg ) {
  my $block = new ABFS::Data::Block content => $msg->content;
  my $key = $msg->header->{blockid};
  $self->best_storage->set( $key, $block );
}

# Pick the best storage for next block
# For now just a random storage
#
method best_storage {
  # Create a storage if none exists
  my $shelf = $self->storages;
  if ( 0 == @$shelf ) {
    $shelf->[0] = new ABFS::Storage::Heap;
  }

  return $shelf->[int rand @$shelf];
}

with 'ABFS::Handler'; # XXX this breaks

__PACKAGE__->meta->make_immutable;
 
1;

