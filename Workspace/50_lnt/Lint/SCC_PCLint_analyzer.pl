##\page           PCLint_analyzer_pl_HEAD                      File Header  -  PCLint_analyzer.pl
##################################################################################################
#
# \copyright <b>COPYRIGHT &copy; CONTINENTAL AUTOMOTIVE GMBH</b>
# \copyright <b>ALLE RECHTE VORBEHALTEN - ALL RIGHTS RESERVED</b>
# \copyright The reproduction, transmission or use of this document or its                      \n
#            contents is not permitted without express written authority                        \n
#            Offenders will be liable for damages                                               \n
#            All rights, including rights created by patent grant or                            \n
#            registration of a utility model or design, are reserved.
#
#
##################################################################################################
#
# \b Project:       Speed_4_0
#
##################################################################################################
#
# <b>Information automatically provided by IMS:</b>
#
#  $ProjectName: /PS/Algorithm_Generic/TESTING/10_Environment/80_Lint/Lint/project.pj $
#
##################################################################################################
#
# <b> File Information: </b>
#  $Author: Goepelt, Daniel (uid09574) $
#  $Date: 2020/02/19 16:49:49CET $
#  $Source: SCC_PCLint_analyzer.pl $
#  $Revision: 1.1 $
#  $State: released $
#
##################################################################################################
#
#  \b PURPOSE:  This perl script generates an excel report which documents the PCLint
#               messages and the PCLint suppressions.
#
##################################################################################################
#
# \remarks      [e.g. design constrains ...]
#
##################################################################################################
#
# <b> CHANGE HISTORY: </b>                                                                      \n
#   Log of all revisions so far:                                                                \n
#   $Log: SCC_PCLint_analyzer.pl  $ \n
#   Revision 1.1 2020/02/19 16:49:49CET Goepelt, Daniel (uid09574)  \n
#   Initial revision \n
#   Member added to project /PS/OSIS_SW_PMG/07_Tool_Data/PC-Lint_9_Scripts/project.pj \n
#   Revision 1.3 2019/02/13 18:09:19CET Centea, Razvan (uidl6365)  \n
#   > Update naming of the lint result file to match CI expectation \n
#   Revision 1.2 2019/02/13 11:25:34CET Doroiman, Octavian (uidm9677)  \n
#   checksum check for .lnt files updated \n
#   Revision 1.1 2016/03/15 10:42:02CET Kaiser, Christian (uid08381)  \n
#   Initial revision \n
#   Member added to project /PS/SPEED_4_0/20_Engineering/20_SW/30_Environment/Generic/Lint/project.pj \n
#   Revision 1.3 2015/09/23 09:57:20CEST Kaiser, Christian (uid08381)  \n
#   reworked for lean-reporing mode \n
#   Revision 1.2 2015/08/26 16:36:25CEST Kaiser, Christian (uid08381)  \n
#   this revision splits up header and C-file related messages \n
#   Revision 1.1 2013/05/21 13:20:33CEST uid13117  \n
#   Initial revision \n
#   Member added to project /PS/SPEED_2_0/20_Engineering/20_SW/30_Environment/Lint/project.pj \n
#   Revision 1.1 2013/04/26 13:01:37CEST Biskup, Axel (uid10618)  \n
#   Initial revision \n
#   Member added to project /PS/OSIS_Tools/SW/Installed_for_direct_use/Test_Tools/project.pj \n
#
#################################################################################################/

use strict;

# Following lines are interpreeted by Per2Exe:

# !! The lib file "lib/File/Temp.pm" needs to be edited to compile this file:
# comment the following line:
# require VMS::Stdio if $^O eq 'VMS';

#perl2exe_include "Tie/Hash/NamedCapture.pm";
#perl2exe_include "Spreadsheet/ParseExcel.pm";
#perl2exe_include "Spreadsheet/ParseExcel/SaveParser.pm";

use Spreadsheet::ParseExcel::SaveParser;
use Cwd;

