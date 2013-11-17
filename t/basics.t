#!/usr/bin/env perl

use strict;
use warnings qw(all);

use FindBin;
use lib "$FindBin::Bin/../lib/";

use Set::Functional;
use Test::Most tests => 13;

use_ok 'MooseX::Trait::Tag';

{
	package Foo;
	use Moose;

	use MooseX::Trait::Tag qw{metadata tag};

	has bar => (
		traits => [qw/metadata/],
		is => 'rw',
		default => 3573573,
	);
	has baz => (
		traits => [qw/metadata tag/],
		is => 'ro',
		default => 94796,
	);
	has bam => (
		is => 'rw',
		default => 94745,
	);

	__PACKAGE__->meta->make_immutable;
}
{
	package Bare;
	use Moose;

	use MooseX::Trait::Tag qw{nothing};

	has bar => (
		is => 'rw',
		default => 3573573,
	);

	__PACKAGE__->meta->make_immutable;
}

my $foo = Foo->new();
my $bare = Bare->new();

cmp_set [$foo->metadata_attributes], [qw{bar baz}], '<tag>_attributes find all tagged attributes';
cmp_set [Set::Functional::intersection [$foo->metadata_attributes], [$foo->tag_attributes]], [qw{baz}], 'Multiple tags on an attribute are orthogonal to eachother';
ok $foo->is_attribute_metadata('bar'), 'is_attribute_<tag> identifies tagged attribute as tagged';
ok ! $foo->is_attribute_metadata('bam'), 'is_attribute_<tag> identifies untagged attribute as not tagged';
ok ! $foo->is_attribute_metadata('none'), 'is_attribute_<tag> identifies non-existent attribute as not tagged';
dies_ok { $foo->is_attribute_metadata() } 'is_attribute_<tag> fails when not given an attribute';
lives_ok { $foo->update_metadata(bar => 235, baz => 789, bam => 'wont update', none => 'also wont update') } 'update_<tag> handles all input';
is $foo->bar, 235, 'update_<tag> modifies writable tagged attributes';
is $foo->baz, 94796, 'update_<tag> does not modify read-only tagged attributes';
is $foo->bam, 94745, 'update_<tag> does not modify untagged attributes';
throws_ok { $bare->metadata_attributes } qr/Can't locate object method/, 'Injecting a tag does not pollute other classes';
lives_ok { $bare->nothing_attributes; $bare->is_attribute_nothing('nothing'); $bare->update_nothing } 'Injecting a tag adds all appropriate methods to the importing class, regardless of the attributes';
