## Implicit_learning task, May 2019
##
## Christina Lutz, based on a script by Sarah Di Pietro
##########################################################################################################################

scenario_type=fMRI_emulation; #In order to test an fMRI mode scenario without an external connection scenario_type=fMRI_emulation; otherwise scenario_type=fMRI


pulses_per_scan = 1;		#registers the first of the specified number of pulses #how many square wave pulses are produced by the MRI scanner during one scan??
scan_period=1000;			#time between complete MRI scans in ms
pulse_code=199;			#used to identify main pulses in fMRI mode in the Analysis window and the logfile
pulse_width=1;				#pulses are 1 ms long #width of pulses in ms
#default_output_port=1; 	#Assigned to the port parameter for stimulus events that do not define that parameter; does not affect output port used for responses
write_codes=false; 		#Writes codes to output port that depend on the event; value will be written to output port at the occurance of all stimuli for which port_code is defined
response_matching=simple_matching;	#Affects how response active stimuli are associated with responses
response_port_output=true;

#active_buttons = 4;
#button_codes = 1,2,3,4;
active_buttons = 2;						#indicates how many response buttons are used in the scenario. Must match buttons selected on response panel
button_codes = 20,21;			#Assigns numerical codes to each response button used in the scenario --> logfile and output port (if write_codes=true)
target_button_codes = 25,26;	#Only used for correct responses to active targets

$stimx=0;
$stimy=0;
$stimPresDur=700;

default_font_size = 50; #AV: 89; NA Pilot Arial: 72
$cross_size = 30;
default_font = "Courier New Chopped";
default_text_color = 0,0,0; #black
default_background_color = 128,128,128; #grey


#$FFlearned="AllRead_MRFont1";
#$FFfamiliar="AllRead_MRFont2";
#$FFnew="AllRead_MRFont3"; #same for familiar and new 

$Schulfont="Courier New Chopped";

#-------------------------------------------------------------------------------------------------------------------
#start of SDL
begin;

#Here, the fixation cross is defined (500 ms, in the middle of the screen). The fixation cross is part of the fixation_trial
text{caption="+";font_color = 0,0,0; font_size=$cross_size;preload=true;}cross;

trial{
	stimulus_event
		{picture{
			text cross; x=$stimx;y=$stimy;
			}fixation_cross;
		}eventFixation;
}fixation_trial;

#Here, the rest trials are defined(5000 ms or 9600 ms, in the middle of the screen).
text{caption="+";font_color = 0,0,0;preload=true;}rest_text;
trial{
	stimulus_event
		{picture{
			text rest_text;
			x=$stimx;y=$stimy;
			}picRest; code="10";
	}eventRest;
}rest_trial;  



##LETTERS Block 1 and Block 2 from Learning task
array{text{caption="b";preload=true;}letter1; 
		text{caption="m";preload=true;}letter2;
		text{caption="u";preload=true;}letter3;
		text{caption="g";preload=true;}letter4;
		text{caption="t";preload=true;}letter5;
		text{caption="z";preload=true;}letter6;
		text{caption="e";preload=true;}letter7;
		text{caption="p";preload=true;}letter8;
		text{caption="b";preload=true;}letter9; 
		text{caption="m";preload=true;}letter10;
		text{caption="u";preload=true;}letter11;
		text{caption="s";preload=true;}letter12;
		text{caption="t";preload=true;}letter13;
		text{caption="z";preload=true;}letter14;
		text{caption="e";preload=true;}letter15;
		text{caption="p";preload=true;}letter16;
	}letter;

