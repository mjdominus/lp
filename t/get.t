#!/icg/bin/perl

use Test::More tests => 9;
use LiquidPlanner;

my $lp = LiquidPlanner->new();
ok($lp);

my ($a) = $lp->get_objects('workspaces');
ok($a, "get workspace array");
is(ref $a, "ARRAY", "array type");
is(@$a, 1, "unique workspace");
my $w = $a->[0];
is($w->{type}, "Workspace", "workspace type");
my $id = $w->{id};
ok($id, "workspace id=$id");

my $w2 = $lp->get_object('workspaces', $id);
ok($w2, "get workspace by id");
is($w2->{type}, "Workspace", "workspace type");
my $id2 = $w2->{id};
is($id2, $id, "ids match");

1;
