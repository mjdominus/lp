
use LiquidPlanner;
use Test::More tests => 4;
use LiquidPlanner::Test;

use_ok("LiquidPlanner::Context");

my $lp = connection();
my $context = $lp->new_context();
ok($context);
is($context->current_folder->{name}, test_space_name());
is($context->current_tasklist->{name}, test_space_name());
