#############################################################################
##
##
#W  yapb.gd                Ferret Package                Chris Jefferson
##
##  Declaration file for functions of the Ferret package.
##
#Y  Copyright (C) 1999,2001 University of St. Andrews, North Haugh,
#Y                          St. Andrews, Fife KY16 9SS, Scotland
##


###########################################################################
##
##

DeclareInfoClass("InfoGAPcpp");
SetInfoLevel(InfoGAPcpp, 2);

DeclareOperation("ConstructMethod", [IsString, IsString, IsString, IsInt]);

DeclareOperation("CompileMethod", [IsString, IsString, IsInt]);



#E  files.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
