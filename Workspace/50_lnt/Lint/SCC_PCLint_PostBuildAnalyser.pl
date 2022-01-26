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
# \b Project:       Speed_2_0
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
#  $Source: SCC_PCLint_PostBuildAnalyser.pl $
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
#   $Log: SCC_PCLint_PostBuildAnalyser.pl  $ \n
#   Revision 1.1 2020/02/19 16:49:49CET Goepelt, Daniel (uid09574)  \n
#   Initial revision \n
#   Member added to project /PS/OSIS_SW_PMG/07_Tool_Data/PC-Lint_9_Scripts/project.pj \n
#   Revision 1.1 2016/03/15 10:42:06CET Kaiser, Christian (uid08381)  \n
#   Initial revision \n
#   Member added to project /PS/SPEED_4_0/20_Engineering/20_SW/30_Environment/Generic/Lint/project.pj \n
#   Revision 1.2 2015/09/21 14:42:31CEST Kaiser, Christian (uid08381)  \n
#   updated heandling of message collection file: \n
#   Temp\Speed_3_0\pclinnt_Developer\PCLint_Header_Messages.txt \n
#   Revision 1.1 2015/09/16 07:12:14CEST Kaiser, Christian (uid08381)  \n
#   Initial revision \n
#   Member added to project /PS/SPEED_3_0/20_Engineering/20_SW/30_Environment/Generic/Lint/project.pj \n
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

my $PCLint_Header_Message_file   = $ARGV[0];


# Set up some formats
my %heading = (
    bold     => 1,
    pattern  => 1,
    bg_color => 'yellow',
    border   => 0,
    align    => 'left',
);
        

my %MonthMap = ( 0 => 'January', 1 => 'February', 2 => 'March', 3 => 'April',
                 4 => 'May', 5 => 'June', 6 => 'July', 7 => 'August',
                 8 => 'September', 9 => 'October', 10 => 'November', 11 => 'December' );

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



open( HEADER_MESSAGES, "$PCLint_Header_Message_file" ) or exit 0;
    
my @names = ();
my @values = ();  
my %HeaderMessageMap = ();  
my $key_index = 0;
my $path_index = 0;
        
my $Line = <HEADER_MESSAGES>;
chomp ($Line);

@names = split "\t", $Line;

for ( $key_index = 0; $key_index <= $#names; $key_index++ )
{
    if ( $names[$key_index] eq "Header File" )
    {
        last;
    }
}
for ( $path_index = 0; $path_index <= $#names; $path_index++ )
{
    if ( $names[$path_index] eq "Path" )
    {
        last;
    }
}
        
        
while ($Line = <HEADER_MESSAGES>)
{
	chomp ($Line);
    @values = split "\t", $Line;
    my %Message = ();
    
    for ( my $count = 0; $count <= $#names; $count++ )
    {
        if ($count != $key_index )
        {
            $Message{$names[$count]} = $values[$count];
        }
    }
    push @{ $HeaderMessageMap{$values[$key_index]}{"Record"}}, \%Message;
    $HeaderMessageMap{$values[$key_index]}{"Path"} = $values[$path_index];
}


my @timedata = localtime(time);
join( ' ', @timedata );
my $second  = $timedata[0];
my $minute  = $timedata[1];
my $hour    = $timedata[2];
my $day     = $timedata[3];
my $month   = getMonth($timedata[4]);
my $year = $timedata[5] + 1900;



for my $entry ( keys %HeaderMessageMap )
{
    my $Revision = "xx";
    my $reportfile = $HeaderMessageMap{$entry}{Path} . "\\" . $entry . ".xls";
    my $headerfile = $HeaderMessageMap{$entry}{Path} . "\\" . $entry;
    
    open( FILE, $headerfile ) or next; ## die "Unable to open file for checking Revision: $headerfile";
    my $hfile = join "", <FILE>;
    my @hlines = split( /\n/, $hfile );

    # add revision information in the report
    for ( my $index = 0 ; $index < (@hlines) ; $index++ )
    {
        if ( $hlines[$index] =~ /\$Revision\:\s+(?<RevStr>[0-9\.]+)/ )
        {
            #  *  $Revision: 1.1 $
            $Revision = $+{RevStr};
            last;
        }
    }
    close (FILE);

     
    print "Generate Lint Report for $reportfile\n";
    
    my $workbook   = Spreadsheet::WriteExcel->new($reportfile);
    my $heading = $workbook->add_format(%heading);
    my $worksheet = $workbook->add_worksheet('PCLint_Message');
    
	$worksheet->set_column( 'A:A', 120 );
	$worksheet->set_column( 'B:B', 20 );
	$worksheet->set_column( 'F:F', 12 );
	$worksheet->set_column( 'H:H', 90 );
    
	$worksheet->write( 1, 0, "Continental Automotive AG",          $heading );
	$worksheet->write( 2, 0, "MISRA and Coding Guidelines Report", $heading );
	$worksheet->write( 3, 0, "Current time",                       $heading );
	$worksheet->write_string( 3, 1, "$hour:$minute:$second" );
	$worksheet->write( 4, 0, "Current date", $heading );
	$worksheet->write_string( 4, 1, "$month $day $year" );
	$worksheet->write( 5, 0, "File", $heading );
	$worksheet->write_string( 5, 1, "$entry" );
	$worksheet->write( 6, 0, "Revision", $heading );
	$worksheet->write_string( 6, 1, "$Revision" );

	$worksheet->write( 8, 0, "Functionality",     $heading );
	$worksheet->write( 8, 1, "Module",            $heading );
	$worksheet->write( 8, 2, "Code Line",         $heading );
	$worksheet->write( 8, 3, "Message Type",      $heading );
	$worksheet->write( 8, 4, "Message Number",    $heading );
	$worksheet->write( 8, 5, "Rule Type",         $heading );
	$worksheet->write( 8, 6, "MISRA Rule Number", $heading );
	$worksheet->write( 8, 7, "Messasge body",     $heading );
    $worksheet->write( 8, 8, "Compiled C-file",   $heading );
    
    my $outputCnt = 9;
    
    for my $Rec ( @{$HeaderMessageMap{$entry}{Record}} )
    {
        # my %Record = %( $Rec );
        $worksheet->write_string( $outputCnt, 0, $Rec->{"Path"} );
        $worksheet->write_string( $outputCnt, 1, $entry );
        $worksheet->write_string( $outputCnt, 2, $Rec->{"Line Number"} );
        $worksheet->write(        $outputCnt, 3, $Rec->{"Message Type"} );
        $worksheet->write(        $outputCnt, 4, $Rec->{"Message Number"} );
        $worksheet->write(        $outputCnt, 5, $Rec->{"Misra Type"} );
        $worksheet->write(        $outputCnt, 6, $Rec->{"Misra Number"} );
        $worksheet->write(        $outputCnt, 7, $Rec->{"Message Body"} );
        $worksheet->write(        $outputCnt, 8, $Rec->{"Compiled File"} );
        $outputCnt++;
        
    }
    
}




