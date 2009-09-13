#!perl -T

# Common test plan for all File type modules. Requires Coverage.

use Test::More qw( no_plan );
use YAML::Syck qw(Load);
eval "use Test::Pod::Coverage";
#plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

for my $modulename ( grep /File::/, all_modules() ) {
  #diag "Testing $modulename";
  require_ok($modulename);

  # Verify isa Device::Plugin
  my $obj = $modulename->new( );
  isa_ok( $obj, 'ABFS::File::Plugin' );

  # Verify that properties exist and parses
  can_ok( $obj, qw(_properties seek pos size write read) );
  my $prop;
  ok($prop = Load $obj->_properties(), "YAML Load $modulename");
}
