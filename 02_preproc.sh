#!/bin/bash
#################################################################################################################################################################################################
####### Second preprocessing: motion outliers, reorient, bet, and FEAT preprocessing #########
#################################################################################################################################################################################################
######################################################################################################################
### Define root directory for the study ###
for DIR in `cat $HOME/opt_reg_temp/direc_list.txt`; do
#####################################################################################################################################################################################################
##### Calculate motion outliers #####
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do
fsl_motion_outliers -i "$DIR"/subjects/func/"$SUB"_"$EXP"_func.nii.gz -o "$DIR"/subjects/func/"$SUB"_"$EXP"_func_moutlier_td.txt
done
done 

echo Motion outlier finished
#####################################################################################################################################################################################################
##### Change volume number ######
#####################################################################################################################################################################################################
cd "$DIR"/scripts/
for VOL in `cat volume_list.txt`;do
sed -i -e "s:set fmri(npts) 411:set fmri(npts) "$VOL":g" "$DIR"/scripts/automation_fsf/master_preproc.fsf
done
#####################################################################################################################################################################################################
##### Make FSL design files ######
cd "$DIR"/scripts/
for SUB in `cat subject_list.txt`; do
for EXP in `cat task_list.txt`;do

cp "$DIR"/scripts/automation_fsf/master_preproc.fsf "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_preproc.fsf
sed -i -e "s:masterdir:"$DIR":g" "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_preproc.fsf
sed -i -e "s:mastersub:"$SUB":g" "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_preproc.fsf
sed -i -e "s:masterexp:"$EXP":g" "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_preproc.fsf

#cp "$DIR"/scripts/automation_fsf/master_stats.fsf "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_stats.fsf
#sed -i -e "s:masterdir:"$DIR":g" "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_stats.fsf
#sed -i -e "s:mastersub:"$SUB":g" "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_stats.fsf
#sed -i -e "s:masterexp:"$EXP":g" "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_stats.fsf
#rm "$DIR"/scripts/automation_fsf/subject_fsf/*-e

#cp "$DIR"/scripts/automation_fsf/master_stats_td.fsf "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_stats_td.fsf
#sed -i -e "s:masterdir:"$DIR":g" "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_stats_td.fsf
#sed -i -e "s:mastersub:"$SUB":g" "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_stats_td.fsf
#sed -i -e "s:masterexp:"$EXP":g" "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_stats_td.fsf
#rm "$DIR"/scripts/automation_fsf/subject_fsf/*-e

feat "$DIR"/scripts/automation_fsf/subject_fsf/"$SUB"_"$EXP"_preproc.fsf &

done
done
#####################################################################################################################################################################################################


echo DO NOT RUN THE SECOND SCRIPT UNTIL ALL PREPROC and TEMPLATE BRAIN IS CREATED FEAT ANALYSIS IS DONE
done


