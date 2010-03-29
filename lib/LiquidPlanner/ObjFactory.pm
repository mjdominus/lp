
package LiquidPlanner::ObjFactory;
use Carp 'croak';

sub new {
  my $class = shift;
  bless {} => $class;
}

sub build {
  my ($self, $hash) = @_;
  my $type = $hash->{type}
    or croak ref($self), " couldn't infer type of object";
  return $self->build_type($type, $hash);
}

sub build_type {
  my ($self, $type, $hash) = @_;
  my $class = _type_class($type)
    or croak "Don't know how to handle object of type '$type'";
  return $class->new($hash);
}

sub _type_class {
  my $type = shift();
  my $cl = do {
    if ($type eq "Snork") { "Blork" }
    else { $type }
  };
  $cl = "LiquidPlanner::Object::$cl" unless $cl =~ /::/;
  _load_module($cl);
  return $cl;
}

sub _load_module {
  my $m = shift;
  $m =~ s{::}{/}g;
  require "$m.pm";
}

1;
