use strict;
use warnings;

use ExtUtils::MakeMaker;
use ExtUtils::MakeMaker::CPANfile;

WriteMakefile(
	NAME                => 'MooseX::Trait::Label',
	AUTHOR              => q{Aaron Cohen <acohen@shutterstock.com>},
	VERSION_FROM        => 'lib/MooseX/Trait/Label.pm',
	ABSTRACT            => 'Declare an attribute with a label',
);
