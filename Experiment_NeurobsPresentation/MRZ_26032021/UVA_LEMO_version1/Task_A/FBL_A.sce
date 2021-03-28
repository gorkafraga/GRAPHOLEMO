# 										FEEDBACK LEARNING TASK
#----------------------------------------------------------------------------------------------------------------------
# - Simultaneous presentation of visual + sound
# - Forced response but trials are NOT response terminated (fMRI)
# - Letter-sound associations are learned by the feedback presented some time after response (jittered for fMRI)
# - Only informative (consistent feedback provided)
# - For each block stimuli are drawn and pairs randomized. 
#
# Note: pcl file contains randomization of the actual stimuli. Called with (include "**.pcl") 
# Original: Patrick Haller. https://github.com/pathalle/ 
# Current version: Gorka Fraga González
# First versions: November 2019, June 2019
#----------------------------------------------------------------------------------------------------------------------
scenario= "FBL_A.sce";
scenario_type=fMRI; 					#use scenario_type=fMRI_emulation for testing outside scanner environemtn;  otherwise scenario_type=fMRI
write_codes=false; 									# generate logs (turned to false for testing purposes)
#MR sequence parameters
pulses_per_scan = 1;			#registers the first of the specified number of pulses #how many square wave pulses are produced by the MRI scanner during one scan??
scan_period=1000;				#time between complete MRI scans in ms
pulse_code=199;				#used to identify main pulses in fMRI mode in the Analysis window and the logfile
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

# Start text 
picture { text { caption="Alles klar, gleich geht's los! Maschinen starten!"; font_size=15; font_color=0,0,0;}start_txt; x=0; y=0;} start_txt_pic;

#Instruction text 
picture { text { caption="<b> Willkommen! </b>														
				 In diesem Experiment lernen Sie eine Fantasieschrift.
				
				Sie werden auf beiden Seiten des Bildschirmes Symbole sehen und dazu einen Laut hören. 
				Darauf wählen Sie ein Symbol, welches zum Laut gehört, indem Sie den passenden Knopf 
drücken (rechts oder links).
				
				Nach jeder Antwort kriegen Sie ein Feedback, welches Ihnen anzeigt, wie Sie gedrückt haben: 
				korrekt (😊), inkorrekt (😕) oder ‘schneller’, wenn Sie zuviel Zeit gebraucht haben.
         
Dadurch werden Sie die korrekten Symbol-Laut Verknüpfungen lernen. 
				
				
				Versuchen Sie so schnell als möglich zu antworten.
		 
		
				<i> Drücken Sie einen Knopf um fortzufahren. </i>"; font= "Segoe UI emoji";font_size=20;text_align=align_left; font_color=0,0,0;}instr_txt; x=0; y=0;} instr_txt_pic;

# fixation
picture { text { caption="+"; font_size=38; font_color=0,0,0;}cross; x=0; y=0;} fix;
picture { text { caption="."; font_size=48; font_color=0,0,0;}; x=0; y=0; } fix2;
# feedback (content is modified later)
picture { text { caption="☺";font= "Segoe UI emoji"; font_size=98; font_color=0,0,0;} fb_pict; x=0; y=0; }feed_pic;

# stimuli from main trial
sound { wavefile { filename = "a_short_2_2.wav"; preload=true;} snd;} astim;
picture { text { caption="V1"; } vTXT1; x=0; y=0;} vstim1; # for testing purposes, use the stim identifier instead of the actual pictue/sound
picture { text { caption="V2";} vTXT2; x=0; y=0;} vstim2;
# combine pics from main trial
picture{ text  cross; x=0; y=0;
			text  vTXT1; x=0; y=0;
		#	text  vTXT2; x=300; y=0;
	}     main_pic; 
	

#NOW WITH CUES
$wdth = 80;
$hght = 65;

# Start task picture
picture{	text start_txt; x=0; y=200;
			bitmap {filename="mri2-nobg.png";preload=true;width=213;height=294;alpha=-1;};x=0; y=0;
	} start_task;


# Fixation with cues!
picture{bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;};x=600; y=0;
		  bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;};x=-600; y=0;	
		  text cross; x=0; y=0;} fix_cue;

# feedback with cues!		
picture{bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;}; x=600; y=0;
		  bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;};x=-600; y=0;	
		  text  fb_pict; x=0; y=0;} feed_pic_cue;

