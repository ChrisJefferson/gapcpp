#############################################################################
##
##
#W  helper_functions.g                                        Chris Jefferson
##
##  This file contains a number of functions which I find of use. I share
##  this file amongst multiple packages, and will try to keep it in sync.
##  The name of the class is changed for each package, to deal with different
##  versions of packages
##
#Y  Copyright (C) 2014     University of St. Andrews, North Haugh,
#Y                          St. Andrews, Fife KY16 9SS, Scotland
##

_gapcppHelperFuncs := rec(

# Copies 'useroptions' over values of 'options' with the same name.
fillUserValues := function(options, useroptions)
  local name, ret;
  
  ret := rec();

  for name in RecNames(options) do
    if IsBound(useroptions.(name)) then
      options.(name) := useroptions.(name);
      Unbind(useroptions.(name));
    fi;
  od;
  
  if useroptions <> rec() then
    Error("Unknown options: ", useroptions);
  fi;
 end
 );
 
 ## This is a local copy of a function which will hopefully get added to
 ## io!
 
IO_PipeThroughWithError_local := 
 function(cmd,args,input)
   local byt,chunk,err,erreof,inpos,nr,out,outeof,r,s,w,status;

   # Start the coprocess:
   s := IO_Popen3(cmd,args,false,false,false);
   if s = fail then return fail; fi;
   # Switch the one we write to to non-blocking mode, just to be sure!
   IO_fcntl(s.stdin!.fd,IO.F_SETFL,IO.O_NONBLOCK);

   # Here we just do I/O multiplexing, sending away input (if non-empty)
   # and receiving stdout and stderr.
   inpos := 0;
   outeof := false;
   erreof := false;
   # Here we collect stderr and stdout:
   err := "";
   out := [];
   if Length(input) = 0 then IO_Close(s.stdin); fi;
   repeat
       if not(outeof) then
           r := [s.stdout];
       else
           r := [];
       fi;
       if not(erreof) then
           Add(r,s.stderr);
       fi;
       if inpos < Length(input) then
           w := [s.stdin];
       else
           w := [];
       fi;
       nr := IO_Select(r,w,[],[],fail,fail);
       if nr = fail then   # an error occurred
           if inpos < Length(input) then IO_Close(s.stdin); fi;
           IO_Close(s.stdout);
           IO_Close(s.stderr);
           return fail;
       fi;
       # First writing:
       if Length(w) > 0 and w[1] <> fail then
           byt := IO_WriteNonBlocking(s.stdin,input,inpos,Length(input)-inpos);
           if byt = fail then
               if LastSystemError().number <> IO.EWOULDBLOCK then
                   IO_Close(s.stdin);
                   IO_Close(s.stdout);
                   IO_Close(s.stderr);
                   return fail;
               fi;
           else
               inpos := inpos + byt;
               if inpos = Length(input) then IO_Close(s.stdin); fi;
           fi;
       fi;
       # Now reading:
       if not(outeof) and r[1] <> fail then
           chunk := IO_Read(s.stdout,4096);
           if chunk = "" then
               outeof := true;
           elif chunk = fail then
               if inpos < Length(input) then IO_Close(s.stdin); fi;
               IO_Close(s.stdout);
               IO_Close(s.stderr);
               return fail;
           else
               Add(out,chunk);
           fi;
       fi;
       if not(erreof) and r[Length(r)] <> fail then
           chunk := IO_Read(s.stderr,4096);
           if chunk = "" then
               erreof := true;
           elif chunk = fail then
               if inpos < Length(input) then IO_Close(s.stdin); fi;
               IO_Close(s.stdout);
               IO_Close(s.stderr);
               return fail;
           else
               Append(err,chunk);
           fi;
       fi;
   until outeof and erreof;
   status := IO_WaitPid(s.pid, true);
   # We have to unbind this here, as by default IO will do its own
   # IO_WaitPid when we close stdout.
   Unbind(s.stdout!.dowaitpid);
   IO_Close(s.stdout);
   IO_Close(s.stderr);
   return rec( out := Concatenation(out), err := err, status := status );
 end;