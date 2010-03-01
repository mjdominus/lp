#!/icg/bin/perl

use Test::More tests => 9;
use LiquidPlanner;
use LiquidPlanner::Test;

my $lp = connection();
ok($lp);
my $account = $lp->get_object('Mxyzptlk');
ok(! $account);
my $err = $lp->get_error();
ok($err);
is($err->{type}, "Error", "yup, it's an error");

$lp->set_autofail(1);
eval { $lp->get_object('Mxyzptlk') };
ok($@, "autofail threw exception");
like($@, qr/(?i)bad request/);

$lp->set_autofail(0);
eval { $lp->get_object('Mxyzptlk') };
ok(! $@, "no autofail, so no exception");

{ my $lp2 = LiquidPlanner->new(autofail => 1);
  ok($lp2);
  ok($lp2->autofail, "constructor autofail option");
}

1;
