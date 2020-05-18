#!/bin/bash

# 3dMVM script used to run whole-brain voxelwise connectivity analysis
# Seeded on bilateral amygdala ROI
# Input data files are the voxelwise connectivity values computed from DoConDecon.sh
# Controlling for sex interaction
# Also controlling for mean frame displacement (to control for head motion)
# Masking to include gray matter only
# Ran 1 t-test for effect of age'

3dMVM	-prefix MVM_seedconn_rest_biamy_age_gm_glt_n49.nii -jobs 40	\
-bsVars "age*sex+meanfd"	\
-qVars "age,meanfd"	\
-mask ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c_3mm.nii	\
-num_glt 1	\
-gltLabel 1 age_effect -gltCode 1 'age :'	\
-dataTable	@biamy_mvm_table_n49.txt
