
package LiquidPlanner::UserAgent;
use base LWP::UserAgent;

sub new {
  my ($class, %args) = @_;
  my $self = $class->SUPER::new();
  $self->_setup_icg_private_hash(\%args);
  return $self;
}

sub set_credentials {
  my ($self, $u, $p) = @_;
  $self->icg_private_hash->{User} = $u;
  $self->icg_private_hash->{Pass} = $p;
}

sub get_credentials {
  my $self = shift;
  my $h = $self->icg_private_hash();
  return ($h->{User}, $h->{Pass});
}

sub _setup_icg_private_hash {
  $_[0]{ICG_PRIVATE} = $_[1];
}

sub icg_private_hash {
  return $_[0]{ICG_PRIVATE};
}

1;
