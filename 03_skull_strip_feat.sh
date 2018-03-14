#!/bin/bash
#################################################################################################################################################################################################
####### optimal skull stripping and first-level feat analysis #########
### Define ROOT directory ###
for DIR in `cat $HOME/opt_reg_temp/direc_list.txt`; do

############################################################################################################################################################################
## REGISTRATION 1 ###
####### cp example_functional image (i.e., middle time-point functional image) FSL's default example_func.nii.gz ########
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do
cp "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/example_func.nii.gz "$DIR"/subjects/struc/"$SUB"_"$EXP"_func.nii.gz 

done
done

############################################################################################################################################################################
### OPTIMAL FUNC skull_stripping ###
###carry out BET###
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do
bet2 "$DIR"/subjects/struc/"$SUB"_"$EXP"_func.nii.gz "$DIR"/subjects/struc/"$SUB"_"$EXP"_func_bet -f 0.1

done
done

### carry out registration ###
### Linear registration of T2S_mag to func space
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do
ants 3 -m MI["$DIR"/subjects/struc/"$SUB"_"$EXP"_func_bet.nii.gz,"$DIR"/subjects/struc/"$SUB"_T2S_mag_brain.nii.gz,1,32] -i 0 -o "$DIR"/subjects/struc/"$SUB"_"$EXP"_T2S2func
done
done

############################################################################################################################################################################
### IMAGE WARPING ###
### Warp images
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do
#### T2S_brain to func for brain masking functional data later
WarpImageMultiTransform 3 "$DIR"/subjects/struc/"$SUB"_T2S_mag_brain.nii.gz "$DIR"/subjects/struc/"$SUB"_"$EXP"_T2S2func_brain.nii.gz "$DIR"/subjects/struc/"$SUB"_"$EXP"_T2S2funcAffine.txt -R "$DIR"/subjects/struc/"$SUB"_"$EXP"_func_bet.nii.gz

#Brain mask example_func using registered T2S_mag_brain & copy file to corresponding feat directory
fslmaths "$DIR"/subjects/struc/"$SUB"_"$EXP"_func.nii.gz -mas "$DIR"/subjects/struc/"$SUB"_"$EXP"_T2S2func_brain.nii.gz "$DIR"/subjects/struc/"$SUB"_"$EXP"_func_brain.nii.gz

done
done
###### mask the filtered func data with the func_brain mask.
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do
cp "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/filtered_func_data.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/filtered_func_data_old.nii.gz
fslsplit "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/filtered_func_data.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/funcvol
ls "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/funcvol*.nii.gz > funcvol_list.txt

for a in `cat funcvol_list.txt`; do
fslmaths "$a" -mas "$DIR"/subjects/struc/"$SUB"_"$EXP"_func_brain.nii.gz "$a"
done

fslmerge -t "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/filtered_func_data.nii.gz "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/funcvol*.nii.gz

rm "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/funcvol*
rm funcvol_list.txt
done
done

############################################################################################################################################################################
###### RUN STATS FEAT #####
#cd "$DIR"/scripts/
#for SUB in `cat subject_list.txt`; do
#for EXP in `cat task_list.txt`;do

#feat "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_stats.fsf &

#done
#done

############################################################################################################################################################################
###### QUALITY ASSURANCE #####
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do
##### FUNC --> ANAT #####
cp "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/reg/example_func2highres.nii.gz "$DIR"/subjects/struc/"$SUB"_"$EXP"_example_func2anat.nii.gz
flirt -in "$DIR"/subjects/struc/"$SUB"_"$EXP"_func_brain.nii.gz -ref "$DIR"/subjects/struc/"$SUB"_anat_brain.nii.gz -applyxfm -init "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/reg/example_func2highres.mat -out "$DIR"/subjects/struc/"$SUB"_"$EXP"_func_brain2anat.nii.gz

##### ANAT --> FUNC #####
flirt -in "$DIR"/subjects/struc/"$SUB"_anat_brain.nii.gz -ref "$DIR"/subjects/struc/"$SUB"_"$EXP"_func_brain.nii.gz -applyxfm -init "$DIR"/subjects/func/"$SUB"_"$EXP"_preproc.feat/reg/highres2example_func.mat -out "$DIR"/subjects/struc/"$SUB"_anat2func.nii.gz

##### FUNC --> T2S #####
WarpImageMultiTransform 3 "$DIR"/subjects/struc/"$SUB"_"$EXP"_func_brain.nii.gz "$DIR"/subjects/struc/"$SUB"_"$EXP"_func2T2S.nii.gz -R "$DIR"/subjects/struc/"$SUB"_T2S_mag_brain.nii.gz -i "$DIR"/subjects/struc/"$SUB"_"$EXP"_T2S2funcAffine.txt &

done
done

echo run first-level FEAT Stats analysis

done
