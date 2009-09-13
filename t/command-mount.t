#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Command::Mount'); }
require_ok('ABFS::Command::Mount');

my $cmd = new ABFS::Command::Mount;
isa_ok( $cmd, 'ABFS::Command::Mount' );

can_ok( $cmd, qw(devicelist mount) );

# Verify that devicelist command is registered
ok( exists $cmd->{config}{Command}{devicelist},   'devicelistiscommand' );

# Test that module can be loaded/unloaded by loader
use ABFS::Core::Loader;
my $loader = new ABFS::Core::Loader;
my @loadok = $loader->add('Command::Mount');
ok( scalar @loadok > 0, 'moduleloaded' );
ok( $loadok[0] eq 'Command::Mount', 'moduleisloadercmd' );
my @unloadok = $loader->del('Command::Mount');
ok( scalar @unloadok > 0, 'moduleunloaded' );
#diag "unload is " . $unloadok[0];
#ok( $unloadok[0] eq 'Command::Mount', 'unloadisloadercmd' );

# Mount some devices
#for my $id ( 0 .. 2 ) {
#  my $req = $cmd->makerequest( command => 'mount', options => {type=>'heap', name=>'memory'}, arguments=>['/'] );
#  my $res = $cmd->request($req);
#  #use Data::Dumper;
#  #warn Dumper $res;
#  ok( $id == $res->{message}{id}, 'id0' );
#  ok( 'heap' eq $res->{message}{type}, 'typeheap' );
#  ok( 'memory' eq $res->{message}{name}, 'namememory' );
#  ok( '/' eq $res->{message}{mountpoint}, '/mountpoint' );
#}
#my $req = $cmd->makerequest( command => 'mount', options => {type=>'invaliddevice', name=>'memory'}, arguments=>['/'] );
#my $res = $cmd->request($req);
#ok( 'Invalid device' eq $res->{message}, 'Invaliddevice' );
#ok ( $res = $cmd->devicelist(), 'devicelist' );
#warn $res->{message};
#POE::Kernel->run();