if ( $#ARGV != 3 ) 
{
	print STDERR "SCC_PCLintAnalyser.pl: Please update the commandline call of your buildspecs pclinnt_Integrator and pclinnt_Developer!\n";
	print STDERR "Commandline options: perl SCC_PCLintAnalyser.pl <integrator_run=0|1> <location_of_project_lit_dir> <path_to_test_object>\n";
	print STDERR "You can copy below the corresponding lines and paste it into your windriver Build Properties dialog as Command.\n";
	print STDERR "COPY-PASTE FOLLOWING LINE for pclinnt_Integrator:\n";
	print STDERR " echo \"Executing integrator\'s PCLint Version and option check\";  perl \$(ENV_DIR)/Generic/Lint/SCC_PCLint_analyzer.pl  1  \$(ENV_DIR)/Project/Lint/lnt  %InFile%  0\n";
	print STDERR "COPY-PASTE FOLLOWING LINE for pclinnt_Developer:\n";
	print STDERR " echo \"executing lint for  %InFile%\" ; \$(LINT_COMMAND) %Includes% %Defines% %InFile% >%InFile%.txt;  perl \$(ENV_DIR)/Generic/Lint/SCC_PCLint_analyzer.pl  0  \$(ENV_DIR)/Project/Lint/lnt  %InFile%  0\n";
	print STDERR "ATTENTION: you need to make sure that for every *.lnt file, the corresponding *.checksum file is available on the same folder as the *.lnt file\n";
	print STDERR "Checksum files for generic *.lnt files may need to be linked form /PS/OSIS_SW_PMG/07_Tool_Data/Lint in case they are missing\n";
	print STDERR "Checksum files for project *.lnt files will need to be created with pclinnt_Integrator and checked in.\n";
	exit 1;
}

#integrator run (checksum generation)
my $integrator_run = $ARGV[0];

#path to *.lnt files
my $lint_dir = $ARGV[1];

#name of the file to be tested
my $test_object = $ARGV[2];

#name and path of the project analized
my $project = "project.lnt";

my $reduced_Mode = 1;

my %MonthMap = ( 0 => 'January', 1 => 'February', 2 => 'March', 3 => 'April',
                 4 => 'May', 5 => 'June', 6 => 'July', 7 => 'August',
                 8 => 'September', 9 => 'October', 10 => 'November', 11 => 'December' );


###########declaration of used variables for the checksum calculation##########

my $Suppression_Checker_Version = "2.0";
my $lint_analisys = 1;

##### declaration of variables used for PCLint suppression ###############

my $month;
my $rev;

my $suppression     = "lint";
my $result_file     = "$test_object.xls";
my $line_start;
my $file_name;

#offset due to numbering in perl. line number in C file starts from 1 but array member number in perls starts from 0.
my $offset = 1;

#Declaration of used variables for the PCLint Refiner#######
my $raw_lint_var;
my @sort_lint_array = ();
my $t;
my $functionality;
my $module;
my $line_no;
my $message_type;
my $message_no;
my $temp_message_no;
my $misra_type;
my $misra_no;
my $message_body;
my $required = "MISRA";
my $comment = 0;

#################end of declaration######################

if ( $integrator_run eq 1 ) # integrator run - checksum generation
{
	# generate checksum files
	&versionCheck("generate"); 
	print "Checksum files are generated. Now you can consider to checkin the generated *.checksum files in case the content has changed.\n";
	print STDERR "Please CHECK THOUROGHLY IF YOU really want to check in, because some files are linked to several projects!\n";
	# no further processing required in that mode
	exit 0;
}
else # Developer Run - Checksum verification
{
	&versionCheck("verify"); 

	if ( $lint_analisys eq 1 ) # message parser and excel sheet generation
	{
        # $file_name = substr( $test_object, ( rindex( $ARGV[3], "/" ) + 1 ) );
        $file_name = $test_object;
		$file_name =~ s/.+\///g;
		my $workbook   = Spreadsheet::WriteExcel->new($result_file);
		my $worksheet2 = $workbook->add_worksheet('PCLint_Message');
		my $worksheet  = $workbook->add_worksheet('PCLint_Suppression');

		# set column width

		# Set up some formats
		my %heading = (
			bold     => 1,
			pattern  => 1,
			bg_color => 'yellow',
			border   => 0,
			align    => 'left',
		);

		my $heading = $workbook->add_format(%heading);

		$worksheet->set_column( 'A:A', 30 );
		$worksheet->set_column( 'B:B', 120 );
		$worksheet2->set_column( 'A:A', 120 );
		$worksheet2->set_column( 'B:B', 20 );
		$worksheet2->set_column( 'F:F', 12 );
		$worksheet2->set_column( 'H:H', 90 );

		$worksheet->write( 1, 0, 'Continental Automotive AG',  $heading );    #print OUTFILE ("Continental Automotive AG\n");
		$worksheet->write( 2, 0, "PCLint Suppression Checker", $heading );
		$worksheet->write_string( 2, 1, "$Suppression_Checker_Version" );
		my @timedata = localtime(time);
		join( ' ', @timedata );
		my $second  = $timedata[0];
		my $minute  = $timedata[1];
		my $hour    = $timedata[2];
		my $day     = $timedata[3];
		my $month   = getMonth($timedata[4]);
		my $year = $timedata[5] + 1900;
		$worksheet->write( 3, 0, "Current time", $heading );
		$worksheet->write( 3, 1, "$hour:$minute:$second" );
		$worksheet->write( 4, 0, "Current date", $heading );
		$worksheet->write( 4, 1, "$month $day $year" );
		$worksheet->write( 5, 0, "File",         $heading );
		$worksheet->write( 5, 1, "$file_name" );

		#search in every c file for the lint suppression
		my $analize_file = $test_object;
		$analize_file =~ s/\//\\/g;

		my $no_suppression = 0;
		open( FILE, $analize_file ) or die "Unable to open file!";
		my $cfile = join "", <FILE>;
		my @lines = split( /\n/, $cfile );

		# add revision information in the report
		for ( my $index = 0 ; $index < (@lines) ; $index++ )
		{
			if ( $lines[$index] =~ /\$Revision\:\s+(?<RevStr>[0-9\.]+)/ )
			{
				# (?<FuncHandle>0x[0-9A-F]{1,2})
				#  *  $Revision: 1.1 $

				$rev = $+{RevStr};

				$worksheet->write( 6, 0, "Revision", $heading );
				$worksheet->write_string( 6, 1, "$rev" );
				$worksheet->write( 7, 0, " " );
				$worksheet->write( 8, 0, " " );

				# $index = (@lines)+2;

				last;
			}
		}

		$worksheet->write( 9, 0, "Codeline ", $heading );
		$worksheet->write( 9, 1, "Message ",  $heading );
		my $col = 10;

		#my $line = 0
		for ( my $i = 0 ; $i < (@lines) ; $i++ )
		{
			if ( $lines[$i] =~ m/$suppression/ )
			{
				if ( $lines[$i] =~ m/\-e/ )
				{

					#if the suppresion mark is found then the line is copied to the report file
					my $codeline = $i + $offset;
					$no_suppression = 1;
					$worksheet->write( $col, 0, $codeline );
					$line_start = index( $lines[$i], "/" );

					#print ("$line_start\n") ;
					if ( $line_start > 0 )
					{
						$worksheet->write( $col, 1, substr( $lines[$i], $line_start ) );
					}
					else
					{
						$worksheet->write( $col, 1, $lines[$i] );
					}
					$col = $col + 1;
				}
				elsif ( $lines[$i] =~ m/\+e/ )
				{

					#if the suppresion mark is found then the line is copied to the report file
					my $codeline = $i + $offset;
					$no_suppression = 1;
					$worksheet->write( $col, 0, $codeline );
					$line_start = index( $lines[$i], "/" );
					if ( $line_start > 0 )
					{
						$worksheet->write( $col, 1, substr( $lines[$i], $line_start ) );
					}
					else { $worksheet->write( $col, 1, $lines[$i] ); }
					$col = $col + 1;
				}
			}
		}

		close(FILE);
		if ( $no_suppression == 0 ) { $worksheet->write( $col, 0, "No PCLint message is suppressed" ); }

		# import in the xls report the PCLint report

		$worksheet2->activate('PCLint_Message');

		open( REPORT, "${test_object}" ) or die "Unable to open file: ${test_object} !";
		my $raw_lint_var = join "", <REPORT>;
		
		print "$raw_lint_var";
		
		my @sort_lint_array = split( /\n/, $raw_lint_var );
		$worksheet2->write( 1, 0, "Continental Automotive AG",          $heading );
		$worksheet2->write( 2, 0, "MISRA and Coding Guidelines Report", $heading );
		$worksheet2->write( 3, 0, "Current time",                       $heading );
		$worksheet2->write_string( 3, 1, "$hour:$minute:$second" );
		$worksheet2->write( 4, 0, "Current date", $heading );
		$worksheet2->write_string( 4, 1, "$month $day $year" );
		$worksheet2->write( 5, 0, "File", $heading );
		$worksheet2->write_string( 5, 1, "$file_name" );
		$worksheet2->write( 6, 0, "Revision", $heading );
		$worksheet2->write_string( 6, 1, "$rev" );

		$worksheet2->write( 8, 0, "Functionality",     $heading );
		$worksheet2->write( 8, 1, "Module",            $heading );
		$worksheet2->write( 8, 2, "Code Line",         $heading );
		$worksheet2->write( 8, 3, "Message Type",      $heading );
		$worksheet2->write( 8, 4, "Message Number",    $heading );
		$worksheet2->write( 8, 5, "Rule Type",         $heading );
		$worksheet2->write( 8, 6, "MISRA Rule Number", $heading );
		$worksheet2->write( 8, 7, "Messasge body",     $heading );

        my $offset = 9;
        my $outputCnt = $offset;

		#open(REFINED,">$ARGV[1]") or die "Unable to open file!";
		for ( $t = 0 ; $t < (@sort_lint_array) - 1 ; $t++ )
		{

			# Following lines will be parsed:
			# D:\SW\BMW\C1_BL32.4.0_20130410\50_Implementation\Source\Speed_2_0\AB_BSW\HAL\CODE\Global\HW_LIMITS\HL_M720.h:242:43: Note 962: Macro 'HL_uw_SYC_EVZ_MAX' defined identically at another location (line 122)
			# D:\SW\BMW\C1_BL32.4.0_20130410\50_Implementation\Source\Speed_2_0\AB_BSW\HAL\CODE\Global\HW_LIMITS\HL_M720.h:122:1: Info 830: Location cited in prior message
			
			if ( $sort_lint_array[$t] =~ /(?<Path>[a-z]\:.+)\\(?<Module>[a-z0-9_\.]+)\:(?<Line>[0-9]+\:[0-9]+)\:\s(?<Type>[a-z]+)\s(?<Number>[0-9]+)\:\s(?<Description>.+)/ig )
			{
				$functionality = $+{Path};
				$module        = $+{Module};
				$line_no       = $+{Line};
				$message_type  = $+{Type};
				$message_no    = $+{Number};
				$message_body  = $+{Description};
                $misra_type = "Non MISRA";
                $misra_no = "-";
                
                if ( $message_body =~ /Violates MISRA 20[0-9]{2}( Required)? Rule (?<MisraNo>[0-9\.]+),\s*(?<MisraDescription>.+$)/ig )
                {
                    $misra_type = "MISRA";
                    $misra_no = $+{MisraNo};
                    $message_body = $+{MisraDescription};
                }

				$worksheet2->write_string( $outputCnt, 0, $functionality );
				$worksheet2->write_string( $outputCnt, 1, $module );
				$worksheet2->write_string( $outputCnt, 2, $line_no );
				$worksheet2->write(        $outputCnt, 3, $message_type );
				$worksheet2->write(        $outputCnt, 4, $message_no );
				$worksheet2->write(        $outputCnt, 5, $misra_type );
				$worksheet2->write(        $outputCnt, 6, $misra_no );
				$worksheet2->write(        $outputCnt, 7, $message_body );
				$outputCnt++;
			}
		}

		close(REPORT);
		
	}
}


sub versionCheck
{
	my $command = $_[0];
	
	# first handle checksum for project.lnt
	&checksumFileRun ( $command, $project );
	
	open( PROJECT, "${lint_dir}/${project}" ) or die "Unable to open file: ${lint_dir}/${project}.";
	$comment = 0;
	# scan through all *.lnt file which are included by project.lnt
    while ( my $Row = <PROJECT> )
    {
        chomp($Row);
		
		#skip all kind of comments before handling any line 
		$Row = &eraseComments($Row);

		if ($Row =~ /.+\.lnt\s*.*/i)
		{
			&checksumFileRun($command, $Row);
		}
    }
	close ( PROJECT );
}

sub eraseComments
{
	my $Row = $_[0];

	$Row =~ s/\/\/.+$//g;
	$Row =~ s/\/\*.+\*\///g;
	$Row =~ s/\s+$//g;
	$Row =~ s/\s+/ /g;

	if ($Row =~ /\/\*/ )
	{
		$comment = 1;
		$Row =~ s/\/\*.+$//g;
	}
	if ($Row =~ /.+\*\// )
	{
		$comment = 0;
		$Row =~ s/.+\*\///g;
	}
	if ($comment == 1)
	{
		next;
	}
	return $Row;
}


sub checksumFileRun
{
	my $command = shift(@_);
	my $filename = shift(@_);
	my $goldenChecksumFileName;
	my $calculatedChecksumFileName;
	my $dir = getcwd;
	my $org_chms;
	my @new_chms;
	my @lnt_array = ();
	# print "Generate checksum for: ${lint_dir}\\$filename\n";  
	open( LNT_FILE, "${lint_dir}\\$filename" ) or die "Unable to open file ${lint_dir}\\$filename!";
	# my $lnt_content = join "", <LNT_FILE>;
	my $lnt_content;
	my @lnt_content_array = <LNT_FILE>;
	
	$comment = 0;
	
	for my $line ( @lnt_content_array )
	{
		$line = &eraseComments($line);
		$lnt_content = "${lnt_content}${line}";
	}

	# $lnt_content =~ s/\s+/ /g;
	@lnt_array = split( //, $lnt_content );
	close(LNT_FILE);
	$goldenChecksumFileName = "${lint_dir}\\$filename";
	$goldenChecksumFileName =~ s/\.lnt/.checksum/;
	if ($command eq "generate")
	{
		print CHECKSUM_FILE_LIST "$filename\n";
					
		open( CHECKSUM_FILE, ">$goldenChecksumFileName" ) or die "Unable to open file $goldenChecksumFileName!";
		print CHECKSUM_FILE &calcChecksum( \@lnt_array );
		close (CHECKSUM_FILE);
		print "Generated checksum file: $goldenChecksumFileName\n";
	}
	elsif ($command eq "verify")
	{	
		$calculatedChecksumFileName = $goldenChecksumFileName;
		$calculatedChecksumFileName =~ s/.+\\//g;		
		$calculatedChecksumFileName = "./${calculatedChecksumFileName}";
		$calculatedChecksumFileName =~ s/\.lnt/.checksum/;
		
		open( CHECKSUM_FILE, "$goldenChecksumFileName");
		$org_chms = &calcChecksum( \@lnt_array );
		@new_chms = <CHECKSUM_FILE>;

		if ( "$org_chms" ne $new_chms[0] )
		{
			$filename =~ s/\s+//g;
			print STDERR "ERROR: Checksum of a lint configuration file is not matching ($filename): \nOriginal checksum='$org_chms'\nCalculated checksum='${new_chms[0]}'\n";
			exit 1;
		}
		close (CHECKSUM_FILE);
	}
	else
	{
		print STDERR "incorrect command!\n";
		exit 1;
	}
	
	@lnt_array = ();
}


sub calcChecksum
{
    my $lnt_array = shift(@_);
	my $checksum = 0;
	my $temp;
	for ( my $i = 0 ; $i < (@{$lnt_array}) ; $i++ )
	{
		if ( $lnt_array->[$i] eq "" )
		{
			#do not consider empty lines
		}
		else
		{
			# convert the character into hex value
			$temp = unpack( "H*", $lnt_array->[$i] );

			#calculate the checksum
			$checksum = $checksum + ( hex($temp) + ( $i + 1 ) );
		}
	}
	# print  "Value: $checksum\n";
	return $checksum
}

sub getMonth
{
    if ( $_[0] > 11 )
    {
        return "Invalid month";
    }
    else
    {

        return $MonthMap{$_[0]};
    }
}