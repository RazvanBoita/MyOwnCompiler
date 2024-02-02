#include "IdList.h"
using namespace std;


int getTypeCode2(const char* dataType) {
    if (strcmp(dataType, "int")==0)
        return 2;
    else if (strcmp(dataType, "float") == 0)
        return 3;
    else if (strcmp(dataType, "string") == 0)
        return 4;
    else if (strcmp(dataType, "char") == 0)
        return 5;
     else if (strcmp(dataType,"bool")==0)
          return 6;
    else
        return -1;
}

void IdList::addVar(const char* type, const char* name) {
    IdInfo var = {string(type), string(name)};
    vars.push_back(var);
}

void IdList::changeScope(const char* name, string newScope) {
    for (IdInfo& v : vars) {
        if (v.name == name) {
            v.scope = newScope;
            return;
        }
    }
}

void IdList::modifyValue(const char* val, const char* name){
    for(IdInfo& v : vars){
        if(v.name==name)
            v.value=val;
    }
}

void IdList::changeVisibility(const char* name, string newVis) {
    for (IdInfo& v : vars) {
        if (v.name == name) {
            v.visibility = newVis;
            return;
        }
    }
}
void IdList::changeConst(const char* name, string yesORno) {
    for (IdInfo& v : vars) {
        if (v.name == name) {
            v.constancy = yesORno;
            return;
        }
    }
}

bool IdList::existsVar(char* var) {
    string strvar = string(var);
     for (const IdInfo& v : vars) {
        if (strvar == v.name) { 
            return true;
        }
    }
    return false;
}


void IdList::printVars() {
    FILE* outFile = fopen("vars.txt", "w");

    // Function to print a formatted cell
    auto printCell = [&](const std::string& content) {
        const int cellWidth = 20;
        std::string truncatedContent;
        if (content.size() > cellWidth) {
            truncatedContent = content.substr(0, cellWidth - 4) + "...";
        } else {
            truncatedContent = content;
        }
        fprintf(outFile, "| %-*s", cellWidth, truncatedContent.c_str());
    };

    // Print header
    fprintf(outFile, "+----------------------+----------------------+----------------------+----------------------+----------------------+\n");
    fprintf(outFile, "| %-20s | %-20s | %-20s  | %-20s |  %-20s | %-20s |\n", "NAME", "TYPE", "SCOPE", "VALUE", "CONSTANT", "VISIBILITY");
    fprintf(outFile, "+----------------------+----------------------+----------------------+----------------------+----------------------+\n");

    // Print data
    for (const IdInfo& v : vars) {
        printCell(v.name);
        printCell(v.type);
        printCell(v.scope);


        if (!v.value.empty()) {
            printCell(v.value);
        } else {
            fprintf(outFile, "| %-20s", "");
        }

        if (!v.constancy.empty()) {
            printCell(v.constancy);
        } else {
            fprintf(outFile, "| %-20s", "");
        }

        // Print visibility if not empty
        if (!v.visibility.empty()) {
            printCell(v.visibility);
        } else {
            fprintf(outFile, "| %-20s", ""); // Empty cell
        }

        fprintf(outFile, "|\n");
    }

    // Print footer
    fprintf(outFile, "+----------------------+----------------------+----------------------+----------------------+----------------------+\n");

    fclose(outFile);
}

const char* IdList::getVarType(const char* var) {
    string strvar = string(var);
    for (const IdInfo& v : vars) {
        if (strvar == v.name) {
            return v.type.c_str();
        }
    }
    return nullptr;
}


void IdList::copyVariables(Classes& classes, const char* sourceClassName, const char* destClassName) {
    const vector<IdInfo>& sourceMembers = classes.getMembers(sourceClassName);
    for (const IdInfo& sourceMember : sourceMembers) {
        string varNameInDest = string(destClassName) + "->" + sourceMember.name;
        addVar(sourceMember.type.c_str(), varNameInDest.c_str());
        if (!sourceMember.visibility.empty())
            changeVisibility(varNameInDest.c_str(), sourceMember.visibility);
        if (!sourceMember.constancy.empty())
            changeConst(varNameInDest.c_str(), sourceMember.constancy);
        changeScope(varNameInDest.c_str(),sourceClassName);
    }
}


IdList::~IdList() {
    vars.clear();
}



 void FunctionInfo::addFunc(char* type, char* name) {
        FuncEntry newFunc;
        newFunc.type = type;
        newFunc.name = name;
        functions.push_back(newFunc);
}

void FunctionInfo::printFuncs() {
        FILE* outFile = fopen("funcs.txt", "w");
        if (!outFile) {
            printf("Eroare deschidere fisier!\n");
            exit(0);
        }
        for (const auto& func : functions) {
            fprintf(outFile, "NAME: %s, TYPE: %s\n", func.name.c_str(),func.type.c_str());
            if(!func.params.empty()) {
                fprintf(outFile, "PARAMS:\n");
                for (const auto& param : func.params) {
                 fprintf(outFile, "  NAME: %s, TYPE: %s\n", param.name.c_str(), param.type.c_str());
                }
                fprintf(outFile, "SCOPE: %s\n",func.scope.c_str());
                fprintf(outFile, "\n");
            } 
            else fprintf(outFile, "This function doesn't have parameters.\n\n");
        }
        fclose(outFile);
}    

