
use LiquidPlanner;
use Test::More tests => 4;
use LiquidPlanner::Test;

use_ok("LiquidPlanner::Context");

my $lp = connection();
my $context = $lp->new_context();
ok($context);
is($context->current_folder->{name}, "ICGroup API Sandbox");
is($context->current_tasklist->{name}, "ICGroup API Sandbox");
