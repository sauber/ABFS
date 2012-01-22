use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'ABFS',
  AUTHOR        => 'Soren Dossing <netcom@sauber.net>',
  VERSION_FROM  => 'lib/ABFS.pm',
  ABSTRACT_FROM => 'lib/ABFS.pm',
  PL_FILES      => {},
  PREREQ_PM     => {
    'Test::More'          => 0,
    'Carp'                => 0,
    'AnyEvent'            => 0,
    'Module::Load'        => 0,
    'List::Util'          => 0,
    'Digest::SHA'         => 0,
    'Crypt::Rijndael'     => 0,
    'Crypt::CBC'          => 0,
    'Term::ReadKey'       => 0,
    'YAML::Syck'          => 0,
    'Text::Table'         => 0,
    # XXX: For development
    'Test::Pod'           => 0,
    'Test::Pod::Coverage' => 0,
    
  },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES    => 'Filesys-Virtual-ABFS-*' },
);
