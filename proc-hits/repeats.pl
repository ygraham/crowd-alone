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

my %scores;
my $n;
my $sngl = 0;
my $deleted_rep = 0;

<STDIN>; # header -> 0:WorkerId	1:src	2:trg	3:input_type	4:q_type	5:ref	6:src_wrds	7:sys_id	8:rid	9:type	10:sid	11:score	12:hit_seconds

while( my $l = <STDIN>){

  chomp($l);

  my @c = split(/\t/,$l);

  my $HITId= $c[0];
  my $WorkerId	= $c[1];
  my $src = $c[2];
  my $trg = $c[3];
  my $item = $c[4];
  my $sys_id = $c[5];
  my $rid = $c[6];
  my $type = $c[7];
  my $sid = $c[8];
  my $score = $c[9];
  my $time = $c[10];
  my $tst_type = $c[9];
  my $k = "$HITId,$src,$trg,$item,$sys_id,$sid";

  if( ! exists $scores{$k} ){
    $scores{$k} = "$WorkerId\_$type\_$score\_$time";
  }else{
    $scores{$k} .= "|$WorkerId\_$type\_$score\_$time";
  }
  
  $n++;
}

print STDERR "$n judgements processed\n";

my %same_judge;
my %dist_judge;

foreach my $k (sort keys %scores){
  my @scrs = split(/\|/,$scores{$k});
  
  if( $k =~ /A1X1U11YXOSZH7/ ){
    print STDERR "About to process: $k\n";
  }

  if(scalar(@scrs)== 1){
    $sngl++;
  }else{
    &process_repeats_for_k($k,@scrs);
  }
}

sub process_repeats_for_k{

  my $k = $_[0]; 
  my @multi;

  for( my $i=1; $i<scalar(@_); $i++ ){
    push(@multi,$_[$i]);
  }

  for( my $i=0; $i<scalar(@multi); $i++){
    for(my $j=$i+1; $j<scalar(@multi); $j++ ){
        &process_repeats($k,$multi[$i],$multi[$j]);
    }
  }
  
}

sub process_repeats{

    my @j1;
    my @j2;
    my $k = $_[0];  # HITId	WorkerId	src	trg	item	sys_id	rid	type	sid	score	time

    @j1 = split(/\_/,$_[1]); # 0:wid, 1:type, 2: score, 3: hit_seconds
    @j2 = split(/\_/,$_[2]);

    my $scr_j1 = $j1[2];
    my $tme_j1 = $j1[3];
    my $scr_j2 = $j2[2];
    my $tme_j2 = $j2[3];

    # same judge
    if( $j1[0] eq $j2[0] ){
        
      my %typs = ();
      my $wid = $j1[0];
      $typs{$j1[1]} = 1;
      $typs{$j2[1]} = 1;
      my $type = "";
      my $gd_dir = "n/a";

      if( (exists $typs{"system"}) && (exists $typs{"repeat"}) ){
        $type = "sys_sys";       
      }elsif( (exists $typs{"system"}) && (exists $typs{"ref"}) ){
        $type = "sys_ref";       
      }elsif( (exists $typs{"system"}) && (exists $typs{"cal"}) ){
        $type = "sys_cal";       
      }

      if( $type ne ""){
        my $new_k = "$wid,$k,$type";

        if( ! exists $same_judge{$new_k} ){
          if( $j1[1] eq "system" ){  ### always put "system" first and ref/cal second
            $same_judge{$new_k} = "$scr_j1,$tme_j1,$scr_j2,$tme_j2"; #print "SYSTEM FIRST\n";
          }else{
            $same_judge{$new_k} = "$scr_j2,$tme_j2,$scr_j1,$tme_j1"; #print "SYSTEM SECOND\n";
          }
        }else{
          $deleted_rep++;
        }
      }

    }else{ # 2 different judges

      my $wid = $j1[0]."/".$j2[0];

      if( $j1[1] eq "repeat" ){  # for diff judges, a "repeat" is equiv. to a system output
        $j1[1] = "system";
      }
      
      if( $j2[1] eq "repeat" ){
        $j2[1] = "system";
      }

      if( $j1[1] eq $j2[1] ){ # only compare judgments of the same type for 2 diff judges

        my $type = $j1[1];
        my $new_k = "$wid,$k,$type";

        #print "$k :: ".$scores{$k}." \n";
     
        if( exists $dist_judge{$new_k} ){
          if( $new_k !~ /_b$/ ){
            $new_k = $new_k."_b"; 
            $dist_judge{$new_k} = "$scr_j1,$tme_j1,$scr_j2,$tme_j2";
          }else{
            print STDERR "distinct judges error for: $new_k: \n"; exit 1;
          }
        }else{
          $dist_judge{$new_k} = "$scr_j1,$tme_j1,$scr_j2,$tme_j2";
        }
      
      }
    }
}

my $i=0;

print "rep_id,a_type,wid,hit,src,trg,item,sys,sid,rep_type,score_a,time_a,score_b,time_b\n";

foreach my $k (sort keys(%same_judge)){
    print "$i,intra,$k,".$same_judge{$k}."\n";
    $i++;
}

foreach my $k (sort keys(%dist_judge)){
    $k =~ s/_b$//;
    print "$i,inter,$k,".$dist_judge{$k}."\n";
    $i++;
}

