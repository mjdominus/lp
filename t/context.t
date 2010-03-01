
use LiquidPlanner;
use Test::More tests => 4;

use_ok("LiquidPlanner::Context");

my $lp = LiquidPlanner->new() or die;
my $context = $lp->new_context();
ok($context);
is($context->current_folder->{name}, "IC Group projects");
is($context->current_tasklist->{name}, "IC Group projects");
