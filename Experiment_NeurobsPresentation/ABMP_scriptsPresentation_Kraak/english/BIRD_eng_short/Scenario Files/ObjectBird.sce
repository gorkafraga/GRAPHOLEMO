active_buttons=3;
button_codes=16,32,3;

default_formatted_text=true;
default_text_color=255,255,255;
default_background_color=0,0,0;
default_font="Times New Roman";

response_matching = simple_matching;

pulse_width=5;
response_port_output=true;

begin;

picture {} default;
picture { text { caption="RIGHT"; font_size=48; font_color=255,255,255; } fb_pict; x=0; y=0; } fb;
picture { text { caption="+"; font_size=48; font_color=255,255,255; }; x=0; y=0; } fix;

picture { bitmap { filename = "test.bmp"; } pict; x=0; y=0; } pstim;
sound { wavefile { filename = "noise.wav";}  snd;} astim;

# for testing purposes, use the stim identifier instead of the actual pictue/sound
#picture { 
#	text { caption="V1"; font="Arial Unicode MS"; font_size=72; } vTXT; x=0; y=0; 
#	text { caption="A1"; font_size=48; } aTXT; x=0; y=-100; 
#} vstim;


trial {
	trial_duration=2500;
	trial_type=specific_response;
	all_responses=false;
	terminator_button=1,2;
	
	picture fix;
	time=0;
	duration=500;

	stimulus_event {
		picture pstim;
#		picture vstim;
		port_code=255;     # changed in pcl code to represent the trial type
		time=500;
		target_button=1,2;
		response_active=true;
		code="consistent";
	} main_stim;
	
	sound astim;  
	time=500;

} main_trial;

trial {
	trial_duration=2000;

	picture fix;
	time=0;
	duration=500;

	stimulus_event {
		picture fb;
		port_code=255;     # changed in pcl code to represent the trial type
		code="pos_feedback";
		time=500;
	} fb_event;
	
} feedback;


trial {
		trial_duration = forever;
		trial_type = specific_response;
		terminator_button = 3;
		picture { 
			text 	{ caption = 
"<b>CRACK THE CODE!</b>
													
													
Next, you will see a symbol and hear a sound at the same time.
You have to find out which symbol matches with each sound. 

If you think the symbol and the sound match press the <b>yellow</b> button. 
If not, press the <b>pink</b> button. If you do not know the answer, try to guess.
After your response you will know whether it was <i> right </i> or  <i>wrong</i>.






<i>Press ENTER to start</i>";
				font_size = 22; font = "Arial"; font_color=224,224,224; background_color=0,0,0; text_align=align_left; 
				};
				x = 0 ; y = 0;	
		};
} instr_start;

trial {
		trial_duration = forever;
		trial_type = specific_response;
		terminator_button = 3;
		picture { 
			text 	{ caption = 
"You will now start the practice. After this, the real test will begin. 

The symbols stay shortly on screen, try to response as fast as you can!
If not, you will see  <i>' too slow'</i> on screen

Can you find out which symbols match with each sound? good luck!




<i>Press ENTER to start the practice</i>";
	font_size = 18; font = "Arial"; font_color=224,224,224; background_color=0,0,0; text_align=align_left; 
				};
				x = 0 ; y = 0;	
		};
} instr_start2;

trial {
		trial_duration = forever;
		trial_type = specific_response;
		terminator_button = 3;
		picture { 
			text 	{ caption = 
"You finished the practice. 

Now the real starts. It is a bit longer.

Some combinations are really hard to find. 
Don't be afraid to make errors.


good luck!


<i>Press ENTER to start</i>";
				font_size = 18; font = "Arial"; font_color=224,224,224; background_color=0,0,0; text_align=align_left; 
				};
				x = 0 ; y = 0;	
		};
} instr_task_LR;

trial {
		trial_duration = forever;
		trial_type = specific_response;
		terminator_button = 3;
		picture { 
			text 	{ caption = 
"You finished the practice. 

Now the real test test starts. It is a bit longer.

Some combinations are really hard to find. 
Don't be afraid to make errors!


good luck!


<i>Press ENTER to start</i>";
				font_size = 20; font = "Arial"; font_color=224,224,224; background_color=0,0,0; text_align=align_left; 
				};
				x = 0 ; y = 0;	
		};
} instr_task_RL;

trial {
		trial_duration = forever;
		trial_type = specific_response;
		terminator_button = 3;
		picture { 
			text 	{ caption = 
"Take a small break...





<i>Press ENTER to start with the next block<i>";
				font_size = 18; font = "Arial"; font_color=224,224,224; background_color=0,0,0; text_align=align_left; 
				};
				x = 0 ; y = 0;	
		};
} pauze;