/*
##LETTER BACKUP (in case one of the regular first two blocks had to be interrupted and a backup block - B3 or B4 - was run)
array{text{caption="k";preload=true;}letterB13_1; 
		text{caption="s";preload=true;}letterB13_2;
		text{caption="o";preload=true;}letterB13_3;
		text{caption="j";preload=true;}letterB13_4;
		text{caption="d";preload=true;}letterB13_5;
		text{caption="n";preload=true;}letterB13_6;
		text{caption="e";preload=true;}letterB13_7;
		text{caption="q";preload=true;}letterB13_8;
		text{caption="k";preload=true;}letterB13_9; 
		text{caption="s";preload=true;}letterB13_10;
		text{caption="o";preload=true;}letterB13_11;
		text{caption="j";preload=true;}letterB13_12;
		text{caption="d";preload=true;}letterB13_13;
		text{caption="n";preload=true;}letterB13_14;
		text{caption="e";preload=true;}letterB13_15;
		text{caption="q";preload=true;}letterB13_16;
		text{caption="target";preload=true;}letterB13_target;
	}letterBackup1_B3;

array{text{caption="t";preload=true;}letterB14_1; 
		text{caption="z";preload=true;}letterB14_2;
		text{caption="i";preload=true;}letterB14_3;
		text{caption="g";preload=true;}letterB14_4;
		text{caption="d";preload=true;}letterB14_5;
		text{caption="n";preload=true;}letterB14_6;
		text{caption="e";preload=true;}letterB14_7;
		text{caption="q";preload=true;}letterB14_8;
		text{caption="t";preload=true;}letterB14_9; 
		text{caption="z";preload=true;}letterB14_10;
		text{caption="i";preload=true;}letterB14_11;
		text{caption="g";preload=true;}letterB14_12;
		text{caption="d";preload=true;}letterB14_13;
		text{caption="n";preload=true;}letterB14_14;
		text{caption="e";preload=true;}letterB14_15;
		text{caption="q";preload=true;}letterB14_16;
		text{caption="target";preload=true;}letterB14_target;
	}letterBackup1_B4;
	
array{text{caption="b";preload=true;}letterB23_1; 
		text{caption="m";preload=true;}letterB23_2;
		text{caption="u";preload=true;}letterB23_3;
		text{caption="p";preload=true;}letterB23_4;
		text{caption="k";preload=true;}letterB23_5;
		text{caption="s";preload=true;}letterB23_6;
		text{caption="o";preload=true;}letterB23_7;
		text{caption="j";preload=true;}letterB23_8;
		text{caption="b";preload=true;}letterB23_9; 
		text{caption="m";preload=true;}letterB23_10;
		text{caption="u";preload=true;}letterB23_11;
		text{caption="p";preload=true;}letterB23_12;
		text{caption="k";preload=true;}letterB23_13;
		text{caption="s";preload=true;}letterB23_14;
		text{caption="o";preload=true;}letterB23_15;
		text{caption="j";preload=true;}letterB23_16;
		text{caption="target";preload=true;}letterB23_target;
	}letterBackup2_B3;

array{text{caption="b";preload=true;}letterB24_1; 
		text{caption="m";preload=true;}letterB24_2;
		text{caption="u";preload=true;}letterB24_3;
		text{caption="p";preload=true;}letterB24_4;
		text{caption="t";preload=true;}letterB24_5;
		text{caption="z";preload=true;}letterB24_6;
		text{caption="i";preload=true;}letterB24_7;
		text{caption="g";preload=true;}letterB24_8;
		text{caption="b";preload=true;}letterB24_9; 
		text{caption="m";preload=true;}letterB24_10;
		text{caption="u";preload=true;}letterB24_11;
		text{caption="p";preload=true;}letterB24_12;
		text{caption="t";preload=true;}letterB24_13;
		text{caption="z";preload=true;}letterB24_14;
		text{caption="i";preload=true;}letterB24_15;
		text{caption="g";preload=true;}letterB24_16;
		text{caption="target";preload=true;}letterB24_target;
	}letterBackup2_B4;
	
array{text{caption="k";preload=true;}letterB1234_1; 
		text{caption="s";preload=true;}letterB1234_2;
		text{caption="o";preload=true;}letterB1234_3;
		text{caption="j";preload=true;}letterB1234_4;
		text{caption="t";preload=true;}letterB1234_5;
		text{caption="z";preload=true;}letterB1234_6;
		text{caption="i";preload=true;}letterB1234_7;
		text{caption="g";preload=true;}letterB1234_8;
		text{caption="k";preload=true;}letterB1234_9; 
		text{caption="s";preload=true;}letterB1234_10;
		text{caption="o";preload=true;}letterB1234_11;
		text{caption="j";preload=true;}letterB1234_12;
		text{caption="t";preload=true;}letterB1234_13;
		text{caption="z";preload=true;}letterB1234_14;
		text{caption="i";preload=true;}letterB1234_15;
		text{caption="g";preload=true;}letterB1234_16;
		text{caption="target";preload=true;}letterB1234_target;
	}letterBackup12_B34;
*/


###FFtrained B1 and B2 from Learning Task
array{text{caption="a";preload=true;}FFtrained1; 
		text{caption="b";preload=true;}FFtrained2;
		text{caption="c";preload=true;}FFtrained3;
		text{caption="d";preload=true;}FFtrained4;
		text{caption="e";preload=true;}FFtrained5;
		text{caption="f";preload=true;}FFtrained6;
		text{caption="g";preload=true;}FFtrained7;
		text{caption="h";preload=true;}FFtrained8;
		text{caption="a";preload=true;}FFtrained9; 
		text{caption="b";preload=true;}FFtrained10;
		text{caption="c";preload=true;}FFtrained11;
		text{caption="d";preload=true;}FFtrained12;
		text{caption="e";preload=true;}FFtrained13;
		text{caption="f";preload=true;}FFtrained14;
		text{caption="g";preload=true;}FFtrained15;
		text{caption="h";preload=true;}FFtrained16;
	}FFtrained;
	

##FFtrained BACKUP (in case one of the regular first two blocks had to be interrupted and a backup block -B3 or B4 -  was run)
array{text{caption="i";preload=true;}FFtrainedB13_1; 
		text{caption="j";preload=true;}FFtrainedB13_2;
		text{caption="k";preload=true;}FFtrainedB13_3;
		text{caption="l";preload=true;}FFtrainedB13_4;
		text{caption="e";preload=true;}FFtrainedB13_5;
		text{caption="f";preload=true;}FFtrainedB13_6;
		text{caption="g";preload=true;}FFtrainedB13_7;
		text{caption="h";preload=true;}FFtrainedB13_8;
		text{caption="i";preload=true;}FFtrainedB13_9; 
		text{caption="j";preload=true;}FFtrainedB13_10;
		text{caption="k";preload=true;}FFtrainedB13_11;
		text{caption="l";preload=true;}FFtrainedB13_12;
		text{caption="e";preload=true;}FFtrainedB13_13;
		text{caption="f";preload=true;}FFtrainedB13_14;
		text{caption="g";preload=true;}FFtrainedB13_15;
		text{caption="h";preload=true;}FFtrainedB13_16;
		text{caption="target";preload=true;}FFtrainedB13_target;
	}FFtrainedBackup1_B3;

