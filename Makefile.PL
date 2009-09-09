use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'ABFS',
    AUTHOR              => q{Soren Dossing <netcom@sauber.net>},
    VERSION_FROM        => 'lib/ABFS.pm',
    ABSTRACT_FROM       => 'lib/ABFS.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'          => 0,
        'Test::Pod'           => 0,
        'Test::Pod::Coverage' => 0,
        'POE'                 => 0,
        'Moose'               => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ABFS-*' },
);
