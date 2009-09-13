#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Command::Echo'); }
require_ok('ABFS::Command::Echo');

my $echo = new ABFS::Command::Echo;
isa_ok( $echo, 'ABFS::Command::Echo' );

can_ok( $echo, qw(echo) );

my $msg = 'hello world';
my $res = $echo->echo($msg);
ok( $msg eq $res, "responseeqrequest" );

my @msg = qw(hello world);
$res = $echo->echo(@msg);
ok( $res eq join(' ', @msg), "joinresponseeqrequest" );

