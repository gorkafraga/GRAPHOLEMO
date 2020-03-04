# 										FEEDBACK LEARNING TASK
#----------------------------------------------------------------------------------------------------------------------
# - Simultaneous presentation of visual + sound
# - Forced response but trials are NOT response terminated (fMRI)
# - Letter-sound associations are learned by the feedback presented some time after response (jittered for fMRI)
# - Only informative (consistent feedback provided)
# - For each block stimuli are drawn and pairs randomized. 
#
# Note: pcl file contains randomization of the actual stimuli. Called with (include "FeedbackLearning-MRI.pcl") 
# Patrick Haller (hallerp@student.ethz.ch), June 2019
#----------------------------------------------------------------------------------------------------------------------
scenario= "FeedLearn_MRI_children_4stim.sce";
scenario_type=fMRI_emulation; 					#use scenario_type=fMRI_emulation for testing outside scanner environemtn;  otherwise scenario_type=fMRI
write_codes=false; 									# generate logs (turned to false for testing purposes)

#MR sequence parameters
pulses_per_scan = 1;					#registers the first of the specified number of pulses #how many square wave pulses are produced by the MRI scanner during one scan??
scan_period=1000;						#time between complete MRI scans in msear
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
picture { text { caption="+"; font_size=20; font_color=0,0,0;}cross; x=0; y=0;} fix;
picture { text { caption="."; font_size=48; font_color=0,0,0;}; x=0; y=0; } fix2;
# feedback (content is modified later)
picture { text { caption="😊"; font_size=80; font_color=0,0,0;} fb_pict; x=0; y=0; }feed_pic;

# stimuli from main trial
sound { wavefile { filename = "norm_ä.wav"; preload=true;} snd;} astim;
picture { text { caption="V1";font_size=80; } vTXT1; x=0; y=0;} vstim1; # for testing purposes, use the stim identifier instead of the actual pictue/sound
picture { text { caption="V2";font_size=80; } vTXT2; x=0; y=0;} vstim2;

# combine pics from main trial
picture{ text  cross; x=0; y=0;
			text  vTXT1; x=-120; y=0; #was 200
			text  vTXT2; x=120; y=0;
	} main_pic;
	
# intro practice
picture { text { caption="<b> Herzlich Willkommen auf dem Planeten Alblabla! </b>	
													
		 Gleich wirst du Ally helfen, die fremde Schrift der Bewohner von hier zu lernen.
		
		Damit du weisst, wie das geht, üben wir das kurz, in Ordnung?"; font_size=15; font_color=0,0,0;}practice_intro_txt; x=0; y=0;} practice_intro_txt_pic;
# combine pic and text for intro
picture{ text  practice_intro_txt; x=0; y=100;
			bitmap {filename="Buchstaben-Planet_small-nobg.png";width=260;height=241;preload=true;alpha=-1;};x=0; y=-100;
	} practice_intro_all;	
	
# intro no practice
picture { text { caption="Toll, Ally kennt nun dank dir ein paar Zeichen mehr - bravo!

		Willst du ihr helfen, auch die restlichen zu lernen?
		
		Wenn du bereit bist, drücke eine Taste und schon geht's los!"; font_size=15; font_color=0,0,0;}intro_txt; x=0; y=0;} intro_txt_pic;

# combine pic and text for intro
picture{ text  intro_txt; x=0; y=100;
			bitmap {filename="Farbig_16-17-removebg.png";width=297;height=211;preload=true;alpha=-1;};x=0; y=-100;
	} intro_all;
	
picture { text { caption="Alles klar, gleich geht's los! Maschinen starten!"; font_size=15; font_color=0,0,0;}start_txt; x=0; y=0;} start_txt_pic;
	
picture{	text start_txt; x=0; y=200;
			bitmap {filename="mri2-nobg.png";preload=true;width=213;height=294;alpha=-1;};x=0; y=0;
	} start_task;

picture { text { caption="Zu Beginn kontrollieren wir kurz, ob die Funkverbindung zu den Aliens bereit ist.

Merke dir dazu die 3 Laute, die du im Folgenden hören wirst"; font_size=13; font_color=0,0,0;}audiotest_txt; x=0; y=0;} audiotest_txt_pic;
	
picture{	text audiotest_txt; x=0; y=200;
			bitmap {filename="headphones.png";preload=true;width=150;height=110;alpha=-1;};x=0; y=0;
	} audiotest_pic;
	
picture { text { caption="Welche Laute hast du gehört?"; font_size=13; font_color=0,0,0;}abfrage_txt; x=0; y=0;} abfrage_txt_pic;
	
picture{	text abfrage_txt; x=0; y=200;
			bitmap {filename="headphones.png";preload=true;width=150;height=110;alpha=-1;};x=0; y=0;
	} abfrage_pic;	

#NOW WITH CUES
$wdth = 80;
$hght = 65;
# Fixation with cues!
picture{bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;};x=200; y=0;
		  bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;};x=-200; y=0;	
		  text cross; x=0; y=0;} fix_cue;

# feedback with cues!		
picture{bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;}; x=200; y=0;
		  bitmap {filename="question_mark.jpg";width=$wdth;height=$hght;preload=true;alpha=-1;};x=-200; y=0;	
		  text  fb_pict; x=0; y=0;} feed_pic_cue;
# ------------------------------------------------------------------------------------------------
# Trial definition 
# ------------------------------------------------------------------------------------------------

				
				
# wait for MR pulse
	 trial{	stimulus_event	{picture	{text{caption="+";font_size=30;font_color=0,0,0;};x=0;y=0;};duration=8000;code="100";}event_wait;}wait;
	
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
			duration = 2000;
			target_button=1;
			response_active=true; 
			code="stim";  
		} main_stim;
		stimulus_event {
			picture fix; 
			time = 2000; 
			duration = 500;
			target_button=1;
			response_active=true; 
			code="ext";  
		} rw_extension;
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
			code="feedback";
		} fb_event;
	} feedback;

