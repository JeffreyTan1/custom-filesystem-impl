#include <string>
#include <vector>
#include <iostream>
#include <sstream>
#include <fstream>
#include <iostream>
#include <stdio.h>
#include <map>
#include <sys/stat.h>
#include <cstdio>
#include <iomanip> 
#include <algorithm>
#include <ctime>
#include <pwd.h>
#include <grp.h>

using std::map;
using std::cout;
using std::endl;
using std::ifstream;
using std::istream;
using std::ofstream;
using std::ostream;
using std::string;
using std::stringstream;
using std::vector;
using std::pair;
using std::cerr;

// EXIT CODES
#define ENOTES 200
#define EINVAL 22
#define ENOENT 2
#define EPERM 1
#define EISDIR 21

// Global variables
string FS; // filesystem name for global access by all functions
bool base64 = true; // set to false if you don't want the content to be encoded/decoded in base64

// FUNCTION DEFINITIONS
int list();
int copyin(string EF, string IF);
int copyout(string IF, string EF);
int mkdir(string ID);
int rm(string IF);
int rmdir(string ID);
int defrag();
int index();
int validIFName(string IF);
int EFExists(string EF);
int unique(string str, string firstChar);
int remove(string str, string firstChar);
int validPath(string str, string firstChar);
string getDir(string file);
int validateNotes(string FS);
int lnExists(string str, string firstChar);
int validIDName(string ID);
int createIntermediateIF(string IF);
int createIntermediateEF(string EF);

/**
Controls the flow of execution to this program
Errors
200: invalid .notes filesystem file.
22 : command doesn't exist / too few arguments
*/
int main(int argc, char **argv)
{
    bool gz = false;
    int exit_code;
    string orgnFile;

    if(argc >= 3)
    {
        // unzip the filesystem if it ends in .gz
        orgnFile = argv[2];
        if(orgnFile.substr(orgnFile.length() - 3, orgnFile.length()) == ".gz" && EFExists(orgnFile) == 0)
        {
            gz = true;
            string unzipCmd = "gunzip " + orgnFile;
            system(unzipCmd.c_str());
        }
        // if not ending in .gz or the .gz file does not exist, then treat the file as a .notes file
        FS = gz ? orgnFile.substr(0, orgnFile.length() - 3) : orgnFile;

        bool validated = true;
        int vn = validateNotes(FS);
        if (vn != 0) {
            cerr << "Invalid .notes file | " << "Exiting with code 200 : ENOTES" << endl;
            exit_code = ENOTES;
            validated = false;
        }

        if(validated){
            string command = argv[1];
            if(command == "list") {
                exit_code = list();
            }
            else if (command == "copyin" && argc == 5) {
                exit_code = copyin(argv[3], argv[4]);
            }
            else if (command == "copyout" && argc == 5) {
                exit_code = copyout(argv[3], argv[4]);
            }
            else if (command == "mkdir" && argc == 4) {
                exit_code = mkdir(argv[3]);
            }
            else if (command == "rm" && argc == 4) {
                exit_code = rm(argv[3]);
            }
            else if (command == "rmdir" && argc == 4) {
                exit_code = rmdir(argv[3]);
            }
            else if (command == "defrag" && argc == 3) {
                exit_code = defrag();
            }
            else
            {
                cerr << "Command doesn't exist | " << "Exiting with code 22 : EINVAL" << endl;
                exit_code = EINVAL;
            }  
        }
    }
    else
    {
        cerr << "Too few arguments | " << "Exiting with code 22 : EINVAL" << endl;
        exit_code = EINVAL;
    }

    if(gz) {
        string zipCmd = "gzip " + orgnFile.substr(0, orgnFile.length() - 3);
        system(zipCmd.c_str());
    }
    
    exit(exit_code);
}

/**
Checks the notes file is valid.
Returns 0 if file is valid, or 1 otherwise.
- Used in main() before executing commands.
*/
int validateNotes(string FS) {
    ifstream FSFile(FS.c_str());
    string line;
    
    int valid = 0;
    getline(FSFile, line);
    if(line != "NOTES V1.0")
    {
        valid = 1;
        return valid;
    }

    while (getline(FSFile, line)) {
        if(FSFile.eof()){
            break;
        }
        string firstChar = line.substr(0,1);
        if(!(firstChar == " " || firstChar =="#" || firstChar =="@" || firstChar =="=")) {
            valid = 1;
        }
    }  

    FSFile.close();
    return valid;
}

