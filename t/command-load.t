#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Command::Load'); }
require_ok('ABFS::Command::Load');

my $cmd = new ABFS::Command::Load;
isa_ok( $cmd, 'ABFS::Command::Load' );

# Have a loader module available.
require_ok('ABFS::Core::Loader');
my $loader = new ABFS::Core::Loader;
$cmd->{modules} = $loader->{modules};
$cmd->{loader}  = $loader;

# Check initial state
my @loaded = $loader->{modules}->nodenames();
ok( scalar @loaded == 0, "No loaded modules to begin with" );

#diag "Nodenames: " . join ', ', @loaded;

# Load some modules
my $module = 'Command::Load';
$cmd->load($module);
@loaded = $loader->{modules}->nodenames();
ok( scalar @loaded > 0, "$module modules loaded, and others" );

#diag "Nodenames: " . join ', ', @loaded;
ok( $loaded[0] eq $module, "First modules loaded is $module" );

# Check list and dependencies
ok( $cmd->lsmod() =~ /$module/, "$module listed as loaded module" );
ok( $cmd->lsdep() =~ /$module/, "$module listed as depending module" );

# Unload module again
my @unloaded = $cmd->unload($module);
ok( scalar @unloaded > 0, "$module unloaded, and others" );
ok( scalar @loaded == scalar @loaded,
  "Same number of modules loaded and unloaded" );

# Clean up sessions
POE::Kernel->run();
