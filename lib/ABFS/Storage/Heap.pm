# Store blocks in process heap memory

package ABFS::Storage::Heap;

use ABFS::Data::Block;
use MooseX::Method::Signatures;
use Moose;
use Devel::Size qw(total_size);

method location { 'local' }

# Use hash trait for accessor subs
#
has '_blocks' => (
  traits    => ['Hash'],
  is        => 'ro',
  isa       => 'HashRef[ABFS::Data::Block]',
  default   => sub { {} },
  handles   => {
    set => 'set',
    get => 'get',
    exists => 'exists',
    keys => 'keys',
    delete => 'delete',
  },
);

# Traverses all blocks to find size
#
method usage { total_size $self }

#with 'ABFS::Storage'; # XXX this breaks

__PACKAGE__->meta->make_immutable;
 
1;
