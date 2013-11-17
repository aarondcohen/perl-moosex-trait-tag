use strict;
use warnings;

use ExtUtils::MakeMaker;
use ExtUtils::MakeMaker::CPANfile;

WriteMakefile(
	NAME                => 'MooseX::Trait::Tag',
	AUTHOR              => q{Aaron Cohen <acohen@shutterstock.com>},
	VERSION_FROM        => 'lib/MooseX/Trait/Tag.pm',
	ABSTRACT            => 'Add an arbitrary tag to an attribute',
);
