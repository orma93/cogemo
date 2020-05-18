#!/bin/bash

# calculate mean acf values across all subjects

workdir=/Volumes/Zeus/MMY1_EmoSnd/analysis_fm/seedbasedconn_n50/Cond_cor_errts

cut -d' ' -f2-7 $workdir/allsubj_acf.txt > $workdir/allsubj_acf2.txt

perl -slane '$a[$_]+=$F[$_] for (0..$#F); END{@a=map {$_/$.} @a;print "@a" }' < $workdir/allsubj_acf2.txt > $workdir/mean_acf.txt

rm $workdir/allsubj_acf2.txt
