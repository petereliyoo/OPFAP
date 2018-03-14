#!/bin/bash
#################################################################################################################################################################################################
####### Initial preprocessing: Set up folders,  copy files, make template #########

## Please make sure you have read the readme file and have done the following before using the script
##### make a directory called "opt_reg_temp" in your $HOME using the command: 
# mkdir $HOME/opt_reg_temp/ 
## NOTE YOU CAN SET YOUR HOME PATH by: HOME=$HOME:NEW FULL ADDRESS

##### please create 3 sets of text file
# 1. "direc_list.txt" with the content: full address where you wish to conduct this analysis i.e., /Users/NAME/Desktop/NAME_OF_YOUR_FOLDER... 
# e.g., /Users/CAT_STEVENS/Desktop/emotion_study 
###### ****It is important that you do not place a slash at the end of your address***** ######

# 2. "subject_list.txt" with the content: list of your subject numbers (one for each line) with the convention, sSUBJECT_NUMBER, e.g., s01 *NEWLINE* s02 *NEWLINE ... s0N
# 3. "task_list.txt" with the content: list of your study folder name, has to be identical to the one listed in 1. e.g., emotion_study

# Copy all text files created above, and the contents of FILES in the zip file you downloaded to /opt_reg_temp/

##### Please copy and rename the following images for each subject into the folder "/opt_reg_temp/", with the convention shown below.
# high resolution T1-weighted image - sSUBJECT_NUMBER_anat.nii.gz e.g., s01_anat.nii.gz
# Second inversion image of high resolution T1-weighted image - sSUBJECT_NUMBER_anat_inv2.nii.gz e.g., s01_anat_inv2.nii.gz
# whole_brain T2*-weighted image - sSUBJECT_NUMBER_T2S_mag.nii.gz e.g., s01_T2S_mag.nii.gz

# functional images - sSUBJECT NUMBER_STUDY_NAME_func.nii.gz e.g., s01_emotion_study_func.nii.gz

### if available, blip_up and blip_down images for B0-correction using fsl's topup - this function is commented out by default, if you wish to use it, then please remove the '#'s from the function in the box named TOPUP below
# blip_up image acquired with the exact same acquisition parameteres as the functional run - sSUBJECT NUMBER_STUDY NAME_UP.nii.gz e.g., s01_emotion_study_UP.nii.gz
# blip_down image acquired with the exact same acquisition parameteres as the functional run, but in the opposite acquisition direciton - sSUBJECT_NUMBER_DOWN.nii.gz e.g., s01_emotion_study_down.nii.gz

### Also, please make sure that you have made your study specific master preprocessing and stats desgin file (*.fsf) 
 
#################################################################################################################################################################################################
######################################################################################################################
### Define root directory for the study ###
for DIR in `cat $HOME/opt_reg_temp/direc_list.txt`; do

### Make folder-tree
mkdir "$DIR"
mkdir "$DIR"/subjects
mkdir "$DIR"/subjects/struc
mkdir "$DIR"/subjects/struc/template
mkdir "$DIR"/subjects/func
mkdir "$DIR"/scripts
mkdir "$DIR"/scripts/automation_fsf
mkdir "$DIR"/scripts/automation_fsf/subject_fsf
mkdir "$DIR"/text_files

