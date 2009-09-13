#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Core::Message'); }
require_ok('ABFS::Core::Message');

my $message = new ABFS::Core::Message;
isa_ok( $message, 'ABFS::Core::Message' );

# Test that default message is request
ok( $message->{messagetype} eq 'request', 'defaultrequest' );

# Test that responses are correct type
my $res =
  ABFS::Core::Message->new( messagetype => 'response' );
ok( $res->{messagetype} eq 'response', 'response' );
