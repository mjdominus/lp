
package LiquidPlanner::Context;
use Carp 'croak';

#
# A context is like a working directory in LP space
# It stores a "current folder" and a "current tasklist"
#
# You can move up and down either the folder tree or the tasklist tree
# using some API I have not yet designed.

# Todo: Add optional folder and tasklist arguments here
sub new {
  my ($class, %opts) = @_;
  my $self = bless {} => $class;
  $self->{Connection} = delete $opts{Connection}
    or croak "Missing 'Connection' argument";

  $self->set_default_tasklist();
  $self->set_default_folder();
  $self->set_current_tasklist($self->default_tasklist());
  $self->set_current_folder($self->default_folder());

  return $self;
}

sub set_default_tasklist {
  my $self = shift;
  $self->{Root_Tasklist} =
    $self->get_object('tasklists',
                      $self->connection->{root_tasklist_id}
                     );
}

sub default_tasklist { $_[0]{Root_Tasklist} }

sub set_default_folder {
  my $self = shift;
  $self->{Root_Folder} =
    $self->get_object('folders',
                      $self->connection->{root_folder_id}
                     );
}

sub default_folder { $_[0]{Root_Folder} }

sub current_tasklist { $_[0]{Tasklist} }
sub set_current_tasklist { $_[0]{Tasklist} = $_[1] }
sub current_folder { $_[0]{Folder} }
sub set_current_folder { $_[0]{Folder} = $_[1] }


sub get_object {
  my $self = shift;
  return $self->connection->get_object(@_);
}

sub connection { $_[0]{Connection} }

1;
