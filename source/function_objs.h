#include <string>

class GAPFunction
{
    Obj obj;
    std::string name;

public:
    GAPFunction() : obj(0), name()
    { }

    void setName(std::string s)
    { name = s; }
    
    Obj getObj()
    {
        if(obj == 0)
        {
            UInt varname = GVarName(name.c_str());
            obj = VAL_GVAR(varname);
        }
        return obj;
    }
};