#Audio test
picture { text { caption="Zu Beginn kontrollieren wir kurz, ob die Kopfhörerverbindung funktioniert und Sie Laute gut hören können.

Merken Sie sich dazu die Laute, die Sie im Folgenden hören werden"; font_size=13; font_color=0,0,0;}audiotest_txt; x=0; y=0;} audiotest_txt_pic;
	
picture{	text audiotest_txt; x=0; y=200;
			bitmap {filename="headphones.png";preload=true;width=150;height=110;alpha=-1;};x=0; y=0;
	} audiotest_pic;
	
picture { text { caption="Welche Laute haben Sie gehört?"; font_size=13; font_color=0,0,0;}abfrage_txt; x=0; y=0;} abfrage_txt_pic;
	 
picture{	text abfrage_txt; x=0; y=200;
			bitmap {filename="headphones.png";preload=true;width=150;height=110;alpha=-1;};x=0; y=0;
	} abfrage_pic;	

# ------------------------------------------------------------------------------------------------
# Trial definition 
# ------------------------------------------------------------------------------------------------	
# wait for MR pulse
   trial{	stimulus_event	
			{picture	{text{caption="+";font_size=48;font_color=0,102,51;};x=0;y=0;};duration=8000;code="100";}
			event_wait;
	}wait;
	
 trial {trial_type=fixed;
			trial_duration=5000;
			stimulus_event {
				picture start_task;
				code="start";
			} start_fb_task;
	} start;
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
		trial_duration = 2500;
		stimulus_event {
			picture main_pic; 
			time = 0; 
			duration = 2500;
			target_button=1;
			response_active=true; 
			code="stim";  
		} main_stim;
	} main_trial;	
	
 # main trial self-paced
	trial {
		trial_type=first_response;
		trial_duration = forever;
		stimulus_event {
			picture main_pic; 
			time = 0; 
			target_button=1;
			response_active=true; 
			code="stim";  
		} main_stim_selfpaced;
	} main_trial_selfpaced;		
	
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


#---- other trials
	
# audiotest
	trial {
		trial_type=first_response;
		trial_duration=forever;
		terminator_button = 1;
		stimulus_event {
			picture audiotest_pic;
			code="audiotest";
		} start_audiotest;
	} audiotest;	
	
# abfrage
	trial {
		trial_type=first_response;
		trial_duration=forever;
		terminator_button = 1;
		stimulus_event {
			picture abfrage_pic;
			code="abfrage";
		} start_abfrage;
	} abfrage;		
	
# Instruction trials: instructions depend upon variable respMatch (defined in pop-up at start )
	
	 trial {
			trial_duration = forever;
			trial_type = first_response;
			terminator_button = 1;
			stimulus_event { 
				picture instr_txt_pic;
				} instr_pic;
			} instr;
	
#[ MRI Pulse terminated start screen] 

# Screen indicating the current block
	picture { text { caption= "x"; font_size=48; font_color=0,102,51;} block_screen_txt ; x=0; y=0; } block_screen_pic;#fill in later in pcl part with block no.
	trial {
			#trial_type=fixed;
			#trial_duration = forever;
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
	
	
#====================================================================================#
#			 BEGIN PCL (It will execute the pcl file to execute randomization 
#====================================================================================#
begin_pcl;

#Pop-up  window asking for input on response order (counterbalanced)
#preset string scenarioName = "FeedLearn-GFG";
preset int blockNum;
preset int leftIsMatch = 1;		# default right=match, left=mismatch
preset string stickers = "check instructions";

# LOG AND OUTPUTFILE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
string  logfilename = logfile.filename();
logfile.set_filename(logfilename.replace("..log","_block"+string(blockNum)+".log"));
logfilename = logfile.filename();		

if (file_exists(logfilename)) then 
	int i = 1;
		loop until !file_exists(logfilename.replace(".log", "-" + string(i) + ".log"))
	begin
        i = i + 1;
   end;
   logfilename = logfilename.replace(".log","-" + string(i) + ".log")
end;
logfile.set_filename(logfilename);
	
#create .txt outputfile
string scenarioName = "FBL_A";
output_file out_file = new output_file;
if (logfile.subject().count()>0) then out_file.open(logfilename.replace(".log",".txt"));
else out_file.open("NoSubj_"+scenarioName+"_block"+string(blockNum)+".txt"); end;

#headers in txt file
out_file.print("block\ttrial\tvStim\taStim\tresp\trt\tfb\titi\tfeedJitter\tvSymbol\taFile\tFBtype\tstimOnset\trespOnset\tfeedbackOnset\n");
#out_file.print("Block"+string(blockNum)+"\t"+"\n\n");
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Execute pcl file with randomizations 
include "FBL_A.pcl";
#Some variables to keep track of things
int  target_button; 
bool random_feedback=false;
double totalResponse=0.0;
int nrCorrect=0;
int avgResponse = 2000;
int correct;


#=================================================================================================================================================================================
#     																																							_m_d[°_°]b_m_
#=================================================================================================================================================================================
#================================================
#
# [ I N S T R U C T I O N ] 
#
#================================================
# practice block or the real stuff
if (blockNum == 0) then 
	audiotest.present();
	block_screen_txt.set_caption("Starte Audiotest", true); 
	block_screen.present(); 
	int aStim = 0;
	array <string> activeSnd[9]= {"t_2_1_loudCheck.wav","l_2_2_loudCheck.wav","b_2_1.wav","in_short_2_1_loudCheck.wav","k_2_1_loudCheck.wav","z_2_2.wav","w_2_2_loudCheck.wav","r_2_1.wav","ach_2_1.wav"};	
	#array <int> practiceOrder[9]= {1,1,2,3,1,2,3,3,2};
 
	# Loop through the pairOrder array and depending on the value select 
	loop int i = 1 until i> 9 begin			
		#aStim = practiceOrder[i];
		#snd.set_filename(activeSnd[aStim]);
		snd.set_filename(activeSnd[i]);
		snd.load();	
		iti_fix_trial.set_duration(iti[i]); #iti trial duration jittered
		iti_fix_trial.present();
		sound_event.set_port_code(55);
		main_trial_audio.present();	
		i=i+1;
	end;
	abfrage.present()
else


#================================================
#
# L O N G     P R A C T I C E  -  OUTSIDE SCANNER 
#
#================================================
# practice block or the real stuff


if (blockNum == 99) then 
	instr.present();
	#start.present();
		int nrCorrect_practice = 0;
		int aStim = 0;
		int vStim1 = 0; 
		int vStim2 = 0; 
		string pairOrderStr;
		array <string> activePict[4] = {"a","b","0","1"};
		array <string> activeSnd[4]= {"äu_2_3.wav","au_2_2.wav","ü_short_2_2.wav","m_2_1.wav"};	
		
		array <int> practiceOrder[20]= {112,113,141,221,212,114,223,221,343,434,112,224,414,323,313,441,131,343,424,442};	
	
		# Loop through the pairOrder array and depending on the value select 
		loop int i = 1 until i> 20 begin
			vTXT1.set_font("FBLearning");#vTXT2.set_font("FBLearning");
		 	vTXT1.set_font_size(100); # vTXT2.set_font_size(100); 	
		   vTXT2.set_width(600);
			
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
				correct = vStim1;
				main_stim.set_port_code(11);
				#rw_extension.set_port_code(11);
			else
				target_button=32; 
				correct = vStim2;
				main_stim.set_port_code(22);
				#rw_extension.set_port_code(22);
			end;
				
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# present the time critical trial:
				iti_fix_trial.set_duration(iti[i]-1000); #iti trial duration jittered
				iti_fix_trial.present();
				# Audio (should continue to next trial so audio and visual appear together 
				sound_event.set_port_code(55);
				main_trial_audio.present();
				int stim_ct = stimulus_manager.stimulus_count();
				#Visual
				if (i <=0) then
					main_trial_selfpaced.present();
				else
					main_trial.present();
				end;
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				stimulus_data sd = stimulus_manager.get_stimulus_data( stim_ct + 1 );
				int RT=sd.reaction_time();	
				int button=sd.button();
				int respOnset = 0;
				int FB=0;						
				if (button==0) then
					fb_pict.set_font_color(0,0,0);
					fb_pict.set_font_size(50);
					fb_pict.set_caption("Schneller!", true);
					fb_event.set_port_code(196);
					FB = 2;	
				else
						if (	(target_button==16 && button==1) || 
							(target_button==32 && button==2)	) then
							FB=1;
							fb_pict.set_font_color(0,102,51);
							fb_pict.set_font_size(120);
							fb_pict.set_caption("😊", true); #positive feedback, richtig entschieden
							fb_event.set_port_code(64);
							nrCorrect_practice = nrCorrect_practice + 1;
						
						else	
							FB=0;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(120);
							fb_pict.set_caption("😕", true); #negative feedback, falsch entschieden
							fb_event.set_port_code(128);
							nrCorrect_practice = 0;
						
					end;	
				end;
			 #~~~~~~~~~~~~Present feedback ~~~~~~~~~~~~~~~~~~~~~~~
				fixBeforeFeedback_trial.set_duration(itifeedback[i]-1000); #iti trial duration jittered
				fixBeforeFeedback_trial.present();
				#Present
				feedback.present();				
			
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Print out stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# Output file:	 
				out_file.print(blockNum); out_file.print("\t"); 	# block nr
				out_file.print(i); out_file.print("\t"); 			# trial nr
				out_file.print(string(vStim1)); out_file.print("\t"); 	# visual stimulus nr, 1,2,3 or 4
				out_file.print(string(vStim2)); out_file.print("\t");
				out_file.print(aStim); out_file.print("\t"); 	# auditive stimulus nr, 1,2,3 or 4	
				out_file.print(button); out_file.print("\t"); 					# response button
				out_file.print(RT); out_file.print("\t"); 						# response time
				out_file.print(FB); out_file.print("\t"); 						# feedback type (0=wrong, 1=good , 2= faster!)
				out_file.print(iti[i]); out_file.print("\t"); 		
				out_file.print(itifeedback[i]); out_file.print("\t"); 		
				out_file.print(activePict[vStim1]); out_file.print("\t");		
				out_file.print(activePict[vStim2]); out_file.print("\t");
				out_file.print(activePict[correct]); out_file.print("\t");		
				out_file.print(activeSnd[aStim]);out_file.print("\t");		# get_filename(snd.filename()));	# filename of the sound
				out_file.print("practice");	out_file.print("\t");				# stimulus onset from 1st pulse
				out_file.print("practice");	out_file.print("\t");				# response onset from 1st pulse
				out_file.print("practice"); 										# feedback onset from 1st pulse
				out_file.print("\n");
				
				i=i+1;
				term.print_line("Correct answers: " + string(nrCorrect_practice));
				if (nrCorrect_practice == 8) then
					break;
				end;	
		end;	

#================================================
#
# S H O R T    P R A C T I C E  -  INSIDE SCANNER  
#
#================================================
elseif (blockNum == 100) then 
	#practice_instr_task.present();
	#start.present();
		int aStim = 0;
		int vStim1 = 0; 
		int vStim2 = 0; 
		string pairOrderStr;
		array <string> activePict[4] = {"A","B","G","H"};
		array <string> activeSnd[4]= {"norm_b.wav", "norm_h.wav","norm_äu.wav", "norm_ö.wav"};	
		
		array <int> practiceOrder[5]= {113,221,212,114,343,331};	
	
		# Loop through the pairOrder array and depending on the value select 
		loop int i = 1 until i> 5 begin
			vTXT1.set_font("BACS1");vTXT2.set_font("BACS1");
		 	vTXT1.set_font_size(100); vTXT2.set_font_size(100);		
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
				correct = vStim1;
				main_stim.set_port_code(11);
				#rw_extension.set_port_code(11);
			else
				target_button=32; 
				correct = vStim2;
				main_stim.set_port_code(22);
				#rw_extension.set_port_code(22);
		end;
				
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# present the time critical trial:
				iti_fix_trial.set_duration(iti[i]); #iti trial duration jittered
				iti_fix_trial.present();
				# Audio (should continue to next trial so audio and visual appear together 
				sound_event.set_port_code(55);
				main_trial_audio.present();
				#Visual
				int stim_ct = stimulus_manager.stimulus_count(); 
				main_trial.present();
				
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					
				# Analyse responses and generate appropriate feedback 
				stimulus_data sd = stimulus_manager.get_stimulus_data( stim_ct + 1 );
				int RT=sd.reaction_time();
				int button=sd.button();
				int respOnset = 0;
				int FB=0;						
				
				if (button==0) then
					fb_pict.set_font_color(0,0,0);
					fb_pict.set_font_size(50);
					fb_pict.set_caption("Schneller!", true);
					fb_event.set_port_code(196);
					FB = 2;	
				else
						if (	(target_button==16 && button==1) || 
							(target_button==32 && button==2)	) then
							FB=1;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(100);
							fb_pict.set_caption("😊", true); #positive feedback, richtig entschieden
							fb_event.set_port_code(64);
						
						else	
							FB=0;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(100);
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
				out_file.print(string(vStim1)); out_file.print("\t"); 	# visual stimulus nr, 1,2,3 or 4
				out_file.print(string(vStim2)); out_file.print("\t");
				out_file.print(aStim); out_file.print("\t"); 	# auditive stimulus nr, 1,2,3 or 4	
				out_file.print(button); out_file.print("\t"); 					# response button
				out_file.print(RT); out_file.print("\t"); 						# response time
				out_file.print(FB); out_file.print("\t"); 						# feedback type (0=wrong, 1=good , 2= faster!)
				out_file.print(iti[i]); out_file.print("\t"); 		
				out_file.print(itifeedback[i]); out_file.print("\t");	
				out_file.print(activePict[vStim1]); out_file.print("\t");		
				out_file.print(activePict[vStim2]); out_file.print("\t");
				out_file.print(activePict[correct]); out_file.print("\t"); 	
				out_file.print(activeSnd[aStim]);out_file.print("\t");		# get_filename(snd.filename()));	# filename of the sound
				out_file.print("practice");	out_file.print("\t");				# stimulus onset from 1st pulse
				out_file.print("practice");	out_file.print("\t");				# response onset from 1st pulse
				out_file.print("practice"); 										# feedback onset from 1st pulse
				out_file.print("\n");
				
				i=i+1;	
		end;
else		
#================================================	
#
#  M A I N    T A S K 
#
#================================================

#some initial shuffling
	itifeedback.shuffle();
	iti.shuffle();	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	instr.present();
	start.present();
	#Present screen indicating block	 [MRI PULSE TERMINATED!]
			block_screen_txt.set_caption("Start block " + string(blockNum), true); 
			block_screen.present(); 	
			# Get time of pulse for calculation of stimuli, resp and feedback onset
			int t0 = pulse_manager.main_pulse_time(1);
			/*	if (blockNum==4) then 				pauzeBeforeEnd.present();				
			else block_screen_txt.set_caption("Start block" + string(blockNum), true); 		
			end;*/
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
array <int> soundOrder[48] = { 0,0,0,0,0,0,0,0,0,0,
										0,0,0,0,0,0,0,0,0,0,
										0,0,0,0,0,0,0,0,0,0,0,0,0,0,
										0,0,0,0,0,0,0,0,0,0,0,0,0,0};
										
array <int> visualOrder[48] = {0,0,0,0,0,0,0,0,0,0,
										0,0,0,0,0,0,0,0,0,0,
										0,0,0,0,0,0,0,0,0,0,0,0,0,0,
										0,0,0,0,0,0,0,0,0,0,0,0,0,0};
										 
									

	#Select 
	if (blockNum == 1) then   
				soundOrder = soundOrderB1;
				visualOrder = visualOrderB1;
 		elseif (blockNum == 2)  then
				soundOrder = soundOrderB2;
				visualOrder = visualOrderB2; 
		elseif (blockNum == 3) then 
				soundOrder = soundOrderB3;
				visualOrder = visualOrderB3;
 		elseif (blockNum == 4) then 
				soundOrder = soundOrderB4;
				visualOrder = visualOrderB4;
 	end;  

	#~~~~~~~~ Assign stimuli for this trial ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	 
	#Create an array with the selected stimuli for this block 
		int vStim1 = 0;
		int vStim2 = 0;
		int aStim = 0;
		string pairOrderStr;
		array <string> activePict[8];
		array <string> activeSnd[6];	
		
		loop int j=1 until j> 8 begin
			activePict[j] = pict_file[blockNum][j];
			j = j+1
		end;
		loop int k=1 until k> 6 begin
			activeSnd[k] = sound_file[blockNum][k];
			k=k+1;
		end; 
			
		# Loop through the pairOrder array and depending on the value select 
		loop int i = 1 until i> 48 begin
			 	vTXT1.set_font_size(100);  # this resets the font size for each trial. A conditional loop will adjust font sizes for specific symbols # Original value: 100
				vTXT1.set_font("lemo6");
				vTXT2.set_font_size(100);
				vTXT2.set_font("lemo6");	
				 
				aStim = soundOrder[i];
				vStim1 = visualOrder[i];
 				
				vTXT1.set_caption(activePict[vStim1], true); 
				snd.set_filename(activeSnd[aStim]);
				snd.load();
				
				if (aStim == vStim1)  then
					target_button=16; 
					main_stim.set_port_code(11);
						 if (leftIsMatch==0)then #Switch buttons depending on presentation order
							target_button=32; 
							main_stim.set_port_code(22)
						end; 
				else
					target_button=32; 
					main_stim.set_port_code(22);
						if (leftIsMatch==0)then 
							target_button=16; 
							main_stim.set_port_code(11)
						end;	
			   end;
		      term.print("target_button");term.print(target_button); term.print("_Astim ");term.print(aStim);term.print("_Vstim1 ");term.print(vStim1);term.print("\n");
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~					
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
				int RT= sd.reaction_time();
				int button=sd.button();
				int respOnset = 0;
				int FB=0;
		   	string FBtype;
				FBtype = "Cong";

					#Prepare array for inconsistent feedback (shuffle it to randomize feedback with different probabiliies.)
					array <int> inconsistentFeedback[10]= {1,1,1,1,1,1,1,1,1,1}; # turn 2 to zero for 80 % positive feedback
					inconsistentFeedback.shuffle();
					
				if (button==0) then
					fb_pict.set_font_color(0,0,0);
					fb_pict.set_font_size(50);
					fb_pict.set_caption("Schneller!", true);
					fb_event.set_port_code(196);
					FB = 2;	
				else
					if (aStim < 7) then
							if (	(target_button==16 && button==1) || (target_button==32 && button==2)	) then
								fb_pict.set_font_color(0,102,51);
								fb_pict.set_font_size(100);
								fb_pict.set_caption("😊", true); #positive feedback, richtig entschieden
								fb_event.set_port_code(64);
								FB=1;
								#register the response onset 
								respOnset = stimOnset+RT;
							else	
								fb_pict.set_font_color(0,0,0);
								fb_pict.set_font_size(100);
								fb_pict.set_caption("😕", true); #negative feedback, falsch entschieden
								fb_event.set_port_code(128);
								FB=0; 
								#register the response onset 
								respOnset = stimOnset+RT;						
							end;
					end;
					# Provide random feedback when some sounds are presented		
               #elseif (aStim > 3 && inconsistentFeedback[1]==1) then
					#				fb_pict.set_font_color(0,102,51);
					#				fb_pict.set_font_size(100);
					#				fb_pict.set_caption("😊", true); #positive feedback, richtig entschieden
					#				FB=inconsistentFeedback[1];
					#				fb_event.set_port_code(64);
					#				FBtype = "Incong";
				   #elseif (aStim > 3 && inconsistentFeedback[1]==0) then
					#				fb_pict.set_font_color(0,0,0);
					#				fb_pict.set_font_size(100);
					#				fb_pict.set_caption("😕", true); #negative feedback, falsch entschieden
					#				FB=inconsistentFeedback[1];
					#				fb_event.set_port_code(128);
					#				FBtype = "Incong";
#					end;
				end;
			 #~~~~~~~~~~~~Present feedback ~~~~~~~~~~~~~~~~~~~~~~~
				fixBeforeFeedback_trial.set_duration(itifeedback[i]); #iti trial duration jittered
				fixBeforeFeedback_trial.present();

				#register feedbackOnset
				int feedbackOnset = clock.time()-t0;
				#Present
				feedback.present();
				#Present a fixation after the last trial of the block
				if (i == 48) then; 
				 event_wait.set_duration(1500);
				 wait.present();
				end;
				
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Print out stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#..............................................................................................
		   	# Output file:	 
				out_file.print(blockNum); out_file.print("\t"); 	# block nr
				out_file.print(i); out_file.print("\t"); 			# trial nr
				out_file.print(vStim1); out_file.print("\t"); 	# visual stimulus nr 
 				out_file.print(aStim); out_file.print("\t"); 	# auditive stimulus nr 		
				out_file.print(button); out_file.print("\t"); 					# response button
				out_file.print(RT); out_file.print("\t"); 						# response time
				out_file.print(FB); out_file.print("\t"); 						# feedback (0=wrong, 1=good , 2= faster!)
				out_file.print(iti[i]); out_file.print("\t"); 		
				out_file.print(itifeedback[i]); out_file.print("\t"); 	
				out_file.print(activeSnd[aStim]);out_file.print("\t");		# get_filename(snd.filename()));	# filename of the sound
				out_file.print(activePict[vStim1]);out_file.print("\t");		#  
				out_file.print(FBtype);out_file.print("\t");		
				out_file.print(stimOnset);	out_file.print("\t");				# stimulus onset from 1st pulse
				out_file.print(respOnset);	out_file.print("\t");				# response onset from 1st pulse
				out_file.print(feedbackOnset); 										# feedback onset from 1st pulse
				out_file.print("\n");
				
				i=i+1;	
		end;
end;
end;