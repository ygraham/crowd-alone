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
my $sys_out_dir = $ARGV[2];
my $bad_ref_dir = $ARGV[3];
my $ref_dir = $ARGV[4];
my $wrt_dir = $ARGV[5];
my $testset = $ARGV[6];
my $n_hits = $ARGV[7];

my $lng = "$src-$trg";
my $start = 0;
my $max_convert = $n_hits * 100;

# skip header
<STDIN>;

my $i=0;
my $log_fn = "$wrt_dir/$lng/snt_".time;
  
print STDERR "conversion began at ".localtime(time)."\n";

while((my $l = <STDIN>)&&($i<($start+$max_convert))){

  if( ($i%100) == 0 ){ print STDERR "."; }
  if( ($i%1000)==0 ){ print STDERR " $i converted at ".localtime(time)."\n"; }

  if( $i >= $start ){

    chomp($l);
    my @c = split(/\t/,$l);

    # system	snt_id	typ	rnd_id
    my $sys_id = $c[0];
    my $snt_id = $c[1];
    my $type =   $c[2];
    my $rnd_id = $c[3];

    my $sed_cmd = "sed -n \'".($snt_id+1)."\'p ";

    if( ($type eq "system")|| ($type eq "repeat") ){
      $sed_cmd .= "$sys_out_dir/$testset.$lng.$sys_id";
    }elsif( $type eq "cal"){
      $sed_cmd .= "$bad_ref_dir/$testset.$lng.$sys_id";
    }elsif( $type eq "ref" ){
      #  $sed_cmd .= "$ref_dir/nc-test2007.$trg"; 
      $sed_cmd .= "$ref_dir/$testset-ref.$trg";
    }

    $sed_cmd =~ s/\(/\\(/g;
    $sed_cmd =~ s/\)/\\)/g;

    my $init;
    my $second;

    if( "".$rnd_id =~ /([0-9]+)([0-9][0-9][0-9])/){
      $init = $1;
      $second = $2; 
    }elsif( "".$rnd_id =~ /([0-9]*)/){
      $init = "0";
      $second = $2;
    }

    if( ! -e "$wrt_dir/$lng/$init"){
      system("mkdir -p $wrt_dir/$lng/$init");
    }

    my $file2wrt = "$wrt_dir/$lng/$init/$rnd_id.gif";
    my $cnv_cmd = "convert -fill black -interline-spacing 5 -pointsize 14 -size 900 caption:@\- $file2wrt";

    system($sed_cmd." | ".$cnv_cmd);
    system($sed_cmd.">>$log_fn");
  }
  $i++;
}

print STDERR "conversion ended at ".localtime(time)."\n";