// string FunctionInfo::getScope(char* name){
//     string strname=string(name);
//     for(const FuncEntry& e : functions)
//         if(strname==e.name)
//             return e.scope;
// }

bool FunctionInfo::existsFunc(char* name){
    string strname=string(name);
    for(const FuncEntry& e : functions)
        if(strname==e.name)
            return true;
    return false;
}


bool FunctionInfo::verifyParams(const char* name, int params[],int length){
    string strname=string(name);
    int i=0;
    for(const FuncEntry& e : functions){
        if(strname==e.name){
            if(e.params.size()!=length) return 0;
            for(const auto& param : e.params)
                if(getTypeCode2(param.type.c_str())!=params[i++])
                    return 0;
        }
    } 
    return 1;  
}

const char* FunctionInfo::getFuncType(char* name){
    string strname=string(name);
    for(const FuncEntry& e : functions)
        if(strname==e.name)
            return e.type.c_str();
    return nullptr;
}

void Classes::addClass(const char* className) {
        classMap[className].className = className;
}

void Classes::addMember(const char* className, const char* type, const char* name) {
        IdInfo member = {string(type), string(name)};
        classMap[className].members.push_back(member);
}

const vector<IdInfo>& Classes::getMembers(const char* className) {
        return classMap[className].members;
}


void Classes::modifyMemberVisibility(const char* className, const char* memberName, const char* newVisibility) {
    auto& classInfo = classMap[className];
    for (auto& member : classInfo.members) {
        if (member.name == memberName) {
            member.visibility = newVisibility;
            return;
        }
    }
    cerr << "Error: Member '" << memberName << "' not found in class '" << className << "'" << endl;
}

void Classes::modifyMemberConstancy(const char* className, const char* memberName, const char* newConstancy) {
    auto& classInfo = classMap[className];

    for (auto& member : classInfo.members) {
        if (member.name == memberName) {
            member.constancy = newConstancy;
            return;
        }
    }
    cerr << "Error: Member '" << memberName << "' not found in class '" << className << "'" << endl;
}

void Classes::printProgress() {
    for (const auto& pair : classMap) {
        const ClassInfo& classInfo = pair.second;
        cout << "Class Name: " << classInfo.className << endl;

        if (!classInfo.members.empty()) {
            cout << "Members:" << endl;
            for (const auto& member : classInfo.members) {
                cout << "  Type: " << member.type
                            << " Name: " << member.name;

                if (!member.visibility.empty()) {
                    cout << " Visibility: " << member.visibility;
                }

                if (!member.constancy.empty()) {
                    cout << " Constancy: " << member.constancy;
                }
                cout << endl;
            }
        } 
        else
            cout << "No members defined yet." << endl;
        cout << endl;
    }
}






bool Classes::hasClass(const char* className){
    return classMap.find(className) != classMap.end();
}

bool Classes::verifyVarInClass(const char* className, const char* varName){
    auto classIt = classMap.find(className);
    if (classIt != classMap.end()) {
        const ClassInfo& classInfo = classIt->second;
        for (const IdInfo& member : classInfo.members) {
            if (member.name == varName) {
                return true;
            }
        }
    }
    return false;
}

void Errors::throwFuncAlreadyDeclared(int lineno){
    printf("Ai o eroare la linia %d\nDeclari o functie care a fost deja declarata\n",lineno);
    exit(0);
}

void Errors::throwNoVar(int lineno){
    printf("Ai o eroare la linia %d\nFolosesti o variabila care nu a fost declarata\n",lineno);
    exit(0);
}

void Errors::throwVarAlreadyDeclared(int lineno){
    printf("Ai o eroare la linia %d\nIncerci sa declari o variabila care a fost declarata deja\n",lineno);
    exit(0);
}

void Errors::throwTypeConflict(int lineno){
    printf("Ai o eroare la linia %d\nIn expresia ta, ai cel putin 2 elemente de tipuri diferite\n",lineno);
    exit(0);
}

void Errors::throwNoFunc(int lineno){
    printf("Ai o eroare la linia %d\nFolosesti o functie care nu a fost declarata!\n",lineno);
    exit(0);
}

void Errors::throwFailedParams(int lineno){
    printf("Ai o eroare la linia %d\nFolosesti o functie care nu are parametrii corecti!\n",lineno);
    exit(0);
}

void Errors::throwAddStrings(int lineno){
    printf("Ai o eroare la linia %d\nNu poti adauga 2 stringuri!\n",lineno);
    exit(0);
}
void Errors::throwAddBools(int lineno){
    printf("Ai o eroare la linia %d\nNu poti adauga 2 bool!\n",lineno);
    exit(0);
}