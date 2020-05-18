  
#!/bin/bash

# 3dMVM script used to run whole-brain voxelwie connectivity analydis
# Seeded on bilateral amygdala ROI
# Input data files are residuals from 3dDeconvolve (task effects removed)
# Controlling for sex interaction
# Also controlling for mean frame displacement from that subject's resting state data (to control for head motion)
# Masking to include gray matter only
# Ran 1 t-test for effect of age


3dMVM	-prefix MVM2_seedconn_biamy_fd_age_glt_n50.nii -jobs 25	\
-mask mni_icbm152_gm_tal_nlin_asym_09c_3mm_mask.nii.gz	\
-bsVars "age*sex+meanfd"	\
-qVars "age,meanfd"	\
-num_glt 1	\
-gltLabel 1 age_effect -gltCode 1 'age :'	\
-dataTable	@biamy_fd_mvm_table_n50.txt


