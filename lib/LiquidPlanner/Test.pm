
package LiquidPlanner::Test;
use LiquidPlanner;
use base Exporter;
our @EXPORT = qw(test_space_id test_space_name connection);

my $wsid_file = "t.dat/test-wsid";
sub test_space_id {
  my $data = qx{cat $wsid_file};
  $data =~ tr/0-9//cd;
  die "Couldn't get ID of default workspace from '$wsid_file'; aborting"
    unless $data;
  return $data;
}

my $wsname_file = "t.dat/test-wsname";
sub test_space_name {
  my $data = qx{cat $wsname_file};
  chomp($data);
  die "Couldn't get name of default workspace from '$wsid_file'; aborting"
    unless $data =~ /\S/;
  return $data;
}

sub connection {
  return LiquidPlanner->new(workspace_id => test_space_id());
}

1;
