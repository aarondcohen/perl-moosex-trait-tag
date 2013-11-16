package MooseX::Trait::Metadata;

=head1 NAME

MooseX::Trait::Metadata - declare an attribute as metadata

=cut

use Moose::Role;
use namespace::autoclean;

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This module defines the Moose attribute trait Metadata.  On the attribute,
Metadata merely acts as an identifying label.  However, by marking any
attribute as Metadata, various methods are installed into the pacakage
declaring the attribute.

Example usage:

	package Foo;
	use Moose;
	use MooseX:Trait::Metadata;

	has field1 => (is => 'rw', traits => [qw{Metadata}]);
	has field2 => (is => 'ro', traits => [qw{Metadata}]);
	has field3 => (is => 'rw', traits => []);

	__PACKAGE__->meta->make_immutable;

	package main;

	my $foo = Foo->new;

	my @metadata_fields = sort $foo->metadata_attributes;
	# @metadata_fields == qw{ field1 field2 }

	print "Yes\n" if $foo->is_metadata_attribute('field1');
	print "No\n" if !$foo->is_metadata_attribute('field3');

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


Moose::Util::meta_attribute_alias('Metadata');

after 'install_accessors' => sub {
	my $attribute = shift;
	my $realclass = $attribute->associated_class();
	my $attribute_name = $attribute->name;

=head2 is_metadata_attribute( $attribute_name )

Given an attribute name, determine if it is a registered metadata attribute.
Requires an attribute name.

=cut

	$realclass->add_method('is_metadata_attribute', sub {
		my $attribute = (shift)->meta->find_attribute_by_name(@_);
		return $attribute && $attribute->does('Metadata');
	}) unless $realclass->has_method('is_metadata_attribute');

=head2 metadata_attributes( )

Returns the names of all attribute fields marked as metadata.

=cut

	$realclass->add_method('metadata_attributes', sub {
		map { $_->name }
		grep { $_->does('Metadata') }
		(shift)->meta->get_all_attributes
	}) unless $realclass->has_method('metadata_attributes');

=head2 update_metadata( attribute1 => $new_value1, ... )

Given name-value pairs, update each writable named metadata attribute with the new value.

=cut

	$realclass->add_method('update_metadata', sub {
		my ($self, %args) = @_;

		for my $attribute (grep { $_->does('Metadata') } $self->meta->get_all_attributes) {
			next unless exists $args{$attribute->name};
			my $writer = $attribute->get_write_method;
			next unless $writer;
			$self->$writer($args{$attribute->name});
		}

		return;
	}) unless $realclass->has_method('update_metadata');
};

1;
