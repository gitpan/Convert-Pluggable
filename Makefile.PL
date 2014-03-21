use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Convert::Pluggable',
    AUTHOR           => q{bradley andersen <bradley@pvnp.us>},
    VERSION_FROM     => 'lib/Convert/Pluggable.pm',
    ABSTRACT_FROM    => 'lib/Convert/Pluggable.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Data::Float' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Convert-Pluggable-*' },
);
