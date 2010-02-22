
package LiquidPlanner;
use JSON::Any;
use ICG::Credentials;
use ICG::Util::LoadModule;
use Carp 'croak';

# Legal %args:
#  username, password
#  credential_key (default LiquidPanner)
#  user
sub new {
  my ($class, %args) = @_;
  my $self = bless {} => $class;

  my ($u, $p) = $self->locate_credentials(%args);

  {
    my $uaf = $args{user_agent_factory} || $class->userAgentFactory();
    load_module($uaf);
    my $ua = $uaf->new();
    $ua->set_credentials($u, $p);
    $self->set_user_agent($ua);
  }

  return $self;
}

sub userAgentFactory {
  return "LiquidPlanner::UserAgent";
}

sub default_credentials_key {
  return 'LiquidPlanner';
}

sub locate_credentials {
  my ($self, %args) = @_;
  my ($u, $p) = @args{'username', 'password'};
  my $key = $args{credential_key} || $self->default_credentials_key();

  unless ($u && $p) {
    my ($cu, $cp) = get_credentials($key);
    $u ||= $cu;
    $p ||= $cp;
  }

  if (! $u) {
    croak "Couldn't get username for default credentials key '$key'; aborting";
  }
  if (! $p) {
    croak "Couldn't get password for default credentials key '$key'; aborting";
  }

  return ($u, $p);
}

sub get_credentials_hash {
  my $self = shift;
  my ($u, $p) = $self->user_agent->get_credentials();
  my %h = (User => $u, Pass => $p);
  return wantarray() ? %h : \%h;
}

sub set_user_agent {
  my ($self, $ua) = @_;
  $self->{UA} = $ua;
}

sub user_agent { $_[0]{UA} }

1;