/**
Gets the subdirectory of the given path.
Returns the name of the subdirectory.
- Used to ensure subdirectories exist before creating a file,
otherwise intermediate directories are created.
- Used to tie a given file/directory to a parent directory for list() and defrag()
*/
string getDir(string file) {
    vector<string> tokens;
    stringstream stream(file);
    string tok;
    while (getline(stream, tok, '/'))
    {
        tokens.push_back(tok);
    }

    if (tokens.size() == 1)
    {
        return "";
    }

    string dir = "";
    for (int i = 0; i < tokens.size() - 1; i++)
    {
          dir = dir + tokens[i] + "/";
    }

    return dir;
}

/**
Counts the length of the string content to a file.
Returns teh count.
Since each character in a string is a byte in C++, return the length of the string.
- Used in list() for the size field of ls -lR format
*/
int getFileBytes(string file) {
    string data = "";
    ifstream FSFile(FS.c_str());
    string line;
    while (getline(FSFile, line)){
        if (line == "@"+file) {
            bool eof = getline(FSFile, line).eof();
            while(line.substr(0,1) == " " && !eof) {
                string content = line;
                eof = getline(FSFile, line).eof();
                string nl = line.substr(0,1) == " " ? "\n" : "";
                data = data + content.substr(1, content.length()) + nl;
            }
            // the case where the last line is a content line
            if(line.substr(0,1) == " ") {
                data = data + line.substr(1, line.length());
            }
            break;
        }
    }
    FSFile.close();
    return data.length();
}

/**
Counts the number of subdirectories in the level below the given directory.
Returns the count.
- Used in list() to get hardlinks of a directory
*/
int getSubDirs(string dir) {
    int subDirCount = 0;
    ifstream FSFile(FS.c_str());
    string line;
    string dirName = "="+dir;
    while (getline(FSFile, line)){
        if (line.find(dirName) != std::string::npos && line.find(dirName) == 0) {
            string dir = line.substr(dirName.length(), line.length());
            if (std::count(dir.begin(), dir.end(), '/') == 1)
            {
               subDirCount++; 
            }
        }
    }
    FSFile.close();
    return subDirCount;
}

/**
Lists the filesystem in ls -lR format
*/
int list() {
    // create a map of all directories and their files
    map<string, vector<string> > directoryFileMap;
    vector<string> newVect;
    directoryFileMap.insert(pair<string, vector<string> >("", newVect));

    ifstream FSFile(FS.c_str());
    string line;
    while (getline(FSFile, line)){
        if(line.substr(0,1) == "=") {
            vector<string> newVect;
            directoryFileMap.insert(pair<string,vector<string> >(line.substr(1, line.length()), newVect));
        }
    }

    FSFile.clear();
    FSFile.seekg(0);

    while (getline(FSFile, line)){
        if(line.substr(0,1) == "@" || line.substr(0,1) == "=" ) {
            string file = line.substr(1, line.length());
            string dir = getDir(file);
            directoryFileMap.at(dir).push_back(file);
        }
    }

    FSFile.close();

    // output map in ls -lR format    
    struct stat info;
    stat(FS.c_str(), &info);

    map<string, vector<string> >::iterator it;
    for(it=directoryFileMap.begin(); it!=directoryFileMap.end(); ++it){
        string directoryName = it->first;
        cout << ".";
        if(it->first != ""){
            cout << "/";
        }
        cout << directoryName.substr(0, directoryName.length()-1) << ":" << '\n';
        cout << "total " << info.st_blocks << endl;

        vector<string> files = it->second;
        std::sort(files.begin(), files.end());
        for (int i = 0; i < files.size() ; i++) {
            string currFile = files[i];
            bool isDir = currFile.substr(currFile.length()-1, currFile.length()) == "/";
            printf( (isDir) ? "d" : "-");
            printf( (info.st_mode & S_IRUSR) ? "r" : "-");
            printf( (info.st_mode & S_IWUSR) ? "w" : "-");
            printf( (info.st_mode & S_IXUSR) ? "x" : "-");
            printf( (info.st_mode & S_IRGRP) ? "r" : "-");
            printf( (info.st_mode & S_IWGRP) ? "w" : "-");
            printf( (info.st_mode & S_IXGRP) ? "x" : "-");
            printf( (info.st_mode & S_IROTH) ? "r" : "-");
            printf( (info.st_mode & S_IWOTH) ? "w" : "-");
            printf( (info.st_mode & S_IXOTH) ? "x" : "-");

            int hardlinks = isDir ? getSubDirs(files[i]) : 1;
            printf(" %d ", hardlinks);

            struct passwd *pw = getpwuid(info.st_uid);
            struct group  *gr = getgrgid(info.st_gid);

            string usr = pw != 0 ? pw->pw_name : "root";
            string grp = gr != 0 ? gr->gr_name : "root";

            cout << usr.c_str() << " ";
            cout << grp.c_str() << " ";

            int bytes = isDir? 0 : getFileBytes(files[i]);
            
            cout << bytes << " ";

            std::time_t t = info.st_mtime;
            std::tm *ptm = std::localtime(&t);
            char buffer[32];
            std::strftime(buffer, 32, "%b %d %H:%M", ptm);  
            
            string subDir = getDir(currFile);
            string currFileName = currFile.substr(currFile.find(subDir) + subDir.length(), currFile.length());
            if(isDir) {
                currFileName = currFileName.substr(0, currFileName.length()-1);
            }

            cout << buffer << " " << currFileName << endl;
        }
        if(std::distance(it, directoryFileMap.end()) > 1)
        {
          cout << endl;  
        }
    }
    
    return 0;
}

