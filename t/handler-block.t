#!perl -T

# prove -I../lib storage-heap.t

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Handler::Block'); }
BEGIN { use_ok('ABFS::Data::Message'); }
BEGIN { use_ok('ABFS::Data::Block'); }
require_ok('ABFS::Handler::Block');

my $handler = new ABFS::Handler::Block;
isa_ok( $handler, 'ABFS::Handler::Block' );

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

ok( $handler->post( $post ), 'post a block');
ok( my $resp = $handler->get( $get ), 'get a block');
ok( $resp->content eq $content, 'Retrieve same data as stored' );
