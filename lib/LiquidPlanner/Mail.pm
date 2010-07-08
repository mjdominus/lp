#                                                                -*- cperl -*-

package LiquidPlanner::Mail;
use strict;
use Carp 'croak';
use Scalar::Util 'blessed';

# expecting args to contain:
#   container: target container, a LiquidPlanner::Object object, or
#   address: target address
#
#   task_name: string  (required)
#   owner: string      (required; should have been optional)
#   estimate: string?  (optional)
#   notes: string or [string array] (optional)
#   from: string       (optional)
sub new_task {
  my ($class, $args) = @_;

  my $self = { %{$args || {}} };
  bless $self => $class;
  $self->_acquire_target_address;

  $self->_validate;

  return $self;
}

sub _acquire_target_address {
  my $self = shift;
  return if exists $self->{address};
  unless (exists $self->{container}) {
    croak "No target container specified";
  }

  # Not implemented yet
  $self->{address} = $self->{container}->target_email_address;
}

sub _validate {
  my $self = shift;
  my @fail;
  my %x_key = map { $_ => 1 } qw(container address task_name owner
                                 estimate notes from);

  exists $self->{address} or push @fail, "No target container specified";
  exists $self->{task_name} or push @fail, "No task name specified";
  exists $self->{owner} or push @fail, "No owner name specified";

  for my $k (keys %$self) {
    $x_key{$k} or push @fail, "Unknown argument '$k'";
  }

  croak(join "; ", @fail) if @fail;
}

sub message {
  my $self = shift;

  my $header = $self->header;
  my $body = $self->body;
  my $attributes = $self->attributes;

  return $self->message_factory
    ->create(header => $header,
             parts => $body,
             attributes => $attributes,
            );
}

sub message_text { $_[0]->message->as_string }

sub message_factory {
  require Email::MIME::Creator;
  Email::MIME::Creator->import();
  return "Email::MIME";
}

sub message_part_factory {
  require Email::MIME::Creator;
  Email::MIME::Creator->import();
  return "Email::MIME";
}

sub attributes { return {} }

sub header {
  my $self = shift;

  return [ From => $self->header_from,
           To => $self->header_to,
           Subject => $self->header_subject,
         ];
}

sub header_from {
  my $self = shift;
  return $self->{from} || "nobody\@icgroup.com"
}

sub header_to {
  my $self = shift;
#  return "mjd\@pobox.com";
  return $self->{address};
}

sub header_subject {
  my $self = shift;
  my @items = ($self->task_name, $self->owner, $self->estimate_string);
  pop @items while @items && $items[-1] =~ /^\s*$/;
  return join ",", @items;
}

sub estimate_string {
  my $self = shift;
  my $est = $self->estimate;
  return "" unless defined $est;
  return blessed $est ? $est->as_string : $est;
}


sub body {
  my $self = shift;

  my $part = $self->message_part_factory->create
    (attributes =>
     { content_type => 'text/plain',
       disposition => "attachment",
       charset => "US-ASCII",
     },
     body => $self->notes || "",
     );
  return $self->notes ? [ $part ] : [];
}

sub task_name { $_[0]{task_name} }
sub owner { $_[0]{owner} }
sub estimate { $_[0]{estimate} }
sub notes {
  my $self = shift;
  my $n = $self->{notes};
  return "" unless defined $n;
  $n = join "\n", @$n, "" if ref $n;
  return $n;
}

1;
