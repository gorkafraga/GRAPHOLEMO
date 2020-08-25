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
scenario= "FeedLearn_A.sce";
scenario_type=fMRI_emulation; 					#use scenario_type=fMRI_emulation for testing outside scanner environemtn;  otherwise scenario_type=fMRI
write_codes=false; 									# generate logs (turned to false for testing purposes)

#MR sequence parameters
pulses_per_scan = 1;					#registers the first of the specified number of pulses #how many square wave pulses are produced by the MRI scanner during one scan??
scan_period=1000;						#time between complete MRI scans in ms
pulse_code=199;						#used to identify main pulses in fMRI mode in the Analysis window and the logfile

# general headers
active_buttons=2;
button_codes=16,32; 					# Only two buttons possible in MRI (response box)
default_formatted_text=true;
default_text_color=0,0,0;
default_background_color=155,155,155;
default_font="Arial"; 	# The feedback-smileys will only appear when this font is installed on the running computer! See folder!
response_matching = simple_matching;
pulse_width=5;
response_port_output=true;

begin;	
# -------------------------------------------------------------
# Stimuli definitions 
# -------------------------------------------------------------

#start screen
picture { bitmap { filename = "test.bmp"; } pict; x=0; y=0;} pstim;
# fixation
picture { text { caption="+"; font_size=38; font_color=0,0,0;}cross; x=0; y=0;} fix;
picture { text { caption="."; font_size=48; font_color=0,0,0;}; x=0; y=0; } fix2;
# feedback (content is modified later)
picture { text { caption="☺"; font_size=98; font_color=0,0,0;} fb_pict; x=0; y=0; }feed_pic;

# stimuli from main trial
sound { wavefile { filename = "norm_ä.wav"; preload=true;} snd;} astim;
picture { text { caption="V1";font_size=80; } vTXT1; x=0; y=0;} vstim1; # for testing purposes, use the stim identifier instead of the actual pictue/sound
picture { text { caption="V2";font_size=80; } vTXT2; x=0; y=0;} vstim2;

# combine pics from main trial
picture{ text  cross; x=0; y=0;
			text  vTXT1; x=-400; y=0;
			text  vTXT2; x=400; y=0;
	} main_pic;
	



#NOW WITH CUES
$wdth = 80;
$hght = 65;
# Fixation with cues!
picture{bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;};x=600; y=0;
		  bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;};x=-600; y=0;	
		  text cross; x=0; y=0;} fix_cue;

# feedback with cues!		
picture{bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;}; x=600; y=0;
		  bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;};x=-600; y=0;	
		  text  fb_pict; x=0; y=0;} feed_pic_cue;
# ------------------------------------------------------------------------------------------------
# Trial definition 
# ------------------------------------------------------------------------------------------------

				
				
# wait for MR pulse
	 trial{	stimulus_event	{picture	{text{caption="+";font_size=48;font_color=0,102,51;};x=0;y=0;};duration=8000;code="100";}event_wait;}wait;
	
# ITI trial  (duration  will be jittered)
	trial {trial_type=fixed;
				all_responses=false;
			trial_duration = 8000;
			stimulus_event {
				picture fix;  
				port_code=111; 
				code="fix";
			} iti_fix;
	} iti_fix_trial;
	
# main trial audio 
	trial {
		trial_type=fixed;
		all_responses=false; 	#prevents terminating trial by an early button press	
		monitor_sounds=false;
		stimulus_event {
			sound astim;
		} sound_event;	
	} main_trial_audio;
	
# main trial
	trial {
		trial_type=fixed;
		all_responses=false; 	#prevents terminating trial by an early button press	
		trial_duration = 2000;
		stimulus_event {
			picture main_pic; 
			time = 0; 
			duration = 2000;
			target_button=1;
			response_active=true; 
			code="stim";  
		} main_stim;
	} main_trial;	
 
# Fixation before feedback (jittered in pcl)
	trial {
		trial_type=fixed;
		all_responses=false;
		trial_duration = 8000;
		stimulus_event {
			picture fix;
			port_code=222;
			code="fix2";   
		} fixBeforeFeedback;
	} fixBeforeFeedback_trial;
	
# Feedback trial
	trial {
		trial_type=fixed;
		trial_duration=2000;
		stimulus_event {
			picture feed_pic;
			#port_code=255;     # changed in pcl code to represent the trial type
			code="feedback";
		} fb_event;
	} feedback;

