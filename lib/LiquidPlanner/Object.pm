package LiquidPlanner::Object;
use Carp 'croak';

# Abstract base class for objects that represent various LP entities

sub new {
  my ($class, $attr) = @_;
  if ($class eq __PACKAGE__) {
    croak "Attempt to instantiate abstract class '$class'";
  }
  bless { %$attr } => $class;
}

sub children {
  die "Unimplemented";
}

sub id { $_[0]{id} }

1;
