#!perl -T

use Test::More qw( no_plan );
use YAML::Syck qw(Load);

# Get list of all modules
opendir DH, "lib/ABFS";
  my @modulelist = grep s/\.pm$//, readdir DH;
close DH;


# Create a dummy wheel necessary for initializing console
my $wheel = eval {
  package ABFS::Core::Wheel;
  my $singleton;
  sub new { $singleton = bless {}, shift }
  sub put { 1 };
  sub AUTOLOAD { *{$AUTOLOAD} = sub {}; undef }
  __PACKAGE__;
}->new();

# Have a loader module for load/unload testing
use ABFS::Core::Loader;
my $loader = new ABFS::Core::Loader;

for my $modulename ( @modulelist ) {
  #diag "Testing $modulename properties\n";

  # Untaint, and various versions of name
  $modulename =~ /(.*)/;
  my $untaint = $1;
  #my $lcmodule = lc $1;
  my $lcmodule = $1;
  my $fullname = "ABFS::$untaint";

  # Verify that module can be initialized
  require_ok($fullname);
  my $obj = $fullname->new( wheel=>$wheel );
  isa_ok( $obj, $fullname );
  isa_ok( $obj, 'ABFS::Common::Loadable' );

  # Verify that properties exist and parses
  can_ok( $obj, qw(_properties) );
  my $prop;
  ok($prop = Load $obj->_properties(), "YAML Load $fullname");

  # Verify that properties are correct type
  my %proptype = (
    Command => HASH,
    Config  => HASH,
    Depend  => ARRAY,
    Event   => ARRAY,
    Request => HASH,
  );
  while ( my($key,$type) = each %proptype ) {
    if ( $prop->{$key} ) {
      ok( $type eq ref $prop->{$key}, "$fullname $key is $type");
    }
  }

  # Verify that all commands and events have a sub of same name
  my @subs = ();
  push @subs, keys %{ $prop->{Command} } if $prop->{Command};
  push @subs, @{ $prop->{Event} } if $prop->{Event};
  can_ok( $obj, @subs ) if @subs;

  # Verify that module (except console) can be loaded and unloaded
  if ( $lcmodule ne 'Console' ) {
    # Load module
    my @loadok = $loader->add($lcmodule);
    ok( scalar @loadok > 0, $lcmodule . ' loaded' );
    ok( $loadok[0] eq $lcmodule, 'loaded module is ' . $lcmodule );

    # Unload it again
    my @unloadok = $loader->del($lcmodule);
    ok( scalar @unloadok > 0, $lcmodule . ' unloaded' );
    #ok( $unloadok[0] eq $lcmodule, 'unloaded module is ' . $lcmodule );
  }

  # XXX: Verify that all commands have a short description
  #if ( $prop->{Command} ) {
  #  for my $cmd ( keys %{ $prop->{Command} } ) {
  #    ok( $prop->{Command}{short}, "$cmd command has short description" );
  #  }
  #}

}
POE::Kernel->run();