/**
Checks whether the subdirectory to the given file/directory exists.
Returns 0 if path is valid, or 1 otherwise.
- Used in copyin() to determine if intermediate directories need to be created
- Used in mkdir() to ensure the subdirectory exists
*/
int validPath(string str) {
    int ret_code = 1;

    string subDir = "=" + getDir(str);

    if (subDir != "=") {
        ifstream FSFile(FS.c_str());
        string line;

        while (getline(FSFile, line))
        {
            if (line == subDir)
            {
                ret_code = 0;
                break;
            }
        }
        FSFile.close();
    }
    else
    {
        ret_code = 0;
    }
    
 
    return ret_code;
}

/**
Parses internal file name to determine if it meets .notes rules.
Returns 0 if name is valid, or 1 otherwise.
- Used in copyin() to determine if IF is named correctly
Errors:
22: IF starts or ends with /
22: IF is . .. or /
*/
int validIFName(string IF)
{
    int ret_code = 0;

    string subDir = getDir(IF);
    string fileName = IF.substr(IF.find(subDir) + subDir.length(), IF.length());

    if (fileName == "/" || fileName == "." || fileName == "..")
    {
        cerr << "Internal file cannot be named \"/\" , \".\" , \"..\"    |  "<< "Exiting with code 22 : EINVAL" << endl;
        ret_code = EINVAL;
    } 
    if (subDir.substr(0,1) == "/" || fileName.substr(fileName.length() -1, fileName.length()) == "/")
    {
        cerr << "Internal file path cannot start or end with a '/'   |  "<< "Exiting with code 22 : EINVAL" << endl;
        ret_code = EINVAL;
    } 

    return ret_code;
}

/**
Checks if external file exists using stat.h
Returns 0 if file exists or 1 otherwise.
- Used in copyin() to determine whether the external file exists
- Used in copyout() to determine if intermediate directories need to be created.
*/
int EFExists(string EF)
{
    int exists; 
    struct stat info;   
    if (stat (EF.c_str(), &info) == 0) {
        exists = 0;
    }
    else {
        
        exists = 1;
    }
    return exists;
}

/**
Creates all intermediate directories for a given internal file.
Returns 0 if operation complete or 1 otherwise.
- Used in copyin() to build intermediate directories if required.
*/
int createIntermediateIF(string IF) 
{
    int ret_code = 0;

    string dir = getDir(IF);

    vector<string> tokens;
    stringstream stream(dir);
    string tok;
    while (getline(stream, tok, '/'))
    {
        tokens.push_back(tok);
    }
    
    // use mkdir on paths that don't exist
    string pathBuilder = "";
    for (int i = 0; i < tokens.size(); i++) {
        
        pathBuilder = pathBuilder + tokens[i] + "/";

        if (unique(pathBuilder, "=") == 0) {
            ret_code = mkdir(pathBuilder);
            if (ret_code != 0) {
                cerr << "Problem creating intermediate directory, " << pathBuilder << "   |   " << "Exiting with code " << ret_code << endl;
                return ret_code;
            }
        }
    } 

    return ret_code;
}


