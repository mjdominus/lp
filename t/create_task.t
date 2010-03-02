
use LiquidPlanner;
use Test::More tests => 1;
use LiquidPlanner::Test;

use_ok("LiquidPlanner::Context");

my $lp = connection();
my $context = $lp->new_context();

# Create a new tasklist and a new folder
my $tl = $context->create_tasklist();

# get root tasklist and look for new tasklist
{
  my $rtl = $context->default_tasklist();
  
}

# get root folder and look for new folder

# move context into the tasklist and folder

# create new task in the new context

# get task info and check task context

# get tasklist and look for task

# get folder and look for task

# destroy task

# get tasklist and look for no task

# get folder and look for no task

# destroy folder, get root folder and look for no folder

# destroy tasklist, get root tasklist and look for no tasklist