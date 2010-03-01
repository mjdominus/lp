
package LiquidPlanner::Test;
use LiquidPlanner;
use base Exporter;
our @EXPORT = qw(get_test_wsid connection);

my $wsid_file = "t.dat/test-wsid";
sub get_test_wsid {
  my $data = qx{cat $wsid_file};
  $data =~ tr/0-9//cd;
  die "Couldn't get ID of default workspace from '$wsid_file'; aborting"
    unless $data;
  return $data;
}

sub connection {
  return LiquidPlanner->new(workspace_id => get_test_wsid());
}

1;
