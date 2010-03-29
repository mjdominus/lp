
package LiquidPlanner;
use strict;
use JSON::Any;
use ICG::Credentials;
use ICG::Util::LoadModule;
use LiquidPlanner::Context;
use URI::URL;
use Carp 'croak';


# Legal %args:
#  username, password
#  credential_key (default LiquidPanner)
#  user
#  workspace_id
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
  $self->set_autofail($args{autofail});
  $self->{debug} = $args{debug};
  $self->set_default_workspace_id($args{workspace_id})
    if exists $args{workspace_id};

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
  my $req = HTTP::Request->new("GET", $url);
  return $self->request($req);
}

sub request {
  my ($self, $req) = @_;
  my $response = $self->user_agent->request($req);
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
  my ($self, @path) = @_;
  my $url = $self->build_request_url(@path);
  return $self->object_factory->build($self->get($url));
}

sub get_object {
  my ($self, @path) = @_;
  my $url = $self->build_request_url(@path);
  return $self->object_factory->build($self->get($url));
}

my %dont_infer_workspace = map {$_ => 1} qw(workspaces account);

sub build_request_url {
  my ($self, @segs) = @_;

  my $opt;
  $opt = shift @segs if ref($segs[0]) eq "HASH";

  my $url = $self->root_url->clone;
  unless ($dont_infer_workspace{$segs[0]}) {
    unshift @segs, "workspaces", $self->default_workspace_id;
  }
  $url->path_segments($url->path_segments, @segs);

  if ($opt) {
    $url->query_form(%$opt);
  }

  warn "# -> url is " . $url->as_string if $self->{debug};
  return $url;
}

sub set_default_workspace_id {
  $_[0]{workspace_id} = $_[1];
}

sub default_workspace_id {
  my $self = shift;
  if (exists $self->{workspace_id}) {
    return $self->{workspace_id} if defined $self->{workspace_id};
    croak "Missing workspace ID parameter";
  }

  my $ws = $self->get_objects("workspaces");
  if (@$ws == 1) {
    $self->set_default_workspace_id($ws->[0]{id});
  } else {
    die "Can't determine default workspace ID; aborting";
  }
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
  if ($self->autofail) {
    die $self->get_error_message || $self->{error_text} || $self->{error_code};
  } else {
    return;
  }
}

sub get_error {
  return $_[0]{error};
}

sub get_error_message {
  return $_[0]{error} && $_[0]{error}{message};
}

my %known_types = map { $_ => 1, "${_}s" => 1 }
  qw(account workspaces tasks tasklists); # etc.

sub known_types {
  return keys %known_types;
}

sub is_known_type {
  my $type = $_[1];
  return $known_types{$type};
}

sub set_autofail {
  my ($self, $val) = @_;
  $self->{autofail} = $val;
}

sub autofail { $_[0]{autofail} }

# Todo: Add optional folder and tasklist arguments here
sub new_context {
  my $self = shift;
  my $factory = $self->context_factory();
  return $factory->new(Connection => $self, @_);
}

sub context_factory {
  require LiquidPlanner::Context;
  return "LiquidPlanner::Context";
}

sub object_factory {
  require LiquidPlanner::ObjFactory;
  return "LiquidPlanner::ObjFactory";
}

1;