array{text{caption="m";preload=true;}FFtrainedB14_1; 
		text{caption="n";preload=true;}FFtrainedB14_2;
		text{caption="o";preload=true;}FFtrainedB14_3;
		text{caption="p";preload=true;}FFtrainedB14_4;
		text{caption="e";preload=true;}FFtrainedB14_5;
		text{caption="f";preload=true;}FFtrainedB14_6;
		text{caption="g";preload=true;}FFtrainedB14_7;
		text{caption="h";preload=true;}FFtrainedB14_8;
		text{caption="m";preload=true;}FFtrainedB14_9; 
		text{caption="n";preload=true;}FFtrainedB14_10;
		text{caption="o";preload=true;}FFtrainedB14_11;
		text{caption="p";preload=true;}FFtrainedB14_12;
		text{caption="e";preload=true;}FFtrainedB14_13;
		text{caption="f";preload=true;}FFtrainedB14_14;
		text{caption="g";preload=true;}FFtrainedB14_15;
		text{caption="h";preload=true;}FFtrainedB14_16;
		text{caption="target";preload=true;}FFtrainedB14_target;
	}FFtrainedBackup1_B4;
	
array{text{caption="a";preload=true;}FFtrainedB23_1; 
		text{caption="b";preload=true;}FFtrainedB23_2;
		text{caption="c";preload=true;}FFtrainedB23_3;
		text{caption="d";preload=true;}FFtrainedB23_4;
		text{caption="i";preload=true;}FFtrainedB23_5;
		text{caption="j";preload=true;}FFtrainedB23_6;
		text{caption="k";preload=true;}FFtrainedB23_7;
		text{caption="l";preload=true;}FFtrainedB23_8;
		text{caption="a";preload=true;}FFtrainedB23_9; 
		text{caption="b";preload=true;}FFtrainedB23_10;
		text{caption="c";preload=true;}FFtrainedB23_11;
		text{caption="d";preload=true;}FFtrainedB23_12;
		text{caption="i";preload=true;}FFtrainedB23_13;
		text{caption="j";preload=true;}FFtrainedB23_14;
		text{caption="k";preload=true;}FFtrainedB23_15;
		text{caption="l";preload=true;}FFtrainedB23_16;
		text{caption="target";preload=true;}FFtrainedB23_target;
	}FFtrainedBackup2_B3;

array{text{caption="a";preload=true;}FFtrainedB24_1; 
		text{caption="b";preload=true;}FFtrainedB24_2;
		text{caption="c";preload=true;}FFtrainedB24_3;
		text{caption="d";preload=true;}FFtrainedB24_4;
		text{caption="m";preload=true;}FFtrainedB24_5;
		text{caption="n";preload=true;}FFtrainedB24_6;
		text{caption="o";preload=true;}FFtrainedB24_7;
		text{caption="p";preload=true;}FFtrainedB24_8;
		text{caption="a";preload=true;}FFtrainedB24_9; 
		text{caption="b";preload=true;}FFtrainedB24_10;
		text{caption="c";preload=true;}FFtrainedB24_11;
		text{caption="d";preload=true;}FFtrainedB24_12;
		text{caption="m";preload=true;}FFtrainedB24_13;
		text{caption="n";preload=true;}FFtrainedB24_14;
		text{caption="o";preload=true;}FFtrainedB24_15;
		text{caption="p";preload=true;}FFtrainedB24_16;
		text{caption="target";preload=true;}FFtrainedB24_target;
	}FFtrainedBackup2_B4;
	
array{text{caption="i";preload=true;}FFtrainedB1234_1; 
		text{caption="j";preload=true;}FFtrainedB1234_2;
		text{caption="k";preload=true;}FFtrainedB1234_3;
		text{caption="l";preload=true;}FFtrainedB1234_4;
		text{caption="m";preload=true;}FFtrainedB1234_5;
		text{caption="n";preload=true;}FFtrainedB1234_6;
		text{caption="o";preload=true;}FFtrainedB1234_7;
		text{caption="p";preload=true;}FFtrainedB1234_8;
		text{caption="i";preload=true;}FFtrainedB1234_9; 
		text{caption="j";preload=true;}FFtrainedB1234_10;
		text{caption="k";preload=true;}FFtrainedB1234_11;
		text{caption="l";preload=true;}FFtrainedB1234_12;
		text{caption="m";preload=true;}FFtrainedB1234_13;
		text{caption="n";preload=true;}FFtrainedB1234_14;
		text{caption="o";preload=true;}FFtrainedB1234_15;
		text{caption="p";preload=true;}FFtrainedB1234_16;
		text{caption="target";preload=true;}FFtrainedB1234_target;
	}FFtrainedBackup12_B34;








##FFfamiliar and FFnew

array{text{caption="a";preload=true;}FFfamiliar1; 
		text{caption="b";preload=true;}FFfamiliar2;
		text{caption="c";preload=true;}FFfamiliar3;
		text{caption="d";preload=true;}FFfamiliar4;
		text{caption="e";preload=true;}FFfamiliar5;
		text{caption="f";preload=true;}FFfamiliar6;
		text{caption="g";preload=true;}FFfamiliar7;
		text{caption="h";preload=true;}FFfamiliar8;
		text{caption="a";preload=true;}FFfamiliar9; 
		text{caption="b";preload=true;}FFfamiliar10;
		text{caption="c";preload=true;}FFfamiliar11;
		text{caption="d";preload=true;}FFfamiliar12;
		text{caption="e";preload=true;}FFfamiliar13;
		text{caption="f";preload=true;}FFfamiliar14;
		text{caption="g";preload=true;}FFfamiliar15;
		text{caption="h";preload=true;}FFfamiliar16;
	}FFfamiliar;

array{text{caption="a";preload=true;}FFnew1; 
		text{caption="b";preload=true;}FFnew2;
		text{caption="c";preload=true;}FFnew3;
		text{caption="d";preload=true;}FFnew4;
		text{caption="e";preload=true;}FFnew5;
		text{caption="f";preload=true;}FFnew6;
		text{caption="g";preload=true;}FFnew7;
		text{caption="h";preload=true;}FFnew8;
		text{caption="a";preload=true;}FFnew9; 
		text{caption="b";preload=true;}FFnew10;
		text{caption="c";preload=true;}FFnew11;
		text{caption="d";preload=true;}FFnew12;
		text{caption="e";preload=true;}FFnew13;
		text{caption="f";preload=true;}FFnew14;
		text{caption="g";preload=true;}FFnew15;
		text{caption="h";preload=true;}FFnew16;
	}FFnew;








