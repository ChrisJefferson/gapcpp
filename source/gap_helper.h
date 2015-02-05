#ifndef GAP_HELPER_PNFRE
#define GAP_HELPER_PNFRE

#include "src/compiled.h"
#include "function_objs.h"

#include <stdexcept>
#include <string>
#include "library/vec1.hpp"
#include "library/algorithms.hpp"
#include "library/perm.hpp"
#include "library/optional.hpp"


namespace GAPdetail
{
template<typename T>
struct GAP_getter
{ };

// Yes, this is useful. It lets someone turn a GAP vector into a
// vec1<Obj>, without having to worry about GAP vector functions
// any more.
template<>
struct GAP_getter<Obj>
{
    bool isa(Obj) const
    { return true; }
    
    Obj operator()(Obj recval) const
    { return recval; }
};

template<>
struct GAP_getter<char*>
{
    bool isa(Obj recval) const
    { return IS_STRING(recval) && IS_STRING_REP(recval); }
    
    char* operator()(Obj recval) const
    {
        if(!isa(recval))
            throw GAPException("Invalid attempt to read string");
        return (char*)CHARS_STRING(recval);
    }
};

template<>
struct GAP_getter<std::string>
{
    bool isa(Obj recval) const
    { return IS_STRING(recval) && IS_STRING_REP(recval); }

    std::string operator()(Obj recval) const
    {
        if(!isa(recval))
            throw GAPException("Invalid attempt to read string");
        return std::string((char*)CHARS_STRING(recval));
    }
};


template<>
struct GAP_getter<bool>
{
    bool isa(Obj recval) const
    { return (recval == True) || (recval == False); }
    
    bool operator()(Obj recval) const
    {
        if(recval == True)
            return true;
        if(recval == False)
            return false;
        if(recval == Fail)
            throw GAPException("Got 'fail' as a Boolean");
        throw GAPException("Not a bool!");
    }
};


template<>
struct GAP_getter<int>
{
    bool isa(Obj recval) const
    { return IS_INTOBJ(recval); }
    
    int operator()(Obj recval) const
    {
        if(!isa(recval))
            throw GAPException("Invalid attempt to read int");
        return INT_INTOBJ(recval);
    }
};

template<typename T, typename Container>
void fillContainer(Obj rec, Container& v)
{
  if(!(IS_SMALL_LIST(rec)))
    throw GAPException("Invalid attempt to read list");
  int len = LEN_LIST(rec);

  v.reserve(len);
  GAP_getter<T> getter;
  for(int i = 1; i <= len; ++i)
  {
      v.push_back(getter(ELM_LIST(rec, i)));
  }
}

// This case, and next one, handle arrays with and without holes
template<typename T>
struct GAP_getter<vec1<T> >
{
    bool isa(Obj recval) const
    { return IS_SMALL_LIST(recval); }
    
    vec1<T> operator()(Obj rec) const
    {
      vec1<T> v;
      fillContainer<T>(rec, v);
      return v;
    }
};

template<typename T>
struct GAP_getter<std::vector<T> >
{
    bool isa(Obj recval) const
    { return IS_SMALL_LIST(recval); }
    
    std::vector<T> operator()(Obj rec) const
    {
      std::vector<T> v;
      fillContainer<T>(rec, v);
      return v;
    }
};


template<typename T, typename Container>
void fillContainerWithHoles(Obj rec, Container& v)
{
  if(!(IS_SMALL_LIST(rec)))
      throw GAPException("Invalid attempt to read list");
  int len = LEN_LIST(rec);

  v.reserve(len);
  GAP_getter<T> getter;
  for(int i = 1; i <= len; ++i)
  {
      if(ISB_LIST(rec, i))
      { v.push_back(getter(ELM_LIST(rec, i))); }
      else
      { v.push_back(optional<T>()); }
  }
  return v;
}

template<typename T>
struct GAP_getter<vec1<optional<T> > >
{
    bool isa(Obj recval) const
    { return IS_SMALL_LIST(recval); }
    
