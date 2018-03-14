#!/bin/bash
############################################################################################################################################################################
####### Co-registration of COPE and VARCOPE images for group-level analysis #########
### Define ROOT directory ###
for DIR in `cat $HOME/opt_reg_temp/direc_list.txt`; do

### Warpig for group analysis #####
##Copy reg folder and files needed for group level FEAT
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do

cp -r "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/reg "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/
mkdir "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard
mkdir "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/stats
mkdir "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/reg
cp "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/stats/*cope*.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/stats/

## make a list of files to manually warp into common space
cd "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/stats/
ls *cope*.nii.gz > "$DIR"/scripts/list.txt
sed -i -e 's/.nii.gz//g' "$DIR"/scripts/list.txt
rm "$DIR"/scripts/*-e

## Warp files: func space --fsl FLIRT--> anat space --ANTS--> template space
cd "$DIR"/scripts/
for z in `cat list.txt`; do
flirt -in "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/stats/"$z".nii.gz -ref "$DIR"/subjects/struc/"$SUB"_anat_brain.nii.gz -applyxfm -init "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg/example_func2highres.mat -out "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/stats/"$z"2anat.nii.gz

WarpImageMultiTransform 3 "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/stats/"$z"2anat.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/stats/"$z".nii.gz -R "$DIR"/subjects/struc/template/"$EXP"template.nii.gz "$DIR"/subjects/struc/template/"$EXP""$SUB"_anat_brainWarp.nii.gz "$DIR"/subjects/struc/template/"$EXP""$SUB"_anat_brainAffine.txt
done

rm list.txt

WarpImageMultiTransform 3 "$DIR"/subjects/struc/"$SUB"_"$EXP"_example_func2anat.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/example_func.nii.gz -R "$DIR"/subjects/struc/template/"$EXP"template.nii.gz "$DIR"/subjects/struc/template/"$EXP""$SUB"_anat_brainWarp.nii.gz "$DIR"/subjects/struc/template/"$EXP""$SUB"_anat_brainAffine.txt

WarpImageMultiTransform 3 "$DIR"/subjects/struc/"$SUB"_"$EXP"_func_brain2anat.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/func_brain.nii.gz -R "$DIR"/subjects/struc/template/"$EXP"template.nii.gz "$DIR"/subjects/struc/template/"$EXP""$SUB"_anat_brainWarp.nii.gz "$DIR"/subjects/struc/template/"$EXP""$SUB"_anat_brainAffine.txt

fslmaths "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/func_brain.nii.gz -bin "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/mask.nii.gz 

flirt -in "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/mean_func.nii.gz -ref "$DIR"/subjects/struc/"$SUB"_anat.nii.gz -applyxfm -init "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg/example_func2highres.mat -out "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/mean_func2anat.nii.gz

WarpImageMultiTransform 3 "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/mean_func2anat.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/mean_func.nii.gz -R "$DIR"/subjects/struc/template/"$EXP"template.nii.gz "$DIR"/subjects/struc/template/"$EXP""$SUB"_anat_brainWarp.nii.gz "$DIR"/subjects/struc/template/"$EXP""$SUB"_anat_brainAffine.txt

cp "$DIR"/subjects/struc/template/"$EXP""$SUB"_anat_braindeformed.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg_standard/reg/highres.nii.gz
cp "$DIR"/subjects/struc/template/"$EXP"template.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg/standard.nii.gz
cp "$DIR"/subjects/struc/template/"$EXP"template.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_stats.feat/reg/standard_brain.nii.gz
done
done



done


echo NOW RUN GROUP_LEVEL ANALYSIS BY USING LOWER-LEVEL FEAT DIRECTORIES AS INPUTS