#start- and end-pics
picture {bitmap {filename = "mri2.png"; preload = true; alpha=-1;width=360;height=341;}intro_pic; x = 0; y = 0;} intropic;	
picture {bitmap {filename = "responsebox.png"; preload = true; alpha=-1;width=260;height=241;}response_box; x = 0; y = 0;} responsebox;
picture {bitmap {filename = "Alien.png"; preload = true; alpha=-1;width=180;height=160;}target_pic; x = 0; y = 0;} targetpic;	
picture {bitmap {filename = "Aliensfarbig.png"; preload = true; alpha=-1;width=300;height=350;}end_pic; x = 0; y = 0;} endpic;	
text{caption="a";font_color = 0,0,255;preload=true;}example;

#Definition of instruction-trial
trial { 
trial_type = first_response; 
trial_duration = forever; 
stimulus_event{
        picture intropic;
} intropic_event;
}intropicTrial; 

trial { 
trial_type = first_response; 
trial_duration = forever; 
stimulus_event{
        picture endpic;
} endpic_event;
} endTrial; 

trial { 
trial_type = first_response; 
trial_duration = forever; 
stimulus_event{
        picture responsebox;
} response_event;
}responseTrial; 

trial { 
trial_type = first_response; 
trial_duration = forever; 
stimulus_event{
        picture targetpic;
} target_event;
}targetTrial; 
		
#Definition of the stimulus-trial (750 ms presentation, in the middle of the screen)
trial{
			stimulus_event
				{picture
					{text letter1;
					x=$stimx;y=$stimy;
					}picStimulus;
				duration=$stimPresDur;
		}eventStimulus;
	}stimulus_trial;

trial{stimulus_event{
	picture targetpic;
		duration=$stimPresDur;}targEventStimulus;
	}targetstimulus_trial;

/*	trial { 
	trial_type = first_response; 
	trial_duration = forever; 
	 stimulus_event{
			  picture BeginImage; 	
	}BeginImage_event;
	}BeginImage_trial; */


#Definition of waiting-for-MR-pulse-trial
trial{
	stimulus_event
		{picture
			{text cross;x=$stimx;y=$stimy;}; 
	mri_pulse=1; duration=5000;code="100";}event_wait;	
}wait;

trial{
	stimulus_event
		{picture
			{text cross;x=$stimx;y=$stimy;}; 
	mri_pulse=1; duration=8000;code="200";}event_wait_end;	
}wait_end;



#----------------------------------------------------------------------------------------------------------------
#start of PCL
#----------------------------------------------------------------------------------------------------------------

begin_pcl;

string Schulfont="Courier New Chopped";
####################################################
preset string cbFonts;
array <string> font_type[3] = {"AllRead_MRFont1","AllRead_MRFont2","AllRead_MRFont3"};
array <string> font_type2[3] = {"AllRead_MRFont2","AllRead_MRFont3","AllRead_MRFont1"};
array <string> font_type3[3] = {"AllRead_MRFont3","AllRead_MRFont1","AllRead_MRFont2"};


if (int(cbFonts) == 1) then font_type = font_type;
elseif (int(cbFonts) == 2) then font_type = font_type2;
elseif (int(cbFonts) == 3) then font_type = font_type3;
end;

####################################################
preset string backupblocks;

if (int(backupblocks)==0) then FFtrained=FFtrained; 

elseif (int(backupblocks)==13) then FFtrained=FFtrainedBackup1_B3; 
elseif (int(backupblocks)==23) then FFtrained=FFtrainedBackup2_B3; 

elseif (int(backupblocks)==14) then FFtrained=FFtrainedBackup1_B4;
elseif (int(backupblocks)==24) then FFtrained=FFtrainedBackup2_B4; 

elseif (int(backupblocks)==1234) then FFtrained=FFtrainedBackup12_B34; end;

####################################################

array<string> condition_order[4]={"T","F","N","L"};

##input not needed because conditions are now fully randomized (shuffled below).
#preset string conditionOrder = "";		# user input
/*array<int>condord[4]={1,2,3,4}; 
if (condition_order.upper()[1]=='L' && condition_order.upper()[2]=='T' && condition_order.upper()[3]=='F' && condition_order.upper()[4]=='N') then condord={1,2,3,4};  #L-letters, T-trained (False font), F-familiar (False font), N-new (False font)
elseif (condition_order.upper()[1]=='T' && condition_order.upper()[2]=='L' && condition_order.upper()[3]=='N' && condition_order.upper()[4]=='F') then condord={2,1,4,3}; 
elseif (condition_order.upper()[1]=='F' && condition_order.upper()[2]=='L' && condition_order.upper()[3]=='T' && condition_order.upper()[4]=='N') then condord={3,1,2,4}; 
elseif (condition_order.upper()[1]=='L' && condition_order.upper()[2]=='F' && condition_order.upper()[3]=='T' && condition_order.upper()[4]=='N') then condord={1,3,2,4}; 
elseif (condition_order.upper()[1]=='N' && condition_order.upper()[2]=='T' && condition_order.upper()[3]=='F' && condition_order.upper()[4]=='L') then condord={4,2,3,1}; 
elseif (condition_order.upper()[1]=='T' && condition_order.upper()[2]=='N' && condition_order.upper()[3]=='L' && condition_order.upper()[4]=='F') then condord={2,4,1,3}; end;
*/
/*
if (conditionOrder.upper()[1]=='L' && conditionOrder.upper()[2]=='T' && conditionOrder.upper()[3]=='F' && conditionOrder.upper()[4]=='N') then condition_order={"L","T","F","N"};  #L-letters, T-trained (False font), F-familiar (False font), N-new (False font)
elseif (conditionOrder.upper()[1]=='T' && conditionOrder.upper()[2]=='L' && conditionOrder.upper()[3]=='N' && conditionOrder.upper()[4]=='F') then condition_order={"T","L","N","F"}; 
elseif (conditionOrder.upper()[1]=='F' && conditionOrder.upper()[2]=='L' && conditionOrder.upper()[3]=='T' && conditionOrder.upper()[4]=='N') then condition_order={"F","L","T","N"}; 
elseif (conditionOrder.upper()[1]=='L' && conditionOrder.upper()[2]=='F' && conditionOrder.upper()[3]=='T' && conditionOrder.upper()[4]=='N') then condition_order={"L","F","T","N"}; 
elseif (conditionOrder.upper()[1]=='N' && conditionOrder.upper()[2]=='T' && conditionOrder.upper()[3]=='F' && conditionOrder.upper()[4]=='L') then condition_order={"N","T","F","L"};
elseif (conditionOrder.upper()[1]=='T' && conditionOrder.upper()[2]=='N' && conditionOrder.upper()[3]=='L' && conditionOrder.upper()[4]=='F') then condition_order={"T","N","L","F"}; end;
*/

