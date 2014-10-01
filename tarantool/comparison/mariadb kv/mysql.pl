#!/usr/bin/perl -w
use strict;
use DBI;
use Time::HiRes 'gettimeofday';

my ($itemid, $clock, $iter) = @ARGV;
my $dbh = DBI->connect('dbi:mysql:database=test', 'testuser', 'testpass', { RaiseError => 1 });

my $st = gettimeofday;
for(my $i = 0; $i < $iter; $i++){
    $dbh->selectall_arrayref('select * from trends_uint where itemid=? and clock=?', undef, $itemid, $clock);
}
my $ft = gettimeofday;

printf "%d\t%d\t%d\t%.4f\t%.6f\n", $itemid, $clock, $iter, ($ft - $st), ($ft - $st) / $iter;
