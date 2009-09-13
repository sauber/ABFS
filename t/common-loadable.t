#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Common::Loadable'); }
require_ok('ABFS::Common::Loadable');

my $loadable = new ABFS::Common::Loadable;
isa_ok( $loadable, 'ABFS::Common::Loadable' );

can_ok( $loadable, qw(_properties dependencies getconfig setconfig) );

# setting and getting config
ok( $loadable->setconfig( 'abc' => 123 ), 'setconfig' );
ok( $loadable->getconfig('abc') == 123, 'getconfig' );
ok( !$loadable->getconfig('def'), 'getundefconfig' );
