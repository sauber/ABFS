#!perl -T

# Common test plan for all Command type modules. Requires Coverage.

use Test::More qw( no_plan );
use YAML::Syck qw(Load);
eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage"
  if $@;

for my $modulename ( grep /Command::/, all_modules() ) {
  require_ok($modulename);

  # Verify isa Plugin and Requestable
  my $obj = $modulename->new();
  isa_ok( $obj, 'ABFS::Command::Plugin' );
  isa_ok( $obj, 'ABFS::Common::Requestable' );

  # Verify that properties exist and parses
  can_ok( $obj, qw(_properties) );
  my $prop;
  ok( $prop = Load $obj->_properties(), "YAML Load $modulename" );

  # Verify that Commands are defined in $prop and in Config
  my $cmd;
  ok( exists $prop->{Command},        "$modulename prop Command" );
  ok( exists $obj->{config}{Command}, "$modulename config Command" );

  # Verify descriptions, subs exist, return responses
  if ( my $cmds = $prop->{Command} ) {
    for my $cmd ( keys %$cmds ) {

      # Verify that summary, description and syntax all exists
      ok( exists $cmds->{$cmd}{summary}, "$modulename,$cmd no summary" );
      ok(
        exists $cmds->{$cmd}{description},
        "$modulename,$cmd no description"
      );
      ok( exists $cmds->{$cmd}{syntax}, "$modulename,$cmd no syntax" );

      # Verify that the subroutine exists
      can_ok( $obj, $cmd );

      # Verify that the result is a response
      # XXX: Actually, all responses must be a string, or a failure
      #my $res = $obj->$cmd();
      #ok( ref $res eq undef, "Result of $cmd is not ref" );
      #ok( length $res > 0, "Result of $cmd is string" );
    }
  }

}
