#
# gapcpp : Dynamically building C++ code in GAP
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "GAPcpp",
Subtitle := "Dynamically building C++ code in GAP",
Version := "0.0.1",
Date := "12/01/2015", # dd/mm/yyyy format

##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "0.0.1">
##  <!ENTITY RELEASEDATE "12 January 2015">
##  <#/GAPDoc>

Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Christopher",
    LastName := "Jefferson",
    WWWHome := "http://caj.host.cs.st-andrews.ac.uk/",
    Email := "caj21@st-andrews.ac.uk",
    PostalAddress := Concatenation(
               "St Andrews\n",
               "Scotland\n",
               "UK" ),
    Place := "St Andrews",
    Institution := "University of St Andrews",
  ),
],

PackageWWWHome := "http://ChrisJefferson.github.io/gapcpp/",

ArchiveURL     := Concatenation("https://github.com/gap-system/gapcpp/",
                                "releases/download/v", ~.Version,
                                "/gapcpp-", ~.Version),
README_URL     := Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),

ArchiveFormats := ".tar.gz",

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "dev",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "GAPcpp",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Search in finite permutation groups",
),

Dependencies := rec(
  GAP := ">= 4.6",
  NeededOtherPackages := [ [ "GAPDoc", ">= 1.5" ] ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [ ],
),

AvailabilityTest := function()
  return true;
end,

TestFile := "tst/testall.g",

#Keywords := [ "TODO" ],

));


