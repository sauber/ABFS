#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS'); }
require_ok('ABFS');

my $abfs = new ABFS;
isa_ok( $abfs, 'ABFS' );
