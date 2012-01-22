#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Data::Block'); }
require_ok('ABFS::Data::Block');

my $data = "Hello World";

my $block = new ABFS::Data::Block content=>$data;
isa_ok( $block, 'ABFS::Data::Block' );

can_ok( $block, qw(content checksum name) );

# Verify content
ok( $data eq $block->content, 'blockdata');

# Verify name and checksum is same
ok( $block->name eq $block->checksum, 'blockkey' );
