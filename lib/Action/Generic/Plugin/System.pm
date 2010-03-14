package Action::Generic::Plugin::System;
use Moose;

has 'name' => (
	is => 'ro',
	required => 1,
	isa => 'Str'
);

has 'params' => ( 
	is	=> 'ro',
	isa => 'ArrayRef',
	required => 1
);

has '_results' => ( 
	is => 'rw',
	isa => 'HashRef'
);

sub run { 
	my( $self ) = @_;
	my $res = {};
	$res->{type} = ref $self;
	$res->{was_run} = 1;
	$res->{code} = system( @{$self->params} );
	$self->_results( $res );
}

__PACKAGE__->meta->make_immutable;
