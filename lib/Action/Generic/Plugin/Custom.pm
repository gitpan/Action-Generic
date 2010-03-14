package Action::Generic::Plugin::Custom;
use Moose;

has 'name' => (
	is => 'ro',
	required => 1,
	isa => 'Str'
);

has 'code' => (
	is => 'ro',
	required => 1,
	isa => 'CodeRef'
);

has '_results' => ( 
	is => 'rw',
	isa => 'HashRef'
);

sub run { 
	my( $self ) = @_;
	my $res = {};
	$res->{type} = ref $self;
	$res->{result} =  $self->code->();
	$res->{was_run} = 1;
	$self->_results( $res );
	
}

__PACKAGE__->meta->make_immutable;
