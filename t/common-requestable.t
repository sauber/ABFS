#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Common::Requestable'); }
require_ok('ABFS::Common::Requestable');

my $request = new ABFS::Common::Requestable;
isa_ok( $request, 'ABFS::Common::Requestable' );

can_ok( $request, qw(request response makerequest makeresponse) );

# Check that we can make requests, and can generate associated reponses
my $req = $request->makerequest( abc => 123 );
my $res = $request->makeresponse( $req, def => 456 );
ok( $res->{request}{abc} eq 123, "Requestable copied to response object" );
ok( $res->{def}          eq 456, "Response exists to request object" );
