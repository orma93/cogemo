#!/bin/bash

#Name: 07_Deconv_Cond_cor.bash
#Author: Orma Ravindranath
#Purpose: Use 3dDeconvolve to model timecourses for all subjects, separated by condition AND scoring
# * on empty lines IS how 3dDeconvolve wants stim files to be formatted

dir=/Volumes/Zeus/MMY1_EmoSnd/analysis_fm
today=`date +%m%d%y`

for subj in /Volumes/Zeus/MMY1_EmoSnd/preproc/task_fm/1*; do
  lunaid=$(echo "$subj" | cut -c43-47)
  stimdir=/Volumes/Zeus/MMY1_EmoSnd/scripts/timing/stim/stimtimes/"$lunaid"
  if [ -e $dir/$lunaid ]
  then
    if [ ! -e $dir/$lunaid/Cond_cor ]
    then
      mkdir $dir/$lunaid/Cond_cor
    fi
  else
    if [ ! -e $dir/$lunaid ]
    then
      mkdir $dir/$lunaid
      mkdir $dir/$lunaid/Cond_cor3
    fi
  fi
  
  workdir="/Volumes/Zeus/MMY1_EmoSnd/analysis_fm/$lunaid/Cond_cor"
  cp $stimdir/*pos_cor.1D $workdir
  cp $stimdir/*pos_errCor.1D $workdir
  cp $stimdir/*neg_cor.1D $workdir
  cp $stimdir/*neg_errCor.1D $workdir
  cp $stimdir/*neu_cor.1D $workdir
  cp $stimdir/*neu_errCor.1D $workdir
  cp $stimdir/*sil_cor.1D $workdir
  cp $stimdir/*sil_errCor.1D $workdir
  cp $stimdir/*all_err_drop.1D $workdir
  
  # assign preprocessed data file for each subject to variables run1, run2, run3, and run4
  # if a subject doesn't have one of the runs, remove the relevant line from timing files and nuisance regressor file
  # AND make the associated variable blank (rather than leaving it unassigned) so that 3dDeconvolve doesn't fail to run
  
  if [ -e $subj/run1/ ]; then
    run1=$subj/run1/nfswudktm_func_5.nii.gz
    cat $subj/run1/nuisance_regressors.txt >> $workdir/"$lunaid"_nuisance_regressors.txt
  else
    run1=""
    sed -ie '1d' $workdir/*pos_cor.1D
    sed -ie '1d' $workdir/*pos_errCor.1D
    sed -ie '1d' $workdir/*neg_cor.1D
    sed -ie '1d' $workdir/*neg_errCor.1D
    sed -ie '1d' $workdir/*neu_cor.1D
    sed -ie '1d' $workdir/*neu_errCor.1D
    sed -ie '1d' $workdir/*sil_cor.1D
    sed -ie '1d' $workdir/*sil_errCor.1D
    sed -ie '1d' $workdir/*all_err_drop.1D
  fi
  
  if [ -e $subj/run2/ ]; then
    run2=$subj/run2/nfswudktm_func_5.nii.gz
    cat $subj/run2/nuisance_regressors.txt >> $workdir/"$lunaid"_nuisance_regressors.txt
  else
    run2=""
    sed -ie '2d' $workdir/*pos_cor.1D
    sed -ie '2d' $workdir/*pos_errCor.1D
    sed -ie '2d' $workdir/*neg_cor.1D
    sed -ie '2d' $workdir/*neg_errCor.1D
    sed -ie '2d' $workdir/*neu_cor.1D
    sed -ie '2d' $workdir/*neu_errCor.1D
    sed -ie '2d' $workdir/*sil_cor.1D
    sed -ie '2d' $workdir/*sil_errCor.1D
    sed -ie '2d' $workdir/*all_err_drop.1D
  fi
  if [ -e $subj/run3/ ]; then
    run3=$subj/run3/nfswudktm_func_5.nii.gz
    cat $subj/run3/nuisance_regressors.txt >> $workdir/"$lunaid"_nuisance_regressors.txt
  else
    run3=""
    sed -ie '3d' $workdir/*pos_cor.1D
    sed -ie '3d' $workdir/*pos_errCor.1D
    sed -ie '3d' $workdir/*neg_cor.1D
    sed -ie '3d' $workdir/*neg_errCor.1D
    sed -ie '3d' $workdir/*neu_cor.1D
    sed -ie '3d' $workdir/*neu_errCor.1D
    sed -ie '3d' $workdir/*sil_cor.1D
    sed -ie '3d' $workdir/*sil_errCor.1D
    sed -ie '3d' $workdir/*all_err_drop.1D
  fi
  if [ -e $subj/run4/ ]; then
    run4=$subj/run4/nfswudktm_func_5.nii.gz
    cat $subj/run4/nuisance_regressors.txt >> $workdir/"$lunaid"_nuisance_regressors.txt
  else
    run4=""
    sed -ie '4d' $workdir/*pos_cor.1D
    sed -ie '4d' $workdir/*pos_errCor.1D
    sed -ie '4d' $workdir/*neg_cor.1D
    sed -ie '4d' $workdir/*neg_errCor.1D
    sed -ie '4d' $workdir/*neu_cor.1D
    sed -ie '4d' $workdir/*neu_errCor.1D
    sed -ie '4d' $workdir/*sil_cor.1D
    sed -ie '4d' $workdir/*sil_errCor.1D
    sed -ie '4d' $workdir/*all_err_drop.1D
  fi
  cd $workdir
  
  # run 3dDeconvolve to estimate task-based effects & generate residuals
  # background connectivity analyses will be conducted using the errts output (the residuals)
  # TENT values were determined based on a comprehensive trial-and-error process to determine values that led to best fit of data WITHOUT overfitting
  # nuisance regressors file is generated during preprocessing and includes 6 motion parameters, the 1st derivatives of these 6 parameters, average CSF signal & its first derivative, average white matter signal & its first derivative

  3dDeconvolve \
  -input $run1 $run2 $run3 $run4 \
  -polort 3 \
  -jobs 12 \
  -local_times \
  -xjpeg "$lunaid"_matrix \
  -num_stimts 25 \
  -stim_times 1 $workdir/"$lunaid"_pos_cor.1D 'TENT(0,22,12)' \
  -stim_label 1 pos_cor \
  -stim_times 2 $workdir/"$lunaid"_pos_errCor.1D 'TENT(0,22,12)' \
  -stim_label 2 pos_errCor \
  -stim_times 3 $workdir/"$lunaid"_neg_cor.1D 'TENT(0,22,12)' \
  -stim_label 3 neg_cor \
  -stim_times 4 $workdir/"$lunaid"_neg_errCor.1D 'TENT(0,22,12)' \
  -stim_label 4 neg_errCor \
  -stim_times 5 $workdir/"$lunaid"_neu_cor.1D 'TENT(0,22,12)' \
  -stim_label 5 neu_cor \
  -stim_times 6 $workdir/"$lunaid"_neu_errCor.1D 'TENT(0,22,12)' \
  -stim_label 6 neu_errCor \
  -stim_times 7 $workdir/"$lunaid"_sil_cor.1D 'TENT(0,22,12)' \
  -stim_label 7 sil_cor \
  -stim_times 8 $workdir/"$lunaid"_sil_errCor.1D 'TENT(0,22,12)' \
  -stim_label 8 sil_errCor \
  -stim_times 9 $workdir/"$lunaid"_all_err_drop.1D 'TENT(0,22,12)' \
  -stim_label 9 all_err_drop \
  -stim_file 10 $workdir/"$lunaid"_nuisance_regressors.txt'[0]' \
  -stim_base 10 \
  -stim_label 10 motion_param_1 \
  -stim_file 11 $workdir/"$lunaid"_nuisance_regressors.txt'[1]' \
  -stim_base 11 \
  -stim_label 11 motion_param_2 \
  -stim_file 12 $workdir/"$lunaid"_nuisance_regressors.txt'[2]' \
  -stim_base 12 \
  -stim_label 12 motion_param_3 \
  -stim_file 13 $workdir/"$lunaid"_nuisance_regressors.txt'[3]' \
  -stim_base 13 \
  -stim_label 13 motion_param_4 \
  -stim_file 14 $workdir/"$lunaid"_nuisance_regressors.txt'[4]' \
  -stim_base 14 \
  -stim_label 14 motion_param_5 \
  -stim_file 15 $workdir/"$lunaid"_nuisance_regressors.txt'[5]' \
  -stim_base 15 \
  -stim_label 15 motion_param_6 \
  -stim_file 16 $workdir/"$lunaid"_nuisance_regressors.txt'[6]' \
  -stim_base 16 \
  -stim_label 16 motion_deriv_1 \
  -stim_file 17 $workdir/"$lunaid"_nuisance_regressors.txt'[7]' \
  -stim_base 17 \
  -stim_label 17 motion_deriv_2 \
  -stim_file 18 $workdir/"$lunaid"_nuisance_regressors.txt'[8]' \
  -stim_base 18 \
  -stim_label 18 motion_deriv_3 \
  -stim_file 19 $workdir/"$lunaid"_nuisance_regressors.txt'[9]' \
  -stim_base 19 \
  -stim_label 19 motion_deriv_4 \
  -stim_file 20 $workdir/"$lunaid"_nuisance_regressors.txt'[10]' \
  -stim_base 20 \
  -stim_label 20 motion_deriv_5 \
  -stim_file 21 $workdir/"$lunaid"_nuisance_regressors.txt'[11]' \
  -stim_base 21 \
  -stim_label 21 motion_deriv_6 \
  -stim_file 22 $workdir/"$lunaid"_nuisance_regressors.txt'[12]' \
  -stim_base 22 \
  -stim_label 22 csf \
  -stim_file 23 $workdir/"$lunaid"_nuisance_regressors.txt'[13]' \
  -stim_base 23 \
  -stim_label 23 csf_deriv \
  -stim_file 24 $workdir/"$lunaid"_nuisance_regressors.txt'[14]' \
  -stim_base 24 \
  -stim_label 24 wm \
  -stim_file 25 $workdir/"$lunaid"_nuisance_regressors.txt'[15]' \
  -stim_base 25 \
  -stim_label 25 wm_deriv \
  -iresp 1 pos_cor_iresp \
  -iresp 2 pos_errCor_iresp \
  -iresp 3 neg_cor_iresp \
  -iresp 4 neg_errCor_iresp \
  -iresp 5 neu_cor_iresp \
  -iresp 6 neu_errCor_iresp \
  -iresp 7 sil_cor_iresp \
  -iresp 8 sil_errCor_iresp \
  -iresp 9 all_err_drop_iresp \
  -fout \
  -rout \
  -bout \
  -fitts "$lunaid"_fitts \
  -errts "$lunaid"_errts \
  -bucket "$lunaid"_bucket \
  -cbucket "$lunaid"_cbucket \
  -GOFORIT 3
done
