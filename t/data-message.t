#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Data::Message'); }
require_ok('ABFS::Data::Message');

my $message = new ABFS::Data::Message;
isa_ok( $message, 'ABFS::Data::Message' );

# Test that default message is request
ok( $message->exchange eq 'request', 'defaultrequest' );

# Test that responses are correct type
my $res =
  ABFS::Data::Message->new(exchange => 'response' );
ok( $res->exchange eq 'response', 'response' );
