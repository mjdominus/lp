
use Test::More tests => 5;

$ENV{ICG_CREDENTIALS} = 't.dat/test-credentials';

use_ok('LiquidPlanner');
my $lp = LiquidPlanner->new();
ok($lp);

{
  my %c = $lp->get_credentials_hash();
  is($c{User}, "dummyUsername");
  is($c{Pass}, "dummyPassword");
  is(keys(%c), 2);
}
