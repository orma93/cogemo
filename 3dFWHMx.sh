#!/bin/bash

workdir=/Volumes/Zeus/MMY1_EmoSnd/analysis_fm

cd $workdir

list=`cat include_idonly_nosubj.txt`

for d in $list; do
	cd $workdir/$d/Cond_cor

	outfile=${d}_acf_bkgrd.txt

	[ -r $outfile ] && rm $outfile

# run 3d FWHMx for individual subject background connectivity data to compute per-subject acf (autocorrelation function) values
	3dFWHMx -detrend -acf -input ${d}_bandpass_errts+tlrc | sed 's/ \+/ /' | sed 1d  > ${d}_acf_bkgrd.txt
# create file with acf values for every subject
	echo "${d} $(cat ${workdir}/${d}/Cond_cor/${d}_acf_bkgrd.txt)"  >> /Volumes/Zeus/MMY1_EmoSnd/analysis_fm/seedbasedconn_n50/Cond_cor_errts/allsubj_acf.txt

done
