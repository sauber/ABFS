#!perl -T

# prove -I../lib device-heap.t

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Device::Heap'); }
require_ok('ABFS::Device::Heap');

my $device = new ABFS::Device::Heap;
isa_ok( $device, 'ABFS::Device::Heap' );
isa_ok( $device, 'ABFS::Device::Plugin' );

# Reference to list
my $list = $device->blocklist();
ok( ref $list eq 'ARRAY', 'blocklistislist');
ok( @$list == 0, 'blocklistisempty');
ok( 0 == $device->usage(), 'size0' );

# Write, stat, read, delete
ok( 1 == $device->write(1,'a'), 'write1' );
ok( 1 == $device->write(2,'b'), 'write2' );
ok( 1 == $device->write(3,'c'), 'write3' );
ok( 0 == $device->write(4), 'write4' );
ok( 0 == $device->write(), 'writenothing' );
ok( 3 == @{$device->blocklist()}, 'list3' );
ok( 6 == $device->usage(), 'size6' );
ok( 1 == $device->stat(1), 'stat1' );
ok( 2 == $device->stat(1, 2), 'stat2' );
ok( 3 == $device->stat(1, 2, 3), 'stat3' );
ok( 0 == $device->stat(4, 5, 6), 'statnot3' );
ok( 1 == $device->stat(4, 1, 6), 'statmix3' );
ok( 'a' eq $device->read(1), 'read1' );
ok( 'b' eq $device->read(2), 'read1' );
ok( 'c' eq $device->read(3), 'read1' );
ok( ! $device->read(4), 'read1' );
ok( 1 == $device->delete(1), 'delete1' );
ok( 1 == $device->delete(2), 'delete2' );
ok( 1 == $device->delete(3), 'delete3' );
ok( 0 == @{$device->blocklist()}, 'list0' );
ok( 0 == $device->usage(), 'size0' );

# Writenew
ok( 1 == $device->writenew(1,'a'), 'writenewa' );
ok( 0 == $device->writenew(1,'b'), 'writenewb' );
ok( 'a' eq $device->read(1), 'read1' );

# Resize, with POE
ok( 1 == $device->write(1,'a'), 'write1' );
ok( 1 == $device->write(2,'b'), 'write2' );
ok( 1 == $device->write(3,'c'), 'write3' );

$device->resize(5);
#POE::Kernel->run();
ok( 4 == $device->usage, 'resize5' );
$device->resize(1);
#POE::Kernel->run();
ok( 0 == $device->usage, 'resize1' );
