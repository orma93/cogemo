3dMVM	-prefix MVM_seedconn_rest_biamy_age_gm_glt_n49.nii -jobs 40	\
-bsVars "age*sex"	\
-qVars age	\
-mask ~/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c_3mm.nii	\
-num_glt 1	\
-gltLabel 1 age_effect -gltCode 1 'age :'	\
-dataTable	@biamy_mvm_table_n49.txt
