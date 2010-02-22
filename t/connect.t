#!/icg/bin/perl

use Test::More tests => 3;
use LiquidPlanner;
use ICG::Credentials;

my $lp = LiquidPlanner->new();
ok($lp);
my $account = $lp->get_object('account');
ok($account);
is($account->{company}, "IC Group", "fetch company name");

1;
