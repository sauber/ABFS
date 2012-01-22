#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Core::Loader'); }
require_ok('ABFS::Core::Loader');

my $loader = new ABFS::Core::Loader;
isa_ok( $loader, 'ABFS::Core::Loader' );

can_ok( $loader, qw(add del getobj initobj uninitobj) );

# Check that Echo module is not yet loaded
eval { new ABFS::Command::Echo };
ok( $@, 'echonotloaded' );

# Load in Echo module, confirm it works.
my @loadok = $loader->add('Command::Echo');
ok( scalar @loadok > 0, 'somemodulesloaded' );
ok( $loadok[0] eq 'Command::Echo', 'firstmoduleisecho' );

# Check that object is right type
my $echoobj = $loader->getobj( $loadok[0] );
isa_ok( $echoobj, 'ABFS::Command::Echo' );

# Unload module and it's dependencies
my @unloadok = $loader->del('Command::Echo');
ok( scalar @unloadok > 0, 'somemodulesunloaded' );
#ok( $unloadok[0] eq 'Echo', 'firstunmoduleisecho' );

# Load bogus module, should not be possible
eval { $loadok = $loader->add('bogus'); };
ok( !$loadok, 'loadedbogusfailure' );
ok( !$loader->getobj('bogus'), 'loadedbogusinit' );

# XXX: unload bogus modules. Should not be possible
#      but something is not right...
#$unloadok = $loader->del('bogus');
#use Data::Dumper;
#diag "unloadok: " . Dumper $unloadok;
#ok( !$unloadok, 'unloadedbogusfailure' );
ok( !$loader->getobj('bogus'), 'unloadedbogusinit' );
#POE::Kernel->run();