    vec1<optional<T> > operator()(Obj rec) const
    {
        vec1<optional<T> > v;
        fillContainerWithHoles<T>(rec, v);
        return v;
    }
};

template<typename T>
struct GAP_getter<std::vector<optional<T> > >
{
    bool isa(Obj recval) const
    { return IS_SMALL_LIST(recval); }
    
    std::vector<optional<T> > operator()(Obj rec) const
    {
        std::vector<optional<T> > v;
        fillContainerWithHoles<T>(rec, v);
        return v;
    }
};

template<>
struct GAP_getter<Permutation>
{
    Permutation operator()(Obj rec) const
    {
        if(TNUM_OBJ(rec) == T_PERM2)
        {
            UInt deg = DEG_PERM2(rec);
            Permutation p = getRawPermutation(deg);
            vec1<int> v(deg);
            UInt2* ptr = ADDR_PERM2(rec);
            for(UInt i = 0; i < deg; ++i)
                p.raw(i+1) = ptr[i] + 1;
            D_ASSERT(p.validate());
            return p;
        }
        else if(TNUM_OBJ(rec) == T_PERM4)
        {
            UInt deg = DEG_PERM4(rec);
            Permutation p = getRawPermutation(deg);
            UInt4* ptr = ADDR_PERM4(rec);
            for(UInt i = 0; i < deg; ++i)
                p.raw(i+1) = ptr[i] + 1;
            return p;
        }
        else
            throw GAPException("Invalid attempt to read perm");
    }
};

}

template<typename T>
T GAP_get(Obj rec)
{
    GAPdetail::GAP_getter<T> getter;
    return getter(rec);
}

template<typename T>
bool GAP_isa(Obj rec)
{
  GAPdetail::GAP_getter<T> getter;
  return getter.isa(rec);
}

class GAP_convertor
{
  Obj o;
public:
  GAP_convertor(Obj _o) : o(_o) { }
  
  template<typename T>
  operator T()
  { return GAP_get<T>(o); }
};

Obj GAP_get_rec(Obj rec, UInt n)
{
    if(!IS_REC(rec))
        throw GAPException("Invalid attempt to read record");
    if(!ISB_REC(rec, n))
        throw GAPException(std::string("Unable to read value from rec"));
    return ELM_REC(rec, n);
}

// This is a special method. It gets a boolean from a record, and assumes
// it is 'false' if not present
bool GAP_get_maybe_bool_rec(Obj rec, UInt n)
{
    if(!IS_REC(rec))
        throw GAPException("Invalid attempt to read record");
    if(!ISB_REC(rec, n))
        return false;
    Obj b = ELM_REC(rec, n);
    if(b == True)
        return true;
    if(b == False)
        return false;
    throw GAPException("Record element is not a boolean");
}

