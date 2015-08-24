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

my $f = $ARGV[0];
my $src = $ARGV[1];
my $trg = $ARGV[2];

open(F,"<$f") or die "cant open $f\n";

my %mean;
my %sd;

while( my $l = <F>){

  chomp($l);
  my $wid = $l;
  my $mean = <F>;
  my $sd = <F>;

  chomp($mean);
  chomp($sd);

  $wid =~ s/^\[1\] \"//;
  $wid =~ s/\"$//;
  $mean =~ s/^\[1\] //;
  $sd =~ s/^\[1\] //;

  $mean{$wid} = $mean;
  $sd{$wid} = $sd;

  #print "$wid\t$mean\t$sd\n"
}
close(F);

# WorkerId	src	trg	input_type	q_type	ref	src_wrds	sys_id	rid	type	sid	score	time
my $l = <STDIN>;
print $l;
my %zero_sd;

while( my $l = <STDIN>){

  if( $l =~ /$src\t$trg/ ){
    my @c = split(/\t/,$l);
    my $wid = $c[1];
    my $scr = int($c[9]);

    if( (! exists $mean{$wid}) || (! exists $sd{$wid})){
      print STDERR "error no stats for $wid\n"; exit 1;
    }

    # remove anyone with standard deviation of 0
    if( $sd{$wid} == 0 ){
      $zero_sd{$wid} = 1;
      next;
    }

    my $z_scr = ($scr-$mean{$wid})/$sd{$wid};
    my $new_scr = $z_scr;

    $c[9] = $new_scr;

    for( my $i=0; $i<scalar(@c); $i++ ){
      if( $i == (scalar(@c)-1) ){
        print $c[$i];
      }else{
        print $c[$i]."\t";
      }
    }
  }
}

print STDERR "removed ".scalar(keys(%zero_sd))." with sd of 0\n";

