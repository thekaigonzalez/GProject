extern (C) int system(const char*);

import std.stdio;
import std.file;
import std.string;
import std.array;

import lib.gmacro;

int main(string[] args) {
    if (args.length == 2) {
        if (args[1] == "-help" || args[1] == "help") {
            writeln("usage: "~args[0]~" [-help] [-version] [run|build|configuration|debug]");
        }
    } 
    if (args.length == 3) {
        if (args[1] == "run") {
            string projname = args[2];
            writeln("gproject-load: Loading "~projname~"...");
            writeln("gproject-load: Checking for "~projname~".gm ...");
            if (projname~".gm".exists) {
                
                writeln("gproject-load: Building "~projname~"...");
                
                /// Use SGMacroFile API to load a file.
                SGMacroFile sgmf = new SGMacroFile(projname~".gm");
                auto projinfo = sgmf.parseOnce();
                if ("none" in projinfo) {
                    writeln("Error: Problem loading file.\n err: expected COMPILER, got NONE!");
                    return -1;
                }
                /// pass project info into Argument handler
                GM_ArgPasser gmap = new GM_ArgPasser(projinfo);
                string[] compilermacro = gmap.getonce("COMPILER");
                if (compilermacro[0] == "NULL") {
                    writeln("gproject-load: Couldn't find the COMPILER macro, is this a project macro file?");
                    return -1;
                }
                string compilerdata = compilermacro[0]; // first argument
                string[] flagsargs = gmap.getonce("FLAGS");
                string flags = flagsargs[0];
                if (flagsargs[0] == "NULL") {
                    writeln("gproject-load: Couldn't find the FLAGS macro, is this a project macro file?");
                    return -1;
                }
                string[] srcs = gmap.getonce("SRC");
                if (srcs[0] == "NULL") {
                    writeln("gproject-load: Couldn't find the SRC macro, is this a project macro file?");
                    return -1;
                }
                

                writeln("gproject-load: Got project information");
                
                writeln("Compiler: "~compilerdata);
                writeln("Flags: "~flags);
                write("Sources: ");
                writeln(srcs);

                writeln("gproject: Is this correct?");
                write("y/n ? ");
                string inp = readln();
                if (inp == "y\n") {
                    foreach (string source; srcs) {
                        writeln("building source "~source);
                        system((compilerdata~" "~flags~" "~source).toStringz());
                    }
                } else {
                    writeln("Ok. Project cancelled!");
                }
            } else {
                writeln("gproject-load: couldn't find a "~projname~".gm file in the current directory.");
                return -1;
            }
        }
    }
    return 0;
}