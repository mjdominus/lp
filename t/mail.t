use strict;
use LiquidPlanner::Mail;
use POSIX 'strftime';
use Test::More;

my $target = do {
  my($f, $t);
  local  $/;
  open $f, "<", "t.dat/test-target-address" and
  chomp($t = <$f>), $t and
  $t
};

if ($target) {
  plan tests => 2;
} else {
  plan skip_all => "no target email address in t.dat/test-target-address";
}

my $date = strftime("%Y-%m-%d %T", localtime());
my $lpm = LiquidPlanner::Mail->new_task(
    {address => $target,
     task_name => "test $$ $date",
     owner => 'mjd',
    }
  );
ok($lpm, "build object");

my $message = $lpm->message;
ok($message, "build message");