# practice instruction trials

	 trial {
			trial_duration = forever;
			trial_type = first_response;
			terminator_button = 1;
			stimulus_event{
			picture intro_all;
			code = "intro";
			}intro_event;
	} instr_task;
	
# instruction trials
	 trial {
			trial_duration = forever;
			trial_type = first_response;
			terminator_button = 1;
			stimulus_event{
			picture practice_intro_all;
			code = "practice_intro";
			}practice_intro_event;
	} practice_instr_task;
	
	
# start trial
	trial {
		trial_type=fixed;
		trial_duration=5000;
		stimulus_event {
			picture start_task;
			code="start";
		} start_fb_task;
	} start;
	
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
	
 
#[ MRI Pulse terminated start screen] 
#----------------------------------------------------------------
# Screen indicating the current block
	picture { text { caption= " "; font_size=15; font_color=0,0,0;} block_screen_txt ; x=0; y=0; } block_screen_pic;#fill in later in pcl part with block no.
	trial {
			picture  block_screen_pic;		  
			mri_pulse = 1;                    #this should terminate the trial by the fMRI pulse
			duration = 5000;
  } block_screen;

#====================================================================================#====================================================================================
#			 BEGIN PCL (It will execute the pcl file to execute randomization 
#====================================================================================#====================================================================================
begin_pcl;

#Pop-up  window asking for input on response order (counterbalanced)
#preset string scenarioName = "FeedLearn-GFG";
preset int blockNum;
preset int fontType;


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
string scenarioName = "FeedLearn_MRI_children_4stim";
output_file out_file = new output_file;
if (logfile.subject().count()>0) then out_file.open(logfilename.replace(".log",".txt"));
else out_file.open("NoSubj_"+scenarioName+"_"+"_B"+string(blockNum)+".txt"); end;

#headers in txt file
out_file.print("block\ttrial\tvStim1\tvStim2\taStim\tresp\trt\tfb\titi\tfeedJitter\tvSymbol1\tvSymbol2\tvSymbolCorrect\taFile\tstimOnset\trespOnset\tfeedbackOnset\n");
#out_file.print("Block"+string(blockNum)+"\t"+"\n\n");

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Execute pcl file with randomizations 
include "FeedLearn_MRI_children_4stim.pcl"
#Some variables to keep track of things
int  target_button;
int correct;
bool random_feedback=false;
double totalResponse=0.0;
array <int> nrCorrect[4]={0,0,0,0};
int avgResponse = 2000;

