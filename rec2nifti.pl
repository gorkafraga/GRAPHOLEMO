#!/usr/bin/perl
###################################################################
#                 RL 2011 IBT Zurich (Switzerland)                #
#                     http://www.mr.ethz.ch/                      #
#                     Rec (PMS format) to Nifti                   #
###################################################################

local $SIG{__DIE__} = \&mydie;
$|=1;
$version="rec2nifti2.pl (27.10.11)";

#27.10.11 another ASL bug removed.
#19.10.11 Scan_Seq added for mixed sequences. ASL bug removed.
#19.10.11 Split dynamics
#7.10.11 Bug with par 3 corrected
#12.8.11 Scalevalue correct per nifti File (if mutiple files will be created)
#        Correct error if par-File not readable...
#5.7.11 error diffusion scans
#30.5.11 offset -id corrected merging with rec2ifti
#11.5.2011 offset corrected
#9.5.2011 multiphase etc.
#2.5.2011 mydie added.
#29.4.11 offset added. Still a problem with shears if not -tra/-tms
#7.2.11 (only minor cosmetic changes)
#15.10.2010: -tms option
#15.9.2010: -id/tra option; voxelsize implemented; bugfixes
#November 2009: initial Version rec2nifti
$|=1;

print "$version\n";

#show some addtional infos
$display=0;

#debugging info
$verbose=0;

#will be larger than 1 if a diffusion scan
$max_diffusion_values=0;

#default no split!
$scan_split=0;

$rotation_id=0;
$rotation_id_tms=0;
$rec2nifti_option="";


while ($ARGV[0] =~ /^-/) {
  $_ = shift @ARGV;
  if (/^-h(elp)?$/) {
    &usage;
  } elsif (/^-c(orrect_dyn)?$/||/^-s(plit)?$/) {
    $correct_dyn=1;
    $scan_split=1;
    $rec2nifti_option="$rec2nifti_option -s";
  } elsif (/^-f(orce)?$/) {
    $scan_store_force=1;
    $rec2nifti_option="$rec2nifti_option -f";
  } elsif (/^-id$/||/^-tra$/) {
    $rotation_id=1;
    $rotation_id_tms=0;
    $rec2nifti_option="$rec2nifti_option -tra";
  } elsif (/^-tms$/) {
    $rotation_id=1;
    $rotation_id_tms=1;
    $rec2nifti_option="$rec2nifti_option -tms";
  } elsif (/^-d(isplay)?$/) {
    $display=1;
  } elsif (/^-vol$/) {
    $single_volume=1;
  } else {
    print "$term_red Unbekannte Option: $_$term_def\n";
    &usage;
  }
}

$version="$version $rec2nifti_option";

$file=$ARGV[0];
if ("$file" eq "") {
  print "No file given.\n";
  &usage;
}

# expand *.rec on Windows (standard on Unix)
if ($^O eq "MSWin32") {
  use File::DosGlob;
  @ARGV = map {
    my @g = File::DosGlob::glob($_) if /[*?]/;
    @g ? @g : $_;
  } @ARGV;
}


