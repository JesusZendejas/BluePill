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
#  $Source: SCC_PCLint.pl $
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
#   $Log: SCC_PCLint.pl  $ \n
#   Revision 1.1 2020/02/19 16:49:49CET Goepelt, Daniel (uid09574)  \n
#   Initial revision \n
#   Member added to project /PS/OSIS_SW_PMG/07_Tool_Data/PC-Lint_9_Scripts/project.pj \n
#   Revision 1.2 2016/08/18 10:38:04CEST Kaiser, Christian (uid08381)  \n
#   reduced messages at build time \n
#   Revision 1.1 2016/07/04 14:15:35CEST Kaiser, Christian (uid08381)  \n
#   Initial revision \n
#   Member added to project /PS/SPEED_4_0/20_Engineering/20_SW/50_Implementation/Environment/Generic/Lint/project.pj \n
#
#################################################################################################/

use strict;

my $blacklist_name;
my $module_name;
my $line;
my $mode;
my @blacklist = ();

if ( ! defined( $blacklist_name = $ARGV[0] ) ||  ! defined( $mode = $ARGV[1] ) || ! defined( $module_name = $ARGV[2] ) )
{
    print "usage: perl $0 <blacklist_name>  < mode = build_mode | detailed_mode >   <module_name>\n";
    exit(2);
}   

open (BLACKLIST, "$blacklist_name")     || die "Can't open file $blacklist_name";
while (my $module_to_ignore = <BLACKLIST>)
{
  chomp ($module_to_ignore); 
  $module_to_ignore = quotemeta $module_to_ignore;

  if ( $module_name =~ /$module_to_ignore/i )
  {
    # not need to analyse this module, since it is part of the black list.
    # print "--> excluded form lint evaluation! Declared as 3rd party source.\n";
    if ( $mode ne "build_mode" )
    {
        last;
    }
    exit 0;
  }
}

my $build_state = 0;

# Process every line from STDIN until EOF
while ($line = <STDIN>) 
{ 
  if ( $line =~ / ((Error)|(Warning)) [0-9]+/ )
  {
    print $line;
    $build_state = 2;
  }
  elsif ($mode ne "build_mode")
  {
    print $line;
  }
}

if ( $build_state == 0 )
{
   # print "  No lint errors / warnings detected."
}

exit $build_state;
