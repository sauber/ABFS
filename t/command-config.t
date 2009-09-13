#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Command::Config'); }
require_ok('ABFS::Command::Config');

my $config = new ABFS::Command::Config;
isa_ok( $config, 'ABFS::Command::Config' );
isa_ok( $config, 'ABFS::Common::Loadable' );

can_ok( $config,
  qw(file command conf setmoduleconfig getmoduleconfig configread) );
#ok( !$config->conf(), 'noconfig' );

# This matches nothing, so nothing gets set
$config->setmoduleconfig( a => 1, 'b:a' => 2 );
ok( $config->conf(), 'nothingconfig' );

# Hard set a config option
$config->{config}{test} = 'Hello World';
my $opt;
ok( $opt = $config->conf(), 'getsomeconfig' );
ok( $opt->{config}{test} eq 'Hello World', 'gethelloworldconf' );

# Overwrite an option
$config->conf( test => 'Goodbye World' );
ok( $config->conf('test') eq 'Goodbye World', 'confoverwrite' );

# Read config commands from a string.
my @cmd = qw(test1 test2 test3);
my @msg;
ok( @msg = $config->configread( { configcmd => join "\n", @cmd } ), 'configread' );
ok( @msg == @cmd, '#requestmatchcmd' );
for my $n ( 0 .. $#cmd ) {
  ok( $msg[$n]{message} eq $cmd[$n], 'configcmdinmessage' );
  ok( $msg[$n]{messagetype} eq 'request', 'msgisrequest' );
}

# XXX: It would be nice to have a modulelist to test with also...
