#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Command'); }
require_ok('ABFS::Command');

my $cmd = new ABFS::Command;
isa_ok( $cmd, 'ABFS::Command' );
isa_ok( $cmd, 'ABFS::Common::Requestable' );

can_ok( $cmd, qw(commandline) );

# Fail when no message is given
ok( !$cmd->commandline( {} ), 'missingmessage' );

# Split command into first word and remaining as arguments
my $req;
ok( $req = $cmd->commandline( { message => 'hello world !' } ),
  'withmessage' );
isa_ok( $req, 'ABFS::Core::Message' );
ok( $req->{command} eq 'hello',   'commandparsed' );
ok( $req->{message} eq 'world !', 'argsparsed' );

# Test that command module can be loaded/unloaded by loader
#use ABFS::Core::Loader;
#my $loader = new ABFS::Core::Loader;
#my @loadok = $loader->add('command');
#ok( scalar @loadok > 0, 'moduleloaded' );
#ok( $loadok[0] eq 'command', 'moduleiscommand' );
#my @unloadok = $loader->del('command');
#ok( scalar @unloadok > 0, 'moduleunloaded' );
#ok( $unloadok[0] eq 'command', 'unloadiscommand' );

# Test the help function
#my $msg;
#ok( $msg = $cmd->help(), 'gethelp' );
##ok( $msg->{message} eq '', 'helpisdefined' );
#ok( $msg->{messagetype} eq 'response', 'helpisdefined' );
