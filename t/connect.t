#!/icg/bin/perl

use Test::More tests => 4;
use LiquidPlanner;
use ICG::Credentials;
use LiquidPlanner::Test;

eval {
    LiquidPlanner->new()->get_object('folders', 0);
};
like($@, qr/Can't determine default workspace ID/);

my $lp = connection();

ok($lp);
my $account = $lp->get_object('account');
ok($account);
is($account->{company}, "IC Group", "fetch company name");

1;
