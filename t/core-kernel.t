#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Core::Kernel'); }
require_ok('ABFS::Core::Kernel');

my $kernel = new ABFS::Core::Kernel;
isa_ok( $kernel, 'ABFS::Core::Kernel' );

can_ok( $kernel, qw(run add del postevent) );

# Test that kernel can be started multiple times
#diag "Waiting 2 secs for kernel to stop";
ok( $kernel->run, 'kernelrun' );

#diag "Waiting 2 secs for kernel to stop";
#ok ( $kernel->run, 'kernelrun' );

# Give kernel something to do: load modules
# XXX: Is this the way kernel and loader should know about each other?
use ABFS::Core::Loader;
my $loader = ABFS::Core::Loader->new( kernel => $kernel );
$kernel->{loader}    = $loader;
$kernel->{configcmd} = '';
#diag "Waiting 2 secs for kernel to stop";
ok( $kernel->run, 'kernelrun' );
