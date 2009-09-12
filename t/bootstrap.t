#!perl -T

# Run only this test:
# prove -I../lib bootstrap.t

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS'); }

my $abfs = new ABFS;
isa_ok( $abfs, 'ABFS' );

# Make sure that command mode loads up
my $resp;
ok( ! $abfs->run_commands(), 'run_commands_none' );

# Make sure that help command can run
($resp) = $abfs->run_commands('load Command::Help', 'help');
ok( $resp, 'run_commands_help' );
diag "resp = $resp";