#logfile
string  logfilename = logfile.filename(); #use filename as logfile name
logfile.set_filename(logfilename.replace(".log",+"_cbFont"+cbFonts+"_B"+backupblocks+".log")); #replace .log with other input + .log
logfilename = logfile.filename();		

if (file_exists(logfilename)) then 
	int i = 2;
		loop until !file_exists(logfilename.replace(".log", "-" + string(i) + ".log"))
	begin
        i = i + 1;
   end;
   logfilename = logfilename.replace(".log",  "-" + string(i) + ".log")
end;
logfile.set_filename(logfilename);

#output file
string scenarioName = "MRI_ImpSymbControl_targMoreJitter";
#output_port parallel1 = output_port_manager.get_port( 1 );
output_file outputfile = new output_file;

# Define headers of output file
if (logfile.subject().count()>0) then outputfile.open(logfilename.replace(".log",".txt")); # include response matching info here
else outputfile.open("NoSubj_"+scenarioName+"_cbFont"+cbFonts+"_B"+backupblocks+".txt");
end;

outputfile.print("trial\tblock\tstimIndex\tCondition\tVstimCaption\tISIjitter\n");


#outputfile.print(condition_order+"\n"); # write in output file





array<int>targButton[2]={1,2}; 

string event_code_letter="60";
string event_code_FFtrained="70";
string event_code_FFfamiliar="80";
string event_code_FFnew="90";
string event_code_rest="50";
string event_code_fixation="40";
int port_code_letter=60;
int port_code_FFtrained=70;
int port_code_FFfamiliar=80;
int port_code_FFnew=90;
int port_code_rest=50;
int port_code_fixation=40;

string event_code_letter_targ="65";
string event_code_FFtrained_targ="75";
string event_code_FFfamiliar_targ="85";
string event_code_FFnew_targ="95";
int port_code_letter_targ=65;
int port_code_FFtrained_targ=75;
int port_code_FFfamiliar_targ=85;
int port_code_FFnew_targ=95;

int port_code_start=100;
int port_code_end=200;


#define blocks
array<text> blocks_letter_array[0][0];
blocks_letter_array.add(letter);
blocks_letter_array.add(letter);
blocks_letter_array.add(letter);
blocks_letter_array.add(letter);

array<text> blocks_FFtrained_array[0][0];
blocks_FFtrained_array.add(FFtrained);
blocks_FFtrained_array.add(FFtrained);
blocks_FFtrained_array.add(FFtrained);
blocks_FFtrained_array.add(FFtrained);

array<text> blocks_FFfamiliar_array[0][0];
blocks_FFfamiliar_array.add(FFfamiliar);
blocks_FFfamiliar_array.add(FFfamiliar);
blocks_FFfamiliar_array.add(FFfamiliar);
blocks_FFfamiliar_array.add(FFfamiliar);

array<text> blocks_FFnew_array[0][0];
blocks_FFnew_array.add(FFnew);
blocks_FFnew_array.add(FFnew);
blocks_FFnew_array.add(FFnew);
blocks_FFnew_array.add(FFnew);

#target is indicated by a 17 (stimuli arrays only contain 16 items)
array<int> letterOrder[18]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17};  #make arrays for the letters to be presented twice each - these will be shuffled so that the order of letter presentation is randomized.
array<int> FFtrainedOrder[18]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17};
array<int> FFfamiliarOrder[18]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17};
array<int> FFnewOrder[18]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17};



#array <int> randISIRest[4] = {7000,7500,8000,8500};
array <int> randISIRest[4] = {7000,7000,7000,9000};
#array<int>isi_jitter[18]={240, 270, 339, 470, 218, 234, 130, 392, 311, 332, 353, 232, 250, 168, 415, 264, 434, 466}; #mean 306.55555555555554, between 100-500
array<int>isi_jitter[18]={207, 283, 164, 127, 190, 255, 257, 202, 199, 151, 333, 472, 423, 215, 118, 321, 408, 163}; #mean 249.3333, between 100-500
#array<int>isi_jitter[18]={277, 385, 418, 338, 451, 429, 252, 474, 483, 293, 324, 250, 475, 430, 496, 434, 344, 233}; #mean 377 between 100-600
int targOccurence=random(0,2);
int r=0; #count variable such that if targOccurence is 1, only one "9" in the Order arrays is used --> target occurs only once in a block. See further below in the conditional statements.