begin_pcl;

#=== switch between simple version (S1-A1/A2, S2-A2/A1, S3-A3/A4, S4-A4/A3) 
#===   and complex version (S1-A1/A2/A3/A4, S2-A2/A1/A3/A4, S3-A3/A1/A2/A4, S4-A4/A1/A2/A3)
bool simple_version=true;

#=== PERCENTAGE POSITIVE FEEDBACK IN INCONSISTENT CONDITION:
# preset int percentage_positive=50;
int percentage_positive=50;

#preset int sound_subset=1;

#=== THE NUMBER OF MATCH/MISMATCH TRIALS PER CONDITION:
int nA1=23;    # number of consistent/inconsistent matches
int nA2=20;		# number of mismatches
int nA3=1;		# number of mismatches
int nA4=6;		# number of mismatches

#=== RESPONSE COUNTERBALANCING
preset string responseMatching = "RL";		# default right=match, left=mismatch
int respMatch=1; 
if (responseMatching.lower()[1]=='l' && responseMatching.lower()[2]=='r') then respMatch=2; end;  

#=== first, make an outputfile
output_file out_file = new output_file;
if (logfile.subject().count()>0) then out_file.open(logfile.subject()+"_BIRD.txt");
else out_file.open("BIRD_nosubject.txt"); end;

out_file.print("block\ttrial\tVstim\tAstim\tmatch\tC/I\tresp\tresult\tRT\tfb\tV-file\tA-file\n\n");
out_file.print(responseMatching+"\n\n");
#=== include the file where the randomisation is executed
include "ObjectBird.pcl"

#=== some variables to keep track of things
int  block=1;
int  target_button; 
bool random_feedback=false;
double totalResponse=0.0;
int nrCorrect=0;
int avgResponse = 1000;

instr_start.present();
instr_start2.present();
#================================================================================================
#=== some practive trials to get the participant's performance

#=== RUN THE PRACTICE BLOCK:

loop 
	int i=1;
	int vStim;
	int aStim;
until i> 30  begin
	# remnove the stimuli from the trial
	pict.unload();
	snd.unload();
	
	aStim=1;
	vStim=1;
	if (practice[i]==2 || practice[i]==3) then aStim=2; end;
	if (practice[i]==3 || practice[i]==4) then vStim=2; end;
		
	# set the new stimulus events for this trial:
	pict.set_filename(pract_pict[vStim]);
	pict.load();
	if (practice[i]<3 ) then    # ---> V1/A1 or V1/A2
#		vTXT.set_caption(pract_pict[vStim], true);
#		aTXT.set_caption(pract_snd[aStim], true);
		snd.set_filename(pract_snd[aStim]);
		snd.load();
		if (practice[i] == 1) then 
			target_button=16; main_stim.set_port_code(1);
		else 
			target_button=32; main_stim.set_port_code(2);
		end;
		vStim=1; aStim=practice[i];
	else	# ---> V2/A1 or V2/A2
