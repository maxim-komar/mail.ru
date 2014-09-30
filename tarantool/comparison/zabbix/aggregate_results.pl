#!/usr/bin/perl -w
use strict;

my $pat = qr/^mytasks\.(\d+)\.(\d+)\.part\d+\t(\d+)\t(\S+)/;
my %h;
while(<>){
    next unless $_ =~ $pat;
    my ($from, $to, $count, $time) = ($1, $2, $3, $4);
    $h{"$from - $to"}{count} += $count;
    $h{"$from - $to"}{time} += $time;
}

foreach(keys %h){
    printf "%s\t%.6f\n", $_, $h{$_}{time} / $h{$_}{count};
}
