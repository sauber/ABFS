#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Core::Block'); }
require_ok('ABFS::Core::Block');

my $data = "Hello World";

my $block = new ABFS::Core::Block content=>$data;
isa_ok( $block, 'ABFS::Core::Block' );

can_ok( $block, qw(content checksum name) );

# Verify content
ok( $data eq $block->content, 'blockdata');

# Verify name and checksum is same
ok( $block->name eq $block->checksum, 'blockkey' );
