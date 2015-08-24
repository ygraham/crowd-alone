#!/usr/bin/perl;

# Copyright 2015 Yvette Graham 
# 
# This file is part of Crowd-Alone.
# 
# Crowd-Alone is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Crowd-Alone is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Crowd-Alone.  If not, see <http://www.gnu.org/licenses/>

use strict;

my $src = $ARGV[0]; 	
my $trg = $ARGV[1]; 	
my $item = $ARGV[2];
my $num_hits = $ARGV[3];

my $use = "usage: perl mturk-hits-csv.pl src trg fl|ad";

if((($src !~ /^es|en|cs|fr|de|ru$/) || ($trg !~ /^es|en|cs|fr|de|ru$/)) || ($item !~ /^fl|ad|ad-k1|ad-k2$/)){
  print STDERR "$use \n"; exit 1;
}

# skip header
<STDIN>;

my $hit_size = 100;
my $i=0; 
my @hits;
my $l;

while($i<$num_hits){

  $hits[$i] = "";

  for( my $j=0; ($j<$hit_size)&&($l = <STDIN>) ; $j++ ){

    chomp($l);
    $l =~ s/\t/,/g;
    $hits[$i] .= $l;   
  
    if( $j != ($hit_size-1) ){
      $hits[$i] .= ",";
    }
  }

  $i++;
}

# HEADER
print "src,trg,item,";

for my $i (0..($hit_size-1)){
  print "sys_id_$i,sid_$i,tst_$i,rid_$i";

  if( $i != ($hit_size-1) ){
    print ",";
  }
}

print "\n";

# hits
my $inf_str = "$src,$trg,$item,";

foreach my $h (@hits){

  print "$inf_str".$h."\n";

}

