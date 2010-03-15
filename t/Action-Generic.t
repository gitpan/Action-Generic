use Test::More tests => 3;

BEGIN { 
	use_ok('Action::Generic') 
};
my $c = new_ok('Action::Generic');
can_ok( $c, qw(run action add_actions) );