intropicTrial.present();
#responseTrial.present();
targetTrial.present(); #example
#waiting for the MR pulse
event_wait.set_port_code(port_code_start);
wait.present();


int trial_no=0;

#--------------------------------------------------------------
# actual presentation
#--------------------------------------------------------------

loop int k=1 until k>blocks_letter_array.count() begin	#A loop is started for the blocks

	
condition_order.shuffle();

letterOrder.shuffle();
FFtrainedOrder.shuffle(); 
FFfamiliarOrder.shuffle(); 
FFnewOrder.shuffle(); 


	#randomize order of words within blocks
	#UNNECESSARY - done above
	#blocks_letter_array[k].shuffle();
	#blocks_FFtrained_array[k].shuffle();
	#blocks_FFfamiliar_array[k].shuffle();
	#blocks_FFnew_array[k].shuffle();
	randISIRest.shuffle(); #choose a random rest period/isi

	
	

	

	loop int j=1 until j>4 begin #this goes through the 4 conditions (letter/FFtrained/FFfamiliar/FFnew)
	
	targOccurence=random(0,2); #target shall occur either 0, 1, or 2 times per block.
	r=0; #count variable counting how often target has occurred (can occur a max of 2 times - defined in if statements)
	
		if (condition_order[j]=="L") then
			isi_jitter.shuffle();	
			#A loop is started for the letter-condition; First, a fixation cross is shown, then the word is presented and so on
			
				loop int i=1 until i>18 begin;
				if letterOrder[i] == 17 && targOccurence==1 && r<1 then 
					term.print("if"); term.print("targ  "); term.print(targOccurence);term.print("letterOrder[i]");term.print(letterOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					targEventStimulus.set_response_active(true);
					targEventStimulus.set_event_code(event_code_letter_targ);
					targEventStimulus.set_target_button(targButton);
					targEventStimulus.set_port_code(port_code_letter_targ);
					
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_letter_array[k][i].filename());outputfile.print("\t");
					outputfile.print("letter");outputfile.print("\t");		 #print condition name
					outputfile.print("letterTarget");outputfile.print("\t") ; #print stimulus name/caption
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					
					targetstimulus_trial.present();
				r = r+1;
				
				elseif letterOrder[i] == 17 && targOccurence==2 && r<2 then 
					term.print("if"); term.print("targ  "); term.print(targOccurence);term.print("letterOrder[i]");term.print(letterOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					targEventStimulus.set_response_active(true);
					targEventStimulus.set_event_code(event_code_letter_targ);
					targEventStimulus.set_target_button(targButton);
					targEventStimulus.set_port_code(port_code_letter_targ);
					
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_letter_array[k][i].filename());outputfile.print("\t");
					outputfile.print("letter");outputfile.print("\t");		 
					outputfile.print("letterTarget");outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					
					targetstimulus_trial.present();
				r = r+1;

				elseif i < 18 && letterOrder[i] == 17 && targOccurence==1 && r==1 then i=i+1; term.print("elseif2"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");continue;
				elseif i < 18 && letterOrder[i] == 17 && targOccurence==0 then i=i+1; term.print("elseif3"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");continue;
				elseif i == 18 && letterOrder[i] == 17 && targOccurence==1 && r==1 then i=i+1; term.print("elseif4"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");break;
				elseif i == 18 && letterOrder[i] == 17 && targOccurence==0 then i=i+1; term.print("elseif5"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");break;

				else 
					term.print("else"); term.print("targ  "); term.print(targOccurence);term.print("letterOrder[i]");term.print(letterOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					picStimulus.set_part(1, blocks_letter_array[k][letterOrder[i]]); 
					eventStimulus.set_event_code(event_code_letter);
					eventStimulus.set_target_button(0);
					eventStimulus.set_port_code(port_code_letter);
				
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_letter_array[k][i].filename());outputfile.print("\t");
					outputfile.print("letter");outputfile.print("\t");		 
					outputfile.print(blocks_letter_array[k][letterOrder[i]].caption());outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					

					#eventStimulus.set_response_active(true);
				
					stimulus_trial.present();
					
				end;
				
				eventFixation.set_event_code(event_code_fixation);
				eventFixation.set_port_code(port_code_fixation);
				eventFixation.set_duration(isi_jitter[i]);
				eventFixation.set_response_active(true);
				fixation_trial.present();
				
				i=i+1
			end;
			

		#this is either the rest block (10.6s) or a inter-block-interval of 5s			
		picRest.set_part(1, cross); 
		eventRest.set_event_code(event_code_rest);
		rest_trial.set_duration(randISIRest[1]); 
		eventRest.set_event_code(event_code_rest);
		rest_trial.present();
		
		
		#r=0;
		
		elseif (condition_order[j]=="T") then
		isi_jitter.shuffle();
			#Same loop for trained-condition
			loop int i=1 until i>18 begin;
				if FFtrainedOrder[i] == 17 && targOccurence==1 && r<1 then 
					term.print("if"); term.print("targ  "); term.print(targOccurence);term.print("trainedOrder[i]");term.print(letterOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					targEventStimulus.set_event_code(event_code_FFtrained_targ);
					targEventStimulus.set_target_button(targButton);
					targEventStimulus.set_port_code(port_code_FFtrained_targ);
					targEventStimulus.set_response_active(true);
					
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_FFtrained_array[k][i].filename());outputfile.print("\t");
					outputfile.print("FFtrained");outputfile.print("\t");		 
					outputfile.print("FFtrainedTarget");outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					
					targetstimulus_trial.present();
				r = r+1
				elseif FFtrainedOrder[i] == 17 && targOccurence==2 && r<2 then 
					term.print("elseif1 "); term.print("targ  "); term.print(targOccurence);term.print("FFtrainedOrder[i]");term.print(FFtrainedOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					targEventStimulus.set_response_active(true);
					targEventStimulus.set_event_code(event_code_FFtrained_targ);
					targEventStimulus.set_target_button(targButton);
					targEventStimulus.set_port_code(port_code_FFtrained_targ);
					
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_FFtrained_array[k][i].filename());outputfile.print("\t");
					outputfile.print("FFtrained");outputfile.print("\t");		 
					outputfile.print("FFtrainedTarget");outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					
					targetstimulus_trial.present();
				r = r+1

				elseif i < 18 && FFtrainedOrder[i] == 17 && targOccurence==1 && r==1 then i=i+1; term.print("elseif2"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");continue;
				elseif i < 18 && FFtrainedOrder[i] == 17 && targOccurence==0 then i=i+1; term.print("elseif3"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");continue;
				elseif i == 18 && FFtrainedOrder[i] == 17 && targOccurence==1 && r==1 then i=i+1; term.print("elseif4"); term.print("targ  "); term.print(targOccurence);term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");break;
				elseif i == 18 && FFtrainedOrder[i] == 17 && targOccurence==0 then i=i+1; term.print("elseif5"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");break;

				else 
					term.print("else "); term.print("targ  "); term.print(targOccurence);term.print("FFtrainedOrder[i] ");term.print(FFtrainedOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					blocks_FFtrained_array[k][FFtrainedOrder[i]].set_font(font_type[1]); ##set font type according to counterbalancing
					blocks_FFtrained_array[k][FFtrainedOrder[i]].redraw();
					picStimulus.set_part(1, blocks_FFtrained_array[k][FFtrainedOrder[i]]); 
					eventStimulus.set_event_code(event_code_FFtrained);
					eventStimulus.set_target_button(0);
					eventStimulus.set_port_code(port_code_FFtrained);

					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_FFtrained_array[k][i].filename());outputfile.print("\t");
					outputfile.print("FFtrained");outputfile.print("\t");		 
					outputfile.print(blocks_FFtrained_array[k][FFtrainedOrder[i]].caption());outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					

					#eventStimulus.set_response_active(true);
				
					stimulus_trial.present();
					
				end;
				
				eventFixation.set_event_code(event_code_fixation);
				eventFixation.set_port_code(port_code_fixation);
				eventFixation.set_duration(isi_jitter[i]);
				eventFixation.set_response_active(true);
				fixation_trial.present();
				
				i=i+1
			end;

		#this is either the rest block (10.6s) or a inter-block-interval of 4s
		picRest.set_part(1, cross); 
		eventRest.set_event_code(event_code_rest);
		rest_trial.set_duration(randISIRest[2]); 
		eventRest.set_event_code(event_code_rest);
		rest_trial.present();
		
		#r=0;
		
		elseif (condition_order[j]=="F") then
		isi_jitter.shuffle();
			#Same loop for familiar-condition
			loop int i=1 until i>18 begin;
				if FFfamiliarOrder[i] == 17 && targOccurence==1 && r<1 then 
					term.print("if "); term.print("targ  "); term.print(targOccurence);term.print("FFfamiliarOrder[i] ");term.print(FFfamiliarOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					targEventStimulus.set_response_active(true);
					targEventStimulus.set_event_code(event_code_FFfamiliar_targ);
					targEventStimulus.set_target_button(targButton);
					targEventStimulus.set_port_code(port_code_FFfamiliar_targ);
					
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_FFfamiliar_array[k][i].filename());outputfile.print("\t");
					outputfile.print("FFfamiliar");outputfile.print("\t");		 
					outputfile.print("FFfamiliarTarget");outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					
					targetstimulus_trial.present();
					r = r+1
				elseif FFfamiliarOrder[i] == 17 && targOccurence==2 && r<2 then 
					term.print("elseif1 "); term.print("targ  "); term.print(targOccurence);term.print("FFfamiliarOrder[i] ");term.print(FFfamiliarOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					targEventStimulus.set_response_active(true);
					targEventStimulus.set_event_code(event_code_FFfamiliar_targ);
					targEventStimulus.set_target_button(targButton);
					targEventStimulus.set_port_code(port_code_FFfamiliar_targ);
					
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_FFfamiliar_array[k][i].filename());outputfile.print("\t");
					outputfile.print("FFfamiliar");outputfile.print("\t");		 
					outputfile.print("FFfamiliarTarget");outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					
					targetstimulus_trial.present();
					r = r+1

				elseif i < 18 && FFfamiliarOrder[i] == 17 && targOccurence==1 && r==1 then i=i+1; term.print("elseif2"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");continue;
				elseif i < 18 && FFfamiliarOrder[i] == 17 && targOccurence==0 then i=i+1; term.print("elseif3"); term.print("targ  "); term.print(targOccurence);term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");continue;
				elseif i == 18 && FFfamiliarOrder[i] == 17 && targOccurence==1 && r==1 then i=i+1; term.print("elseif4"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");break;
				elseif i == 18 && FFfamiliarOrder[i] == 17 && targOccurence==0 then i=i+1; term.print("elseif5"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");break;

				else 
					term.print("else "); term.print("targ  "); term.print(targOccurence);term.print("FFfamiliarOrder[i] ");term.print(letterOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					blocks_FFfamiliar_array[k][FFfamiliarOrder[i]].set_font(font_type[2]); ##set font type according to counterbalancing
					blocks_FFfamiliar_array[k][FFfamiliarOrder[i]].redraw();
					picStimulus.set_part(1, blocks_FFfamiliar_array[k][FFfamiliarOrder[i]]); 
					eventStimulus.set_event_code(event_code_FFfamiliar);
					eventStimulus.set_target_button(0);
					eventStimulus.set_port_code(port_code_FFfamiliar);
					
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_FFfamiliar_array[k][i].filename());outputfile.print("\t");
					outputfile.print("FFfamiliar");outputfile.print("\t");		 
					outputfile.print(blocks_FFfamiliar_array[k][FFfamiliarOrder[i]].caption());outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					

					#eventStimulus.set_response_active(true);
				
					stimulus_trial.present();
					
				end;
				
				eventFixation.set_event_code(event_code_fixation);
				eventFixation.set_port_code(port_code_fixation);
				eventFixation.set_duration(isi_jitter[i]);
				eventFixation.set_response_active(true);
				fixation_trial.present();
				
				i=i+1
			end;

		#this is either the rest block (10.6s) or a inter-block-interval of 5s
		picRest.set_part(1, cross); 
		eventRest.set_event_code(event_code_rest);
		rest_trial.set_duration(randISIRest[3]); 
		eventRest.set_event_code(event_code_rest);
		rest_trial.present();

		#r=0;
		elseif (condition_order[j]=="N") then
		isi_jitter.shuffle();
			#Same loop for new-condition
			loop int i=1 until i>18 begin;
				if FFnewOrder[i] == 17 && targOccurence==1 && r<1 then 
					term.print("if "); term.print("targ  "); term.print(targOccurence);term.print("FFnewOrder[i] ");term.print(FFnewOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i); term.print("\n");
					targEventStimulus.set_response_active(true);
					targEventStimulus.set_event_code(event_code_FFnew_targ);
					targEventStimulus.set_target_button(targButton);
					targEventStimulus.set_port_code(port_code_FFnew_targ);
					
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_FFnew_array[k][i].filename());outputfile.print("\t");
					outputfile.print("FFnew");outputfile.print("\t");		 
					outputfile.print("FFnewTarget");outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					
					targetstimulus_trial.present();
				r = r+1
					elseif FFnewOrder[i] == 17 && targOccurence==2 && r<2 then 
					term.print("elseif1 "); term.print("targ  "); term.print(targOccurence);term.print("FFnewOrder[i] ");term.print(FFnewOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					targEventStimulus.set_response_active(true);
					targEventStimulus.set_event_code(event_code_FFnew_targ);
					targEventStimulus.set_target_button(targButton);
					targEventStimulus.set_port_code(port_code_FFnew_targ);
					
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_FFnew_array[k][i].filename());outputfile.print("\t");
					outputfile.print("FFnew");outputfile.print("\t");		 
					outputfile.print("FFnewTarget");outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					
					targetstimulus_trial.present();
				r = r+1

				elseif i < 18 && FFnewOrder[i] == 17 && targOccurence==1 && r==1 then i=i+1; term.print("elseif2"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");continue;
				elseif i < 18 && FFnewOrder[i] == 17 && targOccurence==0 then i=i+1; term.print("elseif3"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");continue;
				elseif i == 18 && FFnewOrder[i] == 17 && targOccurence==1 && r==1 then i=i+1; term.print("elseif4"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");break;
				elseif i == 18 && FFnewOrder[i] == 17 && targOccurence==0 then i=i+1; term.print("elseif5"); term.print("targ  "); term.print(targOccurence); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");break;

				else 
					term.print("else"); term.print("targ  "); term.print(targOccurence);term.print("FFnewOrder[i]");term.print(letterOrder[i]); term.print("  "); term.print("r");term.print(r); term.print("  "); term.print("i");term.print(i);term.print("\n");
					
					blocks_FFnew_array[k][FFnewOrder[i]].set_font(font_type[3]); ##set font type according to counterbalancing
					blocks_FFnew_array[k][FFnewOrder[i]].redraw();
					picStimulus.set_part(1, blocks_FFnew_array[k][FFnewOrder[i]]); 
					eventStimulus.set_event_code(event_code_FFnew);
					eventStimulus.set_target_button(0);
					eventStimulus.set_port_code(port_code_FFnew);
				
					#print stuff to output txt file
					trial_no=trial_no+1;	
					outputfile.print(trial_no);outputfile.print("\t"); #  Trial index from the beginning of the experiment is :((b-1)*40)+i
					outputfile.print(k);outputfile.print("\t"); 
					outputfile.print(i);outputfile.print("\t");
					#outputfile.print(blocks_FFnew_array[k][i].filename());outputfile.print("\t");
					outputfile.print("FFnew");outputfile.print("\t");		 
					outputfile.print(blocks_FFnew_array[k][FFnewOrder[i]].caption());outputfile.print("\t") ;
					outputfile.print(isi_jitter[i]);outputfile.print("\t");outputfile.print("\n");
					

					#eventStimulus.set_response_active(true);
				
					stimulus_trial.present();
					
				end;
				
				eventFixation.set_event_code(event_code_fixation);
				eventFixation.set_port_code(port_code_fixation);
				eventFixation.set_duration(isi_jitter[i]);
				eventFixation.set_response_active(true);
				fixation_trial.present();
				
				i=i+1
			end;

		#this is either the rest block (10.6s) or a inter-block-interval of 4s
		picRest.set_part(1, cross); 
		eventRest.set_event_code(event_code_rest);
		rest_trial.set_duration(randISIRest[2]); 
		eventRest.set_event_code(event_code_rest);
		rest_trial.present();
		
		#else
		#isi_jitter.shuffle();



		end;
		
		j=j+1;
	end;

	k=k+1;
end;


event_wait_end.set_port_code(port_code_end);
wait_end.present();
endTrial.present();