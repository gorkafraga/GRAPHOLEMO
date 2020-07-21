# 										FEEDBACK LEARNING TASK
#----------------------------------------------------------------------------------------------------------------------
# - Simultaneous presentation of visual + sound
# - Forced response but trials are NOT response terminated (fMRI)
# - Letter-sound associations are learned by the feedback presented some time after response (jittered for fMRI)
# - Only informative (consistent feedback provided)
# - For each block stimuli are drawn and pairs randomized. 
#
# Note: pcl file contains randomization of the actual stimuli. Called with (include "FeedbackLearning-MRI.pcl") 
# Patrick Haller
# https://github.com/pathalle/
# November 2019, June 2019
#----------------------------------------------------------------------------------------------------------------------
scenario= "FeedLearn_Bcomplex.sce";
scenario_type=fMRI_emulation; 					#use scenario_type=fMRI_emulation for testing outside scanner environemtn;  otherwise scenario_type=fMRI
write_codes=false; 									# generate logs (turned to false for testing purposes)

#MR sequence parameters
pulses_per_scan = 1;					#registers the first of the specified number of pulses #how many square wave pulses are produced by the MRI scanner during one scan??
scan_period=1000;						#time between complete MRI scans in ms
pulse_code=199;						#used to identify main pulses in fMRI mode in the Analysis window and the logfile

# general headers
active_buttons=3;
default_formatted_text=true;
default_text_color=0,0,0;
default_background_color=155,155,155;
default_font="Arial"; 	# The feedback-smileys will only appear when this font is installed on the running computer! See folder!
response_matching = simple_matching;
pulse_width=5;
response_port_output=true;

begin;	 
  


# PCL	
begin_pcl;

array <int> soundOrder[40] = 		{3, 2, 3, 4, 1, 3, 5, 2, 1, 2, 5, 1, 3, 2, 3, 5, 1, 5, 1, 4, 5, 1, 2, 4, 3, 1, 2, 5, 4, 2, 5, 4, 1, 5, 4, 3, 4, 3, 2, 4} ;
array <int> matchOrder[40] = 		{21,13,21,22,11,21,32,13,11,13,32,11,21,13,21,32,11,32,11,22,32,11,13,22,21,11,13,32,22,13,32,22,11,32,22,21,22,21,13,22};
array <int> missmatchOrder[40] = 	{12,32,11,23,22,33,31,21,33,11,21,23,22,32,13,12,21,31,13,23,12,23,21,33,11,22,31,13,33,31,12,32,12,22,21,11,32,11,31,13};
int vStim1 = 0;
int vStim2 = 0;
int aStim = 0;

# PCL	
loop int i = 1 until i> 40 begin
      string tmpMatch = string(matchOrder[i]);
		vStim1 = ((int(tmpMatch.substring(1,1))-1)*3)+ int(tmpMatch.substring(2,1)); 
		
		string tmpMissmatch = string(missmatchOrder[i]);
		vStim2 = ((int(tmpMissmatch.substring(1,1))-1)*3)+ int(tmpMissmatch.substring(2,1)); 
		#(rowidx - 1) * max(ncols) + colindex
 		term.print(vStim2);
		term.print( "\n" );
		i = i+1;
end
		
			