# Instruction trials: instructions depend upon variable respMatch (defined in pop-up at start )
	
	 trial {
			trial_duration = forever;
			trial_type = first_response;
			terminator_button = 1;
			picture { 
			text 	{ caption = 
		 "<b> Herzlich Willkommen! </b>														
		 Gleich wirst du eine Fantasieschrift lernen. 
		
		 Drücke auf die <b> blaue Taste (links) </b>, wenn du denkst, dass der Laut, den du hörst, zum linken Symbol gehört. 
		 Drücke auf die <b> gelbe Taste (rechts) </b>, wenn du denkst, dass der Laut, den du hörst, zum rechten Symbol gehört.  
		
		 Wenn du richtig entschieden hast, wird dir ein Smiley angezeigt:
		😊 bedeutet, dass du richtig gedrückt hast, 
		😕 bedeutet, dass du falsch gedrückt hast.
		
		
		Drücke jeweils so schnell du kannst!
 
		<i> Drücke um zu starten</i>";
		font_size = 40; font = "Arial"; text_align=align_left;  
					};
					x = 0 ; y = 0;	
			};
	} instr_task;
	
 
#[ MRI Pulse terminated start screen] 
#----------------------------------------------------------------
# Screen indicating the current block
	picture { text { caption= ""; font_size=48; font_color=0,102,51;} block_screen_txt ; x=0; y=0; } block_screen_pic;#fill in later in pcl part with block no.
	trial {
			#trial_type=fixed;
			#trial_duration = 2000;
			#trial_type = specific_response;
			picture  block_screen_pic;		  
			mri_pulse = 1;                    #this should terminate the trial by the fMRI pulse
			duration = 5000;
  } block_screen;

# This trial can be used to present a special message if it is the last block
	trial {
 			picture { 
				text 	{ caption = 
	"Letzer Block 





	<i> Gut gemacht, fast geschafft!<i>";
					font_size = 18; font = "Arial"; text_align=align_left; 
					};
					x = 0 ; y = 0;	
			};
	mri_pulse = 1;                    #this should terminate the trial by the fMRI pulse
	duration = 4000;
	} pauzeBeforeEnd; 
#====================================================================================#====================================================================================
#			 BEGIN PCL (It will execute the pcl file to execute randomization 
#====================================================================================#====================================================================================
begin_pcl;

#Pop-up  window asking for input on response order (counterbalanced)
#preset string scenarioName = "FeedLearn-GFG";
preset int blockNum;


# LOG AND OUTPUTFILE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
string  logfilename = logfile.filename();
logfile.set_filename(logfilename.replace(".log",+"_"+"_B"+string(blockNum)+".log"));
logfilename = logfile.filename();		

if (file_exists(logfilename)) then 
	int i = 1;
		loop until !file_exists(logfilename.replace(".log", "-" + string(i) + ".log"))
	begin
        i = i + 1;
   end;
   logfilename = logfilename.replace(".log",  "-" + string(i) + ".log")
end;
logfile.set_filename(logfilename);

	
#create .txt outputfile
string scenarioName = "FeedLearnMRI_5x8_noRep";
output_file out_file = new output_file;
if (logfile.subject().count()>0) then out_file.open(logfilename.replace(".log",".txt"));
else out_file.open("NoSubj_"+scenarioName+"_"+"_B"+string(blockNum)+".txt"); end;

#headers in txt file
out_file.print("block\ttrial\tvStims\taStim\tresp\trt\tfb\titi\tfeedJitter\tvSymbols\taFile\tstimOnset\trespOnset\tfeedbackOnset\n");
#out_file.print("Block"+string(blockNum)+"\t"+"\n\n");

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Execute pcl file with randomizations 
include "FeedLearn_A.pcl"
#Some variables to keep track of things
int  target_button; 
bool random_feedback=false;
double totalResponse=0.0;
int nrCorrect=0;
int avgResponse = 2000;
 
#=================================================================================================================================================================================
#        BEGIN MAIN TASK   																																							_m_d[°_°]b_m_
#=================================================================================================================================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
#
# [ P R A C T I C E ] 
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
# practice block or the real stuff


