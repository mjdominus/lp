#!/icg/bin/perl

use Test::More tests => 12;
use LiquidPlanner;

my $lp1 = LiquidPlanner->new();
ok($lp1);
my $ws = $lp1->get_objects("workspaces")->[0];
ok($ws);
my $rfid = $ws->{root_folder_id};
ok($rfid);

{ # Implicit workspace
  my $lp2 = LiquidPlanner->new();
  my $rf = $lp2->get_object('folders', $rfid);
  ok($rf);
  is($rf->{type}, "Folder");

  # Does this still work?
  my $ac = $lp2->get_object('account');
  ok($ac);
  is($ac->{type}, "Member");
}

{ # Explicit workspace
  my $lp2 = LiquidPlanner->new();
  my $rf = $lp2->get_object('workspaces', $ws->{id}, 'folders', $rfid);
  ok($rf);
  is($rf->{type}, "Folder");
}

{ # Explicit workspace is required?
  my $lp2 = LiquidPlanner->new();
  $lp2->set_default_workspace_id(undef);
  eval { $lp2->get_object('folders', $rfid) };
  ok($@);  # Fails because object is not allowed to infer ws id
}

{ # Explicitly set default ws
  my $lp2 = LiquidPlanner->new();
  $lp2->set_default_workspace_id($ws->{id});
  my $rf = $lp2->get_object('folders', $rfid);
  ok($rf);
  is($rf->{type}, "Folder");
}


