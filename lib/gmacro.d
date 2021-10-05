module lib.gmacro;
/**

Copyright (C) 2021 Kai D. Gonzalez

 This file is part of GMacro.

 GMacro is free software: you can redistribute it and/or
 modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
 either version 3 of the License, or (at your option) any later version.

 GMacro is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with GMacro. If not, see http://www.gnu.org/licenses/.

*/
import std.stdio;
import std.algorithm;
import std.file;
import std.string;
import std.conv;
import std.array;

/**
The main Parser Class
*/
class GM_Parser {
    /// All of the stuff to be returned.
        string[string] all_stuff;
        string pkey; /// ....
public:
        this(string p) {
        pkey=p;
        }
    string[string] defineonce() {
        string[] each_statement = pkey.split(";");
        foreach(string stat; each_statement) {
            if (stat.startsWith("#")) {
                            continue;
            }
            if (stat.length > 1 && !startsWith(stat, ";")) {
                string fname = stat[0 .. stat.indexOf("(")];
                string fargs = stat[stat.indexOf("(")+1 .. stat.indexOf(")")];
                fargs = fargs.strip();
                fname = fname.strip();
                if (fname in all_stuff) {
                    writeln("warning:gmacro.d:47: same property defined twice");
                }
                all_stuff[fname] = fargs;
            }
        }
            return all_stuff;
    }
}

class GM_ArgPasser {
    string[string] pass;
public:
    this(string[string] psu) {
        pass = psu;
        }
    string[] getonce(string func) {
        if (func in pass) {
            return pass[func].split(",");
        } else {
            return ["NULL"];
        }
        }
}

class SGMacroFile {
    string fname;
public:
    this(string fnile) {
        fname=fnile;
        }
    string[string] parseOnce() {
        if (!fname.exists) {
            writeln("GMacro: Couldn't open input file.");
            return ["none": "ERROR"];
                }
        File f = File(fname, "r");
        string cpp;

        while (!f.eof()) {
            string l = f.readln();
            if (l.length > 1)
                cpp = cpp~l;
                }
        return new GM_Parser(cpp).defineonce();
        }
}