#		vTXT.set_caption(pract_pict[vStim], true);
#		aTXT.set_caption(pract_snd[aStim], true);
		snd.set_filename(pract_snd[aStim]);
		snd.load();
		if (practice[i] == 3) then 
			target_button=16; main_stim.set_port_code(1);
		else 
			target_button=32; main_stim.set_port_code(2);
		end;
		vStim=2; aStim=practice[i];
	end;
	
	if (respMatch==2 && target_button==16) then 
		target_button=32;
	elseif (respMatch==2 && target_button==32) then
		target_button=16;
	end;			
	
	# present the time critical trial:
	main_trial.present();
	
	# analyse the rersponse and generate appropriate feedback:
	stimulus_data sd=stimulus_manager.last_stimulus_data();
	int RT=sd.reaction_time();
	int button=sd.button();
	int result=0;
	int FB=0;
	
	if (button==0) then
		fb_pict.set_font_color(255,255,255);
		fb_pict.set_caption("TOO SLOW!", true);
		fb_event.set_port_code(196);
	else
		if (	(target_button==16 && button==1) || 
				(target_button==32 && button==2)	) then
			result=1; FB=1;
			fb_pict.set_font_color(255,255,255);
			fb_pict.set_caption("RIGHT", true);
			fb_event.set_port_code(64);
			totalResponse=totalResponse+double(RT);
			nrCorrect=nrCorrect+1;
		else	
			FB=0;
			fb_pict.set_font_color(255,32,32);
			fb_pict.set_caption("WRONG", true);
			fb_event.set_port_code(128);
		end;
	end;
	
	feedback.present();
	
	default.present();
	int t=clock.time()+iti[i];
	
	out_file.print("0\t"); 	# block nr
	out_file.print(i); out_file.print("\t"); 			# trial nr
	out_file.print(vStim); out_file.print("\t"); 	# visual stimulus nr, 1,2,3 or 4
	out_file.print(aStim); out_file.print("\t"); 	# auditive stimulus nr, 1,2,3 or 4
	if ((vStim==1 && aStim==1) || 
		 (vStim==2 && aStim==3)) then
		out_file.print("1\t");								# consistent, match
	else
		out_file.print("0\t");								# consistent, mismatch
	end;	
	out_file.print("C\t"); 									# always consistent in practice block	
	out_file.print(button); out_file.print("\t"); 	# response button
	out_file.print(result); out_file.print("\t"); 	# response result (1=correct, 2=incorrect)
	out_file.print(RT); out_file.print("\t"); 		# response time
	out_file.print(FB); out_file.print("\t"); 		# feedback type (0=wrong, 1=good)
	out_file.print(pract_pict[vStim]);					# get_filename(pict.filename()));	# filename of the picture
	out_file.print("\t");
	out_file.print(pract_snd[aStim]);					# get_filename(snd.filename()));	# filename of the sound
	out_file.print("\n");
	
	loop until clock.time()>=t begin end;
	
	i=i+1;
end;

if (nrCorrect>0) then
	avgResponse = int(totalResponse/double(nrCorrect)+0.5);
end;	

out_file.print("avg_resp = " + string(avgResponse) + "\n");

#=== END BLOCK


if (respMatch==1) then
	instr_task_RL.present();
else
	instr_task_LR.present();
end;	

# main_trial.set_duration(500+avgResponse);

#================================================================================================
#=== the main task, presented in blocks of 200 trials
 
loop
	block=1
until block > 5
begin	
	#=== RUN ONE BLOCK:
	if (block>1) then pauze.present(); end;
	
	if (simple_version) then
		randomize_simple_block();
	else
		randomize_block();
	end;
	
	loop int i=1 until i>4 begin
#		activePict[i]=pict_file[(block-1)*4+i]; # take four new pictures from the randomised picture array
#		activeSnd[i]=sound_file[(block-1)*4+i]; # take four new sounds from the pre-randomised array
		activeSnd[i]=sound_file[snd_array_offset[block]+i]; # take four new sounds from the pre-randomised array
		activePict[i]=pict_file[pict_array_offset[block]+i]; # take four new sounds from the pre-randomised array
		
		i=i+1;
	end; 
	
	loop 
		int i=1;
		int i1=1;
		int i2=1;
		int i3=1;
		int i4=1;
		int vStim;
		int aStim;
	until i>200 begin
		# remnove the stimuli from the trial
		pict.unload();
		snd.unload();
		
		# set the new stimulus events for this trial:
		pict.set_filename(activePict[V_order[i]]);
		pict.load();
		if (V_order[i]==1) then
#			vTXT.set_caption(activePict[V_order[i]], true);
#			aTXT.set_caption("A"+string(VA[V_order[i]][i1]), true);
			snd.set_filename(activeSnd[VA[V_order[i]][i1]]);
			snd.load();
			if (VA[V_order[i]][i1] == 1) then 
				target_button=16; main_stim.set_port_code(1);
			else 
				target_button=32; main_stim.set_port_code(2);
			end;
			random_feedback=false;
			vStim=1; aStim=VA[V_order[i]][i1];
			
			i1=i1+1;
		elseif (V_order[i]==2) then	
#			vTXT.set_caption(activePict[V_order[i]], true);
#			aTXT.set_caption("A"+string(VA[V_order[i]][i2]), true);
			snd.set_filename(activeSnd[VA[V_order[i]][i2]]);
			snd.load();
			if (VA[V_order[i]][i2] == 2) then 
				target_button=16; main_stim.set_port_code(1);
			else 
				target_button=32; main_stim.set_port_code(2);
			end;
			random_feedback=false;
			vStim=2; aStim=VA[V_order[i]][i2];
			i2=i2+1;
		elseif (V_order[i]==3) then	
