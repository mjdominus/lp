#!/icg/bin/perl

use Test::More tests => 10;
use LiquidPlanner;
use LiquidPlanner::Test;


my $lp = connection();
ok($lp);

my ($a) = $lp->get_objects('workspaces');
ok($a, "get workspace array");
is(ref $a, "ARRAY", "array type");
is(@$a, 2, "two workspaces");
my $w;
for my $_w (@$a) {
  $w = $_w and last if $_w->{id} == test_space_id();
}
ok($w);
is($w->{type}, "Workspace", "workspace type");
my $id = $w->{id};
ok($id, "workspace id=$id");

my $w2 = $lp->get_object('workspaces', $id);
ok($w2, "get workspace by id");
is($w2->{type}, "Workspace", "workspace type");
my $id2 = $w2->{id};
is($id2, $id, "ids match");

1;
