#!/usr/bin/env sh

#data=$1 #Main directory with all of the subjects
#subj=$2 #Specific subjects (use * if all??)
#process=$3 #Subdirectory with preprocessed subject data
#fname=$4  # input 4d file (time series)
#condition=$5 #ROI
#mask=$6 #if needed
#censorFile=$7

data=/Volumes/Zeus/MMY1_EmoSnd/analysis_fm
process=Cond_cor
condition="Bilatamy"
pp=/Volumes/Zeus/MMY1_EmoSnd/preproc/task_fm

umask 002

cd $data

#run 3dDeconvolve

for dir in $data/1*; do
	
	subj=$(basename $dir)
	censorFile=$data/$subj/${subj}_censor.1D
	
	for cond in $condition; do
		if [ ! -e $dir/$process/${subj}_${cond}_ROI_full.1D ]; then	
			mv $dir/$process/${subj}_${cond}_ROI.1D $dir/$process/${subj}_${cond}_ROI_full.1D
			awk '{ print $3 }' $dir/$process/${subj}_${cond}_ROI_full.1D > $dir/$process/${subj}_${cond}_ROI.1D
			sed -i 's/Mean_1//g' $dir/$process/${subj}_${cond}_ROI.1D
			sed -i '/^$/d' $dir/$process/${subj}_${cond}_ROI.1D
		fi
	done
	
	cd $subj/$process

	
	for cond in $condition; do
	
		fname=${subj}_bandpass_errts.nii.gz

		3dDeconvolve -input $fname -polort 3 \
			-num_stimts 1 -stim_file 1 $dir/$process/${subj}_${cond}_ROI.1D \
			-rout -bucket ${subj}_3ddeconvolve_corr_${cond} \
			-censor $censorFile \
			-overwrite

		3dREMLfit -matrix ${subj}_3ddeconvolve_corr_${cond}.xmat.1D -input $fname \
                        -rout -tout -Rbuck ${subj}_${cond}_REML -Rvar ${subj}_${cond}_REMLvar -verb \
                       	-overwrite

	#need to get R value from R squared
	#first variable is sub-brik for R^2, second variable is sub-brik for beta coefficient
		3dcalc -a ${subj}_${cond}_REML+tlrc.[4] -b ${subj}_${cond}_REML+tlrc.[2] -expr 'ispositive(b)*sqrt(a)-isnegative(b)*sqrt(a)' -prefix ${subj}_${cond}_REML_r \
                        -overwrite

	#calculate fisher Z scores to run stats
		3dcalc -a ${subj}_${cond}_REML_r+tlrc. -expr 'log((1+a)/(1-a))/2' -prefix ${subj}_${cond}_REML_r_Z -overwrite
	
	done
	cd $data
done
