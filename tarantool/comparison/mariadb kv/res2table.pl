#!/usr/bin/perl -w
use strict;

my %h = ();
while(<>){
    chomp;
    # ./mysql.pl    23348   1409515200  1000000 191.3516    0.000191
    my ($file, $itemid, $clock, $iter, $total_time, $row_time) = split /\t/;
    next unless $file;
    $h{$file}{iter} += $iter;
    $h{$file}{total} += $total_time;
}

print "| solution | select time, us|\n";
print "|----------|----------------|\n";
foreach(sort keys %h){
    printf "| %s | %d |\n", $_, ($h{$_}{total} / $h{$_}{iter}) * 1000000;
}
