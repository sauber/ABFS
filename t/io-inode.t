#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::IO::Inode'); }
require_ok('ABFS::IO::Inode');

my $inode = new ABFS::IO::Inode;
isa_ok( $inode, 'ABFS::IO::Inode' );

can_ok( $inode, qw(open_write size) );

my $filename = '/tmp/abfstest';
$inode->open_write($filename);

#my($res,$size) = $inode->size();
#ok( $size == 0, 'newinodefilesize' );
my $res = $inode->size();
ok( $res->{result} == 0, 'newinodefilesize' );
$data = 'Hello World !!';
$inode->write( $data, 3 );
