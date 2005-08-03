#!perl -w
# -*- coding: utf-8-unix; tab-width: 4; -*-
package warnings::DynamicScope;

# DynamicScope.pm
# ------------------------------------------------------------------------
# Revision: $Id: DynamicScope.pm,v 1.3 2005/08/03 22:25:43 kay Exp $
# Written by Keitaro Miyazaki<KHC03156@nifty.ne.jp>
# Copyright 2005 Keitaro Miyazaki All Rights Reserved.

# HISTORY
# ------------------------------------------------------------------------
# 2005-08-04 Version 1.0.0
#            - Initial version.

use 5.008;
use strict;
use warnings;

our $VERSION = '1.00';
our $REVISION = '$Id: DynamicScope.pm,v 1.3 2005/08/03 22:25:43 kay Exp $';

#-------------------------------------------------------------------------
# Base module(Tied Hash)
#-------------------------------------------------------------------------
package warnings::DynamicScope::WARNINGS_HASH;
use Tie::Hash;
use base "Tie::Hash";
use Symbol::Values 'symbol';

#-------------------------------------------------------------------------
# Variables
#
our $STATUS; # alias of ${^WARNING_BITS}
our (
	 %Bits,		# bitmask on/off
	 %DeadBits,	# bitmask if fatal or not.
	 %Offsets	# bit offset beggining from the string.
	);

#-------------------------------------------------------------------------
# Some aliases
#
no warnings 'Symbol::Values';
symbol('STATUS')->scalar_ref	= *{^WARNING_BITS};		# $STATUS
symbol('bits')->code			= *warnings::bits;		# bits()
symbol('Bits')->hash_ref		= *warnings::Bits;		# %Bits
symbol('DeadBits')->hash_ref	= *warnings::DeadBits;	# %DeadBits # Fatal?
symbol('Offsets')->hash_ref		= *warnings::Offsets;	# %Offsets
use warnings 'Symbol::Values';

#-------------------------------------------------------------------------
# Code
#
INIT {
	__PACKAGE__->STORE('all', $^W);
}

sub TIEHASH {
	my $self;
	bless \$self
}

sub FETCH {
	my ($self, $key) = @_;
	return undef unless exists $Bits{$key};
	my $flag  = vec($STATUS, $Offsets{$key}, 1);
    my $fatal = vec($STATUS, $Offsets{$key}+1, 1);

	$flag
		? $fatal ? 2 : 1
		: 0
}

sub STORE {
	my ($self, $key, $value) = @_;

	unless (exists $Bits{$key})
		{ warnings::Croaker("Unknown warnings category '$key'")}
	
	if (length($Bits{all}) > length($STATUS)) {
		my $new_str = ($STATUS | ("\0" x length($Bits{all})));
		symbol("STATUS")->scalar_ref =  \$new_str;
	}
	
	if ($value) {
		$STATUS |= $Bits{$key};
	} else {
		$STATUS &= ~($Bits{$key});
	}

	if ($key eq 'all') {
		symbol('^W')->scalar = $value ? 1 : 0;
	}

	return vec($STATUS, $Offsets{$key}, 1)
}

sub FIRSTKEY {
	my $self = shift;
	scalar each %Bits
}

sub NEXTKEY {
	my($self, $lastkey) = @_;
	scalar each %Bits
}

sub EXISTS {
	my($self, $key) = @_;
	exists $Bits{$key}
}

sub DELETE {
	my($self, $key) = @_;

	unless (exists $Bits{$key})
		{ warnings::Croaker("Unknown warnings category '$key'")}

	vec($STATUS, $Offsets{$key}, 1) = 0
}

sub CLEAR {
	my $self = shift;
	$STATUS = $warnings::NONE;
	undef
}

sub SCALAR {
	my $self = shift;
	scalar %Bits
}

sub DESTROY {
	$STATUS = $warnings::NONE;
}

#-------------------------------------------------------------------------
# $^W
#-------------------------------------------------------------------------
package warnings::DynamicScope::WARNINGS_SCALAR;
use Tie::Scalar ();
use Symbol::Values 'symbol';
use base "Tie::Scalar";

sub TIESCALAR {
	my $self = symbol('^W')->scalar_ref;
	bless \$self;
}

sub FETCH {
	${$_[0]}
}