FILELOOP: foreach $file (@ARGV) {
  $image_size=0;
  $par_version=3;
  $max_diffusion_values=0;
  if (! ( -f "$file")) {
    print "$file does not exist\n";
    &usage;
  } elsif (! ( -r "$file")){
    print "$file does exist but is not readable\n";
    &usage; 
  } else {
    print "\nFilename: $file\n";
    $base_filename=$file;
    $base_filename=~s/\.[Rr][Ee][Cc]//;
    $par_filename="";
    if ( -f $base_filename."\.par") {
      $par_filename=$base_filename."\.par";
    } elsif ( -f $base_filename."\.PAR") {
      $par_filename=$base_filename."\.PAR";
    } elsif ( -f $base_filename."\.Par") {
      $par_filename=$base_filename."\.Par";
    }
    if (! (-f $par_filename)) {
      print "Suitable par-File does not exist!\n";
      &usage;
    } elsif (! (-r $par_filename)) {
      print "par-File exist, but is not readable!\n";
      &usage;
    }
    #get a few values from the par-file;
    open(FH,"$par_filename");
    my @lines = <FH>;
    close(FH);
  LINE1: while ($line=shift(@lines)){
      if ($line=~/^\.    Examination date\/time/) {
	($_,$bild_date)=split(/:   /,$line);
	($bild_date,$bild_time)=split(/ \/  /,$bild_date);
      }
      if ($line=~/^\.    Protocol name/) {
	($_,$bild_scannum)=split(/:   /,$line);
      }
      if ($line=~/^\.    Image pixel size /) {
	($_,$bild_pixel_size)=split(/:   /,$line);
        $bild_pixel_size=1*$bild_pixel_size;
      }
      if ($line=~/^\.    Recon resolution/) {
	($_,$bild_resolution)=split(/:   /,$line);
	($_,$image_size)=split(/\s+/,$bild_resolution);
      }
      if ($line=~/^\.    Slice thickness/) {
	($_,$bild_slicethickness[0])=split(/:   /,$line);
      }
      if ($line=~/^\.    Slice gap/) {
	($_,$bild_slicegap[0])=split(/:   /,$line);
      }
      if ($line=~/^\.    Max. number of slice/) {
	($_,$max_slice_header)=split(/:   /,$line);
      }
      if ($line=~/^\.    Max. number of gradient orients/) {
	($_,$max_diffusion_values)=split(/:   /,$line);
      }
      if ($line=~/^\.    Number of label types/){
	($_,$max_asl_types)=split(/:   /,$line);
      }
      if ($line=~/^\.    FOV/) {
	($_,$bild_FOV)=split(/:\s+/,$line);
	($bild_FOV_ap,$bild_FOV_fh,$bild_FOV_rl)=split(/\s+/,$bild_FOV);
	($bild_FOV_z,$bild_FOV_y,$bild_FOV_x)=sort {$a <=> $b} ($bild_FOV_ap,$bild_FOV_fh,$bild_FOV_rl); #first try...
	$bild_FOV=$bild_FOV_x;
      }
      last LINE1 if ($line=~/^\#\s*sl\s+ec/);
    }
    if ($image_size==0) {
      $par_version=4;
    }
    if ($max_diffusion_values>0) {
      $par_version=4.1;
    }
    if ($max_asl_types>0) {
      $par_version=4.2;
    }
    $anzahl_bilder=0;		#Zahlt Bilder-1
    $max_bild_slice=-1;
    $max_bild_echo=-1;
    $max_bild_dyn=-1;
    $max_bild_heartphase=-1;
    $max_bild_type=-1;
    $max_bild_scanseq=-1;
    $max_bild_diff_ori=-1;
    $max_bild_diff_ori_b0=-1;
    $max_bild_diff_bvalue=-1;
    $max_bild_asl=-1;
    $max_bild_sliceorientation=-1;
    $min_bild_slice=30000;
    $min_bild_echo=30000;
    $min_bild_dyn=30000;
    $min_bild_heartphase=30000;
    $min_bild_type=30000;
    $min_bild_scanseq=30000;
    $min_bild_diff_ori=30000;
    $min_bild_diff_ori_b0=30000;
    $min_bild_diff_bvalue=30000;
    $min_bild_asl=30000;
    $min_bild_sliceorientation=30000;

  LINE2: while ($line=shift(@lines)){
      last LINE2 if ($line=~/^\# ===/);
      $line=~s/^\s*//;
      @line_part=split(/\s+/,$line);
      if ($line_part[2]!="") {
	if ($par_version>=4) {
	  $bild_scale[$anzahl_bilder]=$line_part[12];
	  $bild_intercept[$anzahl_bilder]=$line_part[11];
	  $image_size[$anzahl_bilder]=$line_part[9];
	  $bild_pixel_size[$anzahl_bilder]=$line_part[7];
	  $bild_slicegap[$anzahl_bilder]=$line_part[23];
	  $bild_slicethickness[$anzahl_bilder]=$line_part[22];
	  $bild_sliceorientation[$anzahl_bilder]=$line_part[25];
          $bild_dyn_scan_begin_time[$anzahl_bilder]=$line_part[31];
          $bild_imageangulation_ap[$anzahl_bilder]=$line_part[16];
          $bild_imageangulation_fh[$anzahl_bilder]=$line_part[17];
          $bild_imageangulation_rl[$anzahl_bilder]=$line_part[18];
          $bild_imageoffcentre_ap[$anzahl_bilder]=$line_part[19];
          $bild_imageoffcentre_fh[$anzahl_bilder]=$line_part[20];
          $bild_imageoffcentre_rl[$anzahl_bilder]=$line_part[21];
          if ($par_version>4) {
	    $bild_diff_bvalue[$anzahl_bilder]=$line_part[41];
	    $bild_diff_ori[$anzahl_bilder]=$line_part[42];
	  } else {
	    $bild_diff_bvalue[$anzahl_bilder]=1;
	    $bild_diff_ori[$anzahl_bilder]=1;
	  }
	  if ($par_version>4.1) {
	    $bild_asl[$anzahl_bilder]=$line_part[48];
	  } else {
	    $bild_asl[$anzahl_bilder]=1;
	  }
	} else {
	  $bild_scale[$anzahl_bilder]=$line_part[8];
	  $bild_intercept[$anzahl_bilder]=$line_part[7];
	  $bild_diff_bvalue[$anzahl_bilder]=1;
	  $bild_diff_ori[$anzahl_bilder]=1;
	  $bild_asl[$anzahl_bilder]=1;
	}
	$bild_slice[$anzahl_bilder]=$line_part[0];
	$bild_echo[$anzahl_bilder]=$line_part[1];
	if ($diffusion_spez) {
	  $bild_dyn[$anzahl_bilder]=($anzahl_bilder%16+1);
	} else {
	  $bild_dyn[$anzahl_bilder]=$line_part[2];
	}
	$bild_heartphase[$anzahl_bilder]=$line_part[3];
	$bild_imagetype[$anzahl_bilder]=$line_part[4];
	$bild_scanseq[$anzahl_bilder]=$line_part[5];
	$bild_image_nr[$bild_dyn[$anzahl_bilder]][$bild_slice[$anzahl_bilder]][$bild_echo[$anzahl_bilder]][$bild_heartphase[$anzahl_bilder]][$bild_imagetype[$anzahl_bilder]][$bild_scanseq[$anzahl_bilder]][$bild_diff_bvalue[$anzahl_bilder]][$bild_diff_ori[$anzahl_bilder]][$bild_asl[$anzahl_bilder]]=$anzahl_bilder;
	if ($verbose) {
	  print $bild_dyn[$anzahl_bilder]." ".$bild_slice[$anzahl_bilder]." ".$bild_echo[$anzahl_bilder]." ".$bild_heartphase[$anzahl_bilder]." ".$bild_imagetype[$anzahl_bilder]." : ".$bild_scanseq[$anzahl_bilder]." : ".$bild_diff_bvalue[$anzahl_bilder]." : ".$bild_diff_ori[$anzahl_bilder]." : ".$bild_asl[$anzahl_bilder]." : ".$bild_image_nr[$bild_dyn[$anzahl_bilder]][$bild_slice[$anzahl_bilder]][$bild_echo[$anzahl_bilder]][$bild_heartphase[$anzahl_bilder]][$bild_imagetype[$anzahl_bilder]][$bild_scanseq[$anzahl_bilder]][$bild_diff_bvalue[$anzahl_bilder]][$bild_diff_ori[$anzahl_bilder]][$bild_asl[$anzahl_bilder]]." SS".$bild_scale[$anzahl_bilder].":".$bild_intercept[$anzahl_bilder].":".$bild_diff_bvalue[$anzahl_bilder].":".$bild_diff_ori[$anzahl_bilder].":".$bild_asl[$anzahl_bilder]."\n";
	}
	($max_bild_slice>=$line_part[0]) || ($max_bild_slice=$line_part[0]);
	($max_bild_echo>=$line_part[1]) || ($max_bild_echo=$line_part[1]);
	($max_bild_dyn>=$line_part[2]) || ($max_bild_dyn=$line_part[2]);
	($max_bild_heartphase>=$line_part[3]) || ($max_bild_heartphase=$line_part[3]);
	($max_bild_type>=$line_part[4]) || ($max_bild_type=$line_part[4]);
	($max_bild_scanseq>=$line_part[5]) || ($max_bild_scanseq=$line_part[5]);
	($max_bild_sliceorientation>=$line_part[25]) || ($max_bild_sliceorientation=$line_part[25]);
	($min_bild_slice<=$line_part[0]) || ($min_bild_slice=$line_part[0]);
	($min_bild_echo<=$line_part[1]) || ($min_bild_echo=$line_part[1]);
	($min_bild_dyn<=$line_part[2]) || ($min_bild_dyn=$line_part[2]);
	($min_bild_heartphase<=$line_part[3]) || ($min_bild_heartphase=$line_part[3]);
	($min_bild_type<=$line_part[4]) || ($min_bild_type=$line_part[4]);
	($min_bild_scanseq<=$line_part[5]) || ($min_bild_scanseq=$line_part[5]);
	($min_bild_sliceorientation<=$line_part[25]) || ($min_bild_sliceorientation=$line_part[25]);
        if ($par_version>4) {
	  if ($line_part[41]>1) {
	    ($max_bild_diff_ori>=$line_part[42]) || ($max_bild_diff_ori=$line_part[42]);
	    ($min_bild_diff_ori<=$line_part[42]) || ($min_bild_diff_ori=$line_part[42]);
	  } else {
	    ($max_bild_diff_ori_b0>=$line_part[42]) || ($max_bild_diff_ori_b0=$line_part[42]);
	    ($min_bild_diff_ori_b0<=$line_part[42]) || ($min_bild_diff_ori_b0=$line_part[42]);
	  }
	  ($max_bild_diff_bvalue>=$line_part[41]) || ($max_bild_diff_bvalue=$line_part[41]);
	  ($min_bild_diff_bvalue<=$line_part[41]) || ($min_bild_diff_bvalue=$line_part[41]);
	  if ($par_version>4.1) {
	    ($max_bild_asl>=$line_part[48]) || ($max_bild_asl=$line_part[48]);
	    ($min_bild_asl<=$line_part[48]) || ($min_bild_asl=$line_part[48]);
	  } else {
	    $max_bild_asl=1;
	    $min_bild_asl=1;
	  }
        } else {
	  $max_bild_diff_ori=1;
          $min_bild_diff_ori=1;
	  $max_bild_diff_bvalue=1;
	  $min_bild_diff_bvalue=1;
      	  $max_bild_diff_ori_b0=1;
	  $min_bild_diff_ori_b0=1;
	  $max_bild_asl=1;
	  $min_bild_asl=1;
	}
	$anzahl_bilder++;
      }
    }
    if ($max_bild_diff_ori==-1) {
      $max_bild_diff_ori=$max_bild_diff_ori_b0;
      $min_bild_diff_ori=$min_bild_diff_ori_b0;
    }
    if ($image_size[0]>0) {
      $bild_pixel_size=$bild_pixel_size[0];
      $image_size=$image_size[0];
    }
    if ($max_bild_asl==-1) {
      $max_bild_asl=1;
      $min_bild_asl=1;
    }
    if ($image_size==0) {
      print "Not a version 3 or 4 Par-File...\n";
      next FILELOOP;
    } else {
      print "Version $par_version Par-File could be read.\n";
    }

    $temp_type="";
    $nr_diff_image_type=0;
    for ($loop_type=$min_bild_type;$loop_type<=$max_bild_type;$loop_type++) {
      if ((defined $bild_image_nr[$min_bild_dyn][$min_bild_slice][$min_bild_echo][$min_bild_heartphase][$loop_type][$min_bild_scanseq][$min_bild_diff_bvalue][$max_bild_diff_ori][$min_bild_asl])||(defined $bild_image_nr[$min_bild_dyn][$min_bild_slice][$min_bild_echo][$min_bild_heartphase][$loop_type][$min_bild_scanseq][$min_bild_diff_bvalue][$max_bild_diff_ori_b0][$min_bild_asl])||(defined $bild_image_nr[$min_bild_dyn][$min_bild_slice][$min_bild_echo][$min_bild_heartphase][$loop_type][$min_bild_scanseq][$min_bild_diff_bvalue][$max_bild_diff_ori][$min_bild_asl])||(defined $bild_image_nr[$min_bild_dyn][$min_bild_slice][$min_bild_echo][$min_bild_heartphase][$loop_type][$max_bild_scanseq][$min_bild_diff_bvalue][$max_bild_diff_ori_b0][$min_bild_asl])) {
	$temp_type="$temp_type$loop_type  ";
	$nr_diff_image_type++;
      }
    }
    $temp_scanseq="";
    $nr_diff_image_scanseq=0;
    for ($loop_scanseq=$min_bild_scanseq;$loop_scanseq<=$max_bild_scanseq;$loop_scanseq++) {
      if ((defined $bild_image_nr[$min_bild_dyn][$min_bild_slice][$min_bild_echo][$min_bild_heartphase][$min_bild_type][$loop_scanseq][$min_bild_diff_bvalue][$max_bild_diff_ori][$min_bild_asl])||(defined $bild_image_nr[$min_bild_dyn][$min_bild_slice][$min_bild_echo][$min_bild_heartphase][$min_bild_type][$loop_scanseq][$min_bild_diff_bvalue][$max_bild_diff_ori_b0][$min_bild_asl])) {
	$temp_scanseq="$temp_scanseq$loop_scanseq  ";
	$nr_diff_image_scanseq++;
      }
    }
    if (($max_bild_sliceorientation!=$min_bild_sliceorientation)&&!($scan_store_force)) {
      print ("\n\nWarning: Your scan has different stack orientations. Convertion may create useless images.\nUse option -f[orce]!\n\n");
      &usage;
    }
    if ($bild_dyn[-1]>$bild_dyn[0]) {
      $dt_dyn_scan=($bild_dyn_scan_begin_time[-1]-$bild_dyn_scan_begin_time[0])/($bild_dyn[-1]-$bild_dyn[0]);
    } else {
      $dt_dyn_scan=1.0;
    }
    if ($display) {		#display some parameters if requested with -d.
      print "PARRECversion  = $par_version\n";
      print "date time      = $bild_date";
      print "scan name      = $bild_scannum";
      print "pixel size     = $bild_pixel_size\n";
      print "image size     = $image_size\n";
      print "dynamic scan   = $bild_dyn[0]\n";
      print "image scale    = $bild_scale[0]\n";
      print "image intercept= $bild_intercept[0]\n";
      print "sl thickness   = $bild_slicethickness[0]\n";
      print "slice gap      = $bild_slicegap[0]\n";
      print "dT Dynamic     = $dt_dyn_scan\n";
      print "Nr of Dynamics = $max_bild_dyn\n";
      print "Nr of Slices   = $min_bild_slice - $max_bild_slice\n";
      print "Nr of Echos    = $min_bild_echo - $max_bild_echo\n";
      print "Nr of HP       = $min_bild_heartphase - $max_bild_heartphase\n";
      print "Nr of diff ori = $min_bild_diff_ori - $max_bild_diff_ori\n";
      print "Nr of b value  = $min_bild_diff_bvalue - $max_bild_diff_bvalue\n";
      print "Nr of ASL value= $min_bild_asl - $max_bild_asl\n";
      print "Nr of Types    = $temp_type\n";
      print "Nr of Scan Seq = $temp_scanseq\n";
    }

    if ($scan_split==0) {
      if ($max_bild_echo != $min_bild_echo) {
	print ("\n\nError: More than one echo: $min_bild_echo - $max_bild_echo\nPlease use option -s\n\n");
	&usage;
      }
      if ($max_bild_heartphase != $min_bild_heartphase) {
	print ("\n\nError: More than one heartphase: $min_bild_heartphase - $max_bild_heartphase\nPlease use option -s\n\n");
	&usage;
      }
      if ($max_bild_type != $min_bild_type) {
	print ("\n\nError: More than one image type: $temp_type\nPlease use option -s\n\n");
	&usage;
      }
      if ($max_bild_scanseq != $min_bild_scanseq) {
	print ("\n\nError: More than one scan sequence: $temp_scanseq\nPlease use option -s\n\n");
	&usage;
      }
      if ($max_bild_asl != $min_bild_asl) {
	print ("\n\nError: More than one ASL type: $min_bild_asl - $max_bild_asl\nPlease use option -s\n\n");
	&usage;
      }
      if (($max_bild_slice-$min_bild_slice+1)*($max_bild_echo-$min_bild_echo+1)*($max_bild_dyn-$min_bild_dyn+1)*(($max_bild_diff_ori-$min_bild_diff_ori+1)*($max_bild_asl-$min_bild_asl+1)*($max_bild_diff_bvalue-$min_bild_diff_bvalue)+1)*$nr_diff_image_type!=$anzahl_bilder) {
	print ("\n\nError: Wrong number of images!\nSlices: ".($max_bild_slice-$min_bild_slice+1)."\nEcho: ".($max_bild_echo-$min_bild_echo+1)."\nDynamics: ".($max_bild_dyn-$min_bild_dyn+1)."\nDiffusion Ori: ".($max_bild_diff_ori-$min_bild_diff_ori+1)."\nDiffusion b value: ".($max_bild_diff_bvalue-$min_bild_diff_bvalue+1)."\nASL values: ".($max_bild_asl-$min_bild_asl+1)."\ndiffernent image types: ".$nr_diff_image_type." ($temp_type)\ndiffernent scan types: ".$nr_diff_image_scanseq." ($temp_scanseq)\nImages: $anzahl_bilder\nPlease use option -s\n\n");
	&usage;
      }
      if (($max_bild_slice-$min_bild_slice+1)*($max_bild_echo-$min_bild_echo+1)*($max_bild_dyn-$min_bild_dyn+1)*(($max_bild_diff_ori-$min_bild_diff_ori+1)*($max_bild_diff_bvalue-$min_bild_diff_bvalue)+1)*($max_bild_asl-$min_bild_asl+1)*$nr_diff_image_type*$nr_diff_image_scanseq!=$anzahl_bilder) {
	print ("\n\nError: Wrong number of images!\nSlices: ".($max_bild_slice-$min_bild_slice+1)."\nEcho: ".($max_bild_echo-$min_bild_echo+1)."\nDynamics: ".($max_bild_dyn-$min_bild_dyn+1)."\nDiffusion Ori: ".($max_bild_diff_ori-$min_bild_diff_ori+1)."\nDiffusion b value: ".($max_bild_diff_bvalue-$min_bild_diff_bvalue+1)."\nASL values: ".($max_bild_asl-$min_bild_asl+1)."\ndiffernent image types: ".$nr_diff_image_type." ($temp_type)\ndiffernent scan types: ".$nr_diff_image_scanseq." ($temp_scanseq)\nImages: $anzahl_bilder\nUse option -split or -s! if scan has been stopped earlier or -s (-split) if multiple heart phases, diffusions direction, image type, scan sequences, heart phases, echos etc.\n\n");
        &usage;
      }
    }
    if (($max_bild_slice-$min_bild_slice+1)*($max_bild_echo-$min_bild_echo+1)*($max_bild_dyn-$min_bild_dyn+1)*(($max_bild_diff_ori-$min_bild_diff_ori+1)*($max_bild_diff_bvalue-$min_bild_diff_bvalue)+1)*($max_bild_asl-$min_bild_asl+1)*$nr_diff_image_type*$nr_diff_image_scanseq!=$anzahl_bilder) {
      print ("\n\nError: Wrong number of images (2)!\nSlices: ".($max_bild_slice-$min_bild_slice+1)."\nEchos: ".($max_bild_echo-$min_bild_echo+1)."\nDynamics: ".($max_bild_dyn-$min_bild_dyn+1)."\nDiffusion Ori: ".($max_bild_diff_ori-$min_bild_diff_ori+1)."\nDiffusion b value: ".($max_bild_diff_bvalue-$min_bild_diff_bvalue+1)."\n ASL values: ".($max_bild_asl-$min_bild_asl+1)."\ndiffernent image types: ".$nr_diff_image_type." ($temp_type)\ndiffernent scan types: ".$nr_diff_image_scanseq." ($temp_scanseq)\nImages: $anzahl_bilder\n\n");
      $max_bild_dyn_calc=$min_bild_dyn-1+int($anzahl_bilder/($max_bild_slice-$min_bild_slice+1)/($max_bild_echo-$min_bild_echo+1)/(($max_bild_diff_ori-$min_bild_diff_ori)*($max_bild_diff_bvalue-$max_bild_diff_bvalue-$min_bild_diff_bvalue)+1)/($max_bild_asl-$min_bild_asl+1)/$nr_diff_image_type/$nr_diff_image_scanseq);
      if ($max_bild_dyn_calc<$max_bild_dyn) {
	$max_bild_dyn=$max_bild_dyn_calc;
	if ($max_bild_dyn==0){
	  $max_bild_dyn=1;  ##bad bugfix for mix sequences where only part of types and scanseqs are avialable!
	}
	print "Number of dynamics will be reduced.\n";
      }
      $wrong_dyn_auto_nr=0;
      if ($max_bild_dyn_calc>$max_bild_dyn) {
	$max_bild_dyn=$max_bild_dyn_calc;
	print "Number of dynamics will be increased.\n";
	$wrong_dyn_auto_nr=1;
      }
      $anzahl_bilder=($max_bild_slice-$min_bild_slice+1)*($max_bild_echo-$min_bild_echo+1)*($max_bild_dyn-$min_bild_dyn+1)*(($max_bild_diff_ori-$min_bild_diff_ori+1)*($max_bild_diff_bvalue-$min_bild_diff_bvalue)+1)*($max_bild_asl-$min_bild_asl+1)*$nr_diff_image_type*$nr_diff_image_scanseq;
      print "new values:\nSlices: ".($max_bild_slice-$min_bild_slice+1)."\nEchos: ".($max_bild_echo-$min_bild_echo+1)."\nDynamics: ".($max_bild_dyn-$min_bild_dyn+1)."\nDiffusion Ori: ".($max_bild_diff_ori-$min_bild_diff_ori+1)."\nDiffusion b value: ".($max_bild_diff_bvalue-$min_bild_diff_bvalue+1)."\nASL values: ".($max_bild_asl-$min_bild_asl+1)."\ndiffernent image types: ".$nr_diff_image_type." ($temp_type)\ndiffernent scan types: ".$nr_diff_image_scanseq." ($temp_scanseq)\nImages: $anzahl_bilder\n";
    }
	
	
    $bildsizebyte=$image_size*$image_size*$bild_pixel_size/8;
    $pixels=$image_size;
    $image_size="${image_size}x${image_size}";
    $target="$base_filename";

    #datafile open
    open(MAIN,"$file") || die "can't open rec-file";
    binmode(MAIN);
    
    print "Starting reordering (tot: ".($anzahl_bilder)." images):\n ";
    $real_number_images=0;
    for ($loop_echo=$min_bild_echo;$loop_echo<=$max_bild_echo;$loop_echo++) {
      for ($loop_hp=$min_bild_heartphase;$loop_hp<=$max_bild_heartphase;$loop_hp++) {
      TYPE: for ($loop_type=$min_bild_type;$loop_type<=$max_bild_type;$loop_type++){
	SCANSEQ: for ($loop_scanseq=$min_bild_scanseq;$loop_scanseq<=$max_bild_scanseq;$loop_scanseq++){
	    if (!defined $bild_image_nr[$min_bild_dyn][$min_bild_slice][$loop_echo][$loop_hp][$loop_type][$loop_scanseq][$max_bild_diff_bvalue][$min_bild_diff_ori][$min_bild_asl]) {
	      next;
	    } else {
	      for ($loop_diff_bvalue=$min_bild_diff_bvalue;$loop_diff_bvalue<=$max_bild_diff_bvalue;$loop_diff_bvalue++) {
		##-----loop over diff ori
		if ($loop_diff_bvalue==$min_bild_diff_bvalue) {
		  $min_bild_diff_ori_temp=$min_bild_diff_ori_b0;
		  $max_bild_diff_ori_temp=$max_bild_diff_ori_b0;
		} else {
		  $min_bild_diff_ori_temp=$min_bild_diff_ori;
		  $max_bild_diff_ori_temp=$max_bild_diff_ori;
		}
		#print "diff orientations: $min_bild_diff_ori_temp $max_bild_diff_ori_temp";
		for ($loop_diff_ori=$min_bild_diff_ori_temp;$loop_diff_ori<=$max_bild_diff_ori_temp;$loop_diff_ori++) {
		  for ($loop_asl=$min_bild_asl;$loop_asl<=$max_bild_asl;$loop_asl++) {
		    $stellen=length($max_bild_dyn);
		    $stellen_diff=length($max_bild_diff_ori);
		    $stellen_diff_bvalue=length($max_bild_diff_bvalue);
		    $stellen_asl=length($max_bild_asl);
		    $stellen_dyn=length($max_bild_dyn);
		    $addition_filename="";
		    if ($max_bild_echo != $min_bild_echo) {
		      $addition_filename=$addition_filename."_ec$loop_echo";
		    }
		    if ($max_bild_heartphase != $min_bild_heartphase) {
		      $addition_filename=$addition_filename."_hp$loop_hp";
		    }
		    if ($max_bild_type != $min_bild_type) {
		      $addition_filename=$addition_filename."_typ$loop_type";
		    }
		    if ($max_bild_scanseq != $min_bild_scanseq) {
		      $addition_filename=$addition_filename."_seq$loop_scanseq";
		    }
		    if (($max_bild_diff_ori != $min_bild_diff_ori) || ($max_bild_diff_bvalue != $min_bild_diff_bvalue)) {
		      $addition_filename=$addition_filename."_bvalue".substr("000000000".($loop_diff_bvalue),-$stellen_diff_bvalue,$stellen_diff_bvalue)."_diffori".substr("000000000".($loop_diff_ori),-$stellen_diff,$stellen_diff);
		    }
		    if ($max_bild_asl != $min_bild_asl) {
		      $addition_filename=$addition_filename."_asl$loop_asl";
		    }
		    $limit_displayed_numbers=int($anzahl_bilder/100);
		    if ($limit_displayed_numbers<1) {
		      $limit_displayed_numbers=1;
		    }
		    print "\n";
		    #---loop over dynamics
		    for ($loop_dyn=$min_bild_dyn;$loop_dyn<=$max_bild_dyn;$loop_dyn++) {
		      if ($single_volume||$loop_dyn==$min_bild_dyn){
			if ($single_volume){
			  $addition_filename_dyn=$addition_filename."_dyn".substr("000000000".($loop_dyn),-$stellen_dyn,$stellen_dyn);
			} else {
			  $addition_filename_dyn=$addition_filename;
			}
			$target="$base_filename$addition_filename_dyn"; 
			&write_header($bild_image_nr[$min_bild_dyn][$min_bild_slice][$loop_echo][$loop_hp][$loop_type][$loop_scanseq][$loop_diff_bvalue][$loop_diff_ori][$loop_asl],$min_bild_dyn,$min_bild_slice, $loop_echo, $loop_hp, $loop_type, $loop_scanseq, $loop_diff_bvalue, $loop_diff_ori, $loop_asl);
		      }
		      open(TARGET,">>$target\.nii") || die "can't append to nii-File $target\.nii";
		      binmode(TARGET);
		      #-----loop over slices	
		      $volume="";
		      my @bild = ();
		      for ($loop_slice=$min_bild_slice;$loop_slice<=$max_bild_slice;$loop_slice++) {
		      $real_number_images++;
			$j=(($loop_dyn-1)*$max_bild_slice)+$loop_slice;
			if (($j%20==0)&&($display==1)) {
			  print "\n";
			}
			if (($j%$limit_displayed_numbers==0)&&($display!=1)) {
			  print "$j ";
			}
			if ($display==1) {
			  print "$j ";
			}
			sysseek(MAIN,$bild_image_nr[$loop_dyn][$loop_slice][$loop_echo][$loop_hp][$loop_type][$loop_scanseq][$loop_diff_bvalue][$loop_diff_ori][$loop_asl]*$bildsizebyte,0);
			if ($verbose) {
			  print "dyn: $loop_dyn; slices: $loop_slice; echo: $loop_echo; hp: $loop_hp; type: $loop_type; scanseq: $loop_scanseq; diff_ori: $loop_diff_ori; als:$loop_asl; size: $bildsizebyte offset: ".$bild_image_nr[$loop_dyn][$loop_slice][$loop_echo][$loop_hp][$loop_type][$loop_scanseq][$loop_diff_bvalue][$loop_diff_ori][$loop_asl]."\n";
			}
			if ($rotation_id&&$bild_sliceorientation[0]!=1) {
			  sysread(MAIN,$bild[$loop_slice-$min_bild_slice],$bildsizebyte,0) || die "no data";
			} else {
			  sysread(MAIN,$bild,$bildsizebyte,0) || die "no data";
			  if ($rotation_id_tms) {
			    for ($m = 1; $m <= $pixels; $m++) {
			      for ($n = 1; $n <= $pixels; $n++) {
				vec($bild_neu,(($pixels-$m)*$pixels+$pixels-$n),$bild_pixel_size)=vec($bild,(($m-1)*$pixels+$n-1),$bild_pixel_size);
			      }
			    }
			    syswrite(TARGET,$bild_neu);
			  } else {  
			    syswrite(TARGET,$bild);
			  }
			}
		      }		#-----loop over slices
		      if ($rotation_id&&$bild_sliceorientation[0]!=1) {
			my @bild_new = ();
			if ($bild_sliceorientation[0]==3) {	#cor
			  $nr_slices=$max_bild_slice-$min_bild_slice+1;
			  for ($l=1;$l<=$nr_slices; $l++) {
			    print "$l ";
			    for ($m = 1; $m <= $pixels; $m++) {
			      for ($n = 1; $n <= $pixels; $n++) {
				# vec($bild_new[$pixels-$m],(($l-1)*$pixels+$n-1),$bild_pixel_size)=vec($bild[$l-1],(($m-1)*$pixels+$n-1),$bild_pixel_size);
				vec($bild_new[$pixels-$m],(((1-$rotation_id_tms)*($l-1)+$rotation_id_tms*($nr_slices-$l))*$pixels+((1-$rotation_id_tms)*($n-1)+$rotation_id_tms*($pixels-$n))),$bild_pixel_size)=vec($bild[$l-1],(($m-1)*$pixels+$n-1),$bild_pixel_size);
			      }
			    }
			  }
			  for ($m = 1; $m <= $pixels; $m++) {
			    syswrite(TARGET,$bild_new[$m-1]);
			  }
			} else {	#sag
			  $nr_slices=$max_bild_slice-$min_bild_slice+1;
			  for ($l=1;$l<=$nr_slices; $l++) {
			    print "$l ";
			    for ($m = 1; $m <= $pixels; $m++) {
			      for ($n = 1; $n <= $pixels; $n++) {
				# vec($bild_new[$pixels-$m],(($n-1)*$nr_slices+$nr_slices-$l),$bild_pixel_size)=vec($bild[$l-1],(($m-1)*$pixels+$n-1),$bild_pixel_size);
				vec($bild_new[$pixels-$m],(((1-$rotation_id_tms)*($n-1)+$rotation_id_tms*($pixels-$n))*$nr_slices+((1-$rotation_id_tms)*($nr_slices-$l)+$rotation_id_tms*($l-1))),$bild_pixel_size)=vec($bild[$l-1],(($m-1)*$pixels+$n-1),$bild_pixel_size);
			      }
			    }
			  }
			  for ($m = 1; $m <= $pixels; $m++) {
			    syswrite(TARGET,$bild_new[$m-1]);
			  }
			}
			if ($loop_dyn==$min_bild_dyn) {
			  print "\nConvertion to transversal orientation ($rec2nifti_option):\n"; 
			}
		      }
		    }		#-----loop over dynamic
		    close(TARGET);
		  }			#-----loop over asl
		}			#-----loop over diff ori
	      }			#-----loop over diff b-value
	    }                   #-----loop over scan seq
	  }                     # end else from defined
	}			#-----loop over type
      }				#-----loop over hp
    }				#-----loop over echo
  
    close(MAIN);

  
    if ($rotation_id&&$bild_sliceorientation[0]!=1) {
      print "\n\nWarning: All scans have been resliced to transversal orientations. ($rec2nifti_option)\n\n"
    }

    print "\n...all images reordered ($real_number_images)\n";
  }
}
  
sub write_header {
  $current_image_nr=$_[0];
  $current_dyn=$_[1];
  $current_slice=$_[2];
  $current_echo=$_[3];
  $current_heartphase=$_[4];
  $current_type=$_[5];
  $current_scanseq=$_[6];
  $current_diff_bvalue=$_[7];
  $current_diff_ori=$_[8];
  $current_asl=$_[9];
  ($verbose)&&print "current_image_nr: $current_image_nr, $current_dyn, $current_slice, $current_echo, $current_heartphase, $current_type, $current_scanseq, $current_diff_bvalue, $current_diff_ori, $current_asl\n";
  if ($rotation_id) {
    if ($bild_sliceorientation[0]==2) { #sag
      ($bild_FOV_y,$bild_FOV_x)=sort {$a <=> $b} ($bild_FOV_ap,$bild_FOV_fh);
      $bild_FOV_z=$bild_FOV_rl;
      $bild_FOV=$bild_FOV_x;
      $bild_res=$bild_FOV/$pixels;
      $image_size_y=$pixels;
      $image_size_z=$pixels;
      $image_size_x=$max_bild_slice-$min_bild_slice+1;
      $bild_res_y=$bild_res;
      $bild_res_z=$bild_res;
      $bild_res_x=$bild_slicethickness[0]+$bild_slicegap[0];
    } elsif ($bild_sliceorientation[0]==3) { #cor
      ($bild_FOV_y,$bild_FOV_x)=sort {$a <=> $b} ($bild_FOV_rl,$bild_FOV_fh);
      $bild_FOV_z=$bild_FOV_ap;
      $bild_FOV=$bild_FOV_x;
      $bild_res=$bild_FOV/$pixels;
      $image_size_z=$pixels;
      $image_size_x=$pixels;
      $image_size_y=$max_bild_slice-$min_bild_slice+1;
      $bild_res_z=$bild_res;
      $bild_res_x=$bild_res;
      $bild_res_y=$bild_slicethickness[0]+$bild_slicegap[0];
    } else {			#tra
      ($bild_FOV_y,$bild_FOV_x)=sort {$a <=> $b} ($bild_FOV_ap,$bild_FOV_rl);
      $bild_FOV_z=$bild_FOV_fh;
      $bild_FOV=$bild_FOV_x;
      $bild_res=$bild_FOV/$pixels;
      $image_size_x=$pixels;
      $image_size_y=$pixels;
      $image_size_z=$max_bild_slice-$min_bild_slice+1;
      $bild_res_x=$bild_res;
      $bild_res_y=$bild_res;
      $bild_res_z=$bild_slicethickness[0]+$bild_slicegap[0];
    }
    if ($rotation_id_tms) {
      $r11=$bild_res_x;
      $r22=$bild_res_y;
      $r33=$bild_res_z;
    } else {
      $r11=-$bild_res_x;
      $r22=-$bild_res_y;
      $r33=$bild_res_z;
    }
    $qa=1;$qb=0;$qc=0;$qd=0;
    $r12=0; $r13=0;
    $r21=0; $r23=0;
    $r31=0; $r32=0;
    $det_r=1;
    $qfactor=1;
    $qx=-$r11*$image_size_x/2-$r12*$image_size_y/2-$r13*$image_size_z/2;
    $qy=-$r21*$image_size_x/2-$r22*$image_size_y/2-$r23*$image_size_z/2;
    $qz=-$r31*$image_size_x/2-$r32*$image_size_y/2-$r33*$image_size_z/2;
  } else {
    ($qa,$qb,$qc,$qd)=&calculate_rotations();
    $bild_res=$bild_FOV/$pixels;
    $image_size_x=$pixels;
    $image_size_y=$pixels;
    $image_size_z=$max_bild_slice-$min_bild_slice+1;
    $bild_res_x=$bild_res;
    $bild_res_y=$bild_res;
    $bild_res_z=$bild_slicethickness[0]+$bild_slicegap[0];
    $r11=$r11*$bild_res_x;
    $r12=$r12*$bild_res_y;
    $r13=$r13*$bild_res_z;
    $r21=$r21*$bild_res_x;
    $r22=$r22*$bild_res_y;
    $r23=$r23*$bild_res_z;
    $r31=$r31*$bild_res_x;
    $r32=$r32*$bild_res_y;
    $r33=$r33*$bild_res_z;
    $qx=-$r11*$image_size_x/2-$r12*$image_size_y/2-$r13*$image_size_z/2;
    $qy=-$r21*$image_size_x/2-$r22*$image_size_y/2-$r23*$image_size_z/2;
    $qz=-$r31*$image_size_x/2-$r32*$image_size_y/2-$r33*$image_size_z/2;
  }
  ($verbose)&&print "Rotation: $qa $qb $qc $qd\n";
  
  #save nii_header
  open(FH,">$target.nii") || die "can't open File $target.nii";
  binmode(FH);
  $leer_string=pack("C255",0);
  syswrite FH,pack("l",348),4,0; #size_of_header (0,4)
  syswrite FH,pack("C10",(100,115,114,32,32,32,32,32,32,0)),10,0; #unused (4,10)
  syswrite FH,"$base_filename.rec$leer_string",17,0; #unused (14,17)
  syswrite FH,$leer_string,7,0; #unused (31,9)
  syswrite FH,"r",1,0;		#unused (38,1)
  syswrite FH,$leer_string,1,0; #unused (31,9)
  $dyn=$max_bild_dyn;
  if ($dyn==1) {
    $nii_dim=3;
  } else {
    $nii_dim=4;
  }
  syswrite FH,pack("S8",($nii_dim,$image_size_x,$image_size_y,$image_size_z,$dyn,1,1,1)),16,0; #dim, recon_dim_x,-_y,slices,dyn,1,1,1     (40,16)
  syswrite FH,"$leer_string",14,0; #unused (56,14)
  if ($bild_pixel_size eq 16) {
    syswrite FH,pack("S",4),2,0; #sign short   #datatype+size (70,4)
    syswrite FH,pack("S",16),2,0; #16
  } else {
    syswrite FH,pack("S",2),2,0; #sign byte
    syswrite FH,pack("S",8),2,0; #8
  }
  syswrite FH,$leer_string,2,0; #start_slice (74,2)
  syswrite FH,pack("f8",($qfactor,$bild_res_x,$bild_res_y,$bild_res_z,$dt_dyn_scan,1.0,1.0,1.0)),36,0; #FOV/recon_res., Slice distance, time distance        (76,32)
  syswrite FH,pack("f1",352.0),4,0; #offset of data 352 (108,4)
  syswrite FH,pack("f2",($bild_scale[$current_image_nr],$bild_intercept[$current_image_nr])),8,0; #rescale slope and intercept    (112,8)

  syswrite FH,pack("S",$max_bild_slice-$min_bild_slice),2,0; #max slice-1 (120,2)
  syswrite FH,$leer_string,1,0; #Slice Order unknown (122,1)
  syswrite FH,pack("C",10),1,0; #Units (123,1) 2: mm 8: s
  syswrite FH,$leer_string,16,0; #start_slice (124,16)
  syswrite FH,pack("S4",(32767,0,0,0)),8,0; #glmax,glmin   (140,8)
  syswrite FH,"$version IBT Zurich: $bild_scannum$leer_string",80,0; #description    (148,80)
  syswrite FH,"$leer_string",24,0; #alternat. Filename (228,24)
  syswrite FH,pack("i",1),2,0;	#Scanner-based anatomical coordinates (252,2) #allways 1
  #  ($verbose)&&print "qfac: $qfactor\n";
  syswrite FH,pack("S",1),2,0;	#Scanner-based anatomical coordinates (254,2)

  #rotational matrix...
  ($verbose)&&print "$qb $qc $qd \n\n";
  syswrite FH,pack("f6",($qb,$qc,$qd,$qx,$qy,$qz)),24,0; #q_b-q_d,q_x-q_z   (256,24)
  syswrite FH,pack("f4",($r11,$r12,$r13,$qx)),16,0; #rotation 1. row   (280,16)
  syswrite FH,pack("f4",($r21,$r22,$r23,$qy)),16,0; #rotation 2. row   (296,16)
  syswrite FH,pack("f4",($r31,$r32,$r33,$qz)),16,0; #rotation 3. row   (312,16)
  syswrite FH,"$leer_string",16,0; #name for statistic (328,16)
  syswrite FH,"n+1$leer_string",4,0; #magic (344,4)
  syswrite FH,"$leer_string",4,0; #magic (348,4)
  close(FH);
  #end save nifti-header
}

sub conv_apfhrl_2_xyz {
  #call: ($img_ori[0-5],$img_off[0-2])=conv_apfhrl_2_xyz($ang_rl,$ang_ap,$ang_fh,$off_ap,$off_fh,$off_rl,$view_axis,$fov_hor,$fov_ver);
  use Math::Trig;
  my ($ang_x,$ang_y,$ang_z,$off_x,$off_y,$off_z,$view_axis,$fov_hor,$fov_ver)=@_;
  my @img_ori;
  my @img_off;
    
  if ($view_axis == 3) {	#coronal
    @view_matrix[0]=[ 1.0, 0.0, 0.0];
    @view_matrix[1]=[ 0.0, 0.0, 1.0];
    @view_matrix[2]=[ 0.0, -1.0, 0.0];
  } else {
    if ($view_axis == 2) {	#sagital
      @view_matrix[0]=[ 0.0, 0.0,-1.0];
      @view_matrix[1]=[ 1.0, 0.0, 0.0];
      @view_matrix[2]=[ 0.0,-1.0, 0.0];
    } else {			#transversal
      @view_matrix[0]=[1.0, 0.0, 0.0];
      @view_matrix[1]=[0.0, 1.0, 0.0];
      @view_matrix[2]=[0.0, 0.0, 1.0];
    }
  }
  #    angulation_to_rowcol( @angulation, @view_axis, @row, @col );
  #    mat_mat( _apat_to_pat, _slice_to_apat, matrix);
  #    _slice_to_apat=view_matrix
  #    _apat_to_pat:
  my $sx,$sy,$sz,$cx,$cy,$cz;
  $sx = sin( deg2rad($ang_x));
  $sy = sin( deg2rad($ang_y));
  $sz = sin( deg2rad($ang_z));
  $cx = cos( deg2rad($ang_x));
  $cy = cos( deg2rad($ang_y));
  $cz = cos( deg2rad($ang_z));

  my @rot_mat;			#incl. pat_to_tal diag(-1,-1,1)
  $rot_mat[0][0] = -$cy * $cz;
  $rot_mat[1][0] = -($sz * $cx + $sx * $sy * $cz);
  $rot_mat[2][0] = ($sx * $sz - $sy * $cx * $cz);
  
  $rot_mat[0][1] = $sz * $cy;
  $rot_mat[1][1] = -($cx * $cz - $sx * $sy * $sz);
  $rot_mat[2][1] = ($sx * $cz + $sy * $sz * $cx);
  
  $rot_mat[0][2] = - $sy;
  $rot_mat[1][2] = $sx * $cy;
  $rot_mat[2][2] = $cx * $cy;

  #print $rot_mat[0][0]." ".$rot_mat[0][1]." ". $rot_mat[0][2]."\n";
  #print $rot_mat[1][0]." ".$rot_mat[1][1]." ". $rot_mat[1][2]."\n";
  #print $rot_mat[2][0]." ".$rot_mat[2][1]." ". $rot_mat[2][2]."\n";

  # matrix multiplication: rot_mat**view_matrix
  my @pat_matrix;
  for (my $i=0;$i<3;$i++) {
    for (my $j=0;$j<3;$j++) {
      $pat_matrix[$i][$j] = $rot_mat[$i][0]*$view_matrix[0][$j]+$rot_mat[$i][1]*$view_matrix[1][$j]+$rot_mat[$i][2]*$view_matrix[2][$j]
    }
  }

  #nicht gemacht #pat_matrix*diag[1,-1,1] analyze_do_dicom
  $r11=$pat_matrix[0][0];
  $r12=+$pat_matrix[0][1];
  $r13=$pat_matrix[0][2];
  $r21=$pat_matrix[1][0];
  $r22=+$pat_matrix[1][1];
  $r23=$pat_matrix[1][2];
  $r31=$pat_matrix[2][0];
  $r32=+$pat_matrix[2][1];
  $r33=$pat_matrix[2][2];


  #  offcentre_to_position_rowcol_based( offcentre, row, col, fov_hor, fov_ver, position_ptr);
  
  my $hor=0.5*$fov_hor;
  my $ver=0.5*$fov_ver;
  
  $img_off[0]=$off_x-$hor*$img_ori[0]-$ver*$img_ori[3];
  $img_off[1]=$off_y-$hor*$img_ori[1]-$ver*$img_ori[4];
  $img_off[2]=$off_z-$hor*$img_ori[2]-$ver*$img_ori[5];

  for (my $i=0;$i<6;$i++) {
    $img_ori[$i]=sprintf("%.3f",$img_ori[$i]);
  }
  for (my $i=0;$i<3;$i++) {
    $img_off[$i]=sprintf("%.3f",$img_off[$i]);
  }  

  return(@img_ori,@img_off);
}

sub calculate_rotations {
  #needs: slice_orient, FOV_ap..., rotation_angles.
  if ($bild_sliceorientation[0]==1) {
    $verbose&&print "transversal slices\n";
    ($bild_FOV_y,$bild_FOV_x)=sort {$a <=> $b} ($bild_FOV_ap,$bild_FOV_rl);
    $bild_FOV_z=$bild_FOV_fh;
    $bild_FOV=$bild_FOV_x;
  } elsif ($bild_sliceorientation[0]==2) {
    $verbose&&print "sagital slices\n";
    ($bild_FOV_y,$bild_FOV_x)=sort {$a <=> $b} ($bild_FOV_ap,$bild_FOV_fh);
    $bild_FOV_z=$bild_FOV_rl;
    $bild_FOV=$bild_FOV_x;
  } else {
    $verbose&&print "Coronal slices\n";
    ($bild_FOV_y,$bild_FOV_x)=sort {$a <=> $b} ($bild_FOV_rl,$bild_FOV_fh);
    $bild_FOV_z=$bild_FOV_ap;
    $bild_FOV=$bild_FOV_x;
  }
  ($verbose)&&print "FOV: $bild_FOV_x $bild_FOV_y $bild_FOV_z\n";
  ($img_ori[0],$img_ori[1],$img_ori[2],$img_ori[3],$img_ori[4],$img_ori[5],$img_off[0],$img_off[1],$img_off[2])=conv_apfhrl_2_xyz( $bild_imageangulation_rl[0], $bild_imageangulation_ap[0], $bild_imageangulation_fh[0],$bild_imageoffcentre_ap[0],$bild_imageoffcentre_fh[0],$bild_imageoffcentre_rl[0],$bild_sliceorientation[0],$bild_FOV_x,$bild_FOV_y);

  $det_r = $r11*$r22*$r33-$r11*$r32*$r23-$r21*$r12*$r33+$r21*$r32*$r13+$r31*$r12*$r23-$r31*$r22*$r13;
  ($verbose)&&print "det: $det_r\n";
  if ($det_r<0) {
    $qfactor=-1;
    $r13=-$r13;
    $r23=-$r23;
    $r33=-$r33;
  } else {
    $qfactor=1;
  }
  
  ($verbose)&&  print "r-Matrix: $r11 $r12 $r13\n";
  ($verbose)&&  print "          $r21 $r22 $r23\n";
  ($verbose)&&  print "          $r31 $r32 $r33\n\n";
  $qa=$r11+$r22+$r33+1.0;
  if ($qa>0.5) {		# simplest case
    $qa=0.5*sqrt($qa);
    $qb=0.25*($r32-$r23)/$qa ;
    $qc=0.25*($r13-$r31)/$qa ;
    $qd=0.25*($r21-$r12)/$qa ;
  } else {			# trickier case 
    $xd = 1.0 + $r11 - ($r22+$r33) ; # 4*b*b 
    $yd = 1.0 + $r22 - ($r11+$r33) ; # 4*c*c 
    $zd = 1.0 + $r33 - ($r11+$r22) ; # 4*d*d 
    if ( $xd > 1.0 ) {
      $qb = 0.5*sqrt($xd);
      $qc = 0.25*($r12+$r21)/$qb;
      $qd = 0.25*($r13+$r31)/$qb;
      $qa = 0.25*($r32-$r23)/$qb;
    } elsif ( $yd > 1.0 ) {
      $qc = 0.5 * sqrt($yd) ;
      $qb = 0.25* ($r12+$r21) / $qc ;
      $qd = 0.25* ($r23+$r32) / $qc ;
      $qa = 0.25* ($r13-$r31) / $qc ;
    } else {
      $qd = 0.5 * sqrt($zd) ;
      $qb = 0.25* ($r13+$r31) / $qd ;
      $qc = 0.25* ($r23+$r32) / $qd ;
      $qa = 0.25* ($r21-$r12) / $qd ;
    }
    if ( $qa < 0.0 ) {
      $qb=-$qb ; $qc=-$qc ; $qd=-$qd; $qa=-$qa;
    }
  }


  if ($det_r<0) {
    $r13=-$r13;
    $r23=-$r23;
    $r33=-$r33;
  }
  return($qa,$qb,$qc,$qd)
}  


sub usage {
  print "\n\nUsage:  $0 [-d] [-tra] [-tmp] [-s] [-f] files.rec
-d[isplay] : display header parameters needed in nifti format
-tra:  use ([-1 0 0][0 -1 0][0 0 1]) as rotation matrix. All non-transversal
     Volumes will be reformated to transversal orienttion. (Faster than -tms)
-id: as -tra (please do no longer use!)
-tms:use identity as rotation matrix. All Volumes will be reformated
     to transversal orienttion. World and Voxelspace identically!
-c[orrect_dyn]: old option for -s. Please use -s in future
-s[plit]: split multi hp, echo, diffusion, asl, and imagetype scans
     into different nii-files. If the scan was aborted, the number of dynamics will be corrected.
-vol:Dynamic scans will be stored with one file per volume
-f[orce]: Scans with more than one stack are not allowed to be converted with
     this program, since the output is useless. With -f a file will be
     created anyway.\n\n";
  my $eingabe;
  print "Press enter to exit";
  chomp($eingabe=<STDIN>);
  exit 0;
}

sub mydie{
  my $why=shift;
  chomp $why;
  print "\n\n\n\ !!! Program stopped due to an error.\nPlease verify output and if needed report errors.\n\n$why\n\n";
  my $eingabe;
  print "Press enter to exit";
  chomp($eingabe=<STDIN>);
  exit 0;
}

