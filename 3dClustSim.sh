  
#!/bin/bash

workdir=/Volumes/Zeus/MMY1_EmoSnd/analysis_fm/task_effects_n50
values=`cat $workdir/mean_acf.txt`

3dClustSim \
   -acf $values \
   -mask ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c_3mm.nii
   -athr 0.10 0.05 0.02 0.01 0.005 0.002 0.001 0.0005 0.0002 0.0001
