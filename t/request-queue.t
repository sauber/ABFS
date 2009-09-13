#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Core::Queue'); }
require_ok('ABFS::Core::Queue');

my $queue = new ABFS::Core::Queue;
isa_ok( $queue, 'ABFS::Core::Queue' );

can_ok( $queue, qw(enqueue next queuesize reprioritize ) );

# Insert one request and dequeue it
my $request = { eventtype => 'request', message => 'hello world' };
$queue->enqueue($request);
ok( 1 == $queue->queuesize(), 'queuesize' );
my $next = $queue->next();
ok( $request eq $next, 'enqueue' );
#$queue->dequeue($next);
#ok( 0 == $queue->queuesize(), 'dequeue' );

# Insert several requsts, reshuffle, and dequeue
for my $i ( 1 .. 10 ) {
  $queue->enqueue( { eventtype => 'request', message => $i } );
}
ok( 10 == $queue->queuesize(), 'enqueue10' );
$queue->reprioritize();
my $i = 10;
#while ( $next = $queue->next() ) {
#  $queue->dequeue($next);
#  ok( --$i == $queue->queuesize(), "dequeue$i" );
#}
