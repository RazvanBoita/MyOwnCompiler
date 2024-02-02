#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <cstring>
using namespace std;

struct IdInfo {
    string type;
    string name;
    string scope;
    string value;
    string visibility;
    string constancy;
};

class Classes {
private:
    struct ClassInfo {
        string className;
        vector<IdInfo> members;
    };

    map<string, ClassInfo> classMap;

public:
    void addClass(const char* className);
    void addMember(const char*,const char*,const char*);
    const vector<IdInfo>& getMembers(const char* className);
    void modifyMemberVisibility(const char*, const char*, const char*);
    void modifyMemberConstancy(const char*, const char*, const char*);
    void printProgress();
    bool hasClass(const char*);
    bool verifyVarInClass(const char*,const char*);
};

class IdList {
    vector<IdInfo> vars;
    Classes classes;
    public:
    bool existsVar(char* s);
    void addVar(const char* type, const char* name);
    void modifyValue(const char* value, const char* name);
    const char* getVarType(const char* var);
    void printVars();
    void changeScope(const char* name, string newScope);
    void changeVisibility(const char* name, string visibility);
    void changeConst(const char* name, string constancy);
    void copyVariables(Classes& classes, const char* sourceClassName, const char* destClassName);
    ~IdList();
};


struct ParamInfo{
    string type;
    string name;

};  



//TODO -  modifica clasa in struct daca nu merge cv

struct FuncEntry{
    string type;
    string name;
    string scope;
    vector<ParamInfo> params;
    void addParameter(const char* paramType, const char* paramName) {
        ParamInfo newParam;
        newParam.type = paramType;
        newParam.name = paramName;
        params.push_back(newParam);
    }
    void changeScope(string newScope){
        scope=newScope;
    }
};

class FunctionInfo{
    public:
        vector<FuncEntry> functions;
        void addFunc(char* type, char* name);
        void printFuncs();
        bool existsFunc(char* name);
        void changeScope(char* name, char* newScope);
        // string getScope(char* name);
        const char* getFuncType(char* name);
        bool verifyParams(const char*, int[], int );
};


class Errors{
    public:
        void throwVarAlreadyDeclared(int lineno);
        void throwFuncAlreadyDeclared(int lineno);
        void throwNoVar(int lineno);
        void throwNoFunc(int lineno);
        void throwTypeConflict(int lineno);
        void throwFailedParams(int lineno);
        void throwAddStrings(int lineno);
        void throwAddBools(int lineno);
};