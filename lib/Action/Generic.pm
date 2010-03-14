package Action::Generic;
use Moose;
use Module::Pluggable require => 1;
use Carp;

use 5.008001;

our $VERSION = '0.000002'; # 0.0.2

has '_action_list' => ( 
	is	=> 'rw',
	isa => 'ArrayRef',
	default => sub { [] } 
);

sub action { 
	my $self = shift;
	my %args = @_;
	for my $a ( $self->plugins ) {
		if( $a =~ /.*$args{type}/ ) { 
			my $action = $a->new( %args );
			return $action;
		}
	}
	# So it wasn't a plugin..
	my $a = $args{type};
	eval "require $a";
	
	unless( $@ ) { 
		my $action = $a->new( %args );
		return $action;
	} else { 
		print $@, "\n";
	}
	return undef;

}

sub add_actions { 
	my( $self, @actions ) = @_;
	my $orig = $self->_action_list;
	for( @actions ) { 
		push @$orig, $_;
	}
	$self->_action_list( $orig );
}

sub run { 
	my( $self ) = @_;
	for( @{$self->_action_list()} ) { 
		$_->run() or croak;;
	}
}

sub results { 
	my( $self ) = @_;
	return [ map { $_->_results } @{$self->_action_list} ];
}

=head1 NAME

Action::Generic - Generic actions in a OO way

=head1 SYNOPSIS

 my $controller = Action::Generic->new();

 my $action = $controller->action( 
   type => 'System',
   name => 'List Files in my Homedir',
   params => [('ls', '-l', '~')],  
 );

 my $custom_action = $controller->action(
   type => 'Custom',
   name => 'A Custom Action',
   code => sub { ... }
 );

 $controller->add_actions( $action, $custom_action );

 $controller->run;

 use Data::Dumper;
 print Dumper( $controller->results );

=head1 DESCRIPTION

Action::Generic is intended to create a simple framework
for executing complex bits of code in a slighly modular, 
OO-ish way.  

It works by creating a "controller" object

 my $controller = Action::Generic->new();

which consumes various actions.  First, use the C<action> method
to create an action, passing it any relevent parameters..

 my $action = $controller->action( 
   type => 'Custom',
   name => 'Hello, world!',
   code => sub { print "Hello, world!\n" }
 );

And push this action to the end of the stack.  

 $controller->add_actions( $action );

Each action is run, in the order added, optionally 
stopping further execution.  

Finally, should any of the actions have any notable result output,
it is stored in a hashref whose keys are the name of the action.

 print Dumper( $controller->results );  # Lots of stuff

Action::Generic ships with only a handful of actions.  Extending
them or adding more is a trivial task (see 'Creating Custom Actions').

=head2 Creating New Action Objects

As mentioned below, there are a few actions that come by default
-- basically what I need to accomplish my goals -- but many may be 
added later.  By you.  I'm done with this!

Every action has two required parameters:

=over 3

=item type 

The type of the action determines what sort of action is being created.
For extending purposes, a type of C<Custom> is shorthand for 
C<Action::Generic::Custom>.  In fact, any package name may be supplied 
here, as long as it implements a few basic methods (see 'Creating Custom
Actions').  Must always be a name -- not a reference.

=item name

The name of the action.  For the most part, this is unused.  However,
the action name is available to the action during execution and is also
used in any errors that may occur (to help you track that shit down).

=back

=head2 Action Types

=over 3

=item System

The C<System> is an easy way to execute some bit of code directly via
the C<system> method.  It takes only one parameter, C<params> which
should be an arrayref containing a list of arguments for the C<system>
call.  

No checking is done to ensure you are trying to do something sane. Or
safe.  Don't be stupid.

=item Custom

C<Custom> executes some arbitrary coderef, stored in the parameter
C<code>.  

=back

=head2 Results

The hashref, obtained via the controller's C<results> method, contains
some information about the running of the actions.  

Each key is the name of the action.  You should probably make sure your
action names are unique.  I would.  But we don't check for that.  

Underneath, there is some information guaranteed to be present:

=over 3

=item type

The type of the action.  This is the fully-qualified name of the class.
In most cases, it is Action::Generic::$some_action_name

=item was_run

A boolean indicating if this particular action was actually run or not.
Useful if something horrible went wrong or the call 

=back

=head2 Creating Custom Actions

Actions may be created two different ways.  The C<action> method will
first look for plugins located in Action::Generic::Plugin namespace.

Failing that, it will attempt to C<require> the action type as a
fully-qualified package.  In both cases, the resulting object must provide
a few behaviours.  The actions distributed with this package are written in
Moose and use that particular terminology.  This author suggests any
additional actions also use Moose.

The constructor C<new()> will be called with the arguments passed from 
the C<action()> method on the controller, with the C<type> removed 
(you already know what sort of thingy you're dealing with if you're
making a new one, right?).

=over 3

=item A C<name> attribute.  

This should be a 'Str'.

=item A C<_results> attribute. 

This should be a 'HashRef'.  The controller object will query each 
action, after running, for the results.  Additionally, there should be
two keys in the C<_result> hashref, as described in the section "Results".

Additional information is encouraged where appropriate.

=item A method, C<run()> must be present.  

C<run()> will be called with no arguments.  Configuration should be done
when creating the object, not running it.  C<run()> should probably use
the opportunity to set up the C<_results> hashref properly.  

=back

=head1 LICSENSE AND COPYING

Distributed under the same terms as Perl itself.

=head1 BUGS

Probably.  Patches welcome!

=head1 AUTHOR

Dave Houston C<< <dhouston@cpan.org> >>, 2010

=cut

1;
