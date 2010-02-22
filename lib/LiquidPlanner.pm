
package LiquidPlanner;
use strict;
use JSON::Any;
use ICG::Credentials;
use ICG::Util::LoadModule;
use URI::URL;
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

  { my $url = $args{root_url} || $self->default_root_url();
    $self->{root_url} = URI::URL->new($url);
    $self->user_agent->set_root_url($self->{root_url});
  }

  $self->{json} = JSON::Any->new();

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

sub default_root_url { "https://app.liquidplanner.com/api" }
sub root_url { return $_[0]{root_url} }

sub _decode {
  my $self = shift;
  return $self->{json}->decode(@_);
}

sub _encode {
  my $self = shift;
  return $self->{json}->encode(@_);
}

sub get {
  my ($self, $url) = @_;
  my $response = $self->user_agent->get($url);
  if ($response->is_success) {
    my $json = $response->content;
    my $obj = $self->_decode($json);
    $self->clear_error();
    return $obj;
  } else {
    return $self->set_error($response);
  }
}

sub get_objects {
  my ($self, $type) = @_;
  my $url = $self->build_request_url($type);
  return $self->get($url);
}

sub get_object {
  my ($self, $type, $id) = @_;
  my $url = $self->build_request_url($type, $id);
  return $self->get($url);
}

sub build_request_url {
  my ($self, @segs) = @_;
  my $url = $self->root_url->clone;
  $url->path_segments($url->path_segments, @segs);
#  warn "# -> url is " . $url->as_string;
  return $url;
}

sub clear_error {
  my $self = shift;
  delete @{$self}{qw(error_code error_text error)};
}

# This thing should really be a subobject
sub set_error {
  my ($self, $response) = @_;
  $self->{error_code} = $response->code;
  $self->{error_text} = $response->content;
  $self->{error} = eval { $self->_decode($response->content) };
  return;
}

sub get_error {
  return $_[0]{error};
}

sub get_error_message {
  return $_[0]{error} && $_[0]{error}{message};
}

my %known_types = map { $_ => 1 }
  qw(Account Workspace Task Tasklist); # etc.

sub known_types {
  return keys %known_types;
}

sub is_known_type {
  return $known_types{$_[0]};
}


1;