/*
Copies an external file to a given internal path.
Returns 0 if okay, or error code.
Errors:
2: ext directory does not exist
22: IF starts or ends with /
22: IF is . .. or /
*/
int copyin(string EF, string IF)
{
    int ret_code = 0;

    int vifn = validIFName(IF);
    if (vifn != 0) {
        ret_code = vifn;
        return ret_code;
    }
    int efe = EFExists(EF);
    if (efe != 0) {
        cerr << "External file does not exist, " << EF << "  |   " << "Exiting with code 2 : ENOENT" << endl; 
        ret_code = ENOENT;
        return ret_code;
    }

    if (unique(IF, "@") != 0){
        rm(IF);
    }

    int vp = validPath(IF);
    if (vp != 0) {
        int ci = createIntermediateIF(IF);
        if (ci != 0) {
            
            ret_code = vp;
            return ret_code;
        }
    }

    ofstream FSFile;
    FSFile.open(FS.c_str(), std::ios_base::app);
    FSFile << "@" << IF << endl;

    string intermediateFile = EF;
    if (base64) {
        intermediateFile = "temp_encode.txt";
        string encode_command = "base64 " + EF + " > " + intermediateFile;
        system(encode_command.c_str());
    }

    // copy file in
    ifstream EFile(intermediateFile.c_str());
    string line;
    while (getline(EFile, line))
    {
        string content = line;
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
    EFile.close();
    FSFile.close();
    
    if (base64)
    {
        string del_command = "rm " + intermediateFile;
        system(del_command.c_str());
    }
    
    return ret_code;
}

/*
Checks whether file/dir exists in the filesystem.
Returns 0 if yes, otherwise 1.
- Used in copyout() and rm() to see if given IF exists
- Used in rmdir() to see if given dir exists
Errors:
2: file/dir does not exist
*/
int lnExists(string str, string firstChar)
{
    string item = firstChar + str;
    ifstream FSFile(FS.c_str());
    string line;
    int exists = ENOENT;
    while (getline(FSFile, line)) {
        if (item == line) {
            exists = 0;
        }
    }

    if (exists == ENOENT) {
        if (firstChar == "@") {
            cerr << "Internal file does not exist, " << str << "  |   " << "Exiting with code 2 : ENOENT" << endl; 
        }
        if (firstChar == "=") {
            cerr << "Dir does not exist, " << str << "  |   " << "Exiting with code 2 : ENOENT" << endl;
        }
    }
    FSFile.close();

    return exists;
}

/**
Creates all intermediate directories for a given external file.
Returns 0 if operation complete or 1 otherwise.
- Used in copyout() to build intermediate directories if required.
*/
int createIntermediateEF(string EF)
{
    int ret_code = 0;

    string dir = getDir(EF);

    vector<string> tokens;
    stringstream stream(dir);
    string tok;
    while (getline(stream, tok, '/'))
    {
        tokens.push_back(tok);
    }
    
    // do mkdir on all paths that don't exist
    string pathBuilder = "";
    for (int i = 0; i < tokens.size(); i++) {
        
        pathBuilder = pathBuilder + tokens[i] + "/";
        
        if (EFExists(pathBuilder) == 1) {
            try {
                string command = "mkdir " + pathBuilder;
                system(command.c_str());
            }
            catch (...) {
                cerr << "Problem creating intermediate directory, " << pathBuilder << "   |   " << "Exiting with code 1 : EPERM" << endl;
                ret_code = EPERM;
                return ret_code;
            }        
        }
    } 

    return ret_code;
}

/**
Copies an internal file to a given external path.
Returns 0 if okay, or error code.
Errors:
2: internal file does not exist
1: problem creating external file
*/
int copyout(string IF, string EF)
{
    int ret_code = 0;
    // do checks for file exists
    int ife = lnExists(IF, "@");
    if (ife != 0) {
        ret_code = ife;
        return ret_code;
    }
    
    int efe = EFExists(EF);
    if (efe != 0) {
        int ci = createIntermediateEF(EF);
        if (ci != 0) {
            ret_code = ci;
            return ret_code;
        }
    }
    
    string extFile = EF;
    if(base64)
    {   
        extFile = "temp_decode.txt";
    }

    // copyout
    string intermediateFile = "@" + IF;
    ifstream FSFile(FS.c_str());
    string line;

    while (getline(FSFile, line))
    {
        if (line == intermediateFile)
        {
            ofstream EFile(extFile.c_str());
            bool eof = getline(FSFile, line).eof();
            
            while(line.substr(0,1) == " " && !eof) {
                string content = line;
                eof = getline(FSFile, line).eof();
                string nl = line.substr(0,1) == " " ? "\n" : "";
                EFile << content.substr(1, content.length()) << nl;
            }

            // the case where the last line is a content line
            if(line.substr(0,1) == " ") {
                EFile << line.substr(1, line.length());
            }
            EFile.close();
        }
    }

    FSFile.close();

    if(base64)
    {
        string decode_command = "base64 --decode " + extFile + " > " + EF;
        system(decode_command.c_str());
        string del_command = "rm " + extFile;
        system(del_command.c_str());
    }
    return ret_code;
}

/**
Checks whether given file/dir is already in the filesystem.
Returns 0 if does not exist, 1 otherwise.
- Used in mkdir() for dir already exists error
- Used in copyin() to see if file needs to be replaced.
*/
int unique(string str, string firstChar)
{
    string item = firstChar + str;
    ifstream FSFile(FS.c_str());
    string line;

    int itemUnique = 0;
    while (getline(FSFile, line))
    {
        if (line == item)
        {
            itemUnique = 1;
        }
    }
    FSFile.close();
    return itemUnique;
}

/**
Checks whether given dir name follows .notes rules.
Returns 0 if valid, 1 otherwise.
- Used in mkdir() to make sure name given is valid.
*/
int validIDName(string ID)
{
    int ret_code = 0;
    if (ID.substr(0,1) == "/" || ID.substr(ID.length() - 1, ID.length()) != "/")
    {
        cerr << "Internal directory cannot start with '/' and must end with '/'   |  "<< "Exiting with code 22 : EINVAL" << endl;
        ret_code = EINVAL;
    } 

    return ret_code;
}

/**
Creates a new directory with given pathname.
Returns 0 if okay, or error code.
Errors:
2: no valid path for this directory
22: directory already exists
22: if directory starts or doesn't end with /
*/
int mkdir(string ID)
{
    int ret_code = 0;
    int vidn = validIDName(ID);
    if (vidn != 0) { 
        ret_code = vidn;
        return ret_code;
    }

    int vp = validPath(ID);
    if (vp != 0) { 
        cerr << "No valid path for this directory, " << ID << "   |   " << "Exiting with code 2 : ENOENT" << endl; 
        ret_code = ENOENT;
        return ret_code;
    }
   

    int unq = unique(ID, "=");
    if (unq != 0)
    {
        cerr << "Directory already exists, " << ID << "   |   " << "Exiting with code 21 : EISDIR" << endl; 
        ret_code = EISDIR;
    }
    else {
        ofstream FSFile;
        FSFile.open(FS.c_str(), std::ios_base::app);
        FSFile << "=" << ID << endl;
        FSFile.close();
    }
    return ret_code;
}

/**
Removes the file/dir record given. Replaces records with leading #
Returns 0 if okay, or 1 otherwise.
- Used in rm() and rmdir() to remove records
*/
int remove(string str, string firstChar) {

    int ret_code = 0;
    try{
        // create a new file with the record removed with "#"
        string rmItem = firstChar + str;
        ifstream FSFile(FS.c_str());
        string line;
        string newFile = FS + "-new";
        ofstream newFSFile(newFile.c_str());
        while (getline(FSFile, line))
        {
            bool hasContent = false;
            bool eof;
            if (line == rmItem)
            { 
                newFSFile << "#" + rmItem.substr(1,rmItem.length());
                // delete content
                if (firstChar == "@") {
                    newFSFile << "\n";
                    eof = getline(FSFile, line).eof();
                    while(line.substr(0,1) == " " && !eof) {
                        hasContent = true;
                        string content = line;
                        eof = getline(FSFile, line).eof();
                        string nl = line.substr(0,1) == " " ? "\n" : "";
                        newFSFile << "#" + content.substr(1, content.length()) << nl;
                    }
                    
                    string spacer = hasContent ? "\n" : "";
                    newFSFile << spacer << line;
                    
                    
                }
            }
            else 
            {
                hasContent = true;
                newFSFile << line;
            }
            if(!eof)
            {
                newFSFile << "\n"; 
            }
                      
            
        }

        newFSFile.close();
        FSFile.close();
        rename(newFile.c_str(), FS.c_str());
    } catch (...) {
        cerr << "Problem opening temporary file or renaming temp file to original file, " << str <<"   |   " << "Exiting with code 1 : EPERM" << endl;
        ret_code = EPERM;
    }
    

    return ret_code;
}

/**
Deletes a given file.
Returns 0 if okay, or error code.
Errors:
2: file does not exist
1: trouble renaming files
*/
int rm(string IF)
{
    int ret_code = 0;

    // check file exists
    int ife = lnExists(IF, "@");
    if (ife != 0) {
        ret_code = ife;
        return ret_code;
    }

    ret_code = remove(IF, "@");
    return ret_code;
}

/**
Deletes a given directory, and recursively deletes all subdirectories and files.
Returns 0 if okay, or error code.
Errors:
2: directory does not exist
1: trouble renaming files
*/
int rmdir(string ID)
{
    int ret_code = 0;
    int de = lnExists(ID, "=");
    if (de != 0) {
        ret_code = de;
        return ret_code;
    }

    //get a vector of all effected files which need to be deleted
    vector<string> effectedFiles;
    vector<string> effectedDirs;
    ifstream FSFile(FS.c_str());
    string line;
    
    while (getline(FSFile, line))
    {
        bool isDir = line.substr(0,1) == "=";
        bool isFile = line.substr(0,1) == "@";

        if(isDir || isFile) {
            string path = line.substr(1, line.length());
            if(path.find(ID) == 0) {
                if(isDir) {
                    effectedDirs.push_back(line.substr(1, line.length()));
                }
                if(isFile) {
                    effectedFiles.push_back(line.substr(1, line.length()));
                }
            }
        }



        if (line.find(ID) != std::string::npos)
        {
            
        }
    }
    FSFile.close();

    for (int i = 0; i < effectedFiles.size(); i++)
    {
        ret_code = rm(effectedFiles[i]);
        if(ret_code != 0) {
            return ret_code;
        }
    }

    for (int i = 0; i < effectedDirs.size(); i++)
    {
        ret_code = remove(effectedDirs[i], "=");;
        if(ret_code != 0) {
            return ret_code;
        }
    }

    return ret_code;
}

/**
Sorts the directory by ls -lR format, and removes all deleted '#' records
*/
int defrag() {
    
    // create map of all directories and their files
    map<string, vector<string> > directoryFileMap;
    vector<string> newVect;
    directoryFileMap.insert(pair<string, vector<string> >("", newVect));
    string newFile = FS + "-new";
    ofstream newFSFile(newFile.c_str());
    newFSFile << "NOTES V1.0" << "\n";
    ifstream FSFile(FS.c_str());
    string line;
    while (getline(FSFile, line)){
        if(line.substr(0,1) == "=") {
            vector<string> newVect;
            directoryFileMap.insert(pair<string,vector<string> >(line.substr(1, line.length()), newVect));
        }
    }
    
    FSFile.clear();
    FSFile.seekg(0); 

    while (getline(FSFile, line)){
        if(line.substr(0,1) == "@" || line.substr(0,1) == "=" ) {
            string file = line.substr(1, line.length());
            string dir = getDir(file);
            directoryFileMap.at(dir).push_back(file);
        }
    }

    // sort file in ls -lR
    map<string, vector<string> >::iterator it;
    for(it=directoryFileMap.begin(); it!=directoryFileMap.end(); ++it) {
        if(it->first != "") {
            newFSFile << "=" + it->first << "\n";
        }
        vector<string> files = it->second;
        std::sort(files.begin(), files.end());
        for (int i = 0; i < files.size() ; i++) {
            FSFile.clear();
            FSFile.seekg(0); 

            while(getline(FSFile, line)) {
                if(line == "@" + files[i]) {
                    newFSFile << line << "\n";
                    bool eof = getline(FSFile, line).eof();
                    bool hasContent = false;

                    while(line.substr(0,1) == " " && !eof) {
                        hasContent = true;
                        string content = line;
                        eof = getline(FSFile, line).eof();
                        string nl = line.substr(0,1) == " " ? "\n" : "";
                        newFSFile << " " + content.substr(1, content.length()) << nl;
                    }

                    if(line.substr(0,1) == " ") {
                        newFSFile << " " + line.substr(1, line.length());
                    }       

                    if (hasContent)
                    {
                       newFSFile << "\n"; 
                    }            

                    break;
                }
                
            }
        }
    }
    newFSFile.close();
    FSFile.close();
    rename(newFile.c_str(), FS.c_str());

    return 0;
}
