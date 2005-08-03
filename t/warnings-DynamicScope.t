# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl warnings-DynamicScope.t'

# Revision: $Id: warnings-DynamicScope.t,v 1.4 2005/08/03 23:30:25 kay Exp $

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More qw(no_plan);
use Test::Exception;

my $init_value;
BEGIN {
	$init_value = $^W;
}

BEGIN { use_ok('warnings::DynamicScope') };
BEGIN { use_ok('warnings::register') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# --------------------------------------------------------------------------
# Test all and $^W

ok($^W{all} == $init_value, 'all: default');
ok($^W == $init_value, '$^W: default');

$^W = 1;

ok($^W{all} == 1, 'all and $^W: set($^W => all, 1)');
ok($^W == 1, 'all and $^W: set($^W => all, 1)');

$^W = 0;

ok($^W{all} == 0, 'all and $^W: set($^W => all, 0)');
ok($^W == 0, 'all and $^W: set($^W => all, 0)');

$^W{all} = 1;

ok($^W{all} == 1, 'all and $^W: set(all => $^W, 1)');
ok($^W == 1, 'all and $^W: set(all => $^W, 1)');

$^W{all} = 0;

ok($^W{all} == 0, 'all and $^W: set(all => $^W, 0)');
ok($^W == 0, 'all and $^W: set(all => $^W, 0)');

# --------------------------------------------------------------------------
# Test warnings::enabled

$^W{all} = 1;
ok(warnings::enabled('all') == 0, "all(enabled doesn't work)");

# --------------------------------------------------------------------------
# Test register;

package Test1;
use warnings::register;
package Test2;
use warnings::register;
package main;

$^W{all} = 1;

lives_ok { $^W{Test1} } "register: Test1";
lives_ok { $^W{Test2} } "register: Test2";

# --------------------------------------------------------------------------
# Test setting values.

ok($^W{Test1} == 1, "Test1: default == 1");
ok($^W{Test2} == 1, "Test2: default == 1");
ok($^W{all}  == 1,  'check: $^W{all} == 1');
ok($^W{all}  == 1,  'check: $^W == 1');

$^W{Test1} = 0;

ok($^W{Test1} == 0, "set: Test1 = 0");
ok($^W{all}  == 1,  'set: no effect($^W{all} == 1)');
ok($^W{all}  == 1,  'set: no effect($^W == 1)');

$^W{Test2} = 0;

ok($^W{Test2} == 0, "set: Test2 = 0");
ok($^W{all}  == 1,  'set: no effect($^W{all} == 1)');
ok($^W{all}  == 1,  'set: no effect($^W == 1)');

$^W{Test1} = 1;
$^W{Test2} = 1;

ok($^W{Test1} == 1, "set: Test1 = 1");
ok($^W{Test2} == 1, "set: Test2 = 1");
ok($^W{all}  == 1,  'set: no effect($^W{all} == 1)');
ok($^W{all}  == 1,  'set: no effect($^W == 1)');

$^W = 0;

ok($^W{Test1} == 0, 'set: $^W => Test1, 0');
ok($^W{Test2} == 0, 'set: $^W => Test2, 0');
ok($^W == 0,        'set: $^W => $^W,   0');
ok($^W{all} == 0,   'set: $^W => all,   0');

$^W = 1;

ok($^W{Test1} == 1, 'set: $^W => Test1, 1');
ok($^W{Test2} == 1, 'set: $^W => Test2, 1');
ok($^W == 1,        'set: $^W => $^W,   1');
ok($^W{all} == 1,   'set: $^W => all,   1');

$^W{all} = 0;

ok($^W{Test1} == 0, "set: all => Test1, 0");
ok($^W{Test2} == 0, "set: all => Test2, 0");
ok($^W == 0,        'set: all => $^W,   0');
ok($^W{all} == 0,   'set: all => all,   0');

$^W{all} = 1;

ok($^W{Test1} == 1, "set: all => Test1, 1");
ok($^W{Test2} == 1, "set: all => Test2, 1");
ok($^W == 1,        'set: all => $^W,   1');
ok($^W{all} == 1,   'set: all => all,   1');

$^W = 0;

$^W{Test1} = 1;

ok($^W{Test1} == 1, "set: Test1 = 1");
ok($^W{all}  == 0,  'set: no effect($^W{all} == 0)');
ok($^W{all}  == 0,  'set: no effect($^W == 0)');

$^W{Test2} = 1;

ok($^W{Test2} == 1, "set: Test2 = 1");
ok($^W{all}  == 0,  'set: no effect($^W{all} == 0)');
ok($^W{all}  == 0,  'set: no effect($^W == 0)');

# --------------------------------------------------------------------------
# Test scope

$^W = 0;
{
	$^W = 1;

	ok($^W{Test1} == 1, 'scope in:  $^W => Test1, 1');
	ok($^W{Test2} == 1, 'scope in:  $^W => Test2, 1');
	ok($^W == 1,        'scope in:  $^W => $^W,   1');
	ok($^W{all} == 1,   'scope in:  $^W => all,   1');
}

ok($^W{Test1} == 1, 'scope out: $^W => Test1, 1');
ok($^W{Test2} == 1, 'scope out: $^W => Test2, 1');
ok($^W == 1,        'scope out: $^W => $^W,   1');
ok($^W{all} == 1,   'scope out: $^W => all,   1');

# --------------------------------------------------------------------------

$^W{all} = 0;
{
	$^W{all} = 1;

	ok($^W{Test1} == 1, 'scope in:  all => Test1, 1');
	ok($^W{Test2} == 1, 'scope in:  all => Test2, 1');
	ok($^W == 1,        'scope in:  all => $^W,   1');
	ok($^W{all} == 1,   'scope in:  all => all,   1');
}

ok($^W{Test1} == 1, 'scope out: all => Test1, 1');
ok($^W{Test2} == 1, 'scope out: all => Test2, 1');
ok($^W == 1,        'scope out: all => $^W,   1');
ok($^W{all} == 1,   'scope out: all => all,   1');

# --------------------------------------------------------------------------

$^W = 0;
$^W{Test1} = 0;
$^W{Test2} = 0;
{
	$^W{Test1} = 1;
	$^W{Test2} = 1;
	
	ok($^W{Test1} == 1, 'scope in:  Test1 = 1');
	ok($^W{Test2} == 1, 'scope in:  Test2 = 1');
	ok($^W == 0,        'scope in:  $^W  == 0');
	ok($^W{all} == 0,   'scope in:  all  == 0');
}

ok($^W{Test1} == 1, 'scope out: Test1 = 1');
ok($^W{Test2} == 1, 'scope out: Test2 = 1');
ok($^W == 0,        'scope out: $^W  == 0');
ok($^W{all} == 0,   'scope out: all  == 0');

# --------------------------------------------------------------------------
# Test simple dynamic scope

$^W = 1;
$^W{all} = 1;
${Test1} = 1;
${Test2} = 1;

{
	local $^W;
	local $^W{all};
	local ${Test1};
	local ${Test2};

	ok($^W{Test1} == 0, 'dscope in:  default == 0');
	ok($^W{Test2} == 0, 'dscope in:  default == 0');
	ok($^W == 0,        'dscope in:  default == 0');
	ok($^W{all} == 0,   'dscope in:  default == 0');
}

ok($^W{Test1} == 1, 'dscope out: Test1 == 1');
ok($^W{Test2} == 1, 'dscope out: Test2 == 1');
ok($^W == 1,        'dscope out: $^W   == 1');
ok($^W{all} == 1,   'dscope out: all   == 1');

# --------------------------------------------------------------------------

$^W = 1;
$^W{all} = 1;
${Test1} = 1;
${Test2} = 1;

{
	local $^W;

	ok($^W{Test1} == 0, 'dscope in:  Test1 initialized to 0 by local $^W');
	ok($^W{Test2} == 0, 'dscope in:  Test2 initialized to 0 by local $^W');
	ok($^W == 0,        'dscope in:  $^W   initialized to 0 by local $^W');
	ok($^W{all} == 0,   'dscope in:  all   initialized to 0 by local $^W');
}

ok($^W{Test1} == 1, 'dscope out: Test1 == 1');
ok($^W{Test2} == 1, 'dscope out: Test2 == 1');
ok($^W == 1,        'dscope out: $^W   == 1');
ok($^W{all} == 1,   'dscope out: all   == 1');

# --------------------------------------------------------------------------

$^W = 0;
$^W{all} = 0;
${Test1} = 0;
${Test2} = 0;

{
	local $^W = 1;

	ok($^W{Test1} == 1, 'dscope in:  Test1 set to 1 by local $^W');
	ok($^W{Test2} == 1, 'dscope in:  Test2 set to 1 by local $^W');
	ok($^W == 1,        'dscope in:  $^W   set to 1 by local $^W');
	ok($^W{all} == 1,   'dscope in:  all   set to 1 by local $^W');
}

ok($^W{Test1} == 0, 'dscope out: Test1 == 0');
ok($^W{Test2} == 0, 'dscope out: Test2 == 0');
ok($^W == 0,        'dscope out: $^W   == 0');
ok($^W{all} == 0,   'dscope out: all   == 0');

# --------------------------------------------------------------------------

$^W = 0;
{
	local $^W = 1;

	ok($^W{Test1} == 1, 'dscope in:  $^W => Test1, 1');
	ok($^W{Test2} == 1, 'dscope in:  $^W => Test2, 1');
	ok($^W == 1,        'dscope in:  $^W => $^W,   1');
	ok($^W{all} == 1,   'dscope in:  $^W => all,   1');
}

ok($^W{Test1} == 0, 'dscope out: $^W => Test1, 0');
ok($^W{Test2} == 0, 'dscope out: $^W => Test2, 0');
ok($^W == 0,        'dscope out: $^W => $^W,   0');
ok($^W{all} == 0,   'dscope out: $^W => all,   0');

# --------------------------------------------------------------------------

$^W{all} = 0;
{
	local $^W{all} = 1;

	ok($^W{Test1} == 1, 'dscope  in: all => Test1, 1');
	ok($^W{Test2} == 1, 'dscope  in: all => Test2, 1');
	ok($^W == 1,        'dscope  in: all => $^W,   1');
	ok($^W{all} == 1,   'dscope  in: all => all,   1');
}

ok($^W{Test1} == 0, 'dscope out: all => Test1, 0');
ok($^W{Test2} == 0, 'dscope out: all => Test2, 0');
ok($^W == 0,        'dscope out: all => $^W,   0');
ok($^W{all} == 0,   'dscope out: all => all,   0');

# --------------------------------------------------------------------------

$^W = 0;
$^W{Test1} = 0;
$^W{Test2} = 0;
{
	local $^W{Test1} = 1;
	local $^W{Test2} = 1;
	
	ok($^W{Test1} == 1, 'scope in:  Test1 = 1');
	ok($^W{Test2} == 1, 'scope in:  Test2 = 1');
	ok($^W == 0,        'scope in:  $^W  == 0');
	ok($^W{all} == 0,   'scope in:  all  == 0');
}

ok($^W{Test1} == 0, 'scope out: Test1 = 0');
ok($^W{Test2} == 0, 'scope out: Test2 = 0');
ok($^W == 0,        'scope out: $^W  == 0');
ok($^W{all} == 0,   'scope out: all  == 0');

# --------------------------------------------------------------------------
# Test recursive call - 1

my $cnt = 90;
$^W{Test1} = 0;
$^W{Test2} = 0;
sub recursive1 {
	if (--$cnt == 0) {
		ok($^W{Test1} == 1, 'recursive1 in: Test1 == 1');
		ok($^W{Test2} == 1, 'recursive1 in: Test2 == 1');
	} else {
		recursive1();
	}
}
$^W{Test1} = 1;
$^W{Test2} = 1;

ok($^W{Test1} == 1, 'recursive1 before: Test1 == 1');
ok($^W{Test2} == 1, 'recursive1 before: Test2 == 1');

recursive1();

ok($^W{Test1} == 1, 'recursive1 before: Test1 == 1');
ok($^W{Test2} == 1, 'recursive1 before: Test2 == 1');

# --------------------------------------------------------------------------
# Test recursive call - 2

$cnt = 90;
$^W{Test1} = 0;
$^W{Test2} = 0;
sub recursive2 {
	if (--$cnt == 0) {
		ok($^W{Test1} == 0, 'recursive2 in: Test1 == 1');
		ok($^W{Test2} == 0, 'recursive2 in: Test2 == 1');
	} else {
		recursive2();
	}
}
$^W{Test1} = 0;
$^W{Test2} = 0;

ok($^W{Test1} == 0, 'recursive2 before: Test1 == 0');
ok($^W{Test2} == 0, 'recursive2 before: Test2 == 0');

recursive2();

ok($^W{Test1} == 0, 'recursive2 before: Test1 == 0');
ok($^W{Test2} == 0, 'recursive2 before: Test2 == 0');

# --------------------------------------------------------------------------
# Test recursive call - 3

$cnt = 90;
$^W{Test1} = 0;
$^W{Test2} = 0;
sub recursive3 {
	if (--$cnt == 0) {
		ok($^W{Test1} == 0, 'recursive3 in: Test1 == 0');
		ok($^W{Test2} == 0, 'recursive3 in: Test2 == 0');
	} else {
		local $^W{Test1} = 0;
		local $^W{Test2} = 0;
		recursive3();
	}
}
$^W{Test1} = 1;
$^W{Test2} = 1;

ok($^W{Test1} == 1, 'recursive3 before: Test1 == 1');
ok($^W{Test2} == 1, 'recursive3 before: Test2 == 1');

recursive3();

ok($^W{Test1} == 1, 'recursive3 before: Test1 == 1');
ok($^W{Test2} == 1, 'recursive3 before: Test2 == 1');

# --------------------------------------------------------------------------
# Test recursive call - 4

$cnt = 90;
$^W{Test1} = 0;
$^W{Test2} = 0;
sub recursive4 {
	if (--$cnt == 0) {
		ok($^W{Test1} == 1, 'recursive4 in: Test1 == 1');
		ok($^W{Test2} == 1, 'recursive4 in: Test2 == 1');
	} else {
		local $^W{Test1} = 1;
		local $^W{Test2} = 1;
		recursive4();
	}
}
$^W{Test1} = 0;
$^W{Test2} = 0;

ok($^W{Test1} == 0, 'recursive4 before: Test1 == 0');
ok($^W{Test2} == 0, 'recursive4 before: Test2 == 0');

recursive4();

ok($^W{Test1} == 0, 'recursive4 before: Test1 == 0');
ok($^W{Test2} == 0, 'recursive4 before: Test2 == 0');

# --------------------------------------------------------------------------
# Test class hierarchy

package Test1;
sub new {
	die "In Test1" if $^W{Test1};
}

package Test2;
our @ISA = 'Test1';
sub new {
	die "In Test2" if $^W{Test2};
	$_[0]->SUPER::new;
}

package main;

$^W{Test1} = 0;
$^W{Test2} = 0;
lives_ok { Test2->new() } "heirarchey 1";

$^W{Test1} = 1;
$^W{Test2} = 0;
dies_ok { Test2->new() } "heirarchey 2";
ok($@ =~ /^In Test1/, "heirarchey 2");

$^W{Test1} = 1;
$^W{Test2} = 1;
dies_ok { Test2->new() } "heirarchey 2";
ok($@ =~ /^In Test2/, "heirarchey 2");

# --------------------------------------------------------------------------
# Test bad category

dies_ok { $^W{unknown_cat} = 1 } 'Bad category(die)';

ok($@ =~ /^Unknown warnings category 'unknown_cat'/,
   'Bad category(error message)');

# --------------------------------------------------------------------------
# Test as pragma

my $dummy;
my $uninit1;

use warnings FATAL => 'uninitialized';

use warnings;

dies_ok { $dummy = $uninit1 . "" } "pragma";

BEGIN {
	$^W{uninitialized} = 0;
}

my $uninit2;
lives_ok { $dummy = $uninit2 . "" } "pragma";

BEGIN {
	$^W{uninitialized} = 1;
}

my $uninit3;
dies_ok { $dummy = $uninit3 . "" } "pragma";

no warnings FATAL => 'uninitialized';
