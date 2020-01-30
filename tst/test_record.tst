gap> LoadPackage("gapcpp", false);;
gap> x := CompileMethod("GAPRecord f(GAPRecord g) { return g; }", "f", 1);;
gap> x(rec());
rec(  )
gap> x(rec(y := 2));
rec( y := 2 )
gap> f := CompileMethod("""
> GAPRecord f(int i) { GAPRecord r; r.set("token", i); return r; }""", "f", 1);;
gap> f(-2);
rec( token := -2 )
gap> f := CompileMethod("""int f(GAPRecord r) { return GAP_get<int>(r.get("token")); }""", "f", 1);;
gap> f(rec(token := 7));
7