sub STORE {
	my($self, $val) = @_;
	${$self} = $val;

	if ($val) {
		$^W{all} = 1;
	} else {
		$^W{all} = 0;
	}
	${$self}
}

sub DESTROY {
}

#-------------------------------------------------------------------------
# Initialize
#-------------------------------------------------------------------------
package warnings::DynamicScope;


BEGIN {
	tie $^W, "warnings::DynamicScope::WARNINGS_SCALAR";
	tie %^W, "warnings::DynamicScope::WARNINGS_HASH";
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

warnings::DynamicScope - Provides warning categories in dynamic scope.

=head1 SYNOPSIS

  require warnings::DynamicScope;

  package GrandMother;
  use warnings::register;
  
  sub deliver {
      my $self;
      $^W{GrandMother} && warn "You have warned by grandma.";
      bless \$self;
  }
  
  package Mother;
  use base "GrandMother";
  use warnings::register;
  
  sub deliver {
      $^W{Mother} && warn "You have warned by mom.";
      $_[0]->SUPER::deliver();
  }
  
  package main;
  
  $^W = 1;
  $^W{GrandMother} = 0;
  
  my $me = Mother->deliver(); # => You have warned by mom.
  
=head1 DESCRIPTION

This module provides warning categories in dynamic scope
through the variable "%^W".

You can use it like special variable "$^W":

 require warnings::DynamicScope;

 package MyPkg;
 use warnings::register;
 
 sub my_func {
     if ($^W{MyPkg}) {
         print "Don't do it!!\n";
     } else {
         print "That's fine\n";
     }
 }
 
 package main;
 $^W = 1;

 {
     local $^W{MyPkg} = 0;
     MyPkg::my_func();
 }
 MyPkg::my_func();

This code prints:

 That's fine.
 Don't do it!!

That's all.

=over 4

=item OBJECTIVE

The reason why I decided to write a new module which
provides capability similar to warnings pragma
is that I found the limitation of "warnings::enabled"
and "warnings::warnif" function.

While I'm writing my module, I noticed that the code like
below will not work as I intended:

  use warnings;
  
  package GrandMother;
  use warnings::register;
  
  sub deliver {
      my $self;
      warnings::warnif("GrandMother", "You have warned by grandma.");
      bless \$self;
  }
  
  package Mother;
  use base "GrandMother";
  use warnings::register;
  
  sub deliver {
      warnings::warnif("Mother", "You have warned by mom.");
      $_[0]->SUPER::deliver();
  }
  
  package main;
  no warnings "GrandMother";
  no warnings "Mother";
  
  my $me = Mother->deliver(); # => You have warned by grandma.

In this code, I intended to inhibit warning messages from each
class "GrandMother" and "Mother".

But, if I run this code, warning in "GrandMother" class will be
emitted. So that means the information by pragma
'no warnings "GrandMother"' would not be passed to "GrandMother"
class properly.

I thought this comes from nature of these function that
these functions uses warnings information in static scope.
(They gets static scope information from stack of caller function.)

So, I started write this module.

=item VARIABLES

This modules brings new special variable called "%^W".
Yes, it is very similar to special variable "$^W"
in appearance, but these are different things.

=back

=head2 TIPS

If you don't like Perl's variable abbreviation like $^W,
try:

 use English qw(WARNING);

=head2 BUGS/LIMITATION

Most of warning categories predefined
in Perl must be set at compile time, or it will not work.

See, code below does not work:

 $^W{uninitialized} = 0;

So, you have to rewrite it as:

 BEGIN {
   $^W{uninitialized} = 0;
 }

This brings same result of:

 no warnings 'uninitialized';

and the effect of dynamic scope will be lost.

This is specification of Perl.

=head2 EXPORT

None by default.

=head1 SEE ALSO

=over 4

=item perllexwarn

Perl Lexical Warnings.

Documentation about lexical warnings.

=item warnings

Perl pragma to control optional warnings.

You can use warning categories based on lexical scope,
by using functions "warnings::enabled", etc.

=item warnings::register

warnings import function.

You can make your warning category with "warnings::register"
pragma.

=back

=head1 AUTHOR

Keitaro Miyazaki, E<lt>KHC03156@nifty.ne.jpE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Keitaro Miyazaki

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.


=cut
