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
use POSIX;
use List::Util qw(shuffle);

my $n_hits = $ARGV[0];

my $start_id = 0;
my $num_per_hit = 7; # + 3 quality control translations
my $num_to_convert =  $n_hits * 100; 

<STDIN>; # skip header

my @systems;
my @snt_ids;
my @rnd_ids;
my @cal_rnd_ids;
my @types;
my $i = 0;
my $set;
my $index;
my $num_segs = 0;

while( (my $l = <STDIN>) && ($i<($start_id+$num_to_convert)) ){

  if( $i >= $start_id ){
    $set = floor($i/$num_per_hit);
    $index = $i - ($set*$num_per_hit);

    chomp($l);
    my @c = split(/\t/,$l);

    $systems[$set][$index] = $c[0];
    $snt_ids[$set][$index] = $c[1];
    $rnd_ids[$set][$index] = $c[2];
    $cal_rnd_ids[$set][$index] = $c[3];
    $types[$set][$index] = "system";

    $num_segs++;
  }

  $i++;
}

$num_segs -= 100;

print STDERR "Read in $i system output ids\n";

# loop through sets and add calibration according to spacing
my $cal_set_spac = 5;

my $max_hits = ($num_segs/$num_per_hit);

for( my $i=0; $i<$max_hits; $i++ ){

  # randomly select 3 sents from swap set for (i) calib (ii) ref (iii) repeat
  my $swap_set;

  if( $i < ($i-($i%(2*$cal_set_spac))+$cal_set_spac)){
    $swap_set = $i + $cal_set_spac;
  }else{
    $swap_set = $i - $cal_set_spac;
  }

  my @rnd = (0..($num_per_hit-1));
  @rnd = shuffle @rnd;

  $systems[$i][7] = $systems[$swap_set][$rnd[0]];
  $systems[$i][8] = $systems[$swap_set][$rnd[1]];
  $systems[$i][9] = $systems[$swap_set][$rnd[2]];

  $snt_ids[$i][7] = $snt_ids[$swap_set][$rnd[0]];
  $snt_ids[$i][8] = $snt_ids[$swap_set][$rnd[1]];
  $snt_ids[$i][9] = $snt_ids[$swap_set][$rnd[2]];

  $types[$i][7] = "cal";
  $types[$i][8] = "ref";
  $types[$i][9] = "repeat";

  $rnd_ids[$i][7] = $cal_rnd_ids[$swap_set][$rnd[0]];
  $rnd_ids[$i][8] = $cal_rnd_ids[$swap_set][$rnd[1]];
  $rnd_ids[$i][9] = $cal_rnd_ids[$swap_set][$rnd[2]];

}

print "system\tsnt_id\ttyp\trnd_id\n";

# shuffle only when all sets arranged
for( my $i=0; ($i<$max_hits); $i++ ){

  my @rnd = (0..($num_per_hit+2));
  @rnd = shuffle @rnd;

  my @rnd_sys;
  my @rnd_snt;
  my @rnd_typ;
  my @rnd_rid;

  foreach my $j (0..($num_per_hit+2)){
    my $r = $rnd[$j]; # essentially selects translation at random (0-9)

    # populate shuffled arrays
    $rnd_sys[$j] = $systems[$i][$r]; 
    $rnd_snt[$j] = $snt_ids[$i][$r]; 
    $rnd_typ[$j] = $types[$i][$r]; 
    $rnd_rid[$j] = $rnd_ids[$i][$r]; 
    
  }

  $systems[$i] = \@rnd_sys;
  $snt_ids[$i] = \@rnd_snt;
  $types[$i]   = \@rnd_typ;
  $rnd_ids[$i] = \@rnd_rid;

  # Print this HIT
  foreach my $j (0..($#{$systems[0]})){
    print $systems[$i][$j]."\t".$snt_ids[$i][$j]."\t".$types[$i][$j]."\t".$rnd_ids[$i][$j]."\n";
  }
}

