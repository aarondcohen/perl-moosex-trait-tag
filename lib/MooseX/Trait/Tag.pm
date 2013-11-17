package MooseX::Trait::Tag;

=head1 NAME

MooseX::Trait::Tag - Add an arbitrary tag to an attribute

=cut

use Moose::Role;
use namespace::autoclean;

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This module provides a way to give a Moose attribute an arbitrary tag.
Various methods are installed into the package declaring the attribute,
allowing for actions to be taken on only the tagged attributes.
This module is inspired by L<http://search.cpan.org/~ether/Moose/lib/Moose/Cookbook/Meta/Labeled_AttributeTrait.pod>

Example usage:

	package Foo;
	use Moose;
	use MooseX:Trait::Tag qw{metadata};

	has field1 => (is => 'rw', traits => [qw{metadata}]);
	has field2 => (is => 'ro', traits => [qw{metadata}]);
	has field3 => (is => 'rw', traits => []);

	__PACKAGE__->meta->make_immutable;

	package main;

	my $foo = Foo->new;

	my @metadata_fields = sort $foo->metadata_attributes;
	# @metadata_fields => qw{ field1 field2 }

	print "Yes\n" if $foo->is_attribute_metadata('field1');
	print "No\n" if !$foo->is_attribute_metadata('field3');

	$foo->update_metadata(
		field1 => 6,
		field2 => 7,
		field3 => 8,
		field4 => 9,
	);
	# => only field1 is modified

=cut

=head1 METHODS

=cut

sub import {
	my $class = shift;
	my $importing_class = caller();
	$class->register_tag(importing_class => $importing_class, tag => $_) for @_;
}

=head2 register_tag(importing_class => $importing_class, tag => $tag)

Install the methods asociated with the tag into the importing class.

=cut

sub register_tag {
	my $class = shift;
	my %args = @_;
	my ($importing_class, $tag) = @args{qw{importing_class tag}};

	#Moose magic to create a new trait bound to the label
	my $tag_class = "$class\::$tag";
	Moose::Meta::Role->initialize($tag_class);
	Moose::Exporter->setup_import_methods(exporting_package => $tag_class);
	Moose::Util::meta_attribute_alias($tag, $tag_class);

=head1 INSTALLED METHODS

=cut

=head2 is_attribute_<tag>( $attribute_name )

Given an attribute name, determine if it is registered to the tag.
Requires an attribute name.

=cut

	my $importing_class_meta = $importing_class->meta;
	$importing_class_meta->add_method("is_attribute_$tag", sub {
		my $attribute = (shift)->meta->find_attribute_by_name(@_);
		return $attribute && $attribute->does($tag);
	}) unless $importing_class_meta->has_method("is_attribute_$tag");

=head2 <tag>_attributes( )

Returns the names of all attributes marked with the tag.

=cut

	$importing_class_meta->add_method("$tag\_attributes", sub {
		map { $_->name }
		grep { $_->does($tag) }
		(shift)->meta->get_all_attributes
	}) unless $importing_class_meta->has_method("$tag\_attributes");

=head2 update_<tag>( attribute1 => $new_value1, ... )

Given name-value pairs, update each writable attribute with the new value
if it is associated with the appropriate tag.

=cut

	$importing_class_meta->add_method("update_$tag", sub {
		my ($self, %args) = @_;

		for my $attribute (grep { $_->does($tag) } $self->meta->get_all_attributes) {
			next unless exists $args{$attribute->name};
			my $writer = $attribute->get_write_method;
			next unless $writer;
			$self->$writer($args{$attribute->name});
		}

		return;
	}) unless $importing_class_meta->has_method("update_$tag");
}

1;