cp $HOME/opt_reg_temp/*anat*.nii.gz "$DIR"/subjects/struc
cp $HOME/opt_reg_temp/*T2S*.nii.gz "$DIR"/subjects/struc
cp $HOME/opt_reg_temp/*UP*.nii.gz "$DIR"/subjects/struc
cp $HOME/opt_reg_temp/*DOWN*.nii.gz "$DIR"/subjects/struc
cp $HOME/opt_reg_temp/*func*.nii.gz "$DIR"/subjects/func
cp $HOME/opt_reg_temp/*.sh "$DIR"/scripts
cp $HOME/opt_reg_temp/*.txt "$DIR"/scripts
cp $HOME/opt_reg_temp/*.txt "$DIR"/text_files
cp $HOME/opt_reg_temp/*.fsf "$DIR"/scripts/automation_fsf
cp $HOME/opt_reg_temp/*.fsf "$DIR"/scripts/automation_fsf/subject_fsf
done

### Define root directory for the study ###
for DIR in `cat $HOME/opt_reg_temp/direc_list.txt`; do
################## TOP UP #####################

#for SUB in `cat subject_list.txt`; do for EXP in `cat task_list.txt`;do fslroi "$DIR"/subjects/struc/"$SUB"_"$EXP"_UP.nii.gz "$DIR"/subjects/struc/b0_blip_up 0 1; fslroi "$DIR"/subjects/struc/"$SUB"_"$EXP"_DOWN.nii.gz "$DIR"/subjects/struc/b0_blip_down 0 1; fslmerge -t "$DIR"/subjects/struc/both_b0 "$DIR"/subjects/struc/b0_blip_up "$DIR"/subjects/struc/b0_blip_down;  topup --imain="$DIR"/subjects/struc/both_b0 --datain="$DIR"/scripts/my_acq_param.txt --config=b02b0.cnf --subsamp=1 --out="$DIR"/subjects/struc/"$SUB"_"$EXP"_topup_results;  applytopup --imain="$DIR"/subjects/func/"$SUB"_"$EXP"_func.nii.gz --inindex=1 --method=jac --datain="$DIR"/scripts/my_acq_param.txt --topup="$DIR"/subjects/struc/"$SUB"_"$EXP"_topup_results --out="$DIR"/subjects/func/"$SUB"_"$EXP"_func.nii.gz;  done; done

#####################################################################################################################################################################################################

#####################################################################################################################################################################################################
### reorientate images to standard orientation and carry out BET###
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do

fslreorient2std "$DIR"/subjects/struc/"$SUB"_anat.nii.gz "$DIR"/subjects/struc/"$SUB"_anat.nii.gz  
fslreorient2std "$DIR"/subjects/struc/"$SUB"_anat_inv2.nii.gz "$DIR"/subjects/struc/"$SUB"_anat_inv2.nii.gz 
fslreorient2std "$DIR"/subjects/struc/"$SUB"_T2S_mag.nii.gz "$DIR"/subjects/struc/"$SUB"_T2S_mag.nii.gz 

fslstats "$DIR"/subjects/struc/"$SUB"_T2S_mag.nii.gz -C > "$SUB"_cog.txt
awk '{print $1}' "$SUB"_cog.txt > tempx.txt
awk '{print $2}' "$SUB"_cog.txt > tempy.txt
awk '{print $3}' "$SUB"_cog.txt > tempz.txt

for x in `cat tempx.txt`; do
for y in `cat tempy.txt`; do
for z in `cat tempz.txt`; do
####### NOTE THE value after -f is the fractional intensity threshold (0->1); default=0.5; smaller values give larger brain outline estimates.
### it is set at 0.15, which was determine to be the optimal value for high-resolution expanded functional image (whole_brain EPI), for SWI images, we suggest ~0.2 which will get rid more of the meninges and other non-brain structures
### However, we recommend testing various -f values to determine a study-specific or sequence-specific value
bet2 "$DIR"/subjects/struc/"$SUB"_T2S_mag.nii.gz "$DIR"/subjects/struc/"$SUB"_T2S_mag_brain.nii.gz -f 0.15 -c "$x" "$y" "$z"
done
done
done

fslstats "$DIR"/subjects/struc/"$SUB"_anat_inv2.nii.gz -C > "$SUB"_cog.txt
awk '{print $1}' "$SUB"_cog.txt > tempx.txt
awk '{print $2}' "$SUB"_cog.txt > tempy.txt
awk '{print $3}' "$SUB"_cog.txt > tempz.txt

for x in `cat tempx.txt`; do
for y in `cat tempy.txt`; do
for z in `cat tempz.txt`; do
bet2 "$DIR"/subjects/struc/"$SUB"_anat_inv2.nii.gz "$DIR"/subjects/struc/"$SUB"_anat_inv2_brain.nii.gz -f 0.2 -c "$x" "$y" "$z"
fslmaths "$DIR"/subjects/struc/"$SUB"_anat.nii.gz -mas "$DIR"/subjects/struc/"$SUB"_anat_inv2_brain.nii.gz "$DIR"/subjects/struc/"$SUB"_anat_brain.nii.gz
done
done
done

done
done
#####################################################################################################################################################################################################

#####################################################################################################################################################################################################
##### Make study specific template #####
##### NOTE: comment this function out and carry it out later if you do not have the structural images for all participants
cd "$DIR"/scripts/
for EXP in `cat task_list.txt`;do mkdir "$DIR"/subjects/struc/template/; cp "$DIR"/subjects/struc/s*_anat_brain.nii.gz "$DIR"/subjects/struc/template/; cd "$DIR"/subjects/struc/template/; buildtemplateparallel.sh -d 3 -o "$EXP" -c 2 s*anat_brain.nii.gz ; done
#####################################################################################################################################################################################################
echo MAKE EVS
"$DIR"/scripts/./02_preproc.sh

done
