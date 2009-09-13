#!perl -T

use Test::More qw( no_plan );

BEGIN {
  use_ok('ABFS::Core::Queue');
  use_ok('ABFS::Core::Loader');
}

# Start loader, start request queue, load echo module
my $loader = new ABFS::Core::Loader;

#my $rq = ABFS::Request::Queue->new( loader => $loader );
#$loader->add('echo');
#
## Call echo request directly
#my $msg = 'Hello World';
#my $res = $rq->call( {
#  module => 'echo',
#  eventtype => 'request',
#  message => $msg,
#} );
#
## Verify we got response
#ok( $res->{eventtype} eq 'response', 'responsetype' );
#ok( $res->{message} eq $msg, 'responsemessage' );
