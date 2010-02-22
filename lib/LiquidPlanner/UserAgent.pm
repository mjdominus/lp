
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

# This is a bad name; too easy to confuse with ->credentials
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

sub set_root_url {
  my $self = shift;
  $self->icg_private_hash->{root_url} = shift;
}

sub root_url {
  my $self = shift;
  return $self->icg_private_hash->{root_url};
}

sub check_url {
  my ($self, $url, $exception) = @_;
  if ($self->root_url->netloc eq $url->netloc) {
    return 1;
  } elsif ($exception) {
    die $exception;
  } else {
    return;
  }
}

sub get_basic_credentials {
  my ($self, $realm, $uri, $proxy) = @_;
  $self->check_url($uri, "URL '$uri' out of bounds");
  return $self->get_credentials();
}


1;
