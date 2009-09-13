#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Core::Block'); }
require_ok('ABFS::Core::Block');

my $block = new ABFS::Core::Block;
isa_ok( $block, 'ABFS::Core::Block' );

can_ok( $block, qw(set get genkey encrypt decrypt) );

my $data = "Hello World";
my $key  = "k1";

# Set properties. Retrieve again and compare.
$block->set( key => $key, dataref => \$data );
my %prop = $block->get(qw(key dataref));
ok( $prop{key}          eq $key,  'blockkey' );
ok( ${ $prop{dataref} } eq $data, 'blockdata' );

# Generate key. Confirm it's updated.
my $gk = $block->genkey();
%prop = $block->get('key');
ok( $gk        ne $key, 'blockgenkey1' );
ok( $prop{key} ne $key, 'blockgenkey2' );

#diag("new block key is $gk");

TODO: {
  local $TODO = "Encrypt key is not scalar";

  # Encrypt and decrypt test
  my $encref = $block->encrypt();
  ok( $$encref ne $data, 'blockencrypt' );
  my $block2 =
    new ABFS::Core::Block( cryptref => $encref, );
  my $decref = $block2->decrypt($gk);

  #ok( $$decref eq $data, 'blockdecrypt' );
}
