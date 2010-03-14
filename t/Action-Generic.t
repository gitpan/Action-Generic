use Test::More tests => 6;

BEGIN { 
	use_ok('Action::Generic') 
};

my $c = new_ok('Action::Generic');

can_ok( $c, qw(run action add_actions) );

my $custom = $c->action( 
		type => 'Custom',
		name => 'A Custom Action',
		code => sub { return 'flying goose' }
);

can_ok( $custom, qw(run name) );

$c->add_actions( $custom );

$c->run;

is( $c->results->[0]->{result}, 'flying goose', 'Check for flying geese');

SKIP: { 
	skip 'Cross-platform issues with system';
	my $system = $c->action(
		type => 'System',
		name => 'A system action',
		params => [qw(ls -al)]
	);
	$c->add_actions( $system );
}

