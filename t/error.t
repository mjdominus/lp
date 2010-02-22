#!/icg/bin/perl

use Test::More tests => 7;
use LiquidPlanner;

my $lp = LiquidPlanner->new();
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

1;
