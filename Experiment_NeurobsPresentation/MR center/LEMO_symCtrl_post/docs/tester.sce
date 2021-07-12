
scenario_type=fMRI_emulation; #In order to test an fMRI mode scenario without an external connection scenario_type=fMRI_emulation; otherwise scenario_type=fMRI
pulses_per_scan = 1;		#registers the first of the specified number of pulses #how many square wave pulses are produced by the MRI scanner during one scan??
scan_period=1000;			#time between complete MRI scans in ms
pulse_code=199;			#used to identify main pulses in fMRI mode in the Analysis window and the logfile
pulse_width=1;				#pulses are 1 ms long #width of pulses in ms
#default_output_port=1; 	#Assigned to the port parameter for stimulus events that do not define that parameter; does not affect output port used for responses
write_codes=false; 		#Writes codes to output port that depend on the event; value will be written to output port at the occurance of all stimuli for which port_code is defined
response_matching=simple_matching;	#Affects how response active stimuli are associated with responses
response_port_output=true;
active_buttons = 2;						#indicates how many response buttons are used in the scenario. Must match buttons selected on response panel
button_codes = 20,21;			#Assigns numerical codes to each response button used in the scenario --> logfile and output port (if write_codes=true)
target_button_codes = 25,26;


begin;
begin_pcl;


array <int> nTargets[5] = {0,1,2,3,4};
 

array<int>targetPosition[0][0];
targetPosition.add({0,0,0,0,0,0,0,1,1});
targetPosition.add({0,0,0,0,0,0,0,0,1});
targetPosition.add({0,0,0,0,0,0,0,0,0});

array <int> currTargets[10] = targetPosition[1];

loop int i=1 until i > 100 begin
	currTargets.shuffle(3,10);

  term.print(currTargets);term.print("\n")
 end; 