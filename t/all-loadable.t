#!perl -T

# Common test plan for all modules that isa Loadable

use Test::More qw( no_plan );
use YAML::Syck qw(Load);
eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

use ABFS::Core::Loader;

for my $modulename ( all_modules() ) {
  next if $modulename =~ /Console/;
  next if $modulename =~ /Constant/;
  next if $modulename eq 'ABFS::Common::Loadable';
  require_ok($modulename);
  my $obj = $modulename->new( );
  if ( $obj->isa('ABFS::Common::Loadable') ) {
    ( my $abfsname = $modulename ) =~ s/ABFS:://;
    #diag "Testing Loadable $abfsname";
    my $prop;
    ok( $prop = Load $obj->_properties(), "YAML Load $abfsname" );
    ok( defined $obj->{config}, "$abfsname has no config" );

    # Try to load/unload module
    my $loader = new ABFS::Core::Loader;
    my @loaded = $loader->add($abfsname);
    ok( scalar @loaded > 0, "$abfsname added by loader" );
  } else {
    #diag "Skipping $modulename";
  }
}
# Close sessions
POE::Kernel->run();
