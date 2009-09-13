#!perl -T

use Test::More qw( no_plan );

BEGIN { use_ok('ABFS::Core::DependencyTree'); }
require_ok('ABFS::Core::DependencyTree');

my $tree = new ABFS::Core::DependencyTree;
isa_ok( $tree, 'ABFS::Core::DependencyTree' );

can_ok( $tree, qw(addnode removenode removerecursive nodenames nodelist) );

# ski depends on snow
# board depends on snow
# snow depends on winter
my $objski    = 'Ski';
my $objsnow   = 'Snow';
my $objboard  = 'Board';
my $objwinter = 'Winter';

# Verify that initial tree is empty
ok( 0 == $tree->numnodes, 'treeinit' );

# Try to add a node depending on another not yet existing
ok( !$tree->addnode( 'ski', $objski, 'snow' ), 'dependmissing' );
ok( 0 == $tree->numnodes, 'treeinit' );

# Build up dependency tree
ok( $tree->addnode( 'winter', $objwinter ), 'nodepend' );
ok( $tree->addnode( 'snow',  $objsnow,  'winter' ), 'depend1' );
ok( $tree->addnode( 'ski',   $objski,   'snow' ),   'depend2' );
ok( $tree->addnode( 'board', $objboard, 'snow' ),   'depend3' );
ok( 4 == $tree->numnodes, 'treeadd' );

# Get list of nodenames - there should be 4
ok( 4 == scalar $tree->nodenames, 'nodenames' );
ok( 4 == scalar $tree->nodelist,  'nodenames' );

# Try to remove nodes that has dependency
ok( !$tree->removenode('ski'),    'noremovedepending' );
ok( !$tree->removenode('snow'),   'noremovedependency' );
ok( !$tree->removenode('winter'), 'noremovedependant' );
ok( 4 == $tree->numnodes,         'treenoremove' );

# Try recursive remove of node that is dependendant
ok( !$tree->removerecursive('snow'), 'noremoverecursivedependant' );
ok( 4 == $tree->numnodes, 'treenoremove' );

# Remove one branch of dependency
ok( $tree->removerecursive('ski'), 'removerecursivedependantlimit' );
ok( 3 == $tree->numnodes, 'treeremoved' );

# Remove the other branch, rest of tree
ok( $tree->removerecursive('board'), 'removerecursivedependantall' );
ok( 0 == $tree->numnodes, 'treeremoved' );