#			vTXT.set_caption(activePict[V_order[i]], true);
#			aTXT.set_caption("A"+string(VA[V_order[i]][i3]), true);
			snd.set_filename(activeSnd[VA[V_order[i]][i3]]);
			snd.load();
			if (VA[V_order[i]][i3] == 3) then 
				target_button=16; main_stim.set_port_code(4);
			else 
				target_button=32; main_stim.set_port_code(8);
			end;
			random_feedback=true;
			vStim=3; aStim=VA[V_order[i]][i3];
			i3=i3+1;
		elseif (V_order[i]==4) then	
#			vTXT.set_caption(activePict[V_order[i]], true);
#			aTXT.set_caption("A"+string(VA[V_order[i]][i4]), true);
			snd.set_filename(activeSnd[VA[V_order[i]][i4]]);
			snd.load();
			if (VA[V_order[i]][i4] == 4) then 
				target_button=16; main_stim.set_port_code(4);
			else 
				target_button=32; main_stim.set_port_code(8);
			end;
			random_feedback=true;
			vStim=4; aStim=VA[V_order[i]][i4];
			i4=i4+1;
		end;	
		
		if (respMatch==2 && target_button==16) then 
			target_button=32;
		elseif (respMatch==2 && target_button==32) then
			target_button=16;
		end;			
		
		# present the time critical trial:
		main_trial.present();

		# analyse the rersponse and generate appropriate feedback:
		stimulus_data sd=stimulus_manager.last_stimulus_data();
		int RT=sd.reaction_time();
		int button=sd.button();
		int result=0;
		int FB=0;
		
		if (button==0) then
			fb_pict.set_font_color(255,255,255);
			fb_pict.set_caption("TOO SLOW!", true);
			fb_event.set_port_code(196);
		else
			if (random_feedback) then
				if (V_order[i]==3) then 
					if ( pos_feedback[1][i3-1]==1 ) then
						FB=1;
						fb_pict.set_font_color(255,255,255);
						fb_pict.set_caption("RIGHT", true);
						fb_event.set_port_code(64);
					else	
						FB=0;
						fb_pict.set_font_color(255,32,32);
						fb_pict.set_caption("WRONG", true);
						fb_event.set_port_code(128);
					end;	
				elseif (V_order[i]==4) then
					if ( pos_feedback[2][i4-1]==1 ) then
						FB=1;
						fb_pict.set_font_color(255,255,255);
						fb_pict.set_caption("RIGHT", true);
						fb_event.set_port_code(64);
					else	
						FB=0;
						fb_pict.set_font_color(255,32,32);
						fb_pict.set_caption("WRONG", true);
						fb_event.set_port_code(128);
					end;
				end;
			else
		if (	(target_button==16 && button==1) || 
				(target_button==32 && button==2)	) then
					result=1; FB=1;
					fb_pict.set_font_color(255,255,255);
					fb_pict.set_caption("RIGHT", true);
					fb_event.set_port_code(64);
				else	
					FB=0;
					fb_pict.set_font_color(255,32,32);
					fb_pict.set_caption("WRONG", true);
					fb_event.set_port_code(128);
				end;
			end;
		end;
		
		feedback.present();
		
		default.present();
		int t=clock.time()+iti[i];
		
		out_file.print(block); out_file.print("\t"); 	# block nr
		out_file.print(i); out_file.print("\t"); 			# trial nr
		out_file.print(vStim); out_file.print("\t"); 	# visual stimulus nr, 1,2,3 or 4
		out_file.print(aStim); out_file.print("\t"); 	# auditive stimulus nr, 1,2,3 or 4
		if (vStim==aStim && vStim<=2) then
			out_file.print("1\t");								# consistent, match
		else
			if (vStim<=2) then
				out_file.print("0\t");							# consistent, mismatch
			else
				out_file.print("2\t");							# inconsistent, either match or mismatch
			end;
		end;	
		if (vStim<=2) then
			out_file.print("C\t"); 								# consistent	
		else
			out_file.print("I\t"); 								# inconsistent
		end;
		out_file.print(button); out_file.print("\t"); 	# response button
		out_file.print(result); out_file.print("\t"); 	# response result (1=correct, 2=incorrect)
		out_file.print(RT); out_file.print("\t"); 		# response time
		out_file.print(FB); out_file.print("\t"); 		# feedback type (0=wrong, 1=good)
		out_file.print(activePict[vStim]);			# get_filename(pict.filename()));	# filename of the picture
		out_file.print("\t");
		out_file.print(activeSnd[aStim]);			# get_filename(snd.filename()));	# filename of the sound
		out_file.print("\n");
	
		
		loop until clock.time()>=t begin end;
		
		i=i+1;
	end;
	#=== END BLOCK

	block=block+1;

end;
