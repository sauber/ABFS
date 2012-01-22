#!perl -T

# prove -I../lib storage-heap.t

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Storage::Heap'); }
BEGIN { use_ok('ABFS::Data::Block'); }
require_ok('ABFS::Storage::Heap');

my $device = new ABFS::Storage::Heap;
isa_ok( $device, 'ABFS::Storage::Heap' );

# Initially there are 0 keys
my $initsize = $device->usage;
ok( $initsize > 0, 'initial size > 0' );
my @list = $device->keys();
ok( @list == 0, 'blocklistisempty');

# Write a block
my $content = 'data';
my $block = new ABFS::Data::Block content=>$content;
my $key = $block->name;
ok( $device->set($block->name, $block), 'write1' );
ok( 1 == $device->keys, 'there is one block');
ok( $device->usage > $initsize, 'size is growing' );

# Read a block
ok( $key eq ($device->keys)[0], 'block name is unchanged' );
ok( $content eq $device->get($key)->content, 'block content is unchanged' );

# Delete a block
ok( $device->delete($key), 'block deleted' );