#=================================================================================================================================================================================
#        BEGIN Instructions 																																						
#=================================================================================================================================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
#
# [ I N S T R U C T I O N ] 
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
# practice block or the real stuff
if (blockNum == 0) then 
	audiotest.present();
	block_screen_txt.set_caption("Starte Audiotest", true); 
	block_screen.present(); 
	int aStim = 0;
	array <string> activeSnd[3]= {"norm_ü.wav", "norm_n.wav","norm_g.wav"};	
	array <int> practiceOrder[9]= {1,1,2,3,1,2,3,3,2};
	
	# Loop through the pairOrder array and depending on the value select 
	loop int i = 1 until i> 9 begin			
		aStim = practiceOrder[i];
		snd.set_filename(activeSnd[aStim]);
		snd.load();	
		iti_fix_trial.set_duration(iti[i]); #iti trial duration jittered
		iti_fix_trial.present();
		sound_event.set_port_code(55);
		main_trial_audio.present();	
		i=i+1;
	end;
	abfrage.present()
else

#=================================================================================================================================================================================
#        BEGIN Practice  																																				
#=================================================================================================================================================================================
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
#
# [ P R A C T I C E ] 
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
# practice block or the real stuff


if (blockNum == 99) then 
	practice_instr_task.present();
	start.present();
		int nrCorrect_practice = 0;
		int aStim = 0;
		int vStim1 = 0; 
		int vStim2 = 0; 
		string pairOrderStr;
		array <string> activePict[4] = {"A","B","G","H"};
		array <string> activeSnd[4]= {"norm_b.wav", "norm_h.wav","norm_äu.wav", "norm_ö.wav"};	
		
		array <int> practiceOrder[20]= {112,113,141,221,212,114,223,221,343,434,112,224,414,323,313,441,131,343,424,442};	
	
		# Loop through the pairOrder array and depending on the value select 
		loop int i = 1 until i> 20 begin
			vTXT1.set_font("BACS2sans");
		 	vTXT1.set_font_size(50);  # this resets the font size for each trial. A conditional loop will adjust font sizes for specific symbols
			vTXT2.set_font("BACS2sans");
			vTXT2.set_font_size(50);		
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
				rw_extension.set_port_code(11);
			else
				target_button=32; 
				correct = vStim2;
				main_stim.set_port_code(22);
				rw_extension.set_port_code(22);
			end;
				
			#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				# present the time critical trial:
				iti_fix_trial.set_duration(iti[i]); #iti trial duration jittered
				iti_fix_trial.present();
				# Audio (should continue to next trial so audio and visual appear together 
				sound_event.set_port_code(55);
				main_trial_audio.present();
				int stim_ct = stimulus_manager.stimulus_count();
				#Visual
				if (i <=5) then
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
					fb_pict.set_font_size(20);
					fb_pict.set_caption("Schneller!", true);
					fb_event.set_port_code(196);
					FB = 2;	
				else
						if (	(target_button==16 && button==1) || 
							(target_button==32 && button==2)	) then
							FB=1;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(80);
							fb_pict.set_caption("😊", true); #positive feedback, richtig entschieden
							fb_event.set_port_code(64);
							nrCorrect_practice = nrCorrect_practice + 1;
						
						else	
							FB=0;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(80);
							fb_pict.set_caption("😕", true); #negative feedback, falsch entschieden
							fb_event.set_port_code(128);
							nrCorrect_practice = 0;
						
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
				term.print_line("Correct answers: " + string(nrCorrect_practice));
				if (nrCorrect_practice == 8) then
					break;
				end;	
		end;
