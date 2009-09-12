#!perl -T

# Run only this test:
# prove -I../lib command-echo.t

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Command::Echo'); }
require_ok('ABFS::Command::Echo');

my $echo = new ABFS::Command::Echo;
isa_ok( $echo, 'ABFS::Command::Echo' );

