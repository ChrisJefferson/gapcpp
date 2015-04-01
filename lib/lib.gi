#############################################################################
##
##
#W  yapb.gi                Ferret Package                Chris Jefferson
##
##  Installation file for functions of the Ferret package.
##
#Y  Copyright (C) 2013-2014 University of St. Andrews, North Haugh,
#Y                          St. Andrews, Fife KY16 9SS, Scotland
##


LoadPackage("io");


ReadPackage( "gapcpp", "lib/helper_functions.g" );

#############################################################################
##
##
##  <#GAPDoc Label="ConStabilize">
##  <ManSection>
##  <Heading>ConStabilize</Heading>
##  <Func Name="ConStabilize" Arg="object, action" Label="for an object and an action"/>
##  <Func Name="ConStabilize" Arg="object, n" Label="for a transformation or partial perm"/>
##  
##  <Description>
##  In the first form this represents the group which stabilises <A>object</A>
##  under <A>action</A>.
##  The currently allowed actions are OnSets, OnSetsSets, OnSetsDisjointSets,
##  OnTuples, OnPairs and OnDirectedGraph.
##
##  In the second form it represents the stabilizer of a partial perm
##  or transformation in the symmetric group on <A>n</A> points.
##
##  Both of these methods are for constructing arguments for the
##  <Ref Func="Solve" /> method.
##
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallMethod(ConstructMethod, [IsString, IsString, IsString, IsInt],
function(incode, retname, funcname, args)
  local outcode, stream, i;
  
  outcode := "";
  
  stream := OutputTextString(outcode, true);

  PrintTo(stream, "#include \"gap_cpp_mapping.hpp\"\n");
  PrintTo(stream, incode,"\n");
  PrintTo(stream, "extern \"C\" {\n");
  
  PrintTo(stream, "Obj Func", funcname, "(Obj self");
  for i in [1..args] do
    PrintTo(stream, ", Obj arg", String(i));
  od;
  
  PrintTo(stream, ") {\n");
  PrintTo(stream, "(void)self;\n");
  PrintTo(stream, "try {\n");
  PrintTo(stream, "return GAP_make(", funcname, "(");
  for i in [1..args] do
    if i > 1 then PrintTo(stream, ", "); fi;
    PrintTo(stream, "GAP_convertor(arg", String(i),")");
  od;
  PrintTo(stream, "));\n");
  PrintTo(stream, "} catch(const GAPException& e) {\n");
  PrintTo(stream, "Pr(e.what(), 0, 0);\n");
  PrintTo(stream, "return Fail;\n");
  PrintTo(stream, "}\n");
  
  PrintTo(stream, "}\n");
  
  PrintTo(stream, "static StructGVarFunc GVarFuncs [] = {\n");
  PrintTo(stream, "{ \"",retname,"\",",
                  String(args),
                  ", \"...\", ",
                  "(UInt**(*)())Func",funcname,
                  ", \"...\" }, {0} };\n");
  
  PrintTo(stream, "static Int InitKernel (StructInitInfo* module)\n");
  PrintTo(stream, "{ (void)module; InitHdlrFuncsFromTable( GVarFuncs ); return 0; }\n");
  
  PrintTo(stream, "static Int InitLibrary(StructInitInfo* module)\n");
  PrintTo(stream, "{ (void)module; InitGVarFuncsFromTable( GVarFuncs ); return 0; }\n");

  PrintTo(stream,
  "static StructInitInfo module = {\n",
  "#ifdef EDIVSTATIC\n",
  " /* type        = */ MODULE_STATIC,\n",
  "#else\n",
  " /* type        = */ MODULE_DYNAMIC,\n",
  "#endif\n",
  " /* name        = */ \",funcname,\",\n",
  " /* revision_c  = */ 0,\n",
  " /* revision_h  = */ 0,\n",
  " /* version     = */ 0,\n",
  " /* crc         = */ 0,\n",
  " /* initKernel  = */ InitKernel,\n",
  " /* initLibrary = */ InitLibrary,\n",
  " /* checkInit   = */ 0,\n",
  " /* preSave     = */ 0,\n",
  " /* postSave    = */ 0,\n",
  " /* postRestore = */ 0,\n",
  " /* filename    = */ 0,\n",
  " /* isGapRootRelative = */ 0\n",
  "};\n",
  "\n",
  "#ifndef EDIVSTATIC\n",
  "StructInitInfo * Init__Dynamic ( void )\n",
  "{\n",
  " return &module;\n",
  "}\n",
  "#endif\n",
  "\n",
  "StructInitInfo * Init__ediv ( void )\n",
  "{\n",
  "  return &module;\n",
  "}\n",
  "}\n");
  
  
  return outcode;
end);

_GAPCPP_Method := 1;

InstallMethod(CompileMethod, [IsString, IsString, IsInt],
function(incode, funcname, args)
  local compilecode, script, ret, splitout, errorout, retname;
  
  _GAPCPP_Method := _GAPCPP_Method + 1;
  
  retname := Concatenation("_GAPCPP_Import", String(_GAPCPP_Method));
  compilecode := ConstructMethod(incode, retname, funcname, args);  
  script := Filename(DirectoriesPackageLibrary("gapcpp"), "../build_lib.sh");  
  ret := IO_PipeThroughWithError_local(script, [], compilecode);
  
  
  if ret.status.status <> 0 then
    Error(Concatenation("Failed to compile!\n","stderr = ",ret.err,
                              "\n stdout = ",ret.out));
    return ret;
  else
    if ret.err <> "" then
      Info(InfoGAPcpp, 2, ret.err);
    fi;
    splitout := SplitString(ret.out, "\n");
    LoadDynamicModule(Concatenation(splitout[Size(splitout)], "/source.so"));
    return EvalString(retname);
  fi;
end);

#E  files.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
