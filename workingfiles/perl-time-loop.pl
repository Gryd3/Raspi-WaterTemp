#!/usr/bin/perl
use strict;
my $checktime = time() + 1;
while (1) {
	while ($checktime > time()) {
		# wait here
	}
	print "One second has elapsed.\n";
	++$checktime;
}
