#!perl -T

# prove -I../lib core-devicelist.t

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Core::Devicelist'); }
require_ok('ABFS::Core::Devicelist');

my $dev = new ABFS::Core::Devicelist;
isa_ok( $dev, 'ABFS::Core::Devicelist' );
isa_ok( $dev, 'ABFS::Common::Loadable' );

#can_ok( $dev, qw(mount unmount devicelist devicematch) );
can_ok( $dev, qw(mount devicelist devicematch) );

# Test that module can be loaded/unloaded by loader
#use ABFS::Core::Loader;
#my $loader = new ABFS::Core::Loader;
#my @loadok = $loader->add('devicelist');
#ok( scalar @loadok > 0, 'moduleloaded' );
#ok( $loadok[0] eq 'devicelist', 'moduleisloadercmd' );
#my @unloadok = $loader->del('devicelist');
#ok( scalar @unloadok > 0, 'moduleunloaded' );
##diag "unload is " . $unloadok[0];
#ok( $unloadok[0] eq 'devicelist', 'unloadisloadercmd' );

# Mount some devices
#for my $id ( 0 .. 2 ) {
#  my $req = $dev->makerequest( command => 'mount', options => {type=>'heap', name=>'memory'}, arguments=>['/'] );
#  my $res = $dev->request($req);
#  #use Data::Dumper;
#  #warn Dumper $res;
#  ok( $id == $res->{message}{id}, 'id0' );
#  ok( 'heap' eq $res->{message}{type}, 'typeheap' );
#  ok( 'memory' eq $res->{message}{name}, 'namememory' );
#  ok( '/' eq $res->{message}{mountpoint}, '/mountpoint' );
#}
#my $req = $dev->makerequest( command => 'mount', options => {type=>'invaliddevice', name=>'memory'}, arguments=>['/'] );
#my $res = $dev->request($req);
#ok( 'Invalid device' eq $res->{message}, 'Invaliddevice' );
#ok ( $res = $dev->devicelist(), 'devicelist' );
#warn $res->{message};
