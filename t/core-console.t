#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Core::Console'); }
require_ok('ABFS::Core::Console');

# Create a dummy wheel necessary for testing
my $wheel = eval {
  package ABFS::Core::Wheel;
  my $singleton;
  sub new { $singleton = bless {}, shift }
  sub put { 1 };
  sub AUTOLOAD { *{$AUTOLOAD} = sub {}; undef }
  __PACKAGE__;
}->new();

# XXX: This generates a warning:
#      "Console wheel already spawned at t/console.t"
my $console = ABFS::Core::Console->new( wheel => $wheel );
isa_ok( $console, 'ABFS::Core::Console' );
isa_ok( $console, 'ABFS::Common::Requestable' );

can_ok( $console, qw(spawn consoleinput response exit) );

ok( $console->response( { message=>'hello world'} ), 'consoleresponse');
POE::Kernel->run();