if (blockNum == 0) then 
	instr_task.present();
		int aStim = 0;
		int vStim1 = 0; 
		int vStim2 = 0; 
		string pairOrderStr;
		array <string> activePict[2] = {"თ","დ"};
		array <string> activeSnd[2]= {"DEU_ä.wav", "DEU_o_short_1.wav"};	
		
		array <int> practiceOrder[6]= {112,121,212,221,112,121};	
	
		# Loop through the pairOrder array and depending on the value select 
		loop int i = 1 until i> 6 begin
		 	vTXT1.set_font_size(100);  # this resets the font size for each trial. A conditional loop will adjust font sizes for specific symbols
			vTXT2.set_font_size(100);		
			pairOrderStr = string(practiceOrder[i]);		
			aStim = int(pairOrderStr.substring(1,1));
			vStim1 = int(pairOrderStr.substring(2,1));
			vStim2 = int(pairOrderStr.substring(3,1));		
			vTXT1.set_caption(activePict[vStim1], true); 
			vTXT2.set_caption(activePict[vStim2], true); 
			snd.set_filename(activeSnd[aStim]);
			snd.load();			
			if (aStim == vStim1) then
				target_button=16; 
				main_stim.set_port_code(11);
			else
				target_button=32; 
				main_stim.set_port_code(22);
		end;
				
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# present the time critical trial:
				iti_fix_trial.set_duration(iti[i]); #iti trial duration jittered
				iti_fix_trial.present();
				# Audio (should continue to next trial so audio and visual appear together 
				sound_event.set_port_code(55);
				main_trial_audio.present();
				#Visual
				main_trial.present();
				
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					
				# Analyse responses and generate appropriate feedback 
				stimulus_data sd=stimulus_manager.last_stimulus_data();
				int RT=sd.reaction_time();
				int button=sd.button();
				int respOnset = 0;
				int FB=0;						
				
				if (button==0) then
					fb_pict.set_font_color(0,0,0);
					fb_pict.set_font_size(48);
					fb_pict.set_caption("Drücke ein wenig schneller!", true);
					fb_event.set_port_code(196);
					FB = 2;	
				else
						if (	(target_button==16 && button==1) || 
							(target_button==32 && button==2)	) then
							FB=1;
							fb_pict.set_font_color(0,102,51);
							fb_pict.set_font_size(168);
							fb_pict.set_caption("☺", true); #positive feedback, richtig entschieden
							fb_event.set_port_code(64);
						
						else	
							FB=0;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(168);
							fb_pict.set_caption("😕", true); #negative feedback, falsch entschieden
							fb_event.set_port_code(128);
						
					end;	
				end;
			 #~~~~~~~~~~~~Present feedback ~~~~~~~~~~~~~~~~~~~~~~~
				fixBeforeFeedback_trial.set_duration(itifeedback[i]); #iti trial duration jittered
				fixBeforeFeedback_trial.present();
				#Present
				feedback.present();				
			
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Print out stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
			# Output file:	 
				out_file.print(blockNum); out_file.print("\t"); 	# block nr
				out_file.print(i); out_file.print("\t"); 			# trial nr
				out_file.print(string(vStim1)+string(vStim2)); out_file.print("\t"); 	# visual stimulus nr, 1,2,3 or 4
				out_file.print(aStim); out_file.print("\t"); 	# auditive stimulus nr, 1,2,3 or 4	
				out_file.print(button); out_file.print("\t"); 					# response button
				out_file.print(RT); out_file.print("\t"); 						# response time
				out_file.print(FB); out_file.print("\t"); 						# feedback type (0=wrong, 1=good , 2= faster!)
				out_file.print(iti[i]); out_file.print("\t"); 		
				out_file.print(itifeedback[i]); out_file.print("\t"); 	
				out_file.print(activePict[vStim1]+activePict[vStim2]);out_file.print("\t");		# get_filename(pict.filename()));	# filename of the picture
				out_file.print(activeSnd[aStim]);out_file.print("\t");		# get_filename(snd.filename()));	# filename of the sound
				out_file.print("practice");	out_file.print("\t");				# stimulus onset from 1st pulse
				out_file.print("practice");	out_file.print("\t");				# response onset from 1st pulse
				out_file.print("practice"); 										# feedback onset from 1st pulse
				out_file.print("\n");
				
				i=i+1;	
		end;
else	
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
#
# [ M A I N    T A S K    S T A R T S  ] 
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

#some initial shuffling

		itifeedback.shuffle();
		iti.shuffle();	
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	instr_task.present();
	#Present screen indicating block	 [MRI PULSE TERMINATED!]
			block_screen_txt.set_caption("Start block " + string(blockNum), true); 
			block_screen.present(); 	
			# Get time of pulse for calculation of stimuli, resp and feedback onset
			int t0 = pulse_manager.main_pulse_time(1);
			/*	if (blockNum==4) then 
				pauzeBeforeEnd.present();
				term.print(clock.time());term.print("\n");
			else 
				block_screen_txt.set_caption("Start block" + string(blockNum), true); 
				block_screen.present();
				term.print(clock.time());term.print("\n");
			end;
			*/
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
array <int> pairOrder[40] = { 0,0,0,0,0,0,0,0,0,0,
										0,0,0,0,0,0,0,0,0,0,
										0,0,0,0,0,0,0,0,0,0,
										0,0,0,0,0,0,0,0,0,0};
										
if (blockNum == 1) then   pairOrder = pairOrderB1;
	elseif (blockNum == 2)  then pairOrder=pairOrderB2;
	elseif (blockNum == 3) then pairOrder=pairOrderB3;
	elseif (blockNum == 4) then pairOrder=pairOrderB4;