namespace GAPdetail
{
template<typename T>
struct GAP_maker
{ };

template<>
struct GAP_maker<int>
{
    Obj operator()(int i)
    { return INTOBJ_INT(i); }
};

template<>
struct GAP_maker<bool>
{
    Obj operator()(bool b) const
    {
        if(b)
            return True;
        else
            return False;
    }
};

template<typename T>
struct GAP_maker<vec1<T> >
{
    Obj operator()(const vec1<T>& v) const
    {
        size_t s = v.size();
        if(s == 0)
        {
          Obj l = NEW_PLIST(T_PLIST_EMPTY, 0);
          SET_LEN_PLIST(l, 0);
          CHANGED_BAG(l);
          return l;
        }
        Obj list = NEW_PLIST(T_PLIST_DENSE, s);
        SET_LEN_PLIST(list, s);
        CHANGED_BAG(list);
        GAP_maker<T> m;
        for(int i = 1; i <= v.size(); ++i)
        {
            SET_ELM_PLIST(list, i, m(v[i]));
            CHANGED_BAG(list);
        }

        return list;
    }
};

template<typename T, typename U>
struct GAP_maker<std::pair<T,U> >
{
    Obj operator()(const std::pair<T,U>& v) const
    {
        Obj list = NEW_PLIST(T_PLIST_DENSE, 2);
        SET_LEN_PLIST(list, 2);

        GAP_maker<T> m_t;
        SET_ELM_PLIST(list, 1, m_t(v.first));
        CHANGED_BAG(list);

        GAP_maker<U> m_u;
        SET_ELM_PLIST(list, 2, m_u(v.second));
        CHANGED_BAG(list);

        return list;
    }
};

template<>
struct GAP_maker<Permutation>
{
    Obj operator()(const Permutation& p) const
    {
        UInt4 deg = p.size();
        // ignore tperm2 for now.
        Obj prod = NEW_PERM4(deg);
        UInt4* pt = ADDR_PERM4(prod);
        for(UInt i = 0; i < deg; ++i)
            pt[i] = p[i+1] - 1;
        return prod;
    }
};

}

template<typename T>
Obj GAP_make(const T& t)
{
    GAPdetail::GAP_maker<T> m;
    return m(t);
}

Obj GAP_getGlobal(const char* name)
{
    UInt i = GVarName(name);
    Obj o =  VAL_GVAR(i);
    if(!o)
        throw GAPException("Missing global : " + std::string(name));
    return o;
}

// We would use CALL_0ARGS and friends here, but in C++
// we have to be more explicit with the types of our functions.
Obj GAP_callFunction(GAPFunction fun)
{
    timing_start_GAP_call(fun.name);
    typedef Obj(*F)(Obj);
    Obj funobj = fun.getObj();
    ObjFunc hdlrfunc = HDLR_FUNC(funobj,0);
    Obj ret = reinterpret_cast<F>(hdlrfunc)(funobj);
    timing_end_GAP_call();
    return ret;
}

Obj GAP_callFunction(GAPFunction fun, Obj arg1)
{
    timing_start_GAP_call(fun.name);
    typedef Obj(*F)(Obj,Obj);
    Obj funobj = fun.getObj();
    ObjFunc hdlrfunc = HDLR_FUNC(funobj,1);
    Obj ret = reinterpret_cast<F>(hdlrfunc)(funobj, arg1);
    timing_end_GAP_call();
    return ret;
}

Obj GAP_callFunction(GAPFunction fun, Obj arg1, Obj arg2)
{
    timing_start_GAP_call(fun.name);
    typedef Obj(*F)(Obj,Obj, Obj);
    Obj funobj = fun.getObj();
    ObjFunc hdlrfunc = HDLR_FUNC(funobj,2);
    Obj ret = reinterpret_cast<F>(hdlrfunc)(funobj, arg1, arg2);
    timing_end_GAP_call();
    return ret;
}

Obj GAP_callFunction(GAPFunction fun, Obj arg1, Obj arg2, Obj arg3)
{
    timing_start_GAP_call(fun.name);
    typedef Obj(*F)(Obj,Obj, Obj, Obj);
    Obj funobj = fun.getObj();
    ObjFunc hdlrfunc = HDLR_FUNC(funobj,3);
    Obj ret = reinterpret_cast<F>(hdlrfunc)(funobj, arg1, arg2, arg3);
    timing_end_GAP_call();
    return ret;
}



// Register and deregister objects so they do not get garbage collected

/*
void GAP_addRef(Obj o)
{
    GAP_callFunction(FunObj_addRef, o);
}

bool GAP_checkRef(Obj o)
{
    return GAP_get<bool>(GAP_callFunction(FunObj_checkRef, o));
}

void GAP_clearRefs()
{
    GAP_callFunction(FunObj_clearRefs);
}*/

void GAP_print(const std::string& s)
{ Pr(s.c_str(), 0, 0); }

#endif