elseif (blockNum == 100) then 
	practice_instr_task.present();
	start.present();
		int aStim = 0;
		int vStim1 = 0; 
		int vStim2 = 0; 
		string pairOrderStr;
		array <string> activePict[4] = {"A","B","G","H"};
		array <string> activeSnd[4]= {"norm_b.wav", "norm_h.wav","norm_äu.wav", "norm_ö.wav"};	
		
		array <int> practiceOrder[5]= {113,221,212,114,343,331};	
	
		# Loop through the pairOrder array and depending on the value select 
		loop int i = 1 until i> 5 begin
			vTXT1.set_font("BACS2sans");
		 	vTXT1.set_font_size(50);  # this resets the font size for each trial. A conditional loop will adjust font sizes for specific symbols
			vTXT2.set_font("BACS2sans");
			vTXT2.set_font_size(50);		
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
				rw_extension.set_port_code(11);
			else
				target_button=32; 
				correct = vStim2;
				main_stim.set_port_code(22);
				rw_extension.set_port_code(22);
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
					fb_pict.set_font_size(20);
					fb_pict.set_caption("Schneller!", true);
					fb_event.set_port_code(196);
					FB = 2;	
				else
						if (	(target_button==16 && button==1) || 
							(target_button==32 && button==2)	) then
							FB=1;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(80);
							fb_pict.set_caption("😊", true); #positive feedback, richtig entschieden
							fb_event.set_port_code(64);
						
						else	
							FB=0;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(80);
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
	start.present();
	#Present screen indicating block	 [MRI PULSE TERMINATED!]
			block_screen_txt.set_caption("Starte Block " + string(blockNum), true); 
			block_screen.present(); 	
			# Get time of pulse for calculation of stimuli, resp and feedback onset
			int t0 = pulse_manager.main_pulse_time(1);

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
		array <string> activePict[4];
		array <string> activeSnd[4];	
		
		loop int j=1 until j> 4 begin
			activePict[j] = pict_file[blockNum][j];
			j = j+1
		end;
		loop int k=1 until k> 4 begin
			activeSnd[k] = sound_file[blockNum][k];
			k=k+1;
		end; 
			
		# Loop through the pairOrder array and depending on the value select 
		loop int i = 1 until i> 40 begin
		 	vTXT1.set_font_size(50);  # this resets the font size for each trial. A conditional loop will adjust font sizes for specific symbols
			vTXT1.set_font(font_type[fontType]);
			vTXT2.set_font_size(50);
			vTXT2.set_font(font_type[fontType]);
			
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
				correct = vStim1;
				main_stim.set_port_code(11);
				rw_extension.set_port_code(11);
			else
				target_button=32; 
				correct = vStim2;
				main_stim.set_port_code(22);
				rw_extension.set_port_code(22);
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
					fb_pict.set_font_size(48);
					fb_pict.set_caption("Schneller!", true);
					fb_event.set_port_code(196);
					FB = 2;	
				else
						if (	(target_button==16 && button==1) || 
							(target_button==32 && button==2)	) then
							FB=1;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(80);
							fb_pict.set_caption("😊", true); #positive feedback, richtig entschieden
							fb_event.set_port_code(64);
						#register the response onset 
							respOnset = stimOnset+RT;
							nrCorrect[aStim] = nrCorrect[aStim]+1;
						else	
							FB=0;
							fb_pict.set_font_color(0,0,0);
							fb_pict.set_font_size(80);
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
				term.print_line("acc p1: " + string(double(nrCorrect[1])/10)+
									 ", acc p2: " + string(double(nrCorrect[2])/10)+
									 ", acc p3: " + string(double(nrCorrect[3])/10)+
									 ", acc p4: " + string(double(nrCorrect[4])/10));	
				 wait.present();
				end;
				
		#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Print out stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#..............................................................................................
		
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
				out_file.print(stimOnset);	out_file.print("\t");				# stimulus onset from 1st pulse
				out_file.print(respOnset);	out_file.print("\t");				# response onset from 1st pulse
				out_file.print(feedbackOnset); 										# feedback onset from 1st pulse
				out_file.print("\n");
				
				term.print_line("#correct p1: " + string(nrCorrect[1])+
									 ", #correct p2: " + string(nrCorrect[2])+
									 ", #correct p3: " + string(nrCorrect[3])+
									 ", #correct p4: " + string(nrCorrect[4]));
				i=i+1;	
		end;
end;
end;