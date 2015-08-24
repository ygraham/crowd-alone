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

SRC=$1;
TRG=$2;
TESTSET=$3;
HITS=10; # number of 100 translation hits to generate

LANG_PAIR_DIR=data/$TESTSET
REF_DIR=data/references
WRITE_DIR=out
IMG_DIR=$WRITE_DIR/img/ad
REF_IMG_DIR=$WRITE_DIR/img/ref/$TRG

mkdir -p $IMG_DIR
mkdir -p $REF_IMG_DIR

# create ref translation images
bash create-ref-img.sh $REF_DIR/$TESTSET-ref.$TRG $REF_IMG_DIR

perl rnd-key.pl $LANG_PAIR_DIR $SRC $TRG $TESTSET > $WRITE_DIR/ad.key.$SRC-$TRG;
perl keys-2-sets-100.pl $HITS < $WRITE_DIR/ad.key.$SRC-$TRG > $WRITE_DIR/ad.exp.rnd.100.ids.$SRC-$TRG;
perl mturk-hits-csv.pl $SRC $TRG ad $HITS < $WRITE_DIR/ad.exp.rnd.100.ids.$SRC-$TRG > $WRITE_DIR/ad.hits.set-05.ad.$SRC-$TRG.csv;

# bad ref translations need to be generated here
BR_DIR=$WRITE_DIR/bad-ref/ad/$SRC-$TRG
mkdir -p $BR_DIR
perl ad-bad-refs.pl $SRC $TRG $LANG_PAIR_DIR $BR_DIR $TESTSET
perl txt-2-img.pl $SRC $TRG $LANG_PAIR_DIR/$SRC-$TRG $BR_DIR $REF_DIR $IMG_DIR $TESTSET $HITS < $WRITE_DIR/ad.exp.rnd.100.ids.$SRC-$TRG 

