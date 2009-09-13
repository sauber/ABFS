#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Request'); }
BEGIN { use_ok('ABFS::Core::Loader'); }
BEGIN { use_ok('ABFS::Core::Message'); }
BEGIN { use_ok('ABFS::Core::Constants'); }
require_ok('ABFS::Request');

my $req = new ABFS::Request;
isa_ok( $req, 'ABFS::Request' );
isa_ok( $req, 'ABFS::Common::Loadable' );

can_ok( $req, qw(requestnext call process selectmodule enqueue) );

# Verify we have a queue to work with
#isa_ok( $req->{queue}, 'ABFS::Request::Queue' );

# Test that module can be loaded/unloaded by loader
#my $loader = new ABFS::Core::Loader;
#my @loadok = $loader->add('request');
#ok( scalar @loadok > 0, 'moduleloaded' );
#ok( $loadok[0] eq 'request', 'moduleisrequest' );
#my @unloadok = $loader->del('request');
#ok( scalar @unloadok > 0, 'moduleunloaded' );
#ok( $unloadok[0] eq 'request', 'unloadisrequest' );

# Create a dummy kernel necessary for testing
my $kernel = eval {
  package ABFS::Core::Wheel;
  my $singleton;
  sub new { $singleton = bless {}, shift }
  sub AUTOLOAD { *{$AUTOLOAD} = sub {}; undef }
  __PACKAGE__;
}->new();
$req->{kernel} = $kernel;

# Enqueue some requests
for my $n ( 1 .. 3 ) {
  $req->enqueue(
    ABFS::Core::Message->new( command=>$n )
  )
}
ok( 3 == $req->{queue}->queuesize(), '3enqueued' );

# Try to process a request
# XXX: But it's not a real request, and nobody to process it, and nobody to
#      reply to.
ok( $req->selectmodule( $req->{queue}->next() ) == PERMFAILURE, 'selectmodule' );
#ok( $req->call( $req->{queue}->next() ) == PERMFAILURE, 'callrequest' );
#ok( ! $req->answer( $req->{queue}->next() ), 'answerrequest' );
POE::Kernel->run();
