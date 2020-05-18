#!/bin/bash

#To extract amygdala ROI timeseries before using DoConDecon script to compute amygdala whole-brain connectivity

data_emo=/Volumes/Zeus/MMY1_EmoSnd/analysis_fm
ROI=/Volumes/Zeus/MMY1_EmoSnd/scripts/ROIs
conditions="Bilatamy"
process=Cond_cor

cd $data_emo

for d in $data_emo/1*; do
	subj=$(basename $d)
	
	for condition in $conditions; do

		echo $condition $d $subj
		
		if [ -e $data_emo/$subj/$process/${subj}_${condition}_ROI.1D ]; then
			rm $data_emo/$subj/$process/${subj}_${condition}_ROI.1D
		fi

		#for amygdala ROIs
		3dROIstats -mask $ROI/${condition}_roi_HarOx_3mm.nii.gz $data_emo/$subj/$process/${subj}_bandpass_errts+tlrc. > $data_emo/$subj/$process/${subj}_${condition}_ROI.1D

	done
done
