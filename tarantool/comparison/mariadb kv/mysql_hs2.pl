#!/usr/bin/perl -w
use strict;

use Net::HandlerSocket;
use Time::HiRes 'gettimeofday';
use Data::Dumper;

my ($itemid, $clock, $iter) = @ARGV;

my $hs = new Net::HandlerSocket({ host => '127.0.0.1', port => 9999 });
my $r0 = $hs->open_index(0, 'test', 'trends_uint', 'PRIMARY', 'itemid,clock,value_avg');


my $st = gettimeofday;
for(my $i = 0; $i < $iter; $i++){
    $hs->execute_single(0, '=', [$itemid, $clock], 1, 0);
}
my $ft = gettimeofday;

printf "%s\t%d\t%d\t%d\t%.4f\t%.6f\n", $0, $itemid, $clock, $iter, ($ft - $st), ($ft - $st) / $iter;
