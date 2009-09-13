#!perl -T

# prove -I../lib device-common.t

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Device::Plugin'); }
require_ok('ABFS::Device::Plugin');

my $device = new ABFS::Device::Plugin;
isa_ok( $device, 'ABFS::Device::Plugin' );
isa_ok( $device, 'ABFS::Common::Loadable' );

# Device operations
can_ok( $device, qw(blocklist size resize usage) );
# Block operations
can_ok( $device, qw(read write writenew stat touch) );
