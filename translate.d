#!/usr/bin/env -S dub

/+ dub.sdl:
name "translate"
dependency "sily" version="~>4.0.0"
dependency "sily:sdlang" version="~>4.0.0"
targetType "executable"
targetPath "bin/"
+/

import std.stdio;
import std.array;
import std.algorithm.searching;
import std.conv : to;
import std.string;

import sily.sdlang;
import sily.file;
import sily.path;
import sily.array;

void main() {
    string readmeIn = readFile(buildAbsolutePath("./readme.sdl"));
    string readme = "";

    SDLNode[] sdl = parseSDL(readmeIn, true);

    foreach (node; sdl) {
        readme ~= handle_any(node);

        readme ~= "\n";
    }

    File f = File(buildAbsolutePath("./README.md"), "w");
    f.write(readme);
    f.close();
}

string handle_children(SDLNode node) {
    string o = "";
    if (node.children.length > 0) o ~= "\n\n";
    foreach (child; node.children) {
        o ~= handle_any(child);
    }
    if (node.children.length > 0) o ~= "\n";
    // return "<!-- UNDEFINED -->";
    return o;
}

string handle_any(SDLNode node) {
    if (node.name == "hr") return "<" ~ node.name ~ ">";
    if (node.name == "br") return " \n";
    if (node.name == "content") {
        string[] values = node.getValues!string(SDLString);
        string text = values.join("\n");
        return text;
    }

    if (node.name == "shield") {
        return handle_shield(node);
    }

    SDLAttribute[] attributes = node.attributes;
    string o = "";
    o ~= "<" ~ node.name ~ "";
    o ~= get_attr_string(attributes);
    o ~= ">";
    o ~= handle_children(node);
    o ~= "</" ~ node.name ~ ">\n";
    return o;
}

string handle_shield(SDLNode node) {
    SDLNode[] children = node.children;
    string o = "<img src='https://img.shields.io/";
    string type = "";
    string label = "";
    string color = "";
    string style = "";
    string link = "";
    string repo = "";
    string logo = "";
    string message = "";
    string logoColor = "";

    foreach (child; children) {
        string[] values = child.getValues!string(SDLString);
        string text = values.join(" ");
        switch (child.name) {
            case "type": type = text; break;
            case "label": label = text; break;
            case "style": style = text; break;
            case "color": color = text; break;
            case "link": link = text; break;
            case "repo": repo = text; break;
            case "logo": logo = text; break;
            case "logo_color": logoColor = text; break;
            case "message": message = text; break;
            default: break;
        }
    }

    if (label.length == 0) label = " ";

    if (type == "release") {
        o ~= "github/v/release/" ~ repo ~ "?";
    } else {
        o ~= "static/v1?";
    }

    if (logo.length != 0) o ~= "&logo=" ~ logo;
    if (color.length != 0) {
        if (color.startsWith("#")) {
            o ~= "&color=" ~ color[1..$];
        } else {
            o ~= "&color=" ~ color;
        }
    }
    if (logoColor.length != 0) {
        if (logoColor.startsWith("#")) {
            o ~= "&logoColor=" ~ logoColor[1..$];
        } else {
            o ~= "&logoColor=" ~ logoColor;
        }
    }
    if (style.length != 0) o ~= "&style=" ~ style;
    if (label.length != 0) o ~= "&label=" ~ label.replace(" ", "%20").replace(":", "%3A");
    if (message.length != 0) o ~= "&message=" ~ message.replace(" ", "%20").replace(":", "%3A");

    o ~= "' />";

    if (link.length != 0) o = "<a href='" ~ link ~ "'>" ~ o ~ "</a>";

    o ~= "\n";

    return o;
}

string get_attr_string(SDLAttribute[] attributes) {
    string o = "";
    foreach (attr; attributes) {
        switch (attr.value.kind) {
            case SDLString:
                o ~= " " ~ attr.name ~ "='" ~ attr.getValue!string ~ "'";
            break;
            default:
                string strval = attr.value.to!string();
                long pos = strval.indexOf(":");
                o ~= " " ~ attr.name ~ "=" ~ strval[pos + 2 .. $-1];
            break;
        }
    }
    return o;
}


