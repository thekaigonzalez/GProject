extern (C) int system(const char*);

import std.stdio;
import std.file;
import std.string;
import std.array;

import lib.gmacro;

int loader(string[] args) {
                SGMacroFile sgmf = new SGMacroFile("GSub");
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
                    if (args[1] == "-stricttags") {
                        writeln("gproject-load: Couldn't find the FLAGS macro, is this a project macro file?");
                        return -1;
                        
                    } else {
                        writeln("gproject-load: pretending there are no flags required.");
                        flags = "";
                    }
                    
                }
                string[] srcs = gmap.getonce("SRC");
                if (srcs[0] == "NULL") {
                        writeln("gproject-load: pretending there are no sources.");
                        srcs = [];
                }
                string[] subs = gmap.getonce("SUBMODS");
                if (subs[0] == "NULL") {
                    writeln("gproject-load: ignoring submods.");
                    subs = [];
                }

                writeln("gproject-load: Got project information");
                
                writeln("Compiler: "~compilerdata);
                writeln("Flags: "~flags);
                write("Sources: ");
                writeln(srcs);
                write("Sub Modules: ");
                writeln(subs);

                writeln("gproject: Is this correct?");
                write("y/n ? ");
                string inp = readln();
                if (inp == "y\n") {
                    foreach (string source; srcs) {
                        if (source == "NULL") continue;
                        else {
                            writeln("building source "~source);
                            system((compilerdata~" "~flags~" "~source).toStringz());
                        }
                    }
                    writeln("gproject: Running submodules...");
                    foreach (string sub; subs) {
                        writeln("gproject-submod: entering directory - "~sub);
                        try {
                            chdir(sub);
                            loader(args);
                        } catch (Exception e) {

                        }
                    }
                } else {
                    writeln("Ok. Project cancelled!");
                }
                return 0;
}

int main(string[] args) {
    if (args.length == 2) {
        if (args[1] == "-help" || args[1] == "help") {
            writeln("usage: "~args[0]~" [-help] [-version] [run]");
        }
    } 
    if (args.length == 2) {
        if (args[1] == "run") {
            writeln("gproject-load: Loading ...");
            writeln("gproject-load: Checking for GProject ...");
            if ("GProject".exists) {
                
                writeln("gproject-load: Building ...");
                
                /// Use SGMacroFile API to load a file.
                SGMacroFile sgmf = new SGMacroFile("GProject");
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
                    if (args[2] == "-stricttags") {
                        writeln("gproject-load: Couldn't find the FLAGS macro, is this a project macro file?");
                        return -1;
                        
                    } else {
                        writeln("gproject-load: pretending there are no flags required.");
                    }
                    
                }
                string[] srcs = gmap.getonce("SRC");
                if (srcs[0] == "NULL") {
                        writeln("gproject-load: pretending there are no sources.");
                        srcs = [];
                    
                }
                string[] subs = gmap.getonce("SUBMODS");
                if (subs[0] == "NULL") {
                    writeln("gproject-load: ignoring submods.");
                    subs = [];
                }

                writeln("gproject-load: Got project information");
                
                    foreach (string source; srcs) {
                        if (source == "NULL") {
                            continue;
                        }
                        writeln("building source "~source);
                        system((compilerdata~" "~flags~" "~source).toStringz());
                    }
                    writeln("gproject: Running submodules...");
                    foreach (string sub; subs) {
                        writeln("gproject-submod: entering directory - "~sub);
                        try {
                            if (sub == "NULL") {
                                continue;
                            }
                            chdir(sub);
                            loader(args);
                        } catch (Exception e) {
                            writeln("gproject-load: Submodule not found.");
                        }
                    }
                }

            } else {
                writeln("GProject Failed.");
                return -1;
            }
        }
    return 0;
}
