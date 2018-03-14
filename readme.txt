****You will require the lastest version of FSL and ANTs to use OPFAP****

Please make sure you have done the following prior to executing the scripts

######
A. make a directory called "opt_reg_temp" in your $HOME using the command (can copy and paste command below):

mkdir $HOME/opt_reg_temp 

NOTE: YOU CAN SET YOUR HOME PATH by: HOME=$HOME:NEW FULL ADDRESS e.g., HOME=$HOME:/Users/CAT_STEVENS
NOTE: it is important to NOT include a slash at the end of the address you assign.
###

######
B. You must have the following of images and name them EXACTLY as per below:

1. 4D fMRI image
	Renamed using the convention:
	  i.e., s00SUBJECTNUMBER_STUDYNAME_func.nii.gz
	  e.g., s001_motor_study_func.nii.gz

2. UNI-DEN image from a MP2RAGE sequence (i.e., high-resolution T1-weighted anatomical image)
	Renamed using the convention:
	  i.e., s00SUBJECTNUMBER_anat.nii.gz
	  e.g., s001_anat.nii.gz

3. Second inversion image from the same MP2RAGE sequence
	Renamed using the convention:
	  i.e., s00SUBJECTNUMBER_anat_inv2.nii.gz
	  e.g., s001_anat_inv2.nii.gz

4. Whole brain T2*-weighted image
	Renamed using the convention:
	  i.e., s00SUBJECTNUMBER_TS2_mag.nii.gz
	  e.g., s001_TS2_mag.nii.gz
##

Copy all renamed images above to $HOME/opt_reg_temp 
Copy all content from opt_reg_files you've downloaded to $HOME/opt_reg_temp 

NOTE: the master_preproc.fsf file is the design file for FEAT analysis.
      master_preproc.fsf performs high-pass filtering (cut off at 0.01Hz; 100s), motion correction, linear and non-linear registration
      you can make your own *.fsf files, but must replace all input names accoridng to the convention currently used
      or simply, you can open the *.fsf files in FEATGUI and turn on/off whatever option you desire and save.   
##

######
C. please create 4 sets of text file:
1. direc_list.txt 
	with the content: full address where you wish to conduct this analysis 
			  i.e., /Users/NAME/Desktop/NAME_OF_YOUR_FOLDER 
                          e.g., /Users/CAT_STEVENS/Desktop/motor_study 

NOTE: YOU CAN SET YOUR HOME PATH by: HOME=$HOME:NEW FULL ADDRESS e.g., HOME=$HOME:/Users/CAT_STEVENS
NOTE: it is important to NOT include a slash at the end of the address you assign.
##
2. subject_list.txt 
	with the content: list of your subject numbers (one for each line)
			  i.e., s00SUBJECTNUMBER
			  e.g., s001 
			        s002
				.
				.
				.				
				s100
				sNNN
##
3. task_list.txt 
	with the content: list of your study folder name(s) - has to be identical to the one listed in 1.
			  i.e., NAME_OF_YOUR_FOLDER 
			  e.g., motor_study
##
4. volume_list.txt
	with the content: number of total volumes of your fMRI images
			  i.e., numberofvolumes 
			  e.g., 621

Copy all text files created above to /opt_reg_temp/
##
###

######
## OPTIONAL ##
D. if you have acquired blip_up and blip_down images for B0-correction using fsl's topup, copy the images to $HOME/opt_reg_temp also using the after renaming the images to:
	i.e., sSUBJECT NUMBER_STUDY NAME_UP.nii.gz 
	e.g., s01_motor_study_up.nii.gz
		and	
	i.e., sSUBJECT_NUMBER_down.nii.gz 
	e.g., s01_motor_study_down.nii.gz

	# blip_up image acquired with the exact same acquisition parameteres as the functional run 
        # blip_down image acquired with the exact same acquisition parameteres as the functional run, but in the opposite acquisition direciton 

Then, uncomment the box named TOP UP in the first script, 01_preproc.sh or run_all.sh, by removing '#'s from the function in the box named TOPUP below
This function is commented out by default


execute the scripts using the following commands:

1. For first preprocessing - Sets up folders, copies files, makes template brain

$HOME/opt_reg_temp/./01_preproc.sh

2. For second preprocessing: calculates motion outliers, reorientates images, conducts bet, makes and runs FEAT preprocessing

$HOME/opt_reg_temp/./02_preproc.sh

3. For optimal skull-stripping - performs optimal skull stripping and creates the optimally skull-stripped 4D-input for first-level FEAT analysis (i.e., filtered_func_data.nii.gz)

$HOME/opt_reg_temp/./03_skull_strip_feat.sh

NOTE: When you run the FEAT stats analysis after this step, please make sure to name your output folder to    LOCATION_OF_YOUR_STUDY_FOLDER/subjects/func/      with the following convention:
	i.e., s00SUBJECTNUMBER_STUDYNAME_stats.feat
	e.g., s001_motor_study_stats.feat

4. For co-registration for group-level analysis - creates necessary files for group-level analysis; co-registers COPE and VARCOPE files at the individual level and various images to the same space.

$HOME/opt_reg_temp/./04_post_feat.sh

NOTE: This step essentially tricks FSL to think that you've ran a default non-linear registration pipeline so that it can run a group-level analysis
      Hence, when the report.html file opens up on your browser, it will show the old registraiton results carried out in 02_preproc.sh,
      but in reality, the statistical maps that FLAME  uses to carry out group-level analysis have been co-registered to the template brain space.

or

5. For fully automatic execution of scripts from 01_preproc.sh to 04_post_feat.sh group - To run this option, you must have a *.fsf that specifically executes the First-level Stats FEAT analysis only, for each participant copied to LOCATION_OF_YOUR_STUDY_FOLDER/scripts/automation_fsf/subject_fsf/   with the convention:
	i.e., s00SUBJECTNUMBER_STUDYNNAME_stats.fsf
	e.g., s001_motor_study_stats.fsf

$HOME/opt_reg_temp/./run_all.sh














