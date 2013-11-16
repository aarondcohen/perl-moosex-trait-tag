use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME                => 'MooseX::Trait::Metadata',
	AUTHOR              => q{Aaron Cohen <acohen@shutterstock.com>},
	VERSION_FROM        => 'lib/MooseX/Trait/Metadata.pm',
	ABSTRACT            => 'Declare an attribute as metadata',
	($ExtUtils::MakeMaker::VERSION >= 6.3002
		? ('LICENSE'=> 'perl')
		: ()),
	PL_FILES            => {},
	PREREQ_PM => {
		'FindBin'              => 0,
		'Moose'                => '2.0',
		'namespace::autoclean' => 0,
		'Test::Most'           => 0,
	},
	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean               => { FILES => 'MooseX-Trait-Metadata-*' },
	META_MERGE => {
		resources => {
			repository => 'git://github.shuttercorp.net/acohen/perl-moosex-trait-metadata.git',
			homepage   => 'http://github.shuttercorp.net/acohen/perl-moosex-trait-metadata',
			bugtracker => 'http://github.shuttercorp.net/acohen/perl-moosex-trait-metadata/issues',
		},
	},
);