end;  

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	#Create an array with the selected stimuli for this block 
		int vStim1 = 0;
		int vStim2 = 0;
		int aStim = 0;
		string pairOrderStr;
		array <string> activePict[8];
		array <string> activeSnd[5];	
		
		loop int j=1 until j> 8 begin
			activePict[j] = pict_file[blockNum][j];
			j = j+1
		end;
		loop int k=1 until k> 5 begin
			activeSnd[k] = sound_file[blockNum][k];
			k=k+1;
		end; 
			
		# Loop through the pairOrder array and depending on the value select 
		loop int i = 1 until i> 40 begin
		 	vTXT1.set_font_size(100);  # this resets the font size for each trial. A conditional loop will adjust font sizes for specific symbols
			vTXT1.set_font("FBLearning");
			vTXT2.set_font_size(100);
			vTXT2.set_font("FBLearning");	
			
			pairOrderStr = string(pairOrder[i]);
			
			aStim = int(pairOrderStr.substring(1,1));
			vStim1 = int(pairOrderStr.substring(2,1));
			vStim2 = int(pairOrderStr.substring(3,1));
			
			vTXT1.set_caption(activePict[vStim1], true); 
			vTXT2.set_caption(activePict[vStim2], true); 
			snd.set_filename(activeSnd[aStim]);
			snd.load();
			
			if (aStim == vStim1) then
				target_button=16; 
				main_stim.set_port_code(11);
			else
				target_button=32; 
				main_stim.set_port_code(22);
		end;
					
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
							
			#				 TRIAL PRESENTATION
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# present the time critical trial:
				iti_fix_trial.set_duration(iti[i]); #iti trial duration jittered
				iti_fix_trial.present();
				
				# Audio (should continue to next trial so audio and visual appear together 
				sound_event.set_port_code(55);
				main_trial_audio.present();
					
				#Visual
				int stimOnset = clock.time()-t0;
				 main_trial.present();
				
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					
				# Analyse responses and generate appropriate feedback 
				stimulus_data sd=stimulus_manager.last_stimulus_data();
				int RT=sd.reaction_time();
				int button=sd.button();
				int respOnset = 0;
				int FB=0;						
				
				if (button==0) then
					fb_pict.set_font_color(0,0,0);
					fb_pict.set_font_size(48);
					fb_pict.set_caption("Drücke ein wenig schneller!", true);
					fb_event.set_port_code(196);
					FB = 2;	
				else
						if (	(target_button==16 && button==1) || 
							(target_button==32 && button==2)	) then
							FB=1;
							fb_pict.set_font_color(0,102,51);
							fb_pict.set_font_size(168);
							fb_pict.set_caption("😊", true); #positive feedback, richtig entschieden
							fb_event.set_port_code(64);
						#register the response onset 
							respOnset = stimOnset+RT;
						else	
							FB=0;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(138);
							fb_pict.set_caption("😕", true); #negative feedback, falsch entschieden
							fb_event.set_port_code(128);
						#register the response onset 
							respOnset = stimOnset+RT;
						end;
					
				end;
			 #~~~~~~~~~~~~Present feedback ~~~~~~~~~~~~~~~~~~~~~~~
				fixBeforeFeedback_trial.set_duration(itifeedback[i]); #iti trial duration jittered
				fixBeforeFeedback_trial.present();
				#register feedbackOnset
				int feedbackOnset = clock.time()-t0;
				#Present
				feedback.present();
				#Present a fixation after the last trial of the block
				if (i == 40) then; 
				 wait.present();
				end;
				
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Print out stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#..............................................................................................
		
			# Output file:	 
				out_file.print(blockNum); out_file.print("\t"); 	# block nr
				out_file.print(i); out_file.print("\t"); 			# trial nr
				out_file.print(string(vStim1)+"_"+string(vStim2)); out_file.print("\t"); 	# visual stimulus nr, 1,2,3 or 4
 				out_file.print(aStim); out_file.print("\t"); 	# auditive stimulus nr, 1,2,3 or 4		
				out_file.print(button); out_file.print("\t"); 					# response button
				out_file.print(RT); out_file.print("\t"); 						# response time
				out_file.print(FB); out_file.print("\t"); 						# feedback type (0=wrong, 1=good , 2= faster!)
				out_file.print(iti[i]); out_file.print("\t"); 		
				out_file.print(itifeedback[i]); out_file.print("\t"); 	
				out_file.print(activePict[vStim1]+activePict[vStim2]);out_file.print("\t");		# get_filename(pict.filename()));	# filename of the picture
				out_file.print(activeSnd[aStim]);out_file.print("\t");		# get_filename(snd.filename()));	# filename of the sound
				out_file.print(stimOnset);	out_file.print("\t");				# stimulus onset from 1st pulse
				out_file.print(respOnset);	out_file.print("\t");				# response onset from 1st pulse
				out_file.print(feedbackOnset); 										# feedback onset from 1st pulse
				out_file.print("\n");
				
				i=i+1;	
		end;
end;
