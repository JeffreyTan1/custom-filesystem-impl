#include <string>
#include <vector>
#include <iostream>
#include <sstream>
#include <fstream>
#include <iostream>
#include <stdio.h>
using std::rename;

using std::cout;
using std::endl;
using std::ifstream;
using std::istream;
using std::ofstream;
using std::ostream;
using std::string;
using std::stringstream;
using std::vector;

string FS;

int list();
int copyin(string EF, string IF);
int copyout(string IF, string EF);
int mkdir(string ID);
int rm(string IF);
int rmdir(string ID);
int defrag();
int index();
bool validPath(string IF);
bool unique(string str, string firstChar);

enum command_code
{
    eList,
    eCopyin,
    eCopyout,
    eMkdir,
    eRm,
    eRmdir,
    eDefrag,
    eIndex,
    eNone
};

command_code hashit(std::string const &inString)
{
    if (inString == "list")
        return eList;
    if (inString == "copyin")
        return eCopyin;
    if (inString == "copyout")
        return eCopyout;
    if (inString == "mkdir")
        return eMkdir;
    if (inString == "rm")
        return eRm;
    if (inString == "rmdir")
        return eRmdir;
    if (inString == "defrag")
        return eDefrag;
    if (inString == "index")
        return eIndex;

    return eNone;
}

int main(int argc, char **argv)
{
    FS = argv[2];

    switch (hashit(argv[1]))
    {
    case eList:
        return list();

    case eCopyin:
        return copyin(argv[3], argv[4]);

    case eCopyout:
        return copyout(argv[3], argv[4]);

    case eMkdir:
        return mkdir(argv[3]);

    case eRm:
        return rm(argv[3]);

    case eRmdir:
        return rmdir(argv[3]);

    case eDefrag:
        return defrag();

    case eIndex:
        return index();

    default:
        break;
    }

    return EXIT_SUCCESS;
}

bool validPath(string IF)
{

    vector<string> tokens;
    stringstream stream(IF);
    string tok;
    while (getline(stream, tok, '/'))
    {
        tokens.push_back(tok);
    }

    if (tokens.size() == 1)
    {
        return true;
    }

    for (int i = 0; i < tokens.size() - 1; i++)
    {
        string dir = "=" + tokens[i];
        ifstream FSFile(FS);
        string line;
        bool dirExists = false;
        while (getline(FSFile, line))
        {
            if (line == dir)
            {
                dirExists = true;
            }
        }

        if (!dirExists)
        {
            return false;
        }    
    }

    return true;
}


int list() {
    return 0;
}

int copyin(string EF, string IF)
{
    if (validPath(IF) && unique(IF, "@"))
    {
        ofstream FSFile;
        FSFile.open(FS, std::ios_base::app);
        FSFile << "@" << IF << endl;

        string content = "";
        ifstream EFile(EF);
        string line;
        while (getline(EFile, line))
        {
            content = content + line;
        }

        if (content.size() > 254)
        {
            content = content.substr(0, 254);
        }

        if (content.size() != 0)
        {
            content = " " + content + "\n";
            FSFile << content;
        }
    }
    return 0;
}

int copyout(string IF, string EF)
{
    string content;

    string file = "@" + IF;
    ifstream FSFile(FS);
    string line;

    bool fileExists = false;
    while (getline(FSFile, line))
    {
        if (line == file)
        {
            fileExists = true;
            getline(FSFile, line);
            content = line.substr(1, line.length() + 1);
        }
    }

    ofstream EFile(EF);
    EFile << content;

    return fileExists;
}

bool unique(string str, string firstChar)
{
    string item = firstChar + str;
    ifstream FSFile(FS);
    string line;

    bool itemUnique = true;
    while (getline(FSFile, line))
    {

        if (line == item)
        {
            itemUnique = false;
        }
    }

    return itemUnique;
}

int mkdir(string ID)
{
    if (unique(ID, "="))
    {
        ofstream FSFile;
        FSFile.open(FS, std::ios_base::app);
        FSFile << "=" << ID << endl;
    }
    return 0;
}

bool remove(string str, string firstChar) {
    string rmItem = firstChar + str;
    ifstream FSFile(FS);
    string line;

    ofstream newFSFile("new-"+FS);

    while (getline(FSFile, line))
    {
        if (line == rmItem)
        {
            newFSFile << "#" + rmItem.substr(1,rmItem.length()+1);
            getline(FSFile, line);
            newFSFile << "\n";
            newFSFile << "#" + line.substr(1, line.length() + 1);
        }
        else 
        {
            newFSFile << line;
        }
        newFSFile << "\n";
    }

    rename(("new-"+FS).c_str(), FS.c_str());

    return true;
}

int rm(string IF)
{
    remove(IF, "@");

    return 0;
}

int rmdir(string ID)
{
    vector<string> effectedFiles;
    ifstream FSFile(FS);
    string line;
    while (getline(FSFile, line))
    {
        if (line.find(ID) != std::string::npos)
        {
            effectedFiles.push_back(line.substr(1, line.length() + 1));
        }
    }

    for (int i = 0; i < effectedFiles.size(); i++)
    {
        rm(effectedFiles[i]);
    }

    remove(ID, "=");

    return 0;
}

int defrag() {
    return 0;
}
int index() {
    return 0;
}