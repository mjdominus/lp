#!/icg/bin/perl

use Test::More tests => 4;
use LiquidPlanner;

my $lp = LiquidPlanner->new();
ok($lp);
my $account = $lp->get_object('Mxyzptlk');
ok(! $account);
my $err = $lp->get_error();
ok($err);
is($err->{type}, "Error", "yup, it's an error");

1;
