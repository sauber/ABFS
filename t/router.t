#!perl -T

# prove -I../lib storage-heap.t

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Router'); }
require_ok('ABFS::Router');

BEGIN { use_ok('ABFS::Data::Message'); }
BEGIN { use_ok('ABFS::Handler::Block'); }

my $router = new ABFS::Router;
isa_ok( $router, 'ABFS::Router' );

my $bh = new ABFS::Handler::Block;

my $handlers = $router->handlers;
ok ( ref $handlers eq 'HASH', 'router handler is hash' );
$handlers->{block} = $bh;

my $content = 'data';
my $block = new ABFS::Data::Block content=>$content;
my $key = $block->name;

my $post = new ABFS::Data::Message
  service => 'block',
  exchange => 'response',
  header => { blockid=>$key },
  content => $content;

my $get = new ABFS::Data::Message
  service => 'block',
  exchange => 'request',
  header => { blockid=>$key };

ok( $router->newmsg( $post ), 'can post message to router' );
