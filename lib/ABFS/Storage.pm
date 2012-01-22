package ABFS::Storage;
use MooseX::Method::Signatures;
use Moose::Role;
use Carp;

# Storage is a cache of blocks

# Required accessors
requires 'get', 'set', 'keys', 'exists', 'delete', 'usage';

requires 'location';
after 'location' => method (Str $newval) {
  croak "Store is neither local nor remote" unless $newval =~ /~(local|remote)$/;
};

1;
