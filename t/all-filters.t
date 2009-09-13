#!perl -T

# Common test plan for all Filter type modules. Requires Coverage.

use Test::More qw( no_plan );
use YAML::Syck qw(Load);
eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

for my $modulename ( grep /Filter::/, all_modules() ) {
  #diag "Testing $modulename";
  require_ok($modulename);

  # Verify isa Requestable
  my $obj = $modulename->new( );
  isa_ok( $obj, 'ABFS::Common::Loadable' );

  # Verify that properties exist and parses
  can_ok( $obj, qw(_properties) );
  my $prop;
  ok($prop = Load $obj->_properties(), "YAML Load $modulename");

  # Verify that _commandhelp exists
  #can_ok( $obj, qw(hooklist) );

  # XXX: Verify that Hooks are defined in $prop
  #use Data::Dumper;
  #diag "$modulename prop: " . Dumper $prop;
  ok( exists $prop->{Hook}, "$modulename prop Hook");

  # Verify subs exist
  if ( my $hooks = $prop->{Hook} ) {
    for my $hook ( @$hooks ) {
  #    #diag "Testing commands $cmd for $modulename";
  #    # Verify that summary, description and syntax all exists
  #    ok( exists $cmds->{$cmd}{summary},     "$modulename,$cmd no summary");
  #    ok( exists $cmds->{$cmd}{description}, "$modulename,$cmd no description");
  #    ok( exists $cmds->{$cmd}{syntax},      "$modulename,$cmd no syntax");
  #    # Verify that the subroutine exists
      can_ok( $obj, $hook);
  #    # Verify that the result is a response
  #    # XXX: Actually, all responses must be a string, or a failure
  #    #my $res = $obj->$cmd({});
  #    #ok( ref $res eq 'HASH', "Result of $cmd is response");
    }
  }

}